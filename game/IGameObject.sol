pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

interface IGameObject {
    /** Интерфейс "Интерфейс Игровой объект" (ИИО).
    👉 принять атаку
    */
    function takeAttack(uint _attackPower, uint _protectionPower) external;
}
