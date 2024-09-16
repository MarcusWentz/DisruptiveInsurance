// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// // For pricefeeds such as ETH/USD.
// import {AggregatorV3Interface} from "chainlink/v0.8/interfaces/AggregatorV3Interface.sol"; 
// For Any API requests.
import {ChainlinkClient,Chainlink} from "chainlink/v0.8/ChainlinkClient.sol"; 
import {Convert} from "./Convert.sol";

// import {Owned} from "solmate/auth/Owned.sol";
// import {ERC20} from "solmate/tokens/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract VolcanoInsurance is ChainlinkClient, Convert {
        
    // variables

    int public LatitudeEruption; 
    int public LongitudeEruption;
    uint public YearEruption;
    uint public MonthEruption;
    uint public DayEruption;
    uint public YearPresent;
    uint public MonthPresent;
    uint public DayPresent;
    uint public OpenWEItoInsure;
    uint public LockedWEItoPolicies;
    string public urlRebuiltJSON = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=1727&refine.month=08&refine.day=03&refine.country=Iceland";
 
    // immutable and constants
    
    uint public immutable fee = 1*10**16;
    bytes32 private immutable jobIdGetInt256 ="fcf4140d696d44b687012232948bdd5d"; 
    bytes32 private immutable jobIdGetUint256 ="ca98366cc7314957b8c012c72f05aeeb";  
    bytes32 private immutable jobIdGetBytes32 = "7da2702f37fd48e5b1b9a5715e3509b6";
    address private immutable oracle = 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD; 
    address public immutable Owner;
    address private ChainlinkTokenAddressRinkeby = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    ERC20TokenContract tokenObject = ERC20TokenContract(ChainlinkTokenAddressRinkeby);
    
    struct policy {
        int LatitudeInsured;
        int LongitudeInsured;
        uint YearSigned;
        uint MonthSigned;
        uint DaySigned;
        uint EthereumAwardTiedToAddress;
    }
    
    mapping(address => policy) public policies;

    using Chainlink for Chainlink.Request;

    constructor() {
        Owner = msg.sender;
        _setPublicChainlinkToken();
    }
    
    modifier contractOwnerCheck() {
        require(msg.sender == Owner, "Only contract owner can interact with this contract");
        _;
    }

    modifier presentTImeCheck() {
        require((DayPresent*MonthPresent*YearPresent) > 0 , "Present time not recorded yet by oracle.");
        _;
    }

    event eventBlockTime(
        uint indexed date
    );
    
    function OracleRequestVolcanoEruptionData(string memory filterYear, string memory filterMonth, string memory filterDay, string memory filterCountry) public {
        require(tokenObject.balanceOf(address(this)) >= 5*(10*16), "CONTRACT NEEDS 0.05 LINK TO DO THIS! PLEASE SEND LINK TO THIS CONTRACT!");
        require(bytes(filterMonth).length == 2 && bytes(filterDay).length == 2, "JSON must have MonthPresent and DayPresent as 2 characters at all times!");
        urlRebuiltJSON= string( abi.encodePacked("https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=",filterYear,
        "&refine.month=",filterMonth,"&refine.day=",filterDay,"&refine.country=",filterCountry) );
        // Chainlink requests.
        request_Latitude();
        request_Longitude();
        request_Year_Eruption();
        request_Month_Eruption();
        request_Day_Eruption();
    }    
    
    function OracleRequestPresentTime() public {
        require(tokenObject.balanceOf(address(this)) >= 3*(10*16), "CONTRACT NEEDS 0.03 LINK TO DO THIS! PLEASE SEND LINK TO THIS CONTRACT!!");
        // Chainlink requests.
        request_YearPresent();
        request_MonthPresent();
        request_DayPresent();
    }
    
    function BuyerCreatePolicy(int inputLat, int inputLong) public payable presentTImeCheck  {
        require(Owner != msg.sender, "Error: Owner cannot self-insure"); // Policy purchaser must not be owner. 
        require(OpenWEItoInsure > 0, 'There is no open ETH in the contract currently.'); // Owner must have funds to cover policy purchase. Made >0 in case multiple policy purchases are made in the same contract for a given address (i.e owner will agree > 1 ETH).
        require(msg.value == (1*10**16), 'Error: Please submit your request with insurance contribution of 0.001 Ether'); // Policy purchaser must be sending their share of insurance contract amount.
        require(policies[msg.sender].EthereumAwardTiedToAddress == 0,"Error: You've already purchased insurance"); // Checks if requester has already bought insurance. 
        OpenWEItoInsure -= (1*(10**18));
        LockedWEItoPolicies += (1*(10**18));
        policies[msg.sender] = policy(inputLat, inputLong,YearPresent,MonthPresent,DayPresent,1);
        payable(Owner).transfer(1*10**16);
        DayPresent = 0;
        MonthPresent = 0;
        YearPresent = 0;
        emit eventBlockTime(block.timestamp);
    }
    
    function BuyerClaimReward() public {
        require(DayEruption > 0, "DayEruption not recorded yet by oracle.");
        require(MonthEruption > 0, "MonthEruption not recorded yet by oracle.");                                                                                                         
        require(YearEruption > 0, "YearEruption not recorded yet by oracle.");        
        require(LatitudeEruption != 0 || LongitudeEruption != 0, "Lat and Long cannot both be 0. Wait for oracle response.");
        require(policies[msg.sender].EthereumAwardTiedToAddress > 0,"Error: You don't have a policy"); // Checks if this address has a policy or not.
        require(dateCompareForm(policies[msg.sender].YearSigned,policies[msg.sender].MonthSigned,policies[msg.sender].DaySigned) < dateCompareForm(YearEruption,MonthEruption,DayEruption) , "Policy was signed after eruption");
        require(policies[msg.sender].LongitudeInsured >=  (LongitudeEruption-100) && policies[msg.sender].LongitudeInsured <=  (LongitudeEruption+100) , "Must be within 1 long coordinate point." );
        require(policies[msg.sender].LatitudeInsured >=  (LatitudeEruption-100) && policies[msg.sender].LatitudeInsured <=  (LatitudeEruption+100) , "Must be within 1 lat coordinate point." );
        policies[msg.sender] = policy(0, 0, 0, 0, 0, 0);
        LockedWEItoPolicies -=(1*(10**18));
        payable(msg.sender).transfer(1*(10**18));
        LatitudeEruption = 0;
        LongitudeEruption = 0;
        YearEruption = 0;
        MonthEruption = 0;
        DayEruption = 0;
        emit eventBlockTime(block.timestamp);
    }
    
    function OwnerSendOneEthToContractFromInsuranceBusiness() public payable contractOwnerCheck {
        require(msg.value == 1*(10**18), "Value sent must equal 1 ETH");
        OpenWEItoInsure += 1*(10**18);
        emit eventBlockTime(block.timestamp);
    }

    function OwnerClaimExpiredPolicyETH(address policyHolder) public contractOwnerCheck presentTImeCheck { 
        require(policies[policyHolder].EthereumAwardTiedToAddress > 0, "Policy does not exist.");
        require(dateCompareForm(YearPresent,MonthPresent,DayPresent) > (dateCompareForm(policies[policyHolder].YearSigned,policies[policyHolder].MonthSigned,policies[policyHolder].DaySigned) + 512) , "Policy has not yet expired");
        LockedWEItoPolicies -=(1*(10**18));
        policies[policyHolder] = policy(0, 0, 0, 0, 0, 0);
        payable(Owner).transfer(address(this).balance);
        DayPresent = 0;
        MonthPresent = 0;
        YearPresent = 0;
        emit eventBlockTime(block.timestamp);
    }
    
    function OwnerLiquidtoOpenETHToWithdraw() public contractOwnerCheck {
        require(OpenWEItoInsure > 0, 'There is no open ETH in the contract currently.'); 
        OpenWEItoInsure -= (1*(10**18));
        payable(Owner).transfer(1*(10**18));
        emit eventBlockTime(block.timestamp);
    }
    
    function OwnerSelfDestructClaimETH() public contractOwnerCheck {
        require(address(this).balance > (LockedWEItoPolicies+OpenWEItoInsure), 'No self destruct detected (address(this).balance == (AccountsInsured+OpenETHtoEnsure))'); 
        payable(Owner).transfer((address(this).balance)-(LockedWEItoPolicies+OpenWEItoInsure));
        emit eventBlockTime(block.timestamp);
    }
    
    
    // Chainlink requests.

    function request_Latitude() private returns (bytes32 requestId) {
        Chainlink.Request memory request = _buildChainlinkRequest(jobIdGetInt256, address(this), this.fulfill_request_Latitude.selector);
        request._add("get", urlRebuiltJSON);
        request._add("path", "records.0.fields.coordinates.0");
        request._addInt("times", 10**2);
        return _sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Latitude(bytes32 _requestId, int oracleLatitudeEruption) public recordChainlinkFulfillment(_requestId){
        LatitudeEruption = oracleLatitudeEruption;
    }
    
    function request_Longitude() private returns (bytes32 requestId) {
        Chainlink.Request memory request = _buildChainlinkRequest(jobIdGetInt256, address(this), this.fulfill_request_Longitude.selector);
        request._add("get", urlRebuiltJSON);
        request._add("path", "records.0.fields.coordinates.1");
        request._addInt("times", 10**2);
        return _sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Longitude(bytes32 _requestId, int oracleLongitudeEruption) public recordChainlinkFulfillment(_requestId)
    {
        LongitudeEruption = oracleLongitudeEruption;
    }
    
    function request_Year_Eruption() private returns (bytes32 requestId) {
        Chainlink.Request memory request = _buildChainlinkRequest(jobIdGetUint256, address(this), this.fulfill_request_Year_Eruption.selector);
        request._add("get", urlRebuiltJSON);
        request._add("path", "records.0.fields.year");
        return _sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Year_Eruption(bytes32 _requestId, uint oracleYearEruption) public recordChainlinkFulfillment(_requestId)
    {
        YearEruption = oracleYearEruption;
    }
    
    function request_Month_Eruption() private returns (bytes32 requestId) {
        Chainlink.Request memory request = _buildChainlinkRequest(jobIdGetBytes32, address(this), this.fulfill_request_Month_Eruption.selector);
        request._add("get", urlRebuiltJSON);
        request._add("path", "records.0.fields.month");
        return _sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Month_Eruption(bytes32 _requestId, bytes32 oracleMonthEruption) public recordChainlinkFulfillment(_requestId)
    {
        MonthEruption = bytes32ToUint(oracleMonthEruption);
    }
    
    function request_Day_Eruption() private returns (bytes32 requestId) {
        Chainlink.Request memory request = _buildChainlinkRequest(jobIdGetBytes32, address(this), this.fulfill_request_Day_Eruption.selector);
        request._add("get", urlRebuiltJSON);
        request._add("path", "records.0.fields.day");
        return _sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Day_Eruption(bytes32 _requestId, bytes32 oracleDayEruption) public recordChainlinkFulfillment(_requestId)
    {
        DayEruption = bytes32ToUint(oracleDayEruption);
        emit eventBlockTime(block.timestamp);
    }
    
    function request_YearPresent() private returns (bytes32 requestId) {
        Chainlink.Request memory request = _buildChainlinkRequest(jobIdGetUint256, address(this), this.fulfill_request_YearPresent.selector);
        request._add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request._add("path", "year");
        return _sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_YearPresent(bytes32 _requestId,uint oracleYearPresent) public recordChainlinkFulfillment(_requestId) {
        YearPresent = oracleYearPresent;
    }
    
    function request_MonthPresent() private returns (bytes32 requestId) {
        Chainlink.Request memory request = _buildChainlinkRequest(jobIdGetUint256, address(this), this.fulfill_request_MonthPresent.selector);
        request._add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request._add("path", "month");
        return _sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_MonthPresent(bytes32 _requestId,uint oracleMonthPresent) public recordChainlinkFulfillment(_requestId) {
        MonthPresent = oracleMonthPresent; 
    }
    
    function request_DayPresent() private returns (bytes32 requestId)  {
        Chainlink.Request memory request = _buildChainlinkRequest(jobIdGetUint256, address(this), this.fulfill_request_DayPresent.selector);
        request._add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request._add("path", "day");
        return _sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_DayPresent(bytes32 _requestId,uint oracleDayPresent) public recordChainlinkFulfillment(_requestId) {
        DayPresent = oracleDayPresent; 
        emit eventBlockTime(block.timestamp);
    }
    
 }
