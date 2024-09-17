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

contract timeChainlinkOracleTest is ChainlinkClient {
        
    using Chainlink for Chainlink.Request;

    // variables

    uint256 public yearPresent;
    uint256 public monthPresent;
    uint256 public dayPresent;
    uint256 public price;
 
    // immutable and constants
    
    uint256 public constant ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY) / 10; // 0.1 * 10**18 (0.1 LINK)
    address public constant chainlinkTokenAddressSepolia = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    string  private constant jobIdGetInt256Sepolia ="ca98366cc7314957b8c012c72f05aeeb"; 
    address private constant oracleSepolia = 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD; 

    constructor() {
        _setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
    }
       
    // Oracle request time from JSON endpoint:
    function OracleRequestPresentTime() public {
        uint256 requestPresentTimeLinkFee = IERC20(address(chainlinkTokenAddressSepolia)).balanceOf(address(this));    
        if(requestPresentTimeLinkFee < 3*ORACLE_PAYMENT) revert notEnoughLinkForThreeRequests();
        // Chainlink requests.
        request_YearPresent();
        request_MonthPresent();
        request_DayPresent();
    } 

    // Sepolia Gas:
    // Gas Limit & Usage by Txn:
    // 432,297 | 279,463 (64.65%) 
    function request_YearPresent() public {
        Chainlink.Request memory req = _buildChainlinkRequest(
            stringToBytes32(jobIdGetInt256Sepolia),
            address(this),
            this.fulfill_request_YearPresent.selector
        );
        req._add("get","https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        req._add("path", "year");
        _sendChainlinkRequestTo(oracleSepolia, req, ORACLE_PAYMENT);
    }

    function fulfill_request_YearPresent(
        bytes32 _requestId,
        uint256 _price
    ) public recordChainlinkFulfillment(_requestId) {
        yearPresent = _price;
    }
  
    function request_MonthPresent() public {
        Chainlink.Request memory req = _buildChainlinkRequest(
            stringToBytes32(jobIdGetInt256Sepolia),
            address(this),
            this.fulfill_request_MonthPresent.selector
        );
        req._add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        req._add("path", "month");
        _sendChainlinkRequestTo(oracleSepolia, req, ORACLE_PAYMENT);
    }

    function fulfill_request_MonthPresent(
        bytes32 _requestId,
        uint256 _price
    ) public recordChainlinkFulfillment(_requestId) {
        monthPresent = _price;
    }

    function request_DayPresent() public {
        Chainlink.Request memory req = _buildChainlinkRequest(
            stringToBytes32(jobIdGetInt256Sepolia),
            address(this),
            this.fulfill_request_DayPresent.selector
        );
        req._add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        req._add("path", "day");
        _sendChainlinkRequestTo(oracleSepolia, req, ORACLE_PAYMENT);
    }
 
    function fulfill_request_DayPresent(
        bytes32 _requestId,
        uint256 _price
    ) public recordChainlinkFulfillment(_requestId) {
        dayPresent = _price;
    }

    function requestEthereumPrice() public {
        Chainlink.Request memory req = _buildChainlinkRequest(
            stringToBytes32(jobIdGetInt256Sepolia),
            address(this),
            this.fulfillEthereumPrice.selector
        );
        req._add(
            "get",
            "https://marcuswentz.github.io/chainlink_test_json_url_types/"
        );
        req._add("path", "uint256");
        req._addInt("times", 100);
        _sendChainlinkRequestTo(oracleSepolia, req, ORACLE_PAYMENT);
    }

    function fulfillEthereumPrice(
        bytes32 _requestId,
        uint256 _price
    ) public recordChainlinkFulfillment(_requestId) {
        price = _price;
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