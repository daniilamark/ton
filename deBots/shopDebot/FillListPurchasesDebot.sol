pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "ShopDebot.sol";
import "structs.sol";
import "interfaces.sol";

contract FillListPurchasesDebot is ShopDebot{
    uint private id_;

    function _menu() virtual internal override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have count purchases paid: {}, count no Paid:{}, total amount paid: {} purchases",
                    m_summaryPurchases.countPurchasesPaid,
                    m_summaryPurchases.countPurchasesNoPaid,
                    m_summaryPurchases.totalAmountPaid
                    
            ),
            sep,
            [
                MenuItem("Show Purchases list","", tvm.functionId(showPurchases)),
                MenuItem("Buy Purchase","", tvm.functionId(paymentPurchase)),
                MenuItem("Delete purchases","", tvm.functionId(deletePurchase))
        
            ]
        );
    }


    function paymentPurchase(uint32 index) public {
        //index = index;
        Terminal.input(tvm.functionId(paymentPurchase_), "Enter number purchase:", false);
    }

    function paymentPurchase_(string value) public {
        (uint256 id, ) = stoi(value);
        id_ = id;
        Terminal.input(tvm.functionId(paymentPurchase__), "Enter price purchase:", false);
    }

    function paymentPurchase__(string value) public {
        (uint256 price, ) = stoi(value);
        optional(uint256) pubkey = 0;
        IShopList(m_address).paymentPurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(id_), uint64(price));
    }
}
