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
        string Latitude;
        string Longitude;
//        int Year;
//        int Month;
//        int Day;
        bool bought;
        uint AwardAmount;
    }
    
    mapping(address => policy) public policies;
        
    function buyPolicy(string calldata Latitude, string calldata Longitude) public payable returns(uint contractBalance) {
        require(msg.sender == tx.origin, 'Error: Contract cannot insure itself - independent address required'); // Policy purchaser must be EOA and not a contract.
        require(owner != msg.sender, "Error: Owner cannot self-insure"); // Policy purchaser must not be owner. 
        require(address(this).balance > 0, 'Error: Owner insufficient funds'); // Owner must have funds to cover policy purchase. Made >0 in case multiple policy purchases are made in the same contract for a given address (i.e owner will agree > 1 ETH).
        require(msg.value == (10 ** 18), 'Error: Please submit your request with insurance contribution of 0.001 Ether'); // Policy purchaser must be sending their share of insurance contract amount.
        require(!policies[msg.sender].bought,"Error: You've already purchased insurance"); // Checks if requester has already bought insurance.  
        
        policySigner = msg.sender;
        policies[policySigner] = policy(Latitude, Longitude, true, ownerAmount);
        
        return address(this).balance; // retuns total amount in the contract - from owner + policy Signer 
//        return address(msg.sender).balance;
        
        }
        
        function getRewardAsPolicyBuyer() public payable {
        policySigner = msg.sender;
        
        
        }
        
}
