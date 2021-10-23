pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

// import interface
import "2_interfaces.sol";

// This contract calls the remote contract function with parameter to store a uint value in the remote contract's
// persistent memory.
contract StorageClient {
    uint8 public m_status = 0;

	constructor() public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0, 101);
		// Check that message has signature (msg.pubkey() is not zero) and message is signed with the owner's private key
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
	}

	modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	function store(Storage storageAddress, uint value) public pure checkOwnerAndAccept {
		// Call the remote contract function with parameter.
		storageAddress.storeValue(value);
	}

    function callback(uint8 status) public{
        m_status = status;
        tvm.accept();
    }
}