// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IVolcanoInsurance {
    
    // Custom Errors
    error PresentTimeNotSet();
    error EtherNotSent();
    error UnexpectedRequestID(bytes32 requestId);
    // Turn require statements into custom errors to save gas.

    // Events
    event eventLog();
    event ResponseUint256(
        bytes32 indexed requestId,
        uint256 value,
        bytes response,
        bytes err
    );
    event ResponseInt256(
        bytes32 indexed requestId,
        int256 value,
        bytes response,
        bytes err
    );

}