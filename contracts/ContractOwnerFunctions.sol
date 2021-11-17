pragma solidity ^0.8.10;

contract ContractOwnerFunctions is Ownable {

    address public immutable owner;
    int public psYear;
    int public psMonth;
    int public psDay;
    int public currentYear;

    constructor() {
        owner = msg.sender;
        // Hard coding values for POC - will reflect policy related details in full spec
        psYear = 2020;
        psMonth = 11;
        psDay = 1;
        currentYear = 2021;
    }

    // Ensure sender is contract owner
    modifier contractOwnerCheck() {
        require(msg.sender == owner, "Only contract owner can interact with this contract");
        _;
    }

    // Send 1 Eth to this contract
    function sendOneEthToContractFromInsuranceBusiness() public payable contractOwnerCheck {
        // payable function - contract is receiving ETH
        require(msg.value == 1 * (10 ** 18), "Value sent must equal 1 ETH");
    }

    function claimEverythingInsuranceBusiness() public contractOwnerCheck {
        // Check that policy is expired - full spec will include current date 
        require(currentYear > psYear), "Policy has not yet expired")
        payable(msg.sender).transfer(address(this).balance);

        // Reset hardcode policy values to 0 - full spec will deal with actual policy details
        psYear = 0;
        psMonth = 0;
        psDay = 0;
    }
}