// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {ByteTheCookiesNFTCollection} from "../src/ByteTheCookiesNFTCollection.sol";

contract DeployByteTheCookiesNFT is Script {
    /*//////////////////////////////////////////////////////////////
                             STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    address public player = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Base Account of Local Chain Anvil

    /// @notice Deploy the ByteTheCookiesNFTCollection contract
    /// @dev Deploy the ByteTheCookiesNFTCollection contract with the network configuration
    /// @return ByteTheCookiesNFTCollection The deployed ByteTheCookiesNFTCollection contract
    function run() external returns (ByteTheCookiesNFTCollection, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        vm.startBroadcast();
        console.log("Deploying ByteTheCookiesNFTCollection contract with name: ", config.name);
        ByteTheCookiesNFTCollection nftContract =
            new ByteTheCookiesNFTCollection(config.name, config.symbol, config.owner);
        vm.stopBroadcast();
        return (nftContract, helperConfig);
    }
}
