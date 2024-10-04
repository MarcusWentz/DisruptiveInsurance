// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Example modified from:
// https://solidity-by-example.org/abi-decode/

contract abiEncodeDecodeHexSting {

    function encode(uint256 unixTime, int256 lat, int256 lon) external pure returns (bytes memory) {
        return abi.encode(unixTime, lat, lon);
    }

    function decode(bytes calldata data) external pure returns ( uint256 unixTime, int256 lat, int256 lon) {
        (unixTime, lat, lon) = abi.decode(data, (uint256, int256, int256));
    }
}
