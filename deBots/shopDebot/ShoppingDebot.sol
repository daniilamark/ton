pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "ShopDebot.sol";
import "structs.sol";
import "interfaces.sol";

contract ShoppingDebot is ShopDebot{
    string private name_;

    function _menu() virtual internal override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have count purchases paid: {}, count no Paid: {}, total amount paid: {} purchases",
                    m_summaryPurchases.countPurchasesPaid,
                    m_summaryPurchases.countPurchasesNoPaid,
                    m_summaryPurchases.totalAmountPaid
                    
            ),
            sep,
            [
                MenuItem("Show Purchases list","", tvm.functionId(showPurchases)),
                MenuItem("Add Purchase","", tvm.functionId(createPurchases)),
                MenuItem("Delete purchases","", tvm.functionId(deletePurchase))
        
            ]
        );
    }


    function createPurchases(uint32 index) public {
        //index = index;
        Terminal.input(tvm.functionId(createPurchases_), "Enter name purchase:", false);
    }

    function createPurchases_(string value) public {
        name_ = value;
        Terminal.input(tvm.functionId(createPurchases__), "Enter count purchase:", false);
    }

    function createPurchases__(string value) public {
        (uint256 count, ) = stoi(value);
        optional(uint256) pubkey = 0;
        IShopList(m_address).p{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(name_, uint64(count));
    }
}
