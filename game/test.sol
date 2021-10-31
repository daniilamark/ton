pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "ArrayHelper.sol";
import "GameObjectContract.sol";

contract BaseStationContract is GameObjectContract{
    uint healthBaseStation = health;
    using ArrayHelper for address[];
    address[] militaryUnits;

    function getProtection(uint valueProtection) virtual external override {
        // require(healthBaseStation < 10);
        healthBaseStation += 1;
    }

    function addMilitaryUnit(address addr) private {
        militaryUnits.push(addr);
    }
    
    function deleteMilitaryUnit(address addre) private {
        militaryUnits.deleteFromArray(addre);
    }
}