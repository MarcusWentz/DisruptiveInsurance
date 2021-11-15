// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.7.0;

contract disruptiveInsurance {
    address public owner;
    uint public ownerAmount;
    
    constructor() public payable {
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
        uint psPaymentAmount;
        uint psAwardAmount;
    }
    
    policySignerStruct[] policies; // array of policies
        
    function buyPolicy(int Latitude, int Longitude, int Year, int Month, int Day) public payable {
        require(msg.sender == tx.origin, 'Error: Contract cannot insure itself - independent address required'); // Policy purchaser must be EOA and not a contract. 
        require(address(this).balance > 0, 'Error: Owner insufficient funds'); // Owner must have funds to cover policy purchase. Made >0 in case multiple policy purchases are made in the same contract for a given address (i.e owner will agree > 1 ETH).
        require(msg.value == (10 ** 16), 'Error: Please submit your request with insurance contribution of 0.001 Ether'); // Policy purchaser must be sending their share of insurance contract amount. 
     //   require(boughtAlready == false, 'Error: This address has already purchased insurance for this location.'); // [of requester] or SignerStruct.BoughtAlready == false;
       
        policies.push(policySignerStruct(msg.sender, Latitude, Longitude, Year, Month, Day, true, msg.value, ownerAmount));
        
        }

}
