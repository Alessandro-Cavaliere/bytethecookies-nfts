// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {DeployByteTheCookiesNFT} from "../../script/DeployByteTheCookiesNFT.s.sol";
import {ByteTheCookiesNFTCollection} from "../../src/ByteTheCookiesNFTCollection.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";

contract NFTTest is Test {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 public constant MINT_PRICE = 0.001 ether;
    HelperConfig public helperConfig;
    ByteTheCookiesNFTCollection public contractNft;
    string public contractName;
    string public contractSymbol;
    address public owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Base Account of Local Chain Anvil (admin)
    address public user;
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
    event CreatedNFT(uint256 indexed tokenId);

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
        contractNft.addToWhitelist(user);
        vm.stopPrank();
        vm.startPrank(user);
        vm.deal(user, MINT_PRICE);
        contractNft.mintNft{value: MINT_PRICE}(exampleImageUri);
        _;
    }

    modifier MintWithLoadAddressAndNotWhiteListed() {
        _;
        ownerShare = MINT_PRICE / 2; // Owner receives 10% of the minting amount
        totalPayment = MINT_PRICE + ownerShare;
        vm.startPrank(user);
        vm.deal(user, totalPayment);
        contractNft.mintNft{value: MINT_PRICE}(exampleImageUri);
    }

    /*//////////////////////////////////////////////////////////////
                           START OF FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function setUp() public {
        DeployByteTheCookiesNFT deployer = new DeployByteTheCookiesNFT();
        (contractNft, helperConfig) = deployer.run();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        vm.startPrank(owner);
        contractNft = new ByteTheCookiesNFTCollection(config.name, config.symbol, config.owner);
        vm.stopPrank();
        contractName = config.name;
        contractSymbol = config.symbol;
        user = makeAddr("user");
        console.log("owner: ", owner);
        console.log("Setup complete");
    }

    function testConstructorAnvil() public {
        string memory expectedName = "ByteTheCookiesNFTCollection__AnvilLocalChain";
        string memory expectedSymbol = "BTC";
        address expectedOwner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        string memory actualName = contractNft.s_name();
        assertEq(actualName, expectedName, "Contract name should match the expected name");

        string memory actualSymbol = contractNft.s_symbol();
        assertEq(actualSymbol, expectedSymbol, "Contract symbol should match the expected symbol");

        address actualOwner = contractNft.owner();
        assertEq(actualOwner, expectedOwner, "Contract owner should match the expected owner");

        bool isOwnerWhitelisted = contractNft.isWhitelisted(expectedOwner);
        assertTrue(isOwnerWhitelisted, "Contract owner should be whitelisted by default");
    }

    function testIfMintPaymentIsCorrect() public MintWithLoadAddressAndWhiteListed {
        uint256 actualOwnerBalance = contractNft.owner().balance;
        assertEq(
            actualOwnerBalance,
            initialOwnerBalance + ownerShare,
            "Owner balance should be increased x 2 of the minting amount"
        );
    }

    function testMintNftWithNotWhitelisteduser() public MintWithLoadAddressAndNotWhiteListed {
        vm.expectRevert(ByteTheCookiesNFTCollection__UserIsNotWhitelisted.selector);
    }

    function testTokenURIFunction() public MintWithLoadAddressAndWhiteListed {
        uint256 tokenId = 1000; // Token ID should match the minted one
        string memory tokenUri = contractNft.tokenURI(tokenId);
        assertEq(tokenUri, exampleImageUri, "Token URI should be correctly set");
    }

    function testGetTokenUriForAddressWhitelistedWithAtLeastAToken() public MintWithLoadAddressAndWhiteListed {
        string memory expectedImageUri = contractNft.getTokenUriForAddress(user);
        assertEq(expectedImageUri, exampleImageUri, "Token URI for address should match the expected URI");
    }

    function testGetTokenUriForAddressWhitelistedButWithoutTokens() public {
        vm.startPrank(owner);
        contractNft.addToWhitelist(user);
        vm.startPrank(user);
        vm.expectRevert(ByteTheCookiesNFTCollection__NoNFTUriForAddress.selector);
        contractNft.getTokenUriForAddress(user);
    }

    function testGetTokenUriForAddressNotWhitelisted() public {
        vm.expectRevert(ByteTheCookiesNFTCollection__UserIsNotWhitelisted.selector);
        contractNft.getTokenUriForAddress(user);
    }

    function testTokenURIForNonexistentToken() public {
        vm.prank(user);
        vm.expectRevert();
        contractNft.tokenURI(12345); // Non-existent token ID
    }

    function testIsWhitelisted() public {
        vm.prank(owner);
        contractNft.addToWhitelist(user);
        bool isWhitelisted = contractNft.isWhitelisted(user);
        assertTrue(isWhitelisted, "Address should be whitelisted");
    }

    function testAddToWhitelist() public {
        vm.startPrank(owner);
        contractNft.addToWhitelist(user);
        bool isWhitelisted = contractNft.isWhitelisted(user);
        assertTrue(isWhitelisted, "Address should be whitelisted");
    }

    function testRemoveFromWhitelist() public {
        vm.startPrank(owner);
        contractNft.removeFromWhitelist(user);
        bool isWhitelisted = contractNft.isWhitelisted(user);
        assertFalse(isWhitelisted, "Address should not be whitelisted");
    }

    function testIfContractNameIsEqualToExpectedAnvil() public view {
        string memory expectedName = "ByteTheCookiesNFTCollection__AnvilLocalChain";
        assertEq(contractName, expectedName, "Contract name should be equal to expected name");
    }

    function testIfContractNameIsEqualToExpectedSepolia() public view {
        string memory expectedName = "ByteTheCookiesNFTCollection__Sepolia";
        assertEq(contractName, expectedName, "Contract name should be equal to expected name");
    }

    function testIfOwnerIsEqualToExpectedSepolia() public view {
        address expectedOwner = 0xCEA0C88efD9b1508275bf59aC5a9f0923013aB53;
        assertEq(owner, expectedOwner, "Owner should be equal to expected owner");
    }

    function testIfOwnerIsEqualToExpectedAnvil() public view {
        address expectedOwner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        assertEq(owner, expectedOwner, "Owner should be equal to expected owner");
    }

    function testMintNftEmitsEvent() public MintWithLoadAddressAndWhiteListed {
        ownerShare = MINT_PRICE / 2; // Owner receives 10% of the minting amount
        totalPayment = MINT_PRICE + ownerShare;
        vm.startPrank(owner);
        initialOwnerBalance = contractNft.owner().balance;
        contractNft.addToWhitelist(user);
        vm.stopPrank();
        vm.startPrank(user);
        vm.deal(user, MINT_PRICE);
        vm.expectEmit(true, true, true, true);
        emit CreatedNFT(1001);
        contractNft.mintNft{value: MINT_PRICE}(exampleImageUri);
    }

    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
