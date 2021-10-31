pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "GameObjectContract.sol";
import "BaseStationContract.sol";

contract MilitaryUnitContract is GameObjectContract {
    address addressBaseStation;
    
    constructor(BaseStationContract baseStation) public {
        addressBaseStation = msg.sender;
        baseStation.addMilitaryUnit(addressBaseStation);
        this.attackerAddress = attackerAddress;
        this.health = health;
        this.protectionPower = protectionPower;
        this.ownerAddress = ownerAddress;
    }
    
    function getTakePowerProtection(uint valueProtection) public override{
        require(valueProtection < 30);
        protectionPower += valueProtection;
    }

    function getTakePowerAttack(uint valueAttack) public override{
        require(valueAttack < 20);
        attackPower += valueAttack;
    }
    function selfDestruction() private onlyOwner{
        ownerAddress.transfer(0, true, 128 + 32);
    }
}