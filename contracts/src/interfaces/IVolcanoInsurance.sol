// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IVolcanoInsurance {
    
    // Custom Errors
    error PresentTimeNotSet();
    error EtherNotSent();
    // Turn require statements into custom errors to save gas.

    // Events
    event eventLog();

}