pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

/// @title wallet
/// @author daniilamark
contract myWallet {
    /*
     Exception codes:
      100 - message sender is not a wallet owner.
      101 - invalid transfer value.
     */

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }

    modifier checkOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 100);
		tvm.accept();
		_;
	}

    /// @param dest Transfer target address.
    /// @param value Nanotons value to transfer.
    /// @param bounce Flag that enables bounce message in case of target contract error.
    function sendTransaction(address dest, uint128 value, bool bounce) public pure checkOwnerAndAccept {
         // Runtime function that allows to make a transfer with arbitrary settings.
        dest.transfer(value, bounce, 0);
    }

    function sendAllAndDestroy(address dest) public pure checkOwnerAndAccept {
        // Runtime function that allows to make a send all balance and destroy the contract.
        // bounce - defaults to true
        // value - 0 - 
        dest.transfer(0, true, 128 + 32);
    }

    function sendNoCommission(address dest, uint128 value) public pure checkOwnerAndAccept {
        // Send without paying commission at your own expense
        // bounce - defaults to true
        dest.transfer(value, true, 0);
    }

    function sendWithCommission(address dest, uint128 value) public pure checkOwnerAndAccept {
        // Send with commission paid at your own expense
        // bounce - defaults to true
        dest.transfer(value, true, 1);
    }

}