// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import "../src/ByteTheCookiesNFTCollection.sol";
import {Vm} from "forge-std/Vm.sol";

contract MintByteTheCookiesNFT is Script {
    string public exampleImageUri = "application/json;base64,ewogICAgInRva2VuSUQiOiAxMDE4LAogICAgIm5hbWUiOiAibGFuZGlsdWlnaTc0NiIsCiAgICAiZGVzY3JpcHRpb24iOiAiSWwgcGlcdTAwZjkgZ2lvdmFuZSBkZWwgdGVhbTogdHJhIHVuIGdpb2NvIGluIEMrKyBlIGxcdTIwMTlhbHRybyBzbW9udGEgYmluYXJpIGNvbWUgZm9zc2VybyBMZWdvLiBTcGVjaWFsaXp6YXRvIGluIHJldiBlIHB3biwgcHJvbnRvIGEgc2VnZmF1bHRhcmUgcXVhbHVucXVlIGNoYWxsZW5nZSBvc2kgYXZ2aWNpbmFyc2kuIiwKICAgICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFVrbEdScndIQUFCWFJVSlFWbEE0V0FvQUFBQVFBQUFBZndBQWZ3QUFRVXhRU0V3QUFBQUJSMEFtYmVQZjhPaTEySWlJWVBLQ2d0aTJJYi9CL3hsSXNCWFlFdEJCQTZPQjhEZUFpUDVQd0IwZHZkNzJDUjFQRVVQckRPTFFXak90ZmVCOC93VmFMV0pvbmRzbmREeDNkUFI2VmxBNElFb0hBQUF3S1FDZEFTcUFBSUFBUHBFK21rZWxvNmloTHBXTE1SQVNDVUFZZEk1U3lEcVIwV2JQaXA1eHhZVGl2dGhrSlpqRCtBdlJlczROQ2JrNGQraHM0eWdIMFczMFVQajdJZzRDOE1JTmYzamVBWUdOMGdNUHRQaHJNeU1OdC9LcXoxeDh0TCs5ajB3dHI2bmxYY0Y2QVM0UkJ0N244ZEh1ZWJSUzQ3R3JWcTluUDA1VXQ0a3ZhUzdMNklTZzM4VSs1anN4YWViT2RrV0EwYmdjVVF4VmczT1ZzZlVuQjdjbm1LU2o5YmVaOFUrUTJGbkpEVG45NUdSOGVrNGdLZVVNbHA1Vm5MeFN4S09WM3ZDeHpIMjBJYzQ2bUVKQVBrZm1BdVdoWkJPQk1BQk1idnNRaXhDM3FvY1dXRS8rUGs3YXlSSUk0dkdSOTIyajdHWlBQejhxQkI3QVJlSmtIR1VtU1A2bzFodlNmL0kzQit0Y2NCSExKY2dhdmY1WWxLNElYbnN5RFhpUmFGOVZLRWxoN0ZyWEpjWG1NbDlCREdmZHdHM0d1Y09LZXh2VmwyUWVnV0dQdDNoMUlRM2ZVQUFscis1NjRBRCsrVzkySkNPeVUzSVJ2UVNrekpIeWZKNXpMOTdxRjJJdWJxaW1UdHlsVUtyc1BIVTB3VlFwbEVZSlFRNTJNdjNmRnNxQUJySjNhVllSV2pUbXV5TW5GOFFvbmxTV3BCSUhDZEpTeDJ2eXZ1bDhYRUZOY0dmam5lNjVuY2pSSUFKaEJlY3lhc2M4SGdueVNBNTMyNEl4K3dydmRkOGVIb0txSVg4YTlaQTVvUUhBbVgrYVdrTUJhc29xL2MyYjdCb1hHS1BvTW1ReFZISEsvT2xOM0FQcUkrdGRtMk1aQlBhM25DUWxSUk4rYkEzenhvbEdkd0hsR3M3ellmRmp2WldqczBkOHpWSXdRdVBrVG9zMExyZkI5eDg1Uk9kMDdGNVFid1lEMUtyeGY3WkNCSFJuRHdnWGJiSVJiSDBqb3E2QWs0cE9oQ0xjOU9acTVJb2xUOHlQRXdKRFg5Z1g2NTgrUnAwemZ1SUNoNDl2TkE2Nit1N0c0cDJFNWhlQ3BYREZYUHN6UDkzdGdJeVMwaTNBSHU2N21KS0srSkkwVWhBaitoMDNhdWE1RUJtVnI2U2dJcS9kQ0Zxa0JESDN3dzhnUXUwUjgrajIvMEdyR2ZTMlE2aGZuUlRCYTdDRXZiV1NSSVBXOGNreEpaTHAzMUlNNFArQ0F2V0djL0pTUmJXUkdrN0xNYnJKWnNCbXlVRlRGTUdkbDNFUVcxZDhQM280SVBsa0tQZXhOQ3NNMHBTM1ErVEV3Z3Y2UTMvaFpYY05iSzVITkwyQmtPS0VyblV1cXU5VGxGM0h6OXRXODAyaG94ajNKYVFOMzlpVWNMOWdUZkwzRmNublRRdzlRMk1nZkVIbDYrcVJHM3MwZGpvTnlSaE1WdFJSZGJuQlJ1Y1h2NGpzQkx2TVJhRGNkdnhPUDkwMFdiWTRUQlhzWS9xZW1ZYVZwck4vZmpwbk1Kd3I1dlRzT3RKTVJ3WHk1czJOOVE2QmZ4ZnhMMUR6d0hpQkpuTUszd1pPeks1QkZ4dXhZd3Q1cUtxbGtSZ2h5OGVFSjJZVXRuaXB4Sm5pNjk3bkEvdFRrRXAvYUlENFQ0azd4OVB6blNPb0EzTFQwL1JmVExSTUFBWjRrbUt4UzZJOEcvQmZDaXA0eWc2V05TVjUwUXpEeXVKdDl0ek9MeEJ5R0ZXNDY1eDA1UU1VVXY3N1dpZTJwUHp5VDVaemRDSlJxY2t1QTZERWFRS3hjQmd5MncyajZoVHhnQjNFaE1vMlQ3NVhtV0pBZnVmVUFXWGgxcUFLQXBtNXA3aUJ3MW1taTNvc3pKT2J6OUFaQzVaY1U5VERCTWdTQ1k4RkJNQ2V4eVNvWGRsYmgzT2J0NVJqSk1IOVpTRUg2NFduQXlJNy9HSWFwUFlpQWdTWDBzbXZBdWFkTFpiWE15Mk42aUtJL0k5VXcxb0U4SHlHUFZWVlhRQ2N0Vy9xSDFjblhEYkFWVDh1dDN0bzVweklRSk5QUFVuclFhcU1kalRWWXZUOXVmS0grRzkzQmRzOW83Uy82VGJRWmFhYSszeG9PdUpBMm5JN3liYzZETVZZejhDVFRHcUhQSzUzTkRsb3hONGFJdlo4ZmQ0UHo5d01WT25EQ3FuSVpoQnQxVnU3Nk1iM1ZBb0h3VHR3NUdCbjFoOFBJY1c5SWlOcm16VVoyUkJHTnhwWWdsdjZLMFF1WHNZZ2dBVWpmVlF3SmtqSlpPcmtwSlpXVStBZDFOKy8rdXZUWnMzN3ZDU0VQZytUcWRUbTl0ZEYxdU8zeFNrbGVtcDROOVZDTlk3ekIwZ3hIamtzZHVuM29UMmNlM2pna2c3Smd6THZmS2NJeHZsTGlFd2UzZ1ZnRWtRb21mN1BmMUxpemlQb2p4RjV6a0JtdFZWa08yYnM2aklyUVpKSk93UEJnTGh6L0xySDNQWk91alp6bFE5bE1DU0N6TmZRSHM3bGJURTFKZWR0eDVPZmkxZHlpc2tyY3RiM2ZBTkk2OVVuUm1TK1JJM09KeHlaMkhUOW9jWFE4WDgxblFxS2QxdDNvVFFCTFlMd2UxTnZ3bkZXMmlzaDZ1ekxnT0NGK1VHd1BZa1JmYzEyMy9rMk5DTWwycDhndDV3cWNub1hiN1ZWblUzamxYVm82VGF3eWpHRGVIWWhScnF0bHBmOVN1NWtaWW0zVmpEcVVOV1dsZFZRVkVyckVnYUxMVU8yK2NrN1hGSXN3dlV2YXVLZnpWb2NwR1hPTHhpaWMrOGpEcVRWOHBpYTB5RzVTVENRS1RtTjZLZVhVSTBSbXl2L0ZtTjFvTlFlVTNHaFdmZ2Z5NzlURXFqaG90azdxMXhZYTJheHdEVXdENkw1SXZSb2JjUXRXTlFjL1hFWVVxYlZ3RXdBWGxkY1haUnhxREVoQmRKdERtVkxjeWUyZnBoSnJVNEJYdlBwdEUrY0RFc2hxR1J0N1pjUUUrYXJWRkNuUnB0Y3h2c0EvN3pCbzlnMjNEY3Q5ZDFDNlYxTVdLRWsyb1lVVU5nSkdtRU8yL2FIN2YwdnlseEZ3OGQ2dVQwcm5kYjNuWDJNeFg2Z25aN2VPRVp5K1h1ZkpyYlFSNWR5dmF5dE9RVXdQUk0xdk9yVUxsV3crT2d0dHEzV3FQbzhNVlNlWnIrbGc0Z2NpMzZ6ZmRkZE5nVENjMHpxLzB4eGhlWVhZOWRpS2pOZEo3dUY3b0hJQUFBPSIKfQo=";
    uint256 public constant MINT_PRICE = 0.01 ether;

    address public constant HOLESKY_CONTRACT_ADDRESS = 0x9A27E3146650D1370773f49A0AE06a720B02cfED; //put here your NFT contract for Holesky
    address public constant SEPOLIA_CONTRACT_ADDRESS = address(0); // put here your NFT contract for Sepolia
    function run() external {
        address mostRecentlyDeployedNFTContract;

        if (block.chainid == 17000) {
            mostRecentlyDeployedNFTContract = HOLESKY_CONTRACT_ADDRESS;
        } else if (block.chainid == 11155111) {
            mostRecentlyDeployedNFTContract = SEPOLIA_CONTRACT_ADDRESS;
        }
        else {
            mostRecentlyDeployedNFTContract = DevOpsTools.get_most_recent_deployment(
                "ByteTheCookiesNFTCollection", 
                block.chainid
            );
        }

        ByteTheCookiesNFTCollection(payable(mostRecentlyDeployedNFTContract));
        console.log("Most recently deployed NFT contract: ", mostRecentlyDeployedNFTContract);
        mintNftOnContract(mostRecentlyDeployedNFTContract);
    }

    function mintNftOnContract(address ByteTheCookiesNFTAddress) public payable {
        vm.startBroadcast();
        ByteTheCookiesNFTCollection(ByteTheCookiesNFTAddress).mintNft{value: MINT_PRICE}(exampleImageUri);
        vm.stopBroadcast();
    }
}

contract SettingWhitelist is Script {
    address public constant HOLESKY_CONTRACT_ADDRESS = 0x9A27E3146650D1370773f49A0AE06a720B02cfED; //put here your NFT contract for Holesky
    address public constant SEPOLIA_CONTRACT_ADDRESS = address(0); // put here your NFT contract for Sepolia
 
    address[] public addresses = [
        0x9cFf19AAf6f6B46639BD66a0a37dE941325BAfF2,
        0x53b2DAC7Bb0BDa548CF241faCd51c2628664C216,
        0x2c88eF658f7Ee732D0f885bCA44F10491b0Bb3CA,
        0x4490716bcee5153eB0f92e6329FE5f4f9a8b4524,
        0x523284b365300f44EfF3FFe6E243a688B60e3d9f,
        0x9a4267d4B1e221f9Cc4c4596367592E5E85F288b,
        0x16f87a40142E062d1ACeFFa4D925114f989f9370,
        0xe873f8aD808312d07C1B925856222dc89f7d0018,
        0x106571aDc955711066ef42CB510CABac2713B111,
        0x2fD394df36381857639d633aad2CB4DDdF40b9D8,
        0x3361AD6f9c5607E6D9957D02dd9F52129c91b59a,
        0x1BCaBBCb237b3AaDAdedf5B0bee2035F195A912C
        //In attesa degli altri membri...
    ];

    function run() external {
        address mostRecentlyDeployedNFTContract;

        if (block.chainid == 17000) {
            mostRecentlyDeployedNFTContract = HOLESKY_CONTRACT_ADDRESS;
        } else if (block.chainid == 11155111) {
            mostRecentlyDeployedNFTContract = SEPOLIA_CONTRACT_ADDRESS;
        }
        else {
            mostRecentlyDeployedNFTContract = DevOpsTools.get_most_recent_deployment(
                "ByteTheCookiesNFTCollection", 
                block.chainid
            );
        }
        ByteTheCookiesNFTCollection nftContract = ByteTheCookiesNFTCollection(payable(mostRecentlyDeployedNFTContract));
        addToWhitelist(nftContract);
    }

    function addToWhitelist(ByteTheCookiesNFTCollection nftContract) internal {
        vm.startBroadcast();
        for (uint256 i = 0; i < addresses.length; i++) {
            if (!nftContract.isWhitelisted(addresses[i])) {
                nftContract.addToWhitelist(addresses[i]);
            }
        }
        vm.stopBroadcast();
    }
}
