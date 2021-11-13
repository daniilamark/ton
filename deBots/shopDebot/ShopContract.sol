pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "structs.sol";
import "interfaces.sol";

contract shoppingList is HasConstructorWithPubKey, IShopList{
    
    uint32 m_countPurchases;
    uint256 m_ownerPubkey;

    mapping(uint32 => Purchase) m_purchase;

    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    constructor(uint256 pubkey) HasConstructorWithPubKey(pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }



    function createPurchase(string name, uint64 _count) external override onlyOwner {
        tvm.accept();
        m_countPurchases++;
        m_purchase[m_countPurchases] = Purchase(m_countPurchases, name, _count, now, 0, false);
    }


    function deletePurchase(uint32 id) external override onlyOwner  {
        require(m_purchase.exists(id), 102);
        tvm.accept();
        delete m_purchase[id];
    }


    function paymentPurchase(uint32 id, uint64 price) external override onlyOwner {
        require(m_purchase.exists(id), 102);
        tvm.accept();
        m_purchase[m_countPurchases].isPurchaseMade = true;
        m_purchase[m_countPurchases].price = price;
    }
    // ------------------------

    function getPurchases() external override returns (Purchase[] purchases) {
    
        for((uint32 id, Purchase purchase) : m_purchase) {
            purchases.push(purchase);
       }
    }

    function getSummaryPurchases() external override returns (SummaryPurchases _summaryPurchases) {
        //_summaryPurchases = SummaryPurchases(0,0,0);
        for((uint id, Purchase purchase) : m_purchase) {
            if  (purchase.isPurchaseMade) {
                _summaryPurchases.countPurchasesPaid += purchase.count;
                _summaryPurchases.totalAmountPaid += purchase.price;
            } else {
                _summaryPurchases.countPurchasesNoPaid += purchase.count;
            }
        }
        _summaryPurchases = SummaryPurchases(_summaryPurchases.countPurchasesPaid, _summaryPurchases.countPurchasesNoPaid, _summaryPurchases.totalAmountPaid);
    }


}
