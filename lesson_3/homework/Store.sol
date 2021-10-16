/**
 * This file was generated by TONDev.
 * TONDev is a part of TON OS (see http://ton.dev).
 */
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "ArrayHelper.sol";

contract Store {
    using ArrayHelper for string[];
    string[] namesOfPeople;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
    
        addLine("Nikola");
        addLine("Dima");
        addLine("Artem");
        addLine("Daniil");

        namesOfPeople.del(0);

        tvm.accept();
    }

    // add name to queue
    function addLine(string name) public returns (string[]){
        namesOfPeople.push("" + name);
        tvm.accept();
        return namesOfPeople;
    }

    // display the list of people in the queue
    function getUsers() public view returns (string) {
        string stringPeopleInLine;
        
        for (uint256 index = 0; index < namesOfPeople.length; index++) {
            if(index == namesOfPeople.length - 1){
                stringPeopleInLine +=  namesOfPeople[index];
            }else{
                stringPeopleInLine +=  namesOfPeople[index] + ", " ;
            }
        }
        tvm.accept();
        return stringPeopleInLine;
   }

    // get the number of people in line
    function getLinesCount() public view returns (uint) {
        tvm.accept();
        return namesOfPeople.length;
    }

    // get the name of the last one in the queue
    function getLastLine() public view returns (string) {
        tvm.accept();
        return namesOfPeople[namesOfPeople.length-1];
    }

    // we call the next one, the zero element of the array disappears
    function callNext() public  {
        tvm.accept();
        namesOfPeople.del(0);
    }
}
