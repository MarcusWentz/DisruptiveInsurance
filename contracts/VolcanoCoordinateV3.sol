pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

contract VolcanoInsurance is ChainlinkClient {
    
    using Chainlink for Chainlink.Request;
  
    uint public Latitude;
    uint public Longitude;
    bytes32 public Time;
    uint private fee;
    address private oracle;
    bytes32 private jobId;

    constructor() public {
        setPublicChainlinkToken();
        oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40;
        jobId = "3b7ca0d48c7a4b2da9268456665d11ae";
        fee = 0.1 * 10 ** 18; // (Varies by network and job)
    }
    
    function request_Latitude() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Latitude.selector);
        request.add("get", "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=2018&refine.location=Italy");
        request.add("path", "records.0.fields.coordinates.0");
        request.addInt("times", 10**18);
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Latitude(bytes32 _requestId, uint _Latitude) public recordChainlinkFulfillment(_requestId)
    {
        Latitude = _Latitude;
    }
    
    function request_Longitude() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Longitude.selector);
        request.add("get", "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=2018&refine.location=Italy");
        request.add("path", "records.0.fields.coordinates.1");
        request.addInt("times", 10**18);
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Longitude(bytes32 _requestId, uint _Longitude) public recordChainlinkFulfillment(_requestId)
    {
        Longitude = _Longitude;
    }
    
    function request_Time_Year_Month() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Time_Year_Month.selector);
        request.add("get", "http://worldclockapi.com/api/json/est/now");
        request.addInt("times", 10**18);
        request.add("path", "currentFileTime");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Time_Year_Month(bytes32 _requestId,bytes32 _Time) public recordChainlinkFulfillment(_requestId)
    {
        Time = _Time; //https://www.epochconverter.com/ldap
    }
 }
