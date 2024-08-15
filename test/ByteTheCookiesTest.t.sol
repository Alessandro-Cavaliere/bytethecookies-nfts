// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {DeployByteTheCookiesNFT} from "../script/DeployByteTheCookiesNFT.s.sol";
import {ByteTheCookiesNFTCollection} from "../src/ByteTheCookiesNFTCollection.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";

contract NFTTest is Test {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 public constant MINT_PRICE = 0.001 ether;
    ByteTheCookiesNFTCollection public nftContract;
    HelperConfig public helperConfig;
    ByteTheCookiesNFTCollection public contractNft;
    string public contractName;
    string public contractSymbol;
    address public owner;
    address public player = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Base Account of Local Chain Anvil
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
        ownerShare = MINT_PRICE / 2; // Owner receives 10% of the minting amount
        totalPayment = MINT_PRICE + ownerShare;
        vm.startPrank(owner);
        initialOwnerBalance = contractNft.owner().balance;
        contractNft.addToWhitelist(player);
        vm.stopPrank();
        vm.startPrank(player);
        vm.deal(player, MINT_PRICE);
        contractNft.mintNft{value: MINT_PRICE}(exampleImageUri);
        _;
    }

    modifier MintWithLoadAddressAndNotWhiteListed() {
        _;
        ownerShare = MINT_PRICE / 2; // Owner receives 10% of the minting amount
        totalPayment = MINT_PRICE + ownerShare;
        vm.startPrank(player);
        vm.deal(player, totalPayment);
        contractNft.mintNft{value: MINT_PRICE}(exampleImageUri);
    }

    /*//////////////////////////////////////////////////////////////
                           START OF FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function setUp() public {
        DeployByteTheCookiesNFT deployer = new DeployByteTheCookiesNFT();
        (nftContract, helperConfig) = deployer.run();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        vm.prank(player); //change this to your address if you would test the function testIfOwnerIsEqualToExpectedSepolia() or testIfOwnerIsEqualToExpectedMainnet(). For this test I use Anvil.
        contractNft = new ByteTheCookiesNFTCollection(config.name, config.symbol, config.owner);
        owner = contractNft.owner();
        contractName = config.name;
        contractSymbol = config.symbol;
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

    function testIfContractNameIsEqualToExpectedSepolia() public {
        string memory expectedName = "ByteTheCookiesNFTCollection__Sepolia";
        assertEq(contractName, expectedName, "Contract name should be equal to expected name");
    }
    function testIfContractNameIsEqualToExpectedAnvil() public {
        string memory expectedName = "ByteTheCookiesNFTCollection__AnvilLocalChain";
        assertEq(contractName, expectedName, "Contract name should be equal to expected name");
    }

    function testIfOwnerIsEqualToExpectedSepolia() public {
        address expectedOwner = 0xCEA0C88efD9b1508275bf59aC5a9f0923013aB53;
        assertEq(owner, expectedOwner, "Owner should be equal to expected owner");
    }

    function testIfOwnerIsEqualToExpectedAnvil() public {
        address expectedOwner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        assertEq(owner, expectedOwner, "Owner should be equal to expected owner");
    }

    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

}
