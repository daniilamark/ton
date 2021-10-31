pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "ArrayHelper.sol";
import "GameObjectContract.sol";

contract BaseStationContract is GameObjectContract{
    uint healthBaseStation = health;
    using ArrayHelper for address[];
    address[] militaryUnits;
    address baseAddress;

    event baseDestroyed(bool isAlive);

    constructor(address _baseAddress) public{   
        baseAddress = msg.sender;
        this.attackerAddress = attackerAddress;
        this.health = health;
        this.protectionPower = protectionPower;
        BaseStationContract(_baseAddress).addMilitaryUnit(this);
    }

    function getTakePowerProtection(uint valueProtection) public override{
        require(valueProtection < 30);
        protectionPower += valueProtection;
    }

    function takeAttack(uint _attackPower, uint _protectionPower) public override onlyOwner {
        attackerAddress = msg.sender;
        health -= (_attackPower - _protectionPower);
        isBaseDestroyed();
    }

    function addMilitaryUnit(address addr) virtual private {
        militaryUnits.push(addr);
    }
    
    function deleteMilitaryUnit(address addre) private {
        militaryUnits.deleteFromArray(addre);
    }
    
    function destructionBase() private onlyOwner{
        baseAddress.transfer(0, true, 128 + 32);
        militaryUnits.deleteAllFromArray();
    }

    function getCountUnits() public view returns (uint) {
        return militaryUnits.length;
    }

    function isBaseDestroyed() public {
        if(getCountUnits() == 0){
            emit baseDestroyed(true);
        }else{
            emit baseDestroyed(false);
        }
    }

    function getMilitaryUnits() public returns (address[] _militaryUnits) {
      return _militaryUnits;
    }

}