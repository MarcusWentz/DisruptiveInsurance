// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract VolcanoInsurance is ChainlinkClient {
    
    using Chainlink for Chainlink.Request;
    
    int public LatitudeEruption;
    int public LongitudeEruption;
    int public YearPresent;
    int public MonthPresent;
    int public DayPresent;
    uint public OpenETHtoEnsure;
    uint public AccountsInsured;
    uint private immutable fee = 1*10**16;
    string public urlRebuiltJSON = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.YearPresent=1727&refine.MonthPresent=08&refine.DayPresent=03&refine.country=Iceland";
    bytes32 private immutable jobId ="e5b0e6aeab36405ba33aea12c6988ed6";  //WORKING INT FOR NEGATIVE VALUES          // jobId = "3b7ca0d48c7a4b2da9268456665d11ae"; //WORKING UINT
    address private immutable oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40; //WORKING INT FOR NEGATIVE VALUES         //oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40; //WORKING UINT    
    address public immutable Owner;
    address private ChainlinkTokenAddressRinkeby = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    ERC20TokenContract tokenObject = ERC20TokenContract(ChainlinkTokenAddressRinkeby);
    
    struct policy {
        int LatitudeInsured;
        int LongitudeInsured;
        int YearSigned;
        int MonthSigned;
        int DaySigned;
        int EthereumAwardTiedToAddress;
    }
    
    mapping(address => policy) public policies;

    constructor() {
        Owner = msg.sender;
        setPublicChainlinkToken();
    }
    
    modifier contractOwnerCheck() {
        require(msg.sender == Owner, "Only contract owner can interact with this contract");
        _;
    }
    
    function urlRebuiltJSONUpdate(string memory filterYear, string memory filterMonth, string memory filterDay, string memory filterCountry) public {
        require(bytes(filterMonth).length == 2, "JSON must have MonthPresent as 2 characters at all times!");
        require(bytes(filterDay).length == 2, "JSON must have DayPresent as 2 characters at all times!");
        urlRebuiltJSON= string( abi.encodePacked("https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.YearPresent=",filterYear,
        "&refine.MonthPresent=",filterMonth,"&refine.DayPresent=",filterDay,"&refine.country=",filterCountry) );
    }
    
    function request_All_Coordinate_Data() public {
        require(tokenObject.balanceOf(address(this)) >= 2*(10*16), "CONTRACT NEEDS 0.02 LINK TO DO THIS! PLEASE SEND LINK!");
        request_Latitude();
        request_Longitude();
    }
    
    function request_All_Time_Data() public {
        require(tokenObject.balanceOf(address(this)) >= 3*(10*16), "CONTRACT NEEDS 0.03 LINK TO DO THIS! PLEASE SEND LINK!");
        request_YearPresent();
        request_MonthPresent();
        request_DayPresent();
    }
    
    function BuyerCreatePolicy(int inputLat, int inputLong) public payable {
        require(DayPresent > 0, "DayPresent not recorded yet by oracle.");
        require(MonthPresent > 0, "MonthPresent not recorded yet by oracle.");
        require(YearPresent > 0, "YearPresent not recorded yet by oracle.");
        require(Owner != msg.sender, "Error: Owner cannot self-insure"); // Policy purchaser must not be owner. 
        require(OpenETHtoEnsure > 0, 'There is no open ETH in the contract currently.'); // Owner must have funds to cover policy purchase. Made >0 in case multiple policy purchases are made in the same contract for a given address (i.e owner will agree > 1 ETH).
        require(msg.value == (10 ** 18), 'Error: Please submit your request with insurance contribution of 0.001 Ether'); // Policy purchaser must be sending their share of insurance contract amount.
        require(policies[msg.sender].EthereumAwardTiedToAddress == 0,"Error: You've already purchased insurance"); // Checks if requester has already bought insurance. 
        OpenETHtoEnsure -= 1;
        AccountsInsured += 1;
        policies[msg.sender] = policy(inputLat, inputLong,YearPresent,MonthPresent,DayPresent,1);
        payable(Owner).transfer(1*(10**18));
        DayPresent = 0;
        MonthPresent = 0;
        YearPresent = 0;
    }
    
    function BuyerClaimReward() public {
        require(LatitudeEruption != 0 || LongitudeEruption != 0, "Lat and Long cannot both be 0. Wait for oracle response.");
        require(policies[msg.sender].EthereumAwardTiedToAddress > 0,"Error: You don't have a policy"); // Checks if this address has a policy or not.
        //!!!!!!!!!!!!!!Check JSON dates or record strings to compare erutption date? I think the contact might be exploited by just changing the string after data is on chain.!!!!!!!!!
        require(policies[msg.sender].LongitudeInsured >=  (LongitudeEruption-100) && policies[msg.sender].LongitudeInsured <=  (LongitudeEruption+100) , "Must be within 1 long coordinate point." );
        require(policies[msg.sender].LatitudeInsured >=  (LatitudeEruption-100) && policies[msg.sender].LatitudeInsured <=  (LatitudeEruption+100) , "Must be within 1 lat coordinate point." );
        AccountsInsured -= 1;
        payable(msg.sender).transfer(1*(10**18));
        LatitudeEruption = 0;
        LongitudeEruption = 0;
    }
    
    function OwnerSendOneEthToContractFromInsuranceBusiness() public payable contractOwnerCheck {
        require(msg.value == 1*(10**18), "Value sent must equal 1 ETH");
        OpenETHtoEnsure += 1;
    }

    function OwnerClaimExpiredPolicyETH(address policyHolder) public contractOwnerCheck { 
        require(DayPresent > 0, "DayPresent not recorded yet by oracle.");
        require(MonthPresent > 0, "MonthPresent not recorded yet by oracle.");
        require(YearPresent > 0, "YearPresent not recorded yet by oracle.");
        require(LatitudeEruption != 0 || LongitudeEruption != 0, "Lat and Long cannot both be 0. Wait for oracle response.");
        require(policies[policyHolder].EthereumAwardTiedToAddress > 0, "Policy does not exist.");
        require( ((YearPresent<<9)+ (MonthPresent<<5) + DayPresent) > ( (policies[policyHolder].YearSigned<<9) + (policies[policyHolder].MonthSigned<<5) + (policies[policyHolder].DaySigned)+512) , "Policy has not yet expired");
        AccountsInsured -=1;
        policies[policyHolder] = policy(0, 0, 0, 0, 0, 0);
        payable(msg.sender).transfer(address(this).balance);
        DayPresent = 0;
        MonthPresent = 0;
        YearPresent = 0;
        LatitudeEruption = 0;
        LongitudeEruption = 0;
    }
    
    function OwnerLiquidtoOpenETHToWithdraw() public contractOwnerCheck {
        require(OpenETHtoEnsure > 0, 'There is no open ETH in the contract currently.'); 
        OpenETHtoEnsure -= 1;
        payable(msg.sender).transfer(1*(10**18));
    }
    
    function request_Latitude() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Latitude.selector);
        request.add("get", urlRebuiltJSON);
        request.add("path", "records.0.fields.coordinates.0");
        request.addInt("times", 10**2);
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Latitude(bytes32 _requestId, int _LatitudeEruption) public recordChainlinkFulfillment(_requestId){
        LatitudeEruption = _LatitudeEruption;
    }
    
    function request_Longitude() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Longitude.selector);
        request.add("get", urlRebuiltJSON);
        request.add("path", "records.0.fields.coordinates.1");
        request.addInt("times", 10**2);
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Longitude(bytes32 _requestId, int _LongitudeEruption) public recordChainlinkFulfillment(_requestId)
    {
        LongitudeEruption = _LongitudeEruption;
    }
    
    function request_YearPresent() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_YearPresent.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.add("path", "year");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_YearPresent(bytes32 _requestId,int _YearPresent) public recordChainlinkFulfillment(_requestId) {
        YearPresent = _YearPresent; 
    }
    
    function request_MonthPresent() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_MonthPresent.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.add("path", "month");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_MonthPresent(bytes32 _requestId,int _MonthPresent) public recordChainlinkFulfillment(_requestId) {
        MonthPresent = _MonthPresent; 
    }
    
    function request_DayPresent() private returns (bytes32 requestId)  {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_DayPresent.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.add("path", "day");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_DayPresent(bytes32 _requestId,int _DayPresent) public recordChainlinkFulfillment(_requestId) {
        DayPresent = _DayPresent; 
    }
    
 }
