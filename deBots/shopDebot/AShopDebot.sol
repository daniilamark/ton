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

import "structs.sol";
import "interfaces.sol";

abstract contract AShopDebot is Debot, Upgradable {
    bytes m_icon;

    TvmCell m_shopStateInit;
    address m_address;  // contract address

    SummaryPurchases m_summaryPurchases; // Statistics
    //uint32 m_purchaseId;    
    uint256 m_masterPubKey; // User pubkey
    address m_msigAddress;  // User wallet address

    uint32 INITIAL_BALANCE =  200000000;  // Initial contract balance

    //constructor(uint256 pubkey) public {}

    function start() public override {
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key", false);
    }


    function setShopCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_shopStateInit = tvm.buildStateInit(code, data);
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
            onErrorId: tvm.functionId(onErrorRepeatCredit)
        }(m_address, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        sdkError;
        exitCode;
        creditAccount(m_msigAddress);
    }

    function setSummaryPurchases(SummaryPurchases summaryPurchase) public {
        m_summaryPurchases = summaryPurchase;
        _menu();
    }

    function onSuccess() public view {
        _getSummaryPurchases(tvm.functionId(setSummaryPurchases));
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
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {HasConstructorWithPubKey, m_masterPubKey}
            });
            tvm.sendrawmsg(deployMsg, 1);
    }

    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        sdkError;
        exitCode;
        deploy();
    }


    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }

    function _getSummaryPurchases(uint32 answerId) private view {
        optional(uint256) none;
        IShopList(m_address).getSummaryPurchases{
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

    function _menu() virtual internal;


     /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Shop DeBot v.2";
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

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }    

}