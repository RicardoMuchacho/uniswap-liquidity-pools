// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import "../src/Swap.sol";

contract SwapAppScript is Script {
    address constant arbRouter2 = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    function run () external returns (SwapApp){
        uint256 privKey = vm.envUint("PRIVATE_KEY");
        string memory rpcUrl = vm.rpcUrl("arbitrum");
        vm.startBroadcast(privKey);

        SwapApp app = new SwapApp(arbRouter2);

        vm.stopBroadcast();

        return app;
    }
}