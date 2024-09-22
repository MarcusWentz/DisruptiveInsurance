// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "./interfaces/IERC20.sol";
import {IVolcanoInsurance} from "./interfaces/IVolcanoInsurance.sol";
// // For pricefeeds such as ETH/USD.
// import {AggregatorV3Interface} from "chainlink/v0.8/interfaces/AggregatorV3Interface.sol"; 
// For Any API requests.
import {ChainlinkClient,Chainlink} from "chainlink/v0.8/ChainlinkClient.sol"; 
import {Convert} from "./util/Convert.sol";
import {Owned} from "solmate/auth/Owned.sol";
// BokkyPooBahsDateTimeLibrary/=lib/BokkyPooBahsDateTimeLibrary/
import { BokkyPooBahsDateTimeLibrary } from "BokkyPooBahsDateTimeLibrary/contracts/BokkyPooBahsDateTimeLibrary.sol";

contract VolcanoInsurance is ChainlinkClient, Convert, IVolcanoInsurance , Owned {
        
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

    function OracleRequestVolcanoEruptionData(string memory filterYear, string memory filterMonth, string memory filterDay, string memory filterCountry) public {
        uint256 requestVolcanoDataLinkFee = IERC20(address(chainlinkTokenAddressSepolia)).balanceOf(address(this));
        require(requestVolcanoDataLinkFee >= 5*(10*16), "CONTRACT NEEDS 0.05 LINK TO DO THIS! PLEASE SEND LINK TO THIS CONTRACT!");
        require(bytes(filterMonth).length == 2 && bytes(filterDay).length == 2, "JSON must have MonthPresent and DayPresent as 2 characters at all times!");
        urlRebuiltJSON= string( abi.encodePacked("https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=",filterYear,
        "&refine.month=",filterMonth,"&refine.day=",filterDay,"&refine.country=",filterCountry) );
        // Chainlink requests.
        request_Latitude();
        request_Longitude();
        request_EruptionDate();
    }    
    
    function BuyerCreatePolicy(int inputLat, int inputLong) public payable  {
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
    
    function BuyerClaimReward() public {
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
    
    function OwnerSendOneEthToContractFromInsuranceBusiness() public payable onlyOwner {
        require(msg.value == 1 ether, "Value sent must equal 1 ETH");
        OpenWEItoInsure += 1 ether;
        emit eventLog();
    }

    function OwnerClaimExpiredPolicyETH(address policyHolder) public onlyOwner { 
        require(policies[policyHolder].ethereumAwardTiedToAddress > 0, "Policy does not exist.");
        // 31,536,000 seconds in 1 year.
        require(block.timestamp > policies[msg.sender].unixTimeSigned + 31536000, "Policy not expired. Wait full year for expiration.");
        LockedWEItoPolicies -= 1 ether;
        policies[policyHolder] = policy(0, 0, 0, 0);
        payable(owner).transfer(address(this).balance);
        emit eventLog();
    }
    
    function OwnerLiquidtoOpenETHToWithdraw() public onlyOwner {
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

    using Chainlink for Chainlink.Request;

    string public eruptionDate;
    int256 public lat;
    int256 public long;
 
    // immutable and constants
    
    uint256 public constant ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY) / 10; // 0.1 * 10**18 (0.1 LINK)

    // If this fails on Sepolia, try to debug with a local Sepolia Chainlink node.
    string  private constant jobIdGetInt256Sepolia ="fcf4140d696d44b687012232948bdd5d"; 
    string  private constant jobIdGetStringSepolia ="7d80a6386ef543a3abb52817f6707e3b"; 
    address private constant oracleSepolia = 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD; 

    string public constant jsonUrl = "https://userclub.opendatasoft.com/api/explore/v2.1/catalog/datasets/les-eruptions-volcaniques-dans-le-monde/records?limit=20&refine=country%3A%22Iceland%22&refine=date%3A%221727%2F08%2F03%22";

    constructor() Owned(msg.sender) {
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
