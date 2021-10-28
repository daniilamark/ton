pragma ton-solidity >= 0.35.0;

library ArrayHelper {
    // Delete the value from `array` at position `index`
    function deleteFromArray(address[] array, address a) internal pure {
        uint help;
        for (uint i = 0; i + 1 < array.length; ++i){
            if (array[i] == a){
                help = i;
            }
        }
        for (uint j = help; j + 1 < array.length; ++j){
            array[j] = array[j + 1];
        }
        array.pop();
    }

    function deleteAllFromArray(address[] array) internal pure {
    for (uint j = 0; j + 1 < array.length; ++j){
            array.pop();
        }
    }
}