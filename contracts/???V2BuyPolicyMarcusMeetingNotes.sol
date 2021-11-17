// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract disruptiveInsurance {
    address public immutable owner;
    uint public ownerAmount;
    address public policySigner;
    
    constructor() payable {
        require(msg.value >= (10 ** 18), "Error: Must have at least 1 ETH for Contract Creation.");
        owner = payable (msg.sender);
        ownerAmount = msg.value;
    }
    
        struct policy {
        int Latitude;
        int Longitude;
        int Year;
        int Month;
        int Day;
        bool bought;
        uint awardAmount;
    }
    
    mapping(address => policy) public policies;
        
    function buyPolicy(int Latitude, int Longitude) public payable {
        require(owner != msg.sender, "Error: Owner cannot self-insure"); // Policy purchaser must not be owner. 
        require(address(this).balance > 0, 'Error: Owner insufficient funds'); // Owner must have funds to cover policy purchase. Made >0 in case multiple policy purchases are made in the same contract for a given address (i.e owner will agree > 1 ETH).
        require(msg.value == (10 ** 18), 'Error: Please submit your request with insurance contribution of 0.001 Ether'); // Policy purchaser must be sending their share of insurance contract amount.
        require(!policies[msg.sender].bought,"Error: You've already purchased insurance"); // Checks if requester has already bought insurance. 
        
        policySigner = msg.sender;
        policies[policySigner] = policy(Latitude, Longitude,1,1,1, true, ownerAmount);
        
//        return address(msg.sender).balance;
        
        }
        
    function getRewardAsPolicyBuyer() public {
        require(policies[msg.sender].bought == true,"Error: You don't have a policy"); // Checks if this address has a policy or not.
        // require coordinates == eruptionLocation [oracle] [min_max]
        // require datePolicySigned < present
        // might be unneeded: policySigner = msg.sender;
        
        payable(msg.sender).transfer(policies[msg.sender].awardAmount);
        // PolicySigner + Year + Month + Day = 0?
        
        }
        
}
