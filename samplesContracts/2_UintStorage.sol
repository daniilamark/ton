pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "2_interfaces.sol";

// This contract implements 'Storage' interface.
contract UintStorage is Storage {

	// State variables:
	uint public value;                // storage for a uint value;
	address public clientAddress;    // last caller address.

	// This function can be called only by another contract. There is no 'tvm.accept()'
	function storeValue(uint v) public override {
		// save parameter v to contract's state variable
		value = v;
		// save address of call
		clientAddress = msg.sender;
        Storage2(clientAddress).callback(1);
        tvm.accept();
	}
}