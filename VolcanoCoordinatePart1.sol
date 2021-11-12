//CHAINLINK CALL FOR HEAT INDEX [ALSO KNOWN AS THE "TEMPERATURE FEELS LIKE" TEMPERATURE] FOR NYC.
//USES OPENWEATHER AS DATA SOURCE. 
//
// OPENWEATHER-API KEY - 122c7a4d9517984a4f8c029d1bd1eb42
//NEW YORK CITY CODE 
//api.openweathermap.org/data/2.5/weather?q={city name}&appid={API key}
//api.openweathermap.org/data/2.5/weather?q=London&appid=122c7a4d9517984a4f8c029d1bd1eb42
//"New York City" weather in degrees fahrenheit [units=imperial]
//http://api.openweathermap.org/data/2.5/weather?q=New%20York%20CIty&units=imperial&appid=122c7a4d9517984a4f8c029d1bd1eb42

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract APIConsumer is ChainlinkClient {
    using Chainlink for Chainlink.Request;
  
    uint256 public TEMP_FEELS_LIKE_NYC;
    
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;
    
    /**
     * Network: Rinkeby
     * Oracle: 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40
     * Job ID: 3b7ca0d48c7a4b2da9268456665d11ae
     * Fee: 0.01 LINK
     * IF THIS DOES NOT WORK TRY ANOTHER LINK ORACLE THAT IS RECENTLY ACTIVE
     */
    constructor() public {
        setPublicChainlinkToken();
        oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40;
        jobId = "3b7ca0d48c7a4b2da9268456665d11ae";
        fee = 0.1 * 10 ** 18; // (Varies by network and job)
    }
    
    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function request_TEMP_FEELS_LIKE_NYC_Data() public returns (bytes32 requestId) 
    {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        
        // Set the URL to perform the GET request on
        request.add("get", "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=2018&refine.location=Italy");
        
        // Set the path to find the desired data in the API response, where the response format is:
        // {"RAW":
        //   {"ETH":
        //    {"USD":
        //     {
        //      "TEMP_FEELS_LIKE_NYC24HOUR": xxx.xxx,
        //     }
        //    }
        //   }
        //  }
        request.add("path", "records.0.fields.coordinates.0");
        
        // Multiply the result by 1000000000000000000 to remove decimals
        int timesAmount = 10**18;
        request.addInt("times", timesAmount);
        
        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    
    /**
     * Receive the response in the form of uint256
     */ 
    function fulfill(bytes32 _requestId, uint256 _TEMP_FEELS_LIKE_NYC) public recordChainlinkFulfillment(_requestId)
    {
        TEMP_FEELS_LIKE_NYC = _TEMP_FEELS_LIKE_NYC;
    }
 
    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}
