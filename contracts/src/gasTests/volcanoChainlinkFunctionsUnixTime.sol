// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// import {FunctionsClient} from "@chainlink/contracts@1.2.0/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsClient} from "chainlink/v0.8/functions/v1_0_0/FunctionsClient.sol"; 


// import {ConfirmedOwner} from "@chainlink/contracts@1.2.0/src/v0.8/shared/access/ConfirmedOwner.sol";
import {ConfirmedOwner} from "chainlink/v0.8/shared/access/ConfirmedOwner.sol"; 


// import {FunctionsRequest} from "@chainlink/contracts@1.2.0/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {FunctionsRequest} from "chainlink/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol"; 

// Any API example in Foundry.
// import {ChainlinkClient,Chainlink} from "chainlink/v0.8/ChainlinkClient.sol"; 

error UnexpectedRequestID(bytes32 requestId);

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/resources/link-token-contracts/
 */

/**
 * @title GettingStartedFunctionsConsumer
 * @notice This is an example contract to show how to make HTTP requests using Chainlink
 * @dev This contract uses hardcoded values and should not be used in production.
 */
contract volcanoChainlinkFunctionsUnixTime is FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    event Response(
        bytes32 indexed requestId,
        uint256 value,
        bytes response,
        bytes err
    );

 // Chainlink Functions logic

 using FunctionsRequest for FunctionsRequest.Request;

 // State variables to store the last request ID, response, and error
 bytes32 public s_lastRequestId;
 bytes public s_lastResponse;
 bytes public s_lastError;

 // State variable to store the returned character information
 // string public wtiPriceOracle; //Estimated value on request: 8476500000. Will get cross chain with Universal Adapter on Mumbai Polygon: https://etherscan.io/address/0xf3584f4dd3b467e73c2339efd008665a70a4185c#readContract latest price
 uint256 public unixTime; //Estimated value on request: 8476500000. Will get cross chain with Universal Adapter on Mumbai Polygon: https://etherscan.io/address/0xf3584f4dd3b467e73c2339efd008665a70a4185c#readContract latest price


 // // Custom error type
 // error UnexpectedRequestID(bytes32 requestId);

 // // Event to log responses
 // event Response(
 //     bytes32 indexed requestId,
 //     uint256 value,
 //     bytes response,
 //     bytes err
 // );

 // Router address. Check to get the router address for your supported network 
 // https://docs.chain.link/chainlink-functions/supported-networks#base-sepolia-testnet
 address constant routerBaseSepolia = 0xf9B8fc078197181C841c296C876945aaa425B278;

 // donID. Check to get the donID for your supported network 
 // https://docs.chain.link/chainlink-functions/supported-networks#base-sepolia-testnet
 bytes32 constant donIDBaseSepolia = 0x66756e2d626173652d7365706f6c69612d310000000000000000000000000000;
 
 //Callback gas limit
 uint32 constant gasLimit = 300000;

 // JavaScript source code
 // Fetch character name from the Star Wars API.
 // Documentation: https://swapi.info/people

 // return Functions.encodeUint256()
 
 string constant javascriptSourceCode = "const apiResponse = await Functions.makeHttpRequest({url: `https://userclub.opendatasoft.com/api/explore/v2.1/catalog/datasets/les-eruptions-volcaniques-dans-le-monde/records?limit=20&refine=country%3A%22United%20States%22&refine=date%3A%221980%2F05%22`}); if (apiResponse.error) {console.error(apiResponse.error);throw Error('Request failed');} const { data } = apiResponse; console.log('API response data:'); const dateNow = data.results[0].date; console.log(dateNow); const timeUnix = Math.floor(new Date(dateNow).getTime() / 1000); console.log(timeUnix); return Functions.encodeUint256(timeUnix);";

 constructor() FunctionsClient(routerBaseSepolia)   {}

 /**
  * @notice Sends an HTTP request for character information
  * @param subscriptionId The ID for the Chainlink subscription
  * @param args The arguments to pass to the HTTP request
  * @return requestId The ID of the request
  */
 function sendRequest(
     uint64 subscriptionId,
     string[] calldata args
 ) external returns (bytes32 requestId) {
     FunctionsRequest.Request memory req;
     req.initializeRequestForInlineJavaScript(javascriptSourceCode); // Initialize the request with JS code
     if (args.length > 0) req.setArgs(args); // Set the arguments for the request

     // Send the request and store the request ID
     s_lastRequestId = _sendRequest(
         req.encodeCBOR(),
         subscriptionId,
         gasLimit,
         donIDBaseSepolia
     );

     return s_lastRequestId;
 }

 /**
  * @notice Callback function for fulfilling a request
  * @param requestId The ID of the request to fulfill
  * @param response The HTTP response data
  * @param err Any errors from the Functions request
  */
 function fulfillRequest(
     bytes32 requestId,
     bytes memory response,
     bytes memory err
 ) internal override {
     if (s_lastRequestId != requestId) {
         revert UnexpectedRequestID(requestId); // Check if request IDs match
     }
     // Update the contract's state variables with the response and any errors
     s_lastResponse = response;
     unixTime = abi.decode(response, (uint256));
     s_lastError = err;

     // Emit an event to log the response
     emit Response(requestId, unixTime, s_lastResponse, s_lastError);
 }

}
