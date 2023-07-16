// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Escrow} from "../src/Escrow.sol";

contract DeployEscrow is Script {
    address private s_buyer = makeAddr("user");
    uint private immutable s_price = 1 ether;
    uint private immutable s_date = block.timestamp + 1 days;
    bool private immutable s_isGoodQuality = true;

    Escrow escrow;

    function run() public returns (Escrow) {
        vm.startBroadcast();
        escrow = new Escrow(
            s_buyer,
            msg.sender,
            s_price,
            s_date,
            s_isGoodQuality
        );
        vm.stopBroadcast();
        return escrow;
    }
}
