// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract disruptiveInsurance {
    address payable public owner;
    uint public ownerAmount;
    
    constructor() payable {
        require(msg.value >= (10 ** 18), "Error: Must have at least 1 ETH for Contract Creation.");
        owner = payable (msg.sender);
        ownerAmount = msg.value;
    }
    
    struct policySignerStruct {
        address policySigner;
        int psLatitude;
        int psLongitude;
        int psYear;
        int psMonth;
        int psDay;
        bool psBoughtAlready;
        uint psAwardAmount;
    }
    
    policySignerStruct[] policies; // array of policies
        
    function buyPolicy(int Latitude, int Longitude, int Year, int Month, int Day) public payable returns(uint contractBalance) {
        require(msg.sender == tx.origin, 'Error: Contract cannot insure itself - independent address required'); // Policy purchaser must be EOA and not a contract.
        require(owner != msg.sender, "Error: Owner cannot self-insure"); // Policy purchaser must not be owner. 
        require(address(this).balance > 0, 'Error: Owner insufficient funds'); // Owner must have funds to cover policy purchase. Made >0 in case multiple policy purchases are made in the same contract for a given address (i.e owner will agree > 1 ETH).
        require(msg.value == (10 ** 18), 'Error: Please submit your request with insurance contribution of 0.001 Ether'); // Policy purchaser must be sending their share of insurance contract amount.
        // require(!policySignerPolicies[msg.sender].psBoughtAlready, 'Error: Address has already purchased this policy.');
        require(Year > 1000);
        require(Year <= 2021);
        require(Month <= 12);
        require(Month > 0);
        require(Day <= 31);
        require(Day > 0);
        
        policies.push(policySignerStruct(msg.sender, Latitude, Longitude, Year, Month, Day, true, ownerAmount));
        
        return address(this).balance;
        
        }
        
// debug fxns vv

//    function getPoliciesCount() public returns(uint) {
//        return policies.length;
//        }

//    function getPolicy(uint index) public returns(address policySigner, int Latitude, int Longitude, int Year, int Month, int Day, bool BoughtAlready, uint AwardAmount) {
//        return (policies[index].policySigner, policies[index].psLatitude, policies[index].psLongitude, policies[index].psYear, policies[index].psMonth, policies[index].psDay, policies[index].psBoughtAlready, policies[index].psAwardAmount);
//    }
    
//    function getPolicy(uint index) public returns(uint AwardAmount) {
//        return (policies[index].psAwardAmount);
//    }


}
