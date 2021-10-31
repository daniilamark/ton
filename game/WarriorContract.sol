pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "MilitaryUnitContract.sol";

contract WarriorContract is MilitaryUnitContract{

    function getTakePowerProtection(uint valueProtection) virtual external override{
        require(valueProtection < 30);
        protectionPower += valueProtection;
    }

    function getTakePowerAttack(uint valueAttack) virtual external override{
        require(valueAttack < 20);
        protectionPower += valueAttack;
    }
}