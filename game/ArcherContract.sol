pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "MilitaryUnitContract.sol";

contract ArcherContract is MilitaryUnitContract {

    constructor(BaseStationContract baseStation) public {
        addressBaseStation = msg.sender;
        baseStation.addMilitaryUnit(addressBaseStation);
    }
    
    function getTakePowerProtection(uint valueProtection) external override{
        require(valueProtection < 30);
        protectionPower += valueProtection;
    }

    function getTakePowerAttack(uint valueAttack) external override{
        require(valueAttack < 20);
        protectionPower += valueAttack;
    }
}