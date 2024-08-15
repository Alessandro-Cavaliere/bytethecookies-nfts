// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {DeployByteTheCookiesNFT} from "../script/DeployByteTheCookiesNFT.s.sol";
import {ByteTheCookiesNFTCollection} from "../src/ByteTheCookiesNFTCollection.sol";
import {Test, console} from "forge-std/Test.sol";

contract NFTTest is Test {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    ByteTheCookiesNFTCollection public contractNft;
    address public owner;
    address public player = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public whitelistAddress = 0xe288506531AC0aC23809F6B92613e75DC121657f;
    uint256 public initialOwnerBalance;
    uint256 public ownerShare;
    uint256 public mintingAmount;
    uint256 public totalPayment;
    string public exampleImageUri = "exampleUri";

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Received(address indexed sender, uint256 value);
    event MetadataUpdate(uint256 indexed tokenId);
    event MetadataRetrieved(uint256 indexed tokenId);
    
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error ByteTheCookiesNFTCollection__UserIsNotWhitelisted();
    error ByteTheCookiesNFTCollection__NoNFTUriForAddress();
    error OZ_ERC721__NoExistentToken();
    error ERC721NonexistentToken();

    /*//////////////////////////////////////////////////////////////
                                 MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier MintWithLoadAddressAndWhiteListed() {
        mintingAmount = 0.001 ether; // Amount to send for minting
        ownerShare = mintingAmount / 2; // Owner receives 10% of the minting amount
        totalPayment = mintingAmount + ownerShare;
        vm.startPrank(owner);
        initialOwnerBalance = contractNft.owner().balance;
        contractNft.addToWhitelist(player);
        vm.stopPrank();
        vm.startPrank(player);
        vm.deal(player, mintingAmount);
        contractNft.mintNft{value: mintingAmount}(exampleImageUri);
        _;
    }

    modifier MintWithLoadAddressAndNotWhiteListed() {
        _;
        mintingAmount = 0.001 ether; // Amount to send for minting
        ownerShare = mintingAmount / 2; // Owner receives 10% of the minting amount
        totalPayment = mintingAmount + ownerShare;
        vm.startPrank(player);
        vm.deal(player, totalPayment);
        contractNft.mintNft{value: mintingAmount}(exampleImageUri);
    }

    /*//////////////////////////////////////////////////////////////
                           START OF FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function setUp() public {
        DeployByteTheCookiesNFT deployer = new DeployByteTheCookiesNFT();
        contractNft = new ByteTheCookiesNFTCollection();
        owner = contractNft.owner();
        console.log("Setup complete");
    }

    function testIfMintPaymentIsCorrect() public MintWithLoadAddressAndWhiteListed{
        uint256 actualOwnerBalance = contractNft.owner().balance;
        assertEq(actualOwnerBalance, initialOwnerBalance + ownerShare, "Owner balance should be increased x 2 of the minting amount");
    }

    function testMintNftWithNotWhitelistedUser() public MintWithLoadAddressAndNotWhiteListed{
        vm.expectRevert(ByteTheCookiesNFTCollection__UserIsNotWhitelisted.selector);
    }


    function testTokenURIFunction() public MintWithLoadAddressAndWhiteListed{
        uint256 tokenId = 1000; // Token ID should match the minted one
        string memory tokenUri = contractNft.tokenURI(tokenId);
        assertEq(tokenUri, exampleImageUri, "Token URI should be correctly set");
    }

    function testGetTokenUriForAddressWhitelistedWithAtLeastAToken() public MintWithLoadAddressAndWhiteListed{
        string memory expectedImageUri= contractNft.getTokenUriForAddress(player);
        assertEq(expectedImageUri, exampleImageUri, "Token URI for address should match the expected URI");
    }


    function testGetTokenUriForAddressWhitelistedButWithoutTokens() public{
        vm.startPrank(owner);
        contractNft.addToWhitelist(player);
        vm.startPrank(player);
        vm.expectRevert(ByteTheCookiesNFTCollection__NoNFTUriForAddress.selector);
        contractNft.getTokenUriForAddress(player);
    }

    function testGetTokenUriForAddressNotWhitelisted() public{
        vm.startPrank(player);
        vm.expectRevert(ByteTheCookiesNFTCollection__UserIsNotWhitelisted.selector);
        contractNft.getTokenUriForAddress(player);
    }

    function testTokenURIForNonexistentToken() public {
        vm.prank(player);
        vm.expectRevert();
        contractNft.tokenURI(12345); // Non-existent token ID
    }


    function testIsWhitelisted() public {
        vm.prank(owner);
        contractNft.addToWhitelist(whitelistAddress);
        bool isWhitelisted = contractNft.isWhitelisted(whitelistAddress);
        assertTrue(isWhitelisted, "Address should be whitelisted");
    }


    function testAddToWhitelist() public {
        contractNft.addToWhitelist(whitelistAddress);
        bool isWhitelisted = contractNft.isWhitelisted(whitelistAddress);
        assertTrue(isWhitelisted, "Address should be whitelisted");
    }

    function testRemoveFromWhitelist() public {
        contractNft.removeFromWhitelist(whitelistAddress);
        bool isWhitelisted = contractNft.isWhitelisted(whitelistAddress);
        assertFalse(isWhitelisted, "Address should not be whitelisted");
    }

    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

}
