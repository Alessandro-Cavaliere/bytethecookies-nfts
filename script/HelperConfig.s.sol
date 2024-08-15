// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console2} from "forge-std/Script.sol";

abstract contract CodeConstants {
    address public FOUNDRY_DEFAULT_SENDER = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error HelperConfig__InvalidChainId();

    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/
    struct NetworkConfig {
        string name;
        string symbol;
        address owner;
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    // Local network state variables
    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
        networkConfigs[ETH_MAINNET_CHAIN_ID] = getMainnetEthConfig();
        // Note: We skip doing the local config
    }

    /// @notice Get the network configuration
    /// @dev Get the network configuration using the getConfigByChainId() function
    /// @return NetworkConfig - The network configuration
    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    /// @notice Set the network configuration
    /// @dev Set the network configuration using the mapping networkConfigs
    /// @param chainId The chain id 
    /// @param networkConfig The network configuration with type NetworkConfig
    function setConfig(uint256 chainId, NetworkConfig memory networkConfig) public {
        networkConfigs[chainId] = networkConfig;
    }

    /// @notice Get the network configuration by chain id
    /// @dev Get the network configuration by chain id using the mapping networkConfigs and check if the chain id is valid
    /// @param chainId The chain id
    /// @return NetworkConfig - The network configuration
    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if(chainId == ETH_MAINNET_CHAIN_ID) {
            return getMainnetEthConfig();
        }
        else if (chainId == ETH_SEPOLIA_CHAIN_ID) {
            return getSepoliaEthConfig();
        }
        else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    /// @notice Get the mainnet network configuration
    /// @dev Get the mainnet network configuration using the getMainnetEthConfig() function
    /// @return mainnetNetworkConfig - The mainnet network configuration
    function getMainnetEthConfig() public view returns (NetworkConfig memory mainnetNetworkConfig) {
        mainnetNetworkConfig = NetworkConfig({
            name: "ByteTheCookiesNFTCollection__Mainnet", 
            symbol: "BTC",
            owner: 0xCEA0C88efD9b1508275bf59aC5a9f0923013aB53
        });
    }

    /// @notice Get the Sepolia network configuration
    /// @dev Get the Sepolia network configuration using the getSepoliaEthConfig() function
    /// @return sepoliaNetworkConfig - The Sepolia network configuration
    function getSepoliaEthConfig() public view returns (NetworkConfig memory sepoliaNetworkConfig) {
        sepoliaNetworkConfig = NetworkConfig({
            name: "ByteTheCookiesNFTCollection__SepoliaTestnet", 
            symbol: "BTC",
            owner: 0xCEA0C88efD9b1508275bf59aC5a9f0923013aB53
        });
    }

    /// @notice Get or create the Anvil network configuration
    /// @dev Get or create the Anvil network configuration using the getOrCreateAnvilEthConfig() function
    /// @return mainnetNetworkConfig - The Anvil network configuration
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        localNetworkConfig = NetworkConfig({
            name: "ByteTheCookiesNFTCollection__AnvilLocalChain", 
            symbol: "BTC",
            owner: FOUNDRY_DEFAULT_SENDER
        });
        return localNetworkConfig;
    }
}