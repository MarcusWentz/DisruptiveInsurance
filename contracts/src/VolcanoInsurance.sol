// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "./interfaces/IERC20.sol";
import {IVolcanoInsurance} from "./interfaces/IVolcanoInsurance.sol";
// // For pricefeeds such as ETH/USD.
// import {AggregatorV3Interface} from "chainlink/v0.8/interfaces/AggregatorV3Interface.sol"; 
// import {FunctionsClient} from "@chainlink/contracts@1.2.0/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsClient} from "chainlink/v0.8/functions/v1_0_0/FunctionsClient.sol"; 

// import {FunctionsRequest} from "@chainlink/contracts@1.2.0/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {FunctionsRequest} from "chainlink/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol"; 



import {Convert} from "./util/Convert.sol";
import {Owned} from "solmate/auth/Owned.sol";
// BokkyPooBahsDateTimeLibrary/=lib/BokkyPooBahsDateTimeLibrary/
import { BokkyPooBahsDateTimeLibrary } from "BokkyPooBahsDateTimeLibrary/contracts/BokkyPooBahsDateTimeLibrary.sol";

contract VolcanoInsurance is FunctionsClient , Convert, IVolcanoInsurance , Owned {
        
    // variables

    int256 public LatitudeEruption; 
    int256 public LongitudeEruption;
    uint256 public YearEruption;
    uint256 public MonthEruption;
    uint256 public DayEruption;
    uint256 public OpenWEItoInsure;
    uint256 public LockedWEItoPolicies;
    // string public urlRebuiltJSON = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=1727&refine.month=08&refine.day=03&refine.country=Iceland";
    string public urlRebuiltJSON = "https://userclub.opendatasoft.com/api/explore/v2.1/catalog/datasets/les-eruptions-volcaniques-dans-le-monde/records?limit=20&refine=country%3A%22Iceland%22&refine=date%3A%221727%2F08%2F03%22";
    // immutable and constants
    
    uint256 public constant policyFee = (1 ether)/100;
    address public constant chainlinkTokenAddressSepolia = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    struct policy {
        int256 latitudeInsured;
        int256 longitudeInsured;
        uint256 unixTimeSigned;
        uint256 ethereumAwardTiedToAddress;
    }
    
    mapping(address => policy) public policies;

    function oracleRequestVolcanoEruptionData(string memory filterYear, string memory filterMonth, string memory filterDay, string memory filterCountry) public {
        uint256 requestVolcanoDataLinkFee = IERC20(address(chainlinkTokenAddressSepolia)).balanceOf(address(this));
        require(requestVolcanoDataLinkFee >= 3*(10*16), "CONTRACT NEEDS 0.03 LINK TO DO THIS! PLEASE SEND LINK TO THIS CONTRACT!");
        require(bytes(filterMonth).length == 2 && bytes(filterDay).length == 2, "JSON must have MonthPresent and DayPresent as 2 characters at all times!");
        urlRebuiltJSON= string( abi.encodePacked("https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=",filterYear,
        "&refine.month=",filterMonth,"&refine.day=",filterDay,"&refine.country=",filterCountry) );
        // // Chainlink requests.
        // request_Latitude();
        // request_Longitude();
        // request_EruptionDate();
    }    
    
    function buyerCreatePolicy(int inputLat, int inputLong) public payable  {
        require(owner != msg.sender, "Error: Owner cannot self-insure"); // Policy purchaser must not be owner. 
        require(OpenWEItoInsure > 0, 'There is no open ETH in the contract currently.'); // Owner must have funds to cover policy purchase. Made >0 in case multiple policy purchases are made in the same contract for a given address (i.e owner will agree > 1 ETH).
        require(msg.value == policyFee , 'Error: Please submit your request with insurance contribution of 0.001 Ether'); // Policy purchaser must be sending their share of insurance contract amount.
        require(policies[msg.sender].ethereumAwardTiedToAddress == 0,"Error: You've already purchased insurance"); // Checks if requester has already bought insurance. 
        OpenWEItoInsure -= 1 ether;
        LockedWEItoPolicies += 1 ether;
        policies[msg.sender] = policy(
            inputLat,
            inputLong,
            block.timestamp,
            1
        );
        (bool sentOwner, ) = payable(owner).call{value: policyFee}("");
        if(sentOwner == false) revert EtherNotSent();   
        emit eventLog();
    }
    
    function buyerClaimReward() public {
        require(DayEruption > 0, "DayEruption not recorded yet by oracle.");
        require(MonthEruption > 0, "MonthEruption not recorded yet by oracle.");                                                                                                         
        require(YearEruption > 0, "YearEruption not recorded yet by oracle.");        
        require(LatitudeEruption != 0 || LongitudeEruption != 0, "Lat and Long cannot both be 0. Wait for oracle response.");
        require(policies[msg.sender].ethereumAwardTiedToAddress > 0,"Error: You don't have a policy"); // Checks if this address has a policy or not.
        uint256 signDateUnixTime = policies[msg.sender].unixTimeSigned;        
        (uint256 year, uint256 month, uint256 day) = BokkyPooBahsDateTimeLibrary.timestampToDate(signDateUnixTime);
        require(dateCompareForm(year, month, day) < dateCompareForm(YearEruption,MonthEruption,DayEruption) , "Policy was signed after eruption");
        require(policies[msg.sender].longitudeInsured >=  (LongitudeEruption-100) && policies[msg.sender].longitudeInsured <=  (LongitudeEruption+100) , "Must be within 1 long coordinate point." );
        require(policies[msg.sender].latitudeInsured >=  (LatitudeEruption-100) && policies[msg.sender].latitudeInsured <=  (LatitudeEruption+100) , "Must be within 1 lat coordinate point." );
        policies[msg.sender] = policy(0, 0, 0, 0);
        LockedWEItoPolicies -= 1 ether;
        payable(msg.sender).transfer(1 ether);
        LatitudeEruption = 0;
        LongitudeEruption = 0;
        YearEruption = 0;
        MonthEruption = 0;
        DayEruption = 0;
        emit eventLog();
    }
    
    function ownerSendOneEthToContractFromInsuranceBusiness() public payable onlyOwner {
        require(msg.value == 1 ether, "Value sent must equal 1 ETH");
        OpenWEItoInsure += 1 ether;
        emit eventLog();
    }

    function ownerClaimExpiredPolicyETH(address policyHolder) public onlyOwner { 
        require(policies[policyHolder].ethereumAwardTiedToAddress > 0, "Policy does not exist.");
        // 31,536,000 seconds in 1 year.
        require(block.timestamp > policies[msg.sender].unixTimeSigned + 31536000, "Policy not expired. Wait full year for expiration.");
        LockedWEItoPolicies -= 1 ether;
        policies[policyHolder] = policy(0, 0, 0, 0);
        payable(owner).transfer(address(this).balance);
        emit eventLog();
    }
    
    function ownerLiquidtoOpenETHToWithdraw() public onlyOwner {
        require(OpenWEItoInsure > 0, 'There is no open ETH in the contract currently.'); 
        OpenWEItoInsure -= 1 ether;
        // payable(owner).transfer(1 ether);
        (bool sentOwner, ) = payable(owner).call{value: 1 ether}("");
        if(sentOwner == false) revert EtherNotSent();   
        emit eventLog();
    }
    
    // function OwnerSelfDestructClaimETH() public onlyOwner {
    //     require(address(this).balance > (LockedWEItoPolicies+OpenWEItoInsure), 'No self destruct detected (address(this).balance == (AccountsInsured+OpenETHtoEnsure))'); 
    //     payable(owner).transfer((address(this).balance)-(LockedWEItoPolicies+OpenWEItoInsure));
    //     emit eventLog();
    // }

    // // Test with 86399 and 86400
    // // Remix IDE gas benchmark:
    // // execution cost	7980 gas
    // function testTimestampToDate(uint unixTimestamp) public pure returns (uint year, uint month, uint day) {
    //     (year, month, day) = BokkyPooBahsDateTimeLibrary.timestampToDate(unixTimestamp);
    // }

    // Chainlink requests.

    error notEnoughLinkForThreeRequests();
               
    // Chainlink Functions Logic

    using FunctionsRequest for FunctionsRequest.Request;

    // State variables to store the last request ID, response, and error
    bytes32 public s_lastRequestIdUnixTime;
    bytes public s_lastResponseUnixTime;
    bytes public s_lastErrorUnixTime;

    // State variable to store the returned character information
    // string public wtiPriceOracle; //Estimated value on request: 8476500000. Will get cross chain with Universal Adapter on Mumbai Polygon: https://etherscan.io/address/0xf3584f4dd3b467e73c2339efd008665a70a4185c#readContract latest price
    uint256 public unixTime; 
    int256 public lat;
    int256 public lon;

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
 
    string constant javascriptSourceCodeUnixTime = "";

    constructor() FunctionsClient(routerBaseSepolia) Owned(msg.sender) {}

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
        req.initializeRequestForInlineJavaScript(javascriptSourceCodeUnixTime); // Initialize the request with JS code
        if (args.length > 0) req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        s_lastRequestIdUnixTime = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donIDBaseSepolia
        );

        return s_lastRequestIdUnixTime;
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
        if (s_lastRequestIdUnixTime != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        s_lastResponseUnixTime = response;
        s_lastErrorUnixTime = err;

        unixTime = abi.decode(response, (uint256));

        if (response.length > 0) {
            (uint256 unixTimeOracle, int256 latOracle,int256 lonOracle) = abi.decode(response, (uint256, int256, int256));

            unixTime = unixTimeOracle;
            lat = latOracle;
            lon = lonOracle;

            emit DecodedResponse(
                requestId,
                unixTimeOracle,
                latOracle,
                lonOracle
            );
        }
    
        // Emit an event to log the response
        emit Response(requestId, response, err);
    }

}
