pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

struct Purchase{
    uint32 id;
    string name;
    uint64 count;
    uint64 createdAt;
    uint64 price;
    bool isPurchaseMade;
}

struct SummaryPurchases{ 
    uint64 countPurchasesPaid;
    uint64 countPurchasesNoPaid;
    uint64 totalAmountPaid;
}