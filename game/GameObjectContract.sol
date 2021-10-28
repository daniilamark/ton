pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "IGameObject.sol";

contract GameObjectContract is IGameObject{
    /** Контракт "Игровой объект" (Реализует "Интерфейс Игровой объект")
    👉 получить силу защиты
    👉 принять атаку [адрес того, кто атаковал можно получить из msg] external
    👉 проверить, убит ли объект (private)
    👉 обработка гибели [вызов метода самоуничтожения (сл в списке)]
    👉 отправка всех денег по адресу и уничтожение
    👉 свойство с начальным количеством жизней (например, 5)
    */

    uint public health = 10;

    event killed(bool isAlive);

    function takeTheAttack(address addressAttacked) virtual public override{
        health -= 1;
    }

    function getProtection() virtual public {
        require(health < 10);
        health += 1;
    }

    function isKilled() private{
        if(health == 0){
            emit killed(true);
        }else{
            emit killed(false);
        }
    }

    function selfDestruction(address dest) private {
        dest.transfer(0, true, 128 + 32);
    }
}
