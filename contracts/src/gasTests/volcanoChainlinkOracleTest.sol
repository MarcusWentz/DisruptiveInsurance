// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import {ChainlinkClient,Chainlink} from "chainlink/v0.8/ChainlinkClient.sol"; 

// Simplified from: 
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol

interface IERC20 {
    // function transfer(address to, uint256 value) external returns (bool);
    // function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

error notEnoughLinkForThreeRequests();

contract volcanoChainlinkOracleTest is ChainlinkClient {

    using Chainlink for Chainlink.Request;

    // variables

    // Original API example (format changed):
    //request._add("path", "records.0.fields.year");

    // Axios tests with new format:
    // console.log(responseDataJSON.results[0].country)
    // console.log(responseDataJSON.results[0].date)
    // console.log(responseDataJSON.results[0].coordinates.lat)
    // console.log(responseDataJSON.results[0].coordinates.lon)

    // New format tests:

    //request._add("path", "results.0.date");
    //request._add("path", "results.0.coordinates.lat");
    //request._add("path", "results.0.coordinates.lon");

    //request._add("path", "results[0].date");
    //request._add("path", "results[0].coordinates.lat");
    //request._add("path", "results[0].coordinates.lon");

    // Working with "," to step deeper into array path:
    // https://docs.chain.link/any-api/get-request/examples/array-response 

    //request._add("path", "results,0,date");
    //request._add("path", "results,0,coordinates,lat");
    //request._add("path", "results,0,coordinates,lon");

    string public eruptionDate;
    int256 public lat;
    int256 public long;
 
    // immutable and constants
    
    uint256 public constant ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY) / 10; // 0.1 * 10**18 (0.1 LINK)
    address public constant chainlinkTokenAddressSepolia = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    // If this fails on Sepolia, try to debug with a local Sepolia Chainlink node.
    string  private constant jobIdGetInt256Sepolia ="fcf4140d696d44b687012232948bdd5d"; 
    string  private constant jobIdGetStringSepolia ="7d80a6386ef543a3abb52817f6707e3b"; 
    address private constant oracleSepolia = 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD; 

    string public constant jsonUrl = "https://userclub.opendatasoft.com/api/explore/v2.1/catalog/datasets/les-eruptions-volcaniques-dans-le-monde/records?limit=20&refine=country%3A%22Iceland%22&refine=date%3A%221727%2F08%2F03%22";

    constructor() {
        _setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
    }
       
    // Oracle request time from JSON endpoint. 
    // Sepolia Gas:
    // Gas Limit & Usage by Txn:
    // 316,185 | 310,118 (98.08%) 
    function OracleRequestVolcanoData() public {
        uint256 requestPresentTimeLinkFee = IERC20(address(chainlinkTokenAddressSepolia)).balanceOf(address(this));    
        if(requestPresentTimeLinkFee < 3*ORACLE_PAYMENT) revert notEnoughLinkForThreeRequests();
        // Chainlink requests.
        request_EruptionDate();
        request_Latitude();
        request_Longitude();
    } 

    function request_EruptionDate() public {
        Chainlink.Request memory req = _buildChainlinkRequest(
            stringToBytes32(jobIdGetStringSepolia),
            address(this),
            this.fulfill_request_EruptionDate.selector
        );
        req._add("get",jsonUrl);
        req._add("path", "results,0,date");
        _sendChainlinkRequestTo(oracleSepolia, req, ORACLE_PAYMENT);
    }

    function fulfill_request_EruptionDate(
        bytes32 _requestId,
        // Calldata is cheaper than memory since it is read only.
        // string memory _price
        string calldata _price
    ) public recordChainlinkFulfillment(_requestId) {
        eruptionDate = _price;
    }
  
    function request_Latitude() public {
        Chainlink.Request memory req = _buildChainlinkRequest(
            stringToBytes32(jobIdGetInt256Sepolia),
            address(this),
            this.fulfill_request_Latitude.selector
        );
        req._add("get",jsonUrl);
        req._add("path", "results,0,coordinates,lat");
        req._addInt("times", 1);
        _sendChainlinkRequestTo(oracleSepolia, req, ORACLE_PAYMENT);
    }

    function fulfill_request_Latitude(
        bytes32 _requestId,
        int256 _price
    ) public recordChainlinkFulfillment(_requestId) {
        lat = _price;
    }

    function request_Longitude() public {
        Chainlink.Request memory req = _buildChainlinkRequest(
            stringToBytes32(jobIdGetInt256Sepolia),
            address(this),
            this.fulfill_request_Longitude.selector
        );
        req._add("get", jsonUrl);
        req._add("path", "results,0,coordinates,lon");
        req._addInt("times", 1);
        _sendChainlinkRequestTo(oracleSepolia, req, ORACLE_PAYMENT);
    }
 
    function fulfill_request_Longitude(
        bytes32 _requestId,
        int256 _price
    ) public recordChainlinkFulfillment(_requestId) {
        long = _price;
    }

    function stringToBytes32(
        string memory source
    ) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }  
    
 }
