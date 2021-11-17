// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract VolcanoInsurance is ChainlinkClient {
    
    using Chainlink for Chainlink.Request;

    int public Latitude;
    int public Longitude;
    int public PresentYear;
    int public PresentMonth;
    int public PresentDay;
    int public CompressedTimeValue;
    uint private immutable fee = 1*10**16;
    string public urlRebuiltJSON = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.PresentYear=1727&refine.PresentMonth=08&refine.PresentDay=03&refine.country=Iceland";
    bytes32 private immutable jobId ="e5b0e6aeab36405ba33aea12c6988ed6";  //WORKING INT FOR NEGATIVE VALUES          // jobId = "3b7ca0d48c7a4b2da9268456665d11ae"; //WORKING UINT
    address private immutable oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40; //WORKING INT FOR NEGATIVE VALUES         //oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40; //WORKING UINT    
    address public immutable Owner;
    address private ChainlinkTokenAddressRinkeby = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    ERC20TokenContract tokenObject = ERC20TokenContract(ChainlinkTokenAddressRinkeby);
    
    struct policy {
        int LatitudeInsured;
        int LongitudeInsured;
        int CompressedTimeValueMapped;
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
        require(bytes(filterMonth).length == 2, "JSON must have PresentMonth as 2 characters at all times!");
        require(bytes(filterDay).length == 2, "JSON must have PresentDay as 2 characters at all times!");
        urlRebuiltJSON= string( abi.encodePacked("https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.PresentYear=",filterYear,
        "&refine.PresentMonth=",filterMonth,"&refine.PresentDay=",filterDay,"&refine.country=",filterCountry) );
    }
    
    function request_All_Coordinate_Data() public {
        require(tokenObject.balanceOf(address(this)) >= 2*(10*16), "CONTRACT NEEDS 0.02 LINK TO DO THIS! PLEASE SEND LINK!");
        request_Latitude();
        request_Longitude();
    }
    
    function request_All_Time_Data() public {
        require(tokenObject.balanceOf(address(this)) >= 3*(10*16), "CONTRACT NEEDS 0.03 LINK TO DO THIS! PLEASE SEND LINK!");
        request_PresentYear();
        request_PresentMonth();
        request_PresentDay();
    }
    
    function BuyerCreatePolicy(int inputLat, int inputLong) public payable {
        require(PresentDay > 0, "PresentDay not recorded yet by oracle.");
        require(PresentMonth > 0, "PresentMonth not recorded yet by oracle.");
        require(PresentYear > 0, "PresentYear not recorded yet by oracle.");
        require(Owner != msg.sender, "Error: Owner cannot self-insure"); // Policy purchaser must not be owner. 
        require(address(this).balance > 0, 'Error: Contract has insufficient funds to insure you.'); // Owner must have funds to cover policy purchase. Made >0 in case multiple policy purchases are made in the same contract for a given address (i.e owner will agree > 1 ETH).
        require(msg.value == (10 ** 18), 'Error: Please submit your request with insurance contribution of 0.001 Ether'); // Policy purchaser must be sending their share of insurance contract amount.
        require(policies[msg.sender].CompressedTimeValueMapped == 0,"Error: You've already purchased insurance"); // Checks if requester has already bought insurance. 
        CompressedTimeValue = (PresentYear<<9)+ (PresentMonth<<5) + PresentDay; //Compressed to make easy to compare with other dates. Do not need to decompress. 
        policies[msg.sender] = policy(inputLat, inputLong, CompressedTimeValue );
        PresentDay = 0;
        PresentMonth = 0;
        PresentYear = 0;
    }
    
    function BuyerClaimReward() public {
        require(Latitude != 0 || Longitude != 0, "Lat and Long cannot both be 0. Wait for oracle response.");
        require(policies[msg.sender].CompressedTimeValueMapped > 0,"Error: You don't have a policy"); // Checks if this address has a policy or not.
        //!!!!!!!!!!!!!!Check JSON dates or record strings to compare erutption date? I think the contact might be exploited by just changing the string after data is on chain.!!!!!!!!!
        require(policies[msg.sender].LongitudeInsured >=  (Longitude-100) && policies[msg.sender].LongitudeInsured <=  (Longitude+100) , "Must be within 1 long coordinate point." );
        require(policies[msg.sender].LatitudeInsured >=  (Latitude-100) && policies[msg.sender].LatitudeInsured <=  (Latitude+100) , "Must be within 1 lat coordinate point." );
        payable(msg.sender).transfer(1*(10**18));
        Latitude = 0;
        Longitude = 0;
        }
    
    function OwnerSendOneEthToContractFromInsuranceBusiness() public payable contractOwnerCheck {
        require(msg.value == 1*(10**18), "Value sent must equal 1 ETH");
    }

    function OwnerClaimExpiredPolicyETH (address policyHolder) public contractOwnerCheck { 
        require(PresentDay > 0, "PresentDay not recorded yet by oracle.");
        require(PresentMonth > 0, "PresentMonth not recorded yet by oracle.");
        require(PresentYear > 0, "PresentYear not recorded yet by oracle.");
        require(Latitude != 0 || Longitude != 0, "Lat and Long cannot both be 0. Wait for oracle response.");
        require(policies[policyHolder].CompressedTimeValueMapped > 0, "Policy does not exist.");
        require( ((PresentYear<<9)+ (PresentMonth<<5) + PresentDay) > policies[policyHolder].CompressedTimeValueMapped+512, "Policy has not yet expired");
        policies[policyHolder] = policy(0, 0, 0);
        payable(msg.sender).transfer(address(this).balance);
        PresentDay = 0;
        PresentMonth = 0;
        PresentYear = 0;
        Latitude = 0;
        Longitude = 0;
    }
    
    function ZDEBUGOwnerSendOneEthToContractFromInsuranceBusiness() public payable contractOwnerCheck {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function request_Latitude() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Latitude.selector);
        request.add("get", urlRebuiltJSON);
        request.add("path", "records.0.fields.coordinates.0");
        request.addInt("add", 180);
        request.addInt("times", 10**2);
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Latitude(bytes32 _requestId, int _Latitude) public recordChainlinkFulfillment(_requestId){
        Latitude = _Latitude;
    }
    
    function request_Longitude() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Longitude.selector);
        request.add("get", urlRebuiltJSON);
        request.add("path", "records.0.fields.coordinates.1");
        request.addInt("times", 10**2);
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Longitude(bytes32 _requestId, int _Longitude) public recordChainlinkFulfillment(_requestId)
    {
        Longitude = _Longitude;
    }
    
    function request_PresentYear() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_PresentYear.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.add("path", "PresentYear");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_PresentYear(bytes32 _requestId,int _PresentYear) public recordChainlinkFulfillment(_requestId) {
        PresentYear = _PresentYear; 
    }
    
    function request_PresentMonth() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_PresentMonth.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.add("path", "PresentMonth");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_PresentMonth(bytes32 _requestId,int _PresentMonth) public recordChainlinkFulfillment(_requestId) {
        PresentMonth = _PresentMonth; 
    }
    
    function request_PresentDay() private returns (bytes32 requestId)  {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_PresentDay.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.add("path", "PresentDay");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_PresentDay(bytes32 _requestId,int _PresentDay) public recordChainlinkFulfillment(_requestId) {
        PresentDay = _PresentDay; 
    }
    
 }
