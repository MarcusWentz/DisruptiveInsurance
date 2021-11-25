// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Convert.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract VolcanoInsurance is ChainlinkClient {
    
    using Chainlink for Chainlink.Request;
    Convert public convert = new Convert();
    
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
    uint private immutable fee = 1*10**16;
    string public urlRebuiltJSON = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=1727&refine.month=08&refine.day=03&refine.country=Iceland";
    bytes32 private immutable jobIdGetInt ="e5b0e6aeab36405ba33aea12c6988ed6"; 
    bytes32 private immutable jobIdGetUint ="3b7ca0d48c7a4b2da9268456665d11ae";  
    bytes32 private immutable jobIdGetBytes32 = "187bb80e5ee74a139734cac7475f3c6e";
    address private immutable oracle = 0x3A56aE4a2831C3d3514b5D7Af5578E45eBDb7a40; 
    address public immutable Owner;
    address private ChainlinkTokenAddressRinkeby = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
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

    constructor() {
        Owner = msg.sender;
        setPublicChainlinkToken();
    }
    
    modifier contractOwnerCheck() {
        require(msg.sender == Owner, "Only contract owner can interact with this contract");
        _;
    }
    
    event recordMessageSender(
        address indexed from
    );
    
    function OracleRequestVolcanoEruptionData(string memory filterYear, string memory filterMonth, string memory filterDay, string memory filterCountry) public {
        require(tokenObject.balanceOf(address(this)) >= 5*(10*16), "CONTRACT NEEDS 0.05 LINK TO DO THIS! PLEASE SEND LINK TO THIS CONTRACT!");
        require(bytes(filterMonth).length == 2, "JSON must have MonthPresent as 2 characters at all times!");
        require(bytes(filterDay).length == 2, "JSON must have DayPresent as 2 characters at all times!");
        urlRebuiltJSON= string( abi.encodePacked("https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=",filterYear,
        "&refine.month=",filterMonth,"&refine.day=",filterDay,"&refine.country=",filterCountry) );
        request_Latitude();
        request_Longitude();
        request_Year_Eruption();
        request_Month_Eruption();
        request_Day_Eruption();
    }    
    
    function OracleRequestPresentTime() public {
        require(tokenObject.balanceOf(address(this)) >= 3*(10*16), "CONTRACT NEEDS 0.03 LINK TO DO THIS! PLEASE SEND LINK TO THIS CONTRACT!!");
        request_YearPresent();
        request_MonthPresent();
        request_DayPresent();
    }
    
    function BuyerCreatePolicy(int inputLat, int inputLong) public payable {
        require(DayPresent > 0, "DayPresent not recorded yet by oracle.");
        require(MonthPresent > 0, "MonthPresent not recorded yet by oracle.");
        require(YearPresent > 0, "YearPresent not recorded yet by oracle.");
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
        emit recordMessageSender(msg.sender);
    }

    function BuyerClaimReward() public {
        require(DayEruption > 0, "DayEruption not recorded yet by oracle.");
        require(MonthEruption > 0, "MonthEruption not recorded yet by oracle.");
        require(YearEruption > 0, "YearEruption not recorded yet by oracle.");
        require(LatitudeEruption != 0 || LongitudeEruption != 0, "Lat and Long cannot both be 0. Wait for oracle response.");
        require(policies[msg.sender].EthereumAwardTiedToAddress > 0,"Error: You don't have a policy"); // Checks if this address has a policy or not.
        require(convert.DateCompareForm(policies[msg.sender].YearSigned,policies[msg.sender].MonthSigned,policies[msg.sender].DaySigned) < convert.DateCompareForm(YearEruption,MonthEruption,DayEruption) , "Policy was signed after eruption");
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
        emit recordMessageSender(msg.sender);
    }
    
    function OwnerSendOneEthToContractFromInsuranceBusiness() public payable contractOwnerCheck {
        require(msg.value == 1*(10**18), "Value sent must equal 1 ETH");
        OpenWEItoInsure += 1*(10**18);
        emit recordMessageSender(msg.sender);
    }

    function OwnerClaimExpiredPolicyETH(address policyHolder) public contractOwnerCheck { 
        require(DayPresent > 0, "DayPresent not recorded yet by oracle.");
        require(MonthPresent > 0, "MonthPresent not recorded yet by oracle.");
        require(YearPresent > 0, "YearPresent not recorded yet by oracle.");
        require(policies[policyHolder].EthereumAwardTiedToAddress > 0, "Policy does not exist.");
        require(convert.DateCompareForm(YearPresent,MonthPresent,DayPresent) > (convert.DateCompareForm(policies[policyHolder].YearSigned,policies[policyHolder].MonthSigned,policies[policyHolder].DaySigned) + 512) , "Policy has not yet expired");
        LockedWEItoPolicies -=(1*(10**18));
        policies[policyHolder] = policy(0, 0, 0, 0, 0, 0);
        payable(msg.sender).transfer(address(this).balance);
        DayPresent = 0;
        MonthPresent = 0;
        YearPresent = 0;
        emit recordMessageSender(msg.sender);
    }
    
    function OwnerLiquidtoOpenETHToWithdraw() public contractOwnerCheck {
        require(OpenWEItoInsure > 0, 'There is no open ETH in the contract currently.'); 
        OpenWEItoInsure -= (1*(10**18));
        payable(msg.sender).transfer(1*(10**18));
        emit recordMessageSender(msg.sender);
    }
    
    function OwnerSelfDestructClaimETH() public contractOwnerCheck {
        require(address(this).balance > (LockedWEItoPolicies+OpenWEItoInsure), 'No self destruct detected (address(this).balance == (AccountsInsured+OpenETHtoEnsure))'); 
        payable(msg.sender).transfer((address(this).balance)-(LockedWEItoPolicies+OpenWEItoInsure));
    }
    
    function request_Latitude() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobIdGetInt, address(this), this.fulfill_request_Latitude.selector);
        request.add("get", urlRebuiltJSON);
        request.add("path", "records.0.fields.coordinates.0");
        request.addInt("times", 10**2);
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Latitude(bytes32 _requestId, int oracleLatitudeEruption) public recordChainlinkFulfillment(_requestId){
        LatitudeEruption = oracleLatitudeEruption;
    }
    
    function request_Longitude() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobIdGetInt, address(this), this.fulfill_request_Longitude.selector);
        request.add("get", urlRebuiltJSON);
        request.add("path", "records.0.fields.coordinates.1");
        request.addInt("times", 10**2);
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Longitude(bytes32 _requestId, int oracleLongitudeEruption) public recordChainlinkFulfillment(_requestId)
    {
        LongitudeEruption = oracleLongitudeEruption;
    }
    
    function request_Year_Eruption() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobIdGetUint, address(this), this.fulfill_request_Year_Eruption.selector);
        request.add("get", urlRebuiltJSON);
        request.add("path", "records.0.fields.year");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Year_Eruption(bytes32 _requestId, uint oracleYearEruption) public recordChainlinkFulfillment(_requestId)
    {
        YearEruption = oracleYearEruption;
    }
    
    function request_Month_Eruption() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobIdGetBytes32, address(this), this.fulfill_request_Month_Eruption.selector);
        request.add("get", urlRebuiltJSON);
        request.add("path", "records.0.fields.month");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Month_Eruption(bytes32 _requestId, bytes32 oracleMonthEruption) public recordChainlinkFulfillment(_requestId)
    {
        MonthEruption = convert.bytes32ToUint(oracleMonthEruption);
    }
    
    function request_Day_Eruption() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobIdGetBytes32, address(this), this.fulfill_request_Day_Eruption.selector);
        request.add("get", urlRebuiltJSON);
        request.add("path", "records.0.fields.day");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_Day_Eruption(bytes32 _requestId, bytes32 oracleDayEruption) public recordChainlinkFulfillment(_requestId)
    {
        DayEruption = convert.bytes32ToUint(oracleDayEruption);
        emit recordMessageSender(msg.sender);
    }
    
    function request_YearPresent() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobIdGetUint, address(this), this.fulfill_request_YearPresent.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.add("path", "year");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_YearPresent(bytes32 _requestId,uint oracleYearPresent) public recordChainlinkFulfillment(_requestId) {
        YearPresent = oracleYearPresent;
    }
    
    function request_MonthPresent() private returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobIdGetUint, address(this), this.fulfill_request_MonthPresent.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.add("path", "month");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_MonthPresent(bytes32 _requestId,uint oracleMonthPresent) public recordChainlinkFulfillment(_requestId) {
        MonthPresent = oracleMonthPresent; 
    }
    
    function request_DayPresent() private returns (bytes32 requestId)  {
        Chainlink.Request memory request = buildChainlinkRequest(jobIdGetUint, address(this), this.fulfill_request_DayPresent.selector);
        request.add("get", "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam");
        request.add("path", "day");
        return sendChainlinkRequestTo(oracle, request, fee);
    }
    function fulfill_request_DayPresent(bytes32 _requestId,uint oracleDayPresent) public recordChainlinkFulfillment(_requestId) {
        DayPresent = oracleDayPresent; 
        emit recordMessageSender(msg.sender);
    }
    
 }
