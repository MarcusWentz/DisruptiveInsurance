// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IVolcanoInsurance {
    
    // Custom Errors
    error PresentTimeNotSet();
    error OwnerIsMsgSender(); 
    error EtherNotSent();
    error NotEnoughCollateralInContract();
    error MsgValueTooSmallForPolicyBuy();
    error MsgValueDoesNotMatchInputCollateral();
    error PolicyAlreadyBoughtUser();
    error PolicyDoesNotExist();
    error PolicyDidNotExpireYet();
    error PolicySignedAfterEruption();
    error VolcanoTimeOracleDataNotSetYet();
    error CoordinatesCannotBeTheOrigin();
    error LatitudeLessThanMin(); 
    error LatitudeGreaterThanMax();        
    error LongitudeLessThanMin();
    error LongitudeGreaterThanMax();
    error UnexpectedRequestID(bytes32 requestId);
    // Turn require statements into custom errors to save gas.

    // Events
    event eventLog();
    event DecodedResponse(
        bytes32 indexed requestId,
        uint256 unixTimeOracle,
        int256 latOracle,
        int256 lonOracle
    );
    event Response(bytes32 indexed requestId, bytes response, bytes err);
}