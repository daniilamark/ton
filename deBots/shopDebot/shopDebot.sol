pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "AShopDebot.sol";
import "structs.sol";
import "interfaces.sol";

contract ShopDebot is AShopDebot{
    
    function _menu() virtual internal override {
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
                MenuItem("Show Purchases list","", tvm.functionId(showPurchases)),
                MenuItem("Delete purchases","", tvm.functionId(deletePurchase))
                
            ]
        );
    }
    
    function showPurchases(uint32 index) public view {
            index = index;
            optional(uint256) none;
            IShopList(m_address).getPurchases{
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

        // подумать
        function showPurchases_(Purchase[] purchases) public{
            uint32 i;
            if (purchases.length > 0 ) {
                Terminal.print(0, "Your Purchases list:");
                for (i = 0; i < purchases.length; i++) {
                    Purchase purchase = purchases[i];
                    Terminal.print(0, format("{} {} {} at {} price:{}  ", purchase.id, purchase.name, 
                    purchase.count, purchase.createdAt, purchase.price));
                }
            } else {
                Terminal.print(0, "Your purchases list is empty");
            }
            _menu();
        }
        

        function deletePurchase(uint32 index) public {
            index = index;
            if ( m_summaryPurchases.countPurchasesPaid + m_summaryPurchases.countPurchasesNoPaid > 0) {
                Terminal.input(tvm.functionId(_deletePurchase), "Enter Purchase number:", false);
            } else {
                Terminal.print(0, "Sorry, you have no Purchase to delete");
                _menu();
            }
        }

        function _deletePurchase(string value) public view {
            (uint256 id, ) = stoi(value);
            optional(uint256) pubkey = 0;
            IShopList(m_address).deletePurchase{
                    abiVer: 2,
                    extMsg: true,
                    sign: true,
                    pubkey: pubkey,
                    time: uint64(now),
                    expire: 0,
                    callbackId: tvm.functionId(onSuccess),
                    onErrorId: tvm.functionId(onError)
                }(uint32(id));
        }
}