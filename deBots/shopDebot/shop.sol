pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

contract shoppingList {

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
    
    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    uint32 m_countPurchases;
    uint256 m_ownerPubkey;
    mapping(uint32 => Purchase) m_purchase;

    constructor(uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function createPurchase(string purchaseName, uint64 purchasesCount, uint64 purchasesPrice) public onlyOwner {
        tvm.accept();
        m_countPurchases++;
        m_purchase[m_countPurchases] = Purchase(m_countPurchases, purchaseName, now, purchasesCount, purchasesPrice, false);
    }

    //  making a purchase
    function updatePurchase(uint32 id, bool purchaseMade) public onlyOwner {
        optional(Purchase) purchase = m_purchase.fetch(id);
        require(purchase.hasValue(), 102);
        tvm.accept();
        Purchase thisPurchase = purchase.get();
        thisPurchase.isPurchaseMade = true;
        m_purchase[id] = thisPurchase;
    }

    function deletePurchase(uint32 id) public onlyOwner {
        require(m_purchase.exists(id), 102);
        tvm.accept();
        delete m_purchase[id];
    }
    // ------------------------

    function getPurchase() public view returns (Purchase[] purchases) {
        string purchaseName;
        uint64 createdAt;
        uint64 purchasesCount;  
        uint64 purchasesMadePrice; 
        bool isPurchaseMade;

        for((uint32 id, Purchase purchase) : m_purchase) {
            purchaseName = purchase.purchaseName;
            createdAt = purchase.createdAt;
            purchasesCount = purchase.purchasesCount;
            purchasesMadePrice = purchase.purchasesMadePrice;
            isPurchaseMade = purchase.isPurchaseMade;
            purchases.push(Purchase(id, purchaseName, createdAt, purchasesCount, purchasesMadePrice, isPurchaseMade));
       }
    }

    function getSummaryPurchases() public view returns (SummaryPurchases summaryPurchases) {
        uint32 countPurchasesPaid;
        uint32 countPurchasesNoPaid;
        uint32 totalAmountPaid;

        for((, Purchase purchase) : m_purchase) {
            if  (purchase.isPurchaseMade) {
                countPurchasesPaid ++;
                totalAmountPaid += uint32(purchase.purchasesMadePrice);
            } else {
                countPurchasesNoPaid ++;
            }
        }
        summaryPurchases = SummaryPurchases(countPurchasesPaid, countPurchasesNoPaid, totalAmountPaid);
    }
}
