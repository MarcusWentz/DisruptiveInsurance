// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract VolcanoInsurance is ChainlinkClient {
    
    using Chainlink for Chainlink.Request;
    address public ChainlinkTokenAddressRinkeby = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    ERC20TokenContract tokenObject = ERC20TokenContract(ChainlinkTokenAddressRinkeby);

    // int public numberOfHits;
    int public Latitude;
    int public Longitude;
    int public Year;
    int public Month;
    int public Day;
    uint private fee;
    address private oracle;
    bytes32 private jobId;

    constructor() {
        setPublicChainlinkToken();
        // jobId = "3b7ca0d48c7a4b2da9268456665d11ae"; //WORKING UINT
        //oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40; //WORKING UINT
        jobId = "e5b0e6aeab36405ba33aea12c6988ed6";  //WORKING INT FOR NEGATIVE VALUES
        oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40; //WORKING INT FOR NEGATIVE VALUES
        fee = 0.1 * 10 ** 18; // (Varies by network and job)
    }
    
    // function request_numberOfHits() public returns (bytes32 requestId) 
    // {
    //     Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_numberOfHits.selector);
    //     request.add("get", "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=1727&refine.month=08&refine.day=03&refine.country=Iceland");
    //     request.add("path", "nhits");
    //     request.addInt("times", 10**18);
    //     return sendChainlinkRequestTo(oracle, request, fee);
    // }
    // function fulfill_request_numberOfHits(bytes32 _requestId, int _numberOfHits) public recordChainlinkFulfillment(_requestId)
    // {
    //     numberOfHits = _numberOfHits;
    // }
    
    function request_All_Coordinate_Data() public {
        require(tokenObject.balanceOf(address(this)) >= 2*(10*17), "CONTRACT NEEDS 0.2 LINK TO DO THIS! PLEASE SEND LINK!");
        request_Latitude();
        request_Longitude();
    }
    
    function request_All_Time_Data() public {
        require(tokenObject.balanceOf(address(this)) >= 3*(10*17), "CONTRACT NEEDS 0.3 LINK TO DO THIS! PLEASE SEND LINK!");
        request_Year();
        request_Month();
        request_Day();
    }
    
    function request_Latitude() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Latitude.selector);
        request.add("get", "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=1727&refine.month=08&refine.day=03&refine.country=Iceland");
        request.add("path", "records.0.fields.coordinates.0");
        request.addInt("add", 180);
        request.addInt("times", 10**18);
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Latitude(bytes32 _requestId, int _Latitude) public recordChainlinkFulfillment(_requestId){
        Latitude = _Latitude;
    }
    
    function request_Longitude() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Longitude.selector);
        request.add("get", "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=1727&refine.month=08&refine.day=03&refine.country=Iceland");
        request.add("path", "records.0.fields.coordinates.1");
        request.addInt("times", 10**18);
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Longitude(bytes32 _requestId, int _Longitude) public recordChainlinkFulfillment(_requestId)
    {
        Longitude = _Longitude;
    }
    
    function request_Year() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Year.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.addInt("times", 10**18);
        request.add("path", "year");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Year(bytes32 _requestId,int _Year) public recordChainlinkFulfillment(_requestId) {
        Year = _Year; 
    }
    
    function request_Month() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Month.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.addInt("times", 10**18);
        request.add("path", "month");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Month(bytes32 _requestId,int _Month) public recordChainlinkFulfillment(_requestId) {
        Month = _Month; 
    }
    
    function request_Day() public returns (bytes32 requestId)  {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Day.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.addInt("times", 10**18);
        request.add("path", "day");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Day(bytes32 _requestId,int _Day) public recordChainlinkFulfillment(_requestId) {
        Day = _Day; 
    }
    
 }
 
 
