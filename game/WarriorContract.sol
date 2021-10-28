pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "MilitaryUnitContract.sol";

abstract contract WarriorContract is MilitaryUnitContract{
    /**
    Контракт "Воин" (родитель "Военный юнит")
    👉 получить силу атаки
    👉 получить силу защиты
    */
    uint healthWarrior = GameObjectContract.health;

    function takeTheAttack(address ad) public override{
        healthWarrior -= 1;
    }

    function getProtection() public override {
        healthWarrior += 1;
    }
}