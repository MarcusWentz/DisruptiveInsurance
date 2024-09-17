// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// npm i @quant-finance/solidity-datetime
// import "@quant-finance/solidity-datetime";

// import { BokkyPooBahsDateTimeLibrary as LibDateTime } from "BokkyPooBahsDateTimeLibrary/contracts/BokkyPooBahsDateTimeLibrary.sol";

// import "BokkyPooBahsDateTimeLibrary/contracts/BokkyPooBahsDateTimeLibrary.sol";
// import "https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/master/contracts/BokkyPooBahsDateTimeLibrary.sol";

// import { BokkyPooBahsDateTimeLibrary } from "https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/master/contracts/BokkyPooBahsDateTimeLibrary.sol";

// // Works in Remix IDE.
// import { BokkyPooBahsDateTimeLibrary } from "https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary/blob/master/contracts/BokkyPooBahsDateTimeLibrary.sol";
// Works in Foundry.
// Note the remappings.txt file has the following path for BokkyPooBahsDateTimeLibrary:
// BokkyPooBahsDateTimeLibrary/=lib/BokkyPooBahsDateTimeLibrary/
import { BokkyPooBahsDateTimeLibrary } from "BokkyPooBahsDateTimeLibrary/contracts/BokkyPooBahsDateTimeLibrary.sol";

contract testTimeOnChain {

    // Test with 86399 and 86400
    // Remix IDE gas benchmark:
    // execution cost	7980 gas
    function testTimestampToDate(uint unixTimestamp) public pure returns (uint year, uint month, uint day) {
        (year, month, day) = BokkyPooBahsDateTimeLibrary.timestampToDate(unixTimestamp);
    }

    // Test with 86399 and 86400
    // Remix IDE gas benchmark:
    // execution cost	9291 gas
    function testTimestampToDateTime(uint unixTimestamp) public pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day, hour, minute, second) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(unixTimestamp);
    }

}
