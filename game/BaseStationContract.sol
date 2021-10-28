pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "ArrayHelper.sol";
import "GameObjectContract.sol";

contract BaseStationContract is GameObjectContract{
    /** Контракт "Базовая станция" (Родитель "Игровой объект")
    👉 получить силу защиты
    👉 добавить военный юнит (добавляет адрес военного юнита в массив или другую структуру данных)
    👉 убрать военный юнит
    👉 обработка гибели [вызов метода самоуничтожения + вызов метода смерти для каждого из военных юнитов базы]
    */

    uint healthBaseStation = health;
    using ArrayHelper for address[];
    address[] public militaryUnits;

    function getProtection() public virtual override{
        require(healthBaseStation < 10);
        healthBaseStation += 1;
    }

    function addMilitaryUnit(address addr) public {
        militaryUnits.push(addr);
    }
    
    function deleteMilitaryUnit(address _addr) public {
        militaryUnits.deleteFromArray(_addr);
    }
    
    function destructionBase() private {
        address addressBase = msg.sender;
        addressBase.transfer(0, true, 128 + 32);
        militaryUnits.deleteAllFromArray();
    }
}