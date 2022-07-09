pragma solidity ^0.8.7;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract membership is ERC1155, Ownable {
    using SafeMath for uint256;

    uint256 public totalPlans;

    constructor(string memory name, string memory symbol, string memory uri) ERC1155(uri) {}

    struct plan {
        string name;
        string uri;
        uint256 subscribers;
        uint256 price;
        uint time;
    }

    struct subscriber {
        uint256 plan;
        uint256 date;
    }

    mapping(uint256 => plan) internal plans;

    mapping(address => subscriber) internal subscribers;

    modifier correctId(uint id) {
        require(id <= totalPlans && id>0, "provide a correct planID");
        _;
    }

    function ifExpired(uint id) internal view returns(bool) {
        if(subscribers[msg.sender].plan == id) {
            if((block.timestamp).sub(subscribers[msg.sender].date < plans[id].time)) {
                return false;
            } else {
                return true;
            }
        } else {
            return true;
            }
        }

    function setURI(string memory uri) external OnlyOwner {
        _setURI(uri);
    }

    function addPlan(string memory _name, string memory uri, uint256 price, uint time) external OnlyOwner {
        totalPlans = totalPlans.add(1);
        uint256 id = totalPlans.add(1);
        plans[_id] = plan(_name, uri, 0, price, time);
    }

    function updatePlan(uint id, string memory _name, string memory uri, uint256 price, uint time) external OnlyOwner {
        plans[id] = plan(_name, uri, plans[id].subscribers, price, time);
    }

    function subscribe(uint256 planId) external correctId(planID) payable {
        require(ifExpired(planId) == true, "your currect plan hasn't expired yet");
        require(msg.value == plans[planId].price, "please send correct amount of ether");
        plans[planId].subscribers = (plans[planId].subscribers.add(1));
        
    }
}