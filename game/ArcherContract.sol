pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "MilitaryUnitContract.sol";

abstract contract ArcherContract is MilitaryUnitContract {
    /**
    Контракт "Воин" (родитель "Военный юнит")
    👉 получить силу атаки
    👉 получить силу защиты
    */    
    uint healthArcher = GameObjectContract.health;

    function takeTheAttack(address ad) public override{
        healthArcher -= 1;
    }

    function getProtection() public override {
        healthArcher += 1;
    }
}