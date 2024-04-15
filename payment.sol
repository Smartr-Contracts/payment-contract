//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

// Useful for debugging. Remove when deploying to a live network.
import "hardhat/console.sol";

// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
// import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * A smart contract that allows changing a state variable of the contract and tracking the changes
 * It also allows the owner to withdraw the Ether in the contract
 * @author BuidlGuidl
 */
contract YourContract {
	// State Variables
	address public immutable owner; //corp wallet address
	mapping(address => uint) public payementMap;


	// Constructor: Called once on contract deployment
	// Check packages/hardhat/deploy/00_deploy_your_contract.ts
	constructor(address _owner) {
		owner = _owner;
	}

	// Modifier: used to define a set of rules that must be met before or after a function is executed
	// Check the withdraw() function
	modifier isOwner() {
		// msg.sender: predefined variable that represents address of the account that called the current function
		require(msg.sender == owner, "Not the Owner");
		_;
	}

    function get(address _addr) public view returns (uint) {
        // Mapping always returns a value.
        // If the value was never set, it will return the default value.
        return payementMap[_addr];
    }


	function updatePayementMap() public payable {
		// Print data to the hardhat chain console. Remove when deploying to a live network.
        if (msg.value == 0.00032 ether) {
            payementMap[msg.sender] = block.timestamp;
        }
        else if (msg.value > 0.00032 ether){
            //refund for overpayement
            (bool success, ) = payable(msg.sender).call{value: (msg.value - 0.00032 ether)}("");
            require(success, "Failed to send Ether");
        }
        else {
            //refund for underpayment
            (bool success, ) = payable(msg.sender).call{value: msg.value}("");
            require(success, "Failed to send Ether");
        }
	}

	/**
	 * Function that allows the owner to withdraw all the Ether in the contract
	 * The function can only be called by the owner of the contract as defined by the isOwner modifier
	 */
	function withdraw() public isOwner {
		(bool success, ) = owner.call{ value: address(this).balance }("");
		require(success, "Failed to send Ether");
	}

	/**
	 * Function that allows the contract to receive ETH
	 */
	receive() external payable {}
}
