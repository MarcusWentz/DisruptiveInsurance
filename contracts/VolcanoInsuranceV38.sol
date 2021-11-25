// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./OracleVolcanoAndTime.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Convert.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract VolcanoInsurance {
    
    OracleVolcanoAndTime public oracleVolcanoAndTime = new OracleVolcanoAndTime();
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
    address public immutable Owner;
    string public urlRebuiltJSON = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=1727&refine.month=08&refine.day=03&refine.country=Iceland";
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
    }
    
    modifier contractOwnerCheck() {
        require(msg.sender == Owner, "Only contract owner can interact with this contract");
        _;
    }
    
    event recordMessageSender(
        address indexed from
    );
    
    function OracleRequestVolcanoEruptionData(string memory filterYear, string memory filterMonth, string memory filterDay, string memory filterCountry) public {
        require(bytes(filterMonth).length == 2, "JSON must have MonthPresent as 2 characters at all times!");
        require(bytes(filterDay).length == 2, "JSON must have DayPresent as 2 characters at all times!");
        urlRebuiltJSON= string( abi.encodePacked("https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=",filterYear,
        "&refine.month=",filterMonth,"&refine.day=",filterDay,"&refine.country=",filterCountry) );
        oracleVolcanoAndTime.request_Latitude(urlRebuiltJSON);
        oracleVolcanoAndTime.request_Longitude(urlRebuiltJSON);
        oracleVolcanoAndTime.request_Year_Eruption(urlRebuiltJSON);
        oracleVolcanoAndTime.request_Month_Eruption(urlRebuiltJSON);
        oracleVolcanoAndTime.request_Day_Eruption(urlRebuiltJSON);
    }   
    
    function OracleRequestPresentTime() public {
        LatitudeEruption = oracleVolcanoAndTime.LatitudeEruption();
        // require(tokenObject.balanceOf(address(this)) >= 3*(10*16), "CONTRACT NEEDS 0.03 LINK TO DO THIS! PLEASE SEND LINK TO THIS CONTRACT!!");
        // oracleVolcanoAndTime.request_YearPresent();
        // oracleVolcanoAndTime.request_MonthPresent();
        // oracleVolcanoAndTime.request_DayPresent();
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
        emit recordMessageSender(Owner);
    }

    function OwnerClaimExpiredPolicyETH(address policyHolder) public contractOwnerCheck { 
        require(DayPresent > 0, "DayPresent not recorded yet by oracle.");
        require(MonthPresent > 0, "MonthPresent not recorded yet by oracle.");
        require(YearPresent > 0, "YearPresent not recorded yet by oracle.");
        require(policies[policyHolder].EthereumAwardTiedToAddress > 0, "Policy does not exist.");
        require(convert.DateCompareForm(YearPresent,MonthPresent,DayPresent) > (convert.DateCompareForm(policies[policyHolder].YearSigned,policies[policyHolder].MonthSigned,policies[policyHolder].DaySigned) + 512) , "Policy has not yet expired");
        LockedWEItoPolicies -=(1*(10**18));
        policies[policyHolder] = policy(0, 0, 0, 0, 0, 0);
        payable(Owner).transfer(address(this).balance);
        DayPresent = 0;
        MonthPresent = 0;
        YearPresent = 0;
        emit recordMessageSender(Owner);
    }
    
    function OwnerLiquidtoOpenETHToWithdraw() public contractOwnerCheck {
        require(OpenWEItoInsure > 0, 'There is no open ETH in the contract currently.'); 
        OpenWEItoInsure -= (1*(10**18));
        payable(Owner).transfer(1*(10**18));
        emit recordMessageSender(Owner);
    }
    
    function OwnerSelfDestructClaimETH() public contractOwnerCheck {
        require(address(this).balance > (LockedWEItoPolicies+OpenWEItoInsure), 'No self destruct detected (address(this).balance == (AccountsInsured+OpenETHtoEnsure))'); 
        payable(Owner).transfer((address(this).balance)-(LockedWEItoPolicies+OpenWEItoInsure));
        emit recordMessageSender(Owner);
    }
    
 }
