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

    uint256 public openWeiToInsure;
    uint256 public lockedWeiToPolicies;    // string public urlRebuiltJSON = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=1727&refine.month=08&refine.day=03&refine.country=Iceland";

    // string public urlRebuiltJSON = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=1727&refine.month=08&refine.day=03&refine.country=Iceland";
    string public constant URL_REBUILT_JSON = "https://userclub.opendatasoft.com/api/explore/v2.1/catalog/datasets/les-eruptions-volcaniques-dans-le-monde/records?limit=20&refine=country%3A%22Iceland%22&refine=date%3A%221727%2F08%2F03%22";
    // immutable and constants
    
    uint256 public constant INSURANCE_POLICY_FEE = (1 ether)/100;
    // address public constant chainlinkTokenAddressSepolia = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    struct policy {
        int256 latitudeInsured;
        int256 longitudeInsured;
        uint256 unixTimeSigned;
        uint256 ethereumAwardTiedToAddress;
    }
    
    mapping(address => policy) public policies;

    // function oracleRequestVolcanoEruptionData(string memory filterYear, string memory filterMonth, string memory filterDay, string memory filterCountry) public {
    //     uint256 requestVolcanoDataLinkFee = IERC20(address(chainlinkTokenAddressSepolia)).balanceOf(address(this));
    //     require(requestVolcanoDataLinkFee >= 3*(10*16), "CONTRACT NEEDS 0.03 LINK TO DO THIS! PLEASE SEND LINK TO THIS CONTRACT!");
    //     require(bytes(filterMonth).length == 2 && bytes(filterDay).length == 2, "JSON must have MonthPresent and DayPresent as 2 characters at all times!");
    //     urlRebuiltJSON= string( abi.encodePacked("https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=",filterYear,
    //     "&refine.month=",filterMonth,"&refine.day=",filterDay,"&refine.country=",filterCountry) );
    //     // // Chainlink requests.
    //     // request_Latitude();
    //     // request_Longitude();
    //     // request_EruptionDate();
    // }    
    
    function buyerCreatePolicy(int inputLat, int inputLong) public payable  {
        // Policy purchaser must not be owner. 
        if(owner == msg.sender) revert OwnerIsMsgSender(); 
        // Owner must have funds to cover policy purchase. Made >0 in case multiple policy purchases are made in the same contract for a given address (i.e owner will agree > 1 ETH).
        if(openWeiToInsure == 0) revert NotEnoughCollateralInContract(); 
        // Policy purchaser must be sending their share of insurance contract amount.
        if(msg.value != INSURANCE_POLICY_FEE) revert MsgValueTooSmallForPolicyBuy(); 
        // Checks if requester has already bought insurance. 
        if(policies[msg.sender].ethereumAwardTiedToAddress != 0) revert PolicyAlreadyBoughtUser(); 
        openWeiToInsure -= 1 ether;
        lockedWeiToPolicies += 1 ether;
        policies[msg.sender] = policy(
            inputLat,
            inputLong,
            block.timestamp,
            1
        );
        (bool sentOwner, ) = payable(owner).call{value: INSURANCE_POLICY_FEE}("");
        if(sentOwner == false) revert EtherNotSent();   
        emit eventLog();
    }
    
    function buyerClaimReward() public {
        if(volcanoEruptionUnixTime == 0) revert VolcanoTimeOracleDataNotSetYet();    
        if(volcanoEruptionLatitude == 0 && volcanoEruptionLongitude == 0) revert CoordinatesCannotBeTheOrigin();
        // Checks if this address has a policy or not.        
        if(policies[msg.sender].ethereumAwardTiedToAddress == 0) revert PolicyDoesNotExist(); 
        uint256 signDateUnixTime = policies[msg.sender].unixTimeSigned;        

        // (uint256 year, uint256 month, uint256 day) = BokkyPooBahsDateTimeLibrary.timestampToDate(signDateUnixTime);
        // require(dateCompareForm(year, month, day) < dateCompareForm(yearEruption,monthEruption,dayEruption) , "Policy was signed after eruption");

        if(signDateUnixTime > volcanoEruptionUnixTime) revert PolicySignedAfterEruption();

        // Must be within 1 latitude coordinate point.
        if(policies[msg.sender].latitudeInsured >= (volcanoEruptionLatitude - 100) 
           || 
           policies[msg.sender].latitudeInsured <=  (volcanoEruptionLatitude + 100) )  revert NotWithinOneLatitudePoint();
        // Must be within 1 longitude coordinate point.
        if(policies[msg.sender].longitudeInsured >= (volcanoEruptionLongitude - 100) 
           ||
           policies[msg.sender].longitudeInsured <=  (volcanoEruptionLongitude + 100) ) revert NotWithinOneLongitudePoint();
     
        policies[msg.sender] = policy(0, 0, 0, 0);
        lockedWeiToPolicies -= 1 ether;
        payable(msg.sender).transfer(1 ether);
        volcanoEruptionLatitude = 0;
        volcanoEruptionLongitude = 0;
        volcanoEruptionUnixTime = 0;
        emit eventLog();
    }
    
    function ownerSendOneEthToContractFromInsuranceBusiness() public payable onlyOwner {
        if(msg.value != 1 ether) revert MsgValueNotOneEther();
        openWeiToInsure += 1 ether;
        emit eventLog();
    }

    function ownerClaimExpiredPolicyETH(address policyHolder) public onlyOwner { 
        if(policies[policyHolder].ethereumAwardTiedToAddress == 0) revert PolicyDoesNotExist();
        // 31,536,000 seconds in 1 year.
        if(block.timestamp < policies[msg.sender].unixTimeSigned + 31536000) revert PolicyDidNotExpireYet();
        lockedWeiToPolicies -= 1 ether;
        policies[policyHolder] = policy(0, 0, 0, 0);
        payable(owner).transfer(address(this).balance);
        emit eventLog();
    }
    
    function ownerLiquidtoOpenETHToWithdraw() public onlyOwner {
        if(openWeiToInsure == 0) revert NotEnoughCollateralInContract(); 
        openWeiToInsure -= 1 ether;
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
    uint256 public volcanoEruptionUnixTime; 
    // lat and lon range signed is -180 to 180.
    // int16 is within this range:
    // https://mavlevin.com/2023/02/22/Size-Matters-Solidity-Integer-Range-Cheatsheet-From-uint8-To-uint256.html
    int16 public volcanoEruptionLatitude;
    int16 public volcanoEruptionLongitude;

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
 
    string constant javascriptSourceCode = "const { ethers } = await import('npm:ethers@6.10.0'); const apiResponse = await Functions.makeHttpRequest({url: `https://userclub.opendatasoft.com/api/explore/v2.1/catalog/datasets/les-eruptions-volcaniques-dans-le-monde/records?limit=20&refine=country%3A%22United%20States%22&refine=date%3A%221980%2F05%22`}); if (apiResponse.error) {console.error(apiResponse.error);throw Error('Request failed');} const { data } = apiResponse; console.log('API response data:'); const dateNow = data.results[0].date; console.log(dateNow); const timeUnix = Math.floor(new Date(dateNow).getTime() / 1000); console.log(timeUnix); const latRaw = data.results[0].coordinates.lat; console.log(latRaw); const latScaled = latRaw*100; console.log(latScaled); const lonRaw = data.results[0].coordinates.lon; console.log(lonRaw); const lonScaled = lonRaw*100; console.log(lonScaled); console.log('Ethers.js version: ', ethers.version); const abiCoder = ethers.AbiCoder.defaultAbiCoder(); const encodedAbiString = abiCoder.encode(['uint256', 'int16', 'int16'],[ 327456000 , 4620 , -12218 ]); console.log(encodedAbiString); console.log(ethers.getBytes(encodedAbiString)); return ethers.getBytes(encodedAbiString);";
    
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
        req.initializeRequestForInlineJavaScript(javascriptSourceCode); // Initialize the request with JS code
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

        if (response.length > 0) {
            (uint256 unixTimeOracle, int16 latOracle, int16 lonOracle) = abi.decode(response, (uint256, int16, int16));

            volcanoEruptionUnixTime = unixTimeOracle;
            volcanoEruptionLatitude = latOracle;
            volcanoEruptionLongitude = lonOracle;

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
