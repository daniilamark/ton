pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

import "IGameObject.sol";

contract GameObjectContract is IGameObject{
    uint public health = 20;
    uint public protectionPower  = 5;
    uint public attackPower = 10;
    address public ownerAddress;
    address public attackerAddress;

    event killed(bool isAlive);

    constructor() public{   
        ownerAddress = msg.sender;
    }

    modifier onlyOwner {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
    }

    function getTakePowerProtection(uint valueProtection) external {
        require(valueProtection < 30);
        protectionPower += valueProtection;
    }

    function takeAttack(uint _attackPower, uint _protectionPower) public override onlyOwner {
        attackerAddress = msg.sender;
        health -= (_attackPower - _protectionPower);
        isKilled();
    }

    function isKilled() private {
        if(health <= 0){
            emit killed(true);
        }else{
            emit killed(false);
        }
    }

    function selfDestruction() private onlyOwner{
        ownerAddress.transfer(0, true, 128 + 32);
    }
    
    function getOwner() public view returns (address) {    
        return ownerAddress;
    }
    
}
