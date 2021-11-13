pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "structs.sol";

interface IMsig {
   function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}

interface IShopList {
   function createPurchase(string name, uint64 count) external;
   function deletePurchase(uint32 id) external;
   function paymentPurchase(uint32 id, uint64 price) external;
   
   function getPurchases() external returns (Purchase[] purchases);
   function getSummaryPurchases() external returns (SummaryPurchases);
}

abstract contract HasConstructorWithPubKey {
   constructor(uint256 pubkey) public {}
}