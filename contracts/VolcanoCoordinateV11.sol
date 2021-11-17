// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract VolcanoInsurance is ChainlinkClient {
    
    using Chainlink for Chainlink.Request;

    int public Latitude;
    int public Longitude;
    int public Year;
    int public Month;
    int public Day;
    int public CompressedTimeValue;
    string public urlRebuiltJSON;
    uint private immutable fee = 1*10**16;
    bytes32 private immutable jobId ="e5b0e6aeab36405ba33aea12c6988ed6";  //WORKING INT FOR NEGATIVE VALUES          // jobId = "3b7ca0d48c7a4b2da9268456665d11ae"; //WORKING UINT
    address private immutable oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40; //WORKING INT FOR NEGATIVE VALUES         //oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40; //WORKING UINT    
    address private ChainlinkTokenAddressRinkeby = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    ERC20TokenContract tokenObject = ERC20TokenContract(ChainlinkTokenAddressRinkeby);

    constructor() {
        setPublicChainlinkToken();
    }
    
    function request_All_Coordinate_Data() public {
        require(tokenObject.balanceOf(address(this)) >= 2*(10*16), "CONTRACT NEEDS 0.02 LINK TO DO THIS! PLEASE SEND LINK!");
        request_Latitude();
        request_Longitude();
    }
    
    function request_All_Time_Data() public {
        require(tokenObject.balanceOf(address(this)) >= 3*(10*16), "CONTRACT NEEDS 0.03 LINK TO DO THIS! PLEASE SEND LINK!");
        request_Year();
        request_Month();
        request_Day();
    }
    
    function getAllDataConfiredTime() public {
        require(Day > 0);
        require(Month > 0);
        //Buy policy logic
        CompressedTimeValue = (Year<<9)+ (Month<<5) + Day; //Compressed to make easy to compare with other dates. Do not need to decompress. 
    }

    function getAllDataConfirmedCoordinates() public {
        require(Latitude != 0 && Longitude != 0);
        //Reward policy buyer
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function inputValues(string memory year, string memory month, string memory day, string memory country) public
    {
        require(bytes(month).length == 2, "JSON must have month as 2 characters at all times!");
        require(bytes(day).length == 2, "JSON must have day as 2 characters at all times!");
        urlRebuiltJSON= string( abi.encodePacked("https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=",year,
        "&refine.month=",month,"&refine.day=",day,"&refine.country=",country) );
    }
    
    function request_Latitude() private returns (bytes32 requestId) {
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
    
    function request_Longitude() private returns (bytes32 requestId) {
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
    
    function request_Year() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Year.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.addInt("times", 10**18);
        request.add("path", "year");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Year(bytes32 _requestId,int _Year) public recordChainlinkFulfillment(_requestId) {
        Year = _Year; 
    }
    
    function request_Month() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill_request_Month.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.addInt("times", 10**18);
        request.add("path", "month");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Month(bytes32 _requestId,int _Month) public recordChainlinkFulfillment(_requestId) {
        Month = _Month; 
    }
    
    function request_Day() private returns (bytes32 requestId)  {
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
