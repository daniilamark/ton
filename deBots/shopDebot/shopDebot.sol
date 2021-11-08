pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
 
import "../base/Debot.sol";
import "../base/Terminal.sol";
import "../base/Menu.sol";
import "../base/AddressInput.sol";
import "../base/ConfirmInput.sol";
import "../base/Upgradable.sol";
import "../base/Sdk.sol";

struct Purchase{
    uint32 id;
    string purchaseName;
    uint64 createdAt;
    uint64 purchasesCount;
    uint64 purchasesMadePrice;
    bool isPurchaseMade;
}

struct SummaryPurchases{ 
    uint32 countPurchasesPaid;
    uint32 countPurchasesNoPaid;
    uint32 totalAmountPaid;
}

interface IMsig {
   function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}

interface IShopDebot {
   function createPurchase(string purchaseName, uint64 purchasesCount, uint64 purchasesPrice) external;
   function updatePurchase(uint32 id, bool purchaseMade) external;
   function deletePurchase(uint32 id) external;
   function getPurchase() external returns (Purchase[] purchases);
   function getSummaryPurchases() external returns (SummaryPurchases);
}

abstract contract AShop {
   constructor(uint256 pubkey) public {}
}

contract shopDebot is Debot, Upgradable {
    bytes m_icon;

    TvmCell m_shopCode; // contract code
    TvmCell m_shopData; // contract data
    TvmCell m_shopStateInit; // contract stateInit
    address m_address;  // contract address

    SummaryPurchases m_summaryPurchases; // Statistics
    uint32 m_purchasesId;    
    uint256 m_masterPubKey; // User pubkey
    address m_msigAddress;  // User wallet address

    uint32 INITIAL_BALANCE =  200000000;  // Initial contract balance


    function setShopCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_shopCode = code;
        m_shopData = data;
        m_shopStateInit = tvm.buildStateInit(m_shopCode, m_shopData);
    }


    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }

    //

    function onSuccess() public view {
        _getSummaryPurchases(tvm.functionId(setSummaryPurchases));
    }

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key", false);
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Shop DeBot";
        version = "0.2.0";
        publisher = "daniilamark";
        key = "Shop list manager";
        author = "daniilamark";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a SHOP DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x"+value);
        if (status) {
            m_masterPubKey = res;
            Terminal.print(0, "Checking if you already have a Purchase list ...");
            TvmCell deployState = tvm.insertPubkey(m_shopStateInit, m_masterPubKey);
            m_address = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format( "Info: your SHOP contract address is {}", m_address));
            Sdk.getAccountType(tvm.functionId(checkStatus), m_address);
        } else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }


    function checkStatus(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and  contract is already deployed
            _getSummaryPurchases(tvm.functionId(setSummaryPurchases));
        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "You don't have a SHOP list yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your SHOP list contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", m_address));
        }
    }


    function creditAccount(address value) public {
        m_msigAddress = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        IMsig(m_msigAddress).sendTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)  // Just repeat if something went wrong
        }(m_address, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        // TODO: check errors if needed.
        sdkError;
        exitCode;
        creditAccount(m_msigAddress);
    }


    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkIfStatusIs0), m_address);
    }

    function checkIfStatusIs0(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }


    function deploy() private view {
            TvmCell image = tvm.insertPubkey(m_shopStateInit, m_masterPubKey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: m_address,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {AShop, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }


    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        // TODO: check errors if needed.
        sdkError;
        exitCode;
        deploy();
    }

    function setSummaryPurchases(SummaryPurchases summaryPurchase) public {
        m_summaryPurchases = summaryPurchase;
        _menu();
    }

    function _menu() private {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (countPurchasesPaid/countPurchasesNoPaid/totalAmountPaid) Purchases",
                    m_summaryPurchases.countPurchasesPaid,
                    m_summaryPurchases.countPurchasesNoPaid,
                    m_summaryPurchases.totalAmountPaid
                    
            ),
            sep,
            [
                MenuItem("Create new Purchases","",tvm.functionId(createPurchases)),
                MenuItem("Show Purchases list","",tvm.functionId(showPurchases))
                
            ]
        );
    }
    // MenuItem("Update Purchases status","",tvm.functionId(updatePurchases)),
    // MenuItem("Delete Purchases","",tvm.functionId(deletePurchases))

    function createPurchases(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(createPurchases_), "One line please:", false);
    }

    // createPurchase(string purchaseName, uint64 purchasesCount, uint64 purchasesPrice)

    // or only VALUE
    function createPurchases_(string purchaseName, uint64 purchasesCount, uint64 purchasesPrice) public view {
        optional(uint256) pubkey = 0;
        IShopDebot(m_address).createPurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(purchaseName, purchasesCount, purchasesPrice);
    }

    // 
    function showPurchases(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IShopDebot(m_address).getPurchase{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showPurchases_),
            onErrorId: 0
        }();
    }

    //
    function showPurchases_(Purchase[] purchases) public {
        uint32 i;
        if (purchases.length > 0 ) {
            Terminal.print(0, "Your Purchases list:");
            for (i = 0; i < purchases.length; i++) {
                Purchase purchase = purchases[i];
                string completed;
                if (purchase.isPurchaseMade) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {} {} {}  \"{}\"  at {}", purchase.id, completed, purchase.purchaseName, 
                purchase.createdAt, purchase.purchasesCount,  purchase.purchasesMadePrice));
            }
        } else {
            Terminal.print(0, "Your purchases list is empty");
        }
        _menu();
    }
    /* 
    function updatePurchases(uint32 index) public {
        index = index;
        if (m_stat.completeCount + m_stat.incompleteCount > 0) {
            Terminal.input(tvm.functionId(updateTask_), "Enter task number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no tasks to update");
            _menu();
        }
    }

    function updateTask_(string value) public {
        (uint256 num,) = stoi(value);
        m_taskId = uint32(num);
        ConfirmInput.get(tvm.functionId(updateTask__),"Is this task completed?");
    }

    function updateTask__(bool value) public view {
        optional(uint256) pubkey = 0;
        ITodo(m_address).updateTask{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_taskId, value);
    }


    function deleteTask(uint32 index) public {
        index = index;
        if (m_stat.completeCount + m_stat.incompleteCount > 0) {
            Terminal.input(tvm.functionId(deleteTask_), "Enter task number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no tasks to delete");
            _menu();
        }
    }

    function deleteTask_(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        ITodo(m_address).deleteTask{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }
 */
    function _getSummaryPurchases(uint32 answerId) private view {
        optional(uint256) none;
        IShopDebot(m_address).getSummaryPurchases{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }
}