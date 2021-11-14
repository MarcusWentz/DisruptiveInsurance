pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

contract VolcanoInsurance is ChainlinkClient {
    
    using Chainlink for Chainlink.Request;
  
    int public numberOfHits;
    int public Latitude;
    int public Longitude;
    int public Year;
    int public Month;
    uint private fee;
    address private oracle;
    bytes32 private jobId;

    constructor() public {
        setPublicChainlinkToken();
        //oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40; //WORKING UINT
        oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40; //WORKING INT FOR NEGATIVE VALUES
        // jobId = "3b7ca0d48c7a4b2da9268456665d11ae"; //WORKING UINT
        jobId = "e5b0e6aeab36405ba33aea12c6988ed6";  //WORKING INT FOR NEGATIVE VALUES
        fee = 0.1 * 10 ** 18; // (Varies by network and job)
    }
    
    function request_numberOfHits() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_numberOfHits.selector);
        request.add("get", "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=1727&refine.month=08&refine.day=03&refine.country=Iceland");
        request.add("path", "nhits");
        request.addInt("times", 10**18);
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_numberOfHits(bytes32 _requestId, int _numberOfHits) public recordChainlinkFulfillment(_requestId)
    {
        numberOfHits = _numberOfHits;
    }
    
    function request_Latitude() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Latitude.selector);
        request.add("get", "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=1727&refine.month=08&refine.day=03&refine.country=Iceland");
        request.add("path", "records.0.fields.coordinates.0");
        request.addInt("add", 180);
        request.addInt("times", 10**18);
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Latitude(bytes32 _requestId, int _Latitude) public recordChainlinkFulfillment(_requestId)
    {
        Latitude = _Latitude;
    }
    
    function request_Longitude() public returns (bytes32 requestId) 
    {
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
    
    function request_Year() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Year.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.addInt("times", 10**18);
        request.add("path", "year");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Year(bytes32 _requestId,int _Year) public recordChainlinkFulfillment(_requestId)
    {
        Year = _Year; //https://www.epochconverter.com/ldap
    }
    
    function request_Month() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Month.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.addInt("times", 10**18);
        request.add("path", "month");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Month(bytes32 _requestId,int _Month) public recordChainlinkFulfillment(_requestId)
    {
        Month = _Month; //https://www.epochconverter.com/ldap
    }
 }
