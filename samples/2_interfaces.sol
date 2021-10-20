// Remote contract interface.
interface Storage {
	function storeValue(uint value) external;
}

// Remote contract interface.
interface Storage2 {
	function callback(uint8 status) external;
}