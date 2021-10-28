pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "GameObjectContract.sol";
import "BaseStationContract.sol";

contract MilitaryUnitContract is GameObjectContract {
    /** 
    👉 конструктор принимает "Базовая станция" и вызывает метод "Базовой Станции" "Добавить военный юнит" 
    а у себя сохраняет адрес "Базовой станции"
    👉 атаковать (принимает ИИО [его адрес])
    👉 получить силу атаки
    👉 получить силу защиты
    👉 обработка гибели [вызов метода самоуничтожения + убрать военный юнит из базовой станции]
    👉 смерть из-за базы (проверяет, что вызов от родной базовой станции только будет работать)
     [вызов метода самоуничтожения]
    */
    address addressBaseStation;
    uint healtMilitaryUnit = health;

    constructor(BaseStationContract baseStation) public {
        baseStation.addMilitaryUnit(msg.sender);
        addressBaseStation = msg.sender;
    }

    function takeTheAttack(address addres) virtual public override{
        healtMilitaryUnit -= 1;
    }

    function getProtection() virtual public override {
        require(healtMilitaryUnit < 10);
        healtMilitaryUnit += 1;
    }

    function Attack(address ad) public {
        // атаковать по адрессу
        healtMilitaryUnit -= 1;
    }
}
