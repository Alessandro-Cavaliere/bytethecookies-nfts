// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import "../src/ByteTheCookiesNFTCollection.sol";
import {Vm} from "forge-std/Vm.sol";

contract MintByteTheCookiesNFT is Script {
    string public exampleImageUri = "exampleUri";
    address public player = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Base Account of Local Chain Anvil
    uint256 public constant MINT_PRICE = 0.001 ether;
    function run() external view {
        address mostRecentlyDeployedNFTContract = DevOpsTools.get_most_recent_deployment("ByteTheCookiesNFTCollection", block.chainid);
        ByteTheCookiesNFTCollection(payable(mostRecentlyDeployedNFTContract));
    }

    function mintNftOnContract(address ByteTheCookiesNFTAddress) public {
        vm.startBroadcast();
        vm.prank(player);
        vm.deal(player, MINT_PRICE);
        ByteTheCookiesNFTCollection(ByteTheCookiesNFTAddress).mintNft{value: MINT_PRICE}(exampleImageUri);
        vm.stopBroadcast();
    }
}

contract RetrieveTokenUri is Script {
    address public player = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Base Account of Local Chain Anvil
    function run() external {
        address mostRecentlyDeployedNFTContract = DevOpsTools.get_most_recent_deployment("ByteTheCookiesNFTCollection", block.chainid);
        ByteTheCookiesNFTCollection(payable(mostRecentlyDeployedNFTContract));
    }

}

contract BalanceOfOwner is Script {
    address public player = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Base Account of Local Chain Anvil
    function run() external {
        address mostRecentlyDeployedNFTContract = DevOpsTools.get_most_recent_deployment("ByteTheCookiesNFTCollection", block.chainid);
        ByteTheCookiesNFTCollection(payable(mostRecentlyDeployedNFTContract));
    }

    function getBalance() public view returns (uint256) {
        console.log("Balance of player: ", address(player).balance);
        return address(player).balance;
    }
}
