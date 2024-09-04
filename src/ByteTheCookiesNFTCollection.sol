// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {console} from "forge-std/Test.sol";

contract ByteTheCookiesNFTCollection is ERC721URIStorage, Ownable {

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    string public s_name;
    string public s_symbol;
    address private s_owner;
    uint256 private s_tokenCounter;
    mapping(address => bool) private s_whitelist;
    mapping(address => string[]) private s_ownershipUris;   
    mapping(uint256 tokenId => string) private _tokenURIs;
    string public constant VERSION = "ByteTheCookiesNFTCollection_v1.0.3";
    uint256 public constant MINT_PRICE = 0.01 ether;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event CreatedNFT(uint256 indexed tokenId);
    event MetadataRetrieved(uint256 indexed tokenId);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error OZ_ERC721__NoExistentToken();
    error ByteTheCookiesNFTCollection__NoNFTUriForAddress();
    error ByteTheCookiesNFTCollection__UserIsNotWhitelisted();
    error ByteTheCookiesNFTCollection__InvalidPayment();

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(string memory name, string memory symbol, address owner) ERC721(name, symbol) Ownable(msg.sender) {
        s_name = name;
        s_symbol = symbol;
        s_owner = msg.sender;
        s_tokenCounter = 1000; // Starting tokenId Counter
        s_whitelist[msg.sender] = true; // Owner is whitelisted by default
    }

    /*//////////////////////////////////////////////////////////////
                           START OF FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Mint a new NFT
    /// @dev Mint a new NFT though the minting process and is only available to whitelisted addresses
    /// @param tokenUri The URI of the token - the json data containing the metadata
    function mintNft(string memory tokenUri) public payable {
        require(s_whitelist[msg.sender], ByteTheCookiesNFTCollection__UserIsNotWhitelisted());
        require(msg.value >= MINT_PRICE, ByteTheCookiesNFTCollection__InvalidPayment());
        uint256 tokenCounter = s_tokenCounter;
        _safeMint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, tokenUri);
        uint256 ownerShare = msg.value / 2;
        payable(owner()).transfer(ownerShare);
        s_ownershipUris[msg.sender].push(tokenUri);
        s_tokenCounter = s_tokenCounter + 1;
        emit CreatedNFT(tokenCounter);
    }

    /// @notice Get the URI of the token
    /// @dev Get the URI of the token providing the tokenId - The tokenURI can be visualized in the browser with IPFS Companion or with IPFS Desktop
    /// @param tokenId The tokenId assosiated with the NFT token
    /// @return The URI of the token
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(ownerOf(tokenId) != address(0), OZ_ERC721__NoExistentToken());
        require(bytes(_tokenURIs[tokenId]).length != 0, ByteTheCookiesNFTCollection__NoNFTUriForAddress());
        string memory imageURI = _tokenURIs[tokenId];
        return imageURI;
    }

    /// @notice Add an address to the whitelist
    /// @dev Add an address to the whitelist so it can mint NFTs. onlyOwner modifier is used to restrict access to the function to the owner
    /// @param user The address to be added to the whitelist
    function addToWhitelist(address user) external onlyOwner {
        s_whitelist[user] = true;
    }

    /// @notice Remove an address from the whitelist
    /// @dev Remove an address from the whitelist so it can't mint NFTs. onlyOwner modifier is used to restrict access to the function to the owner
    /// @param user The address to be removed from the whitelist
    function removeFromWhitelist(address user) external onlyOwner {
        s_whitelist[user] = false;
    }
    
    /// @notice Get all token URIs for a specific address
    /// @dev Get the list of token URIs associated with the given address
    /// @param user The address to get the token URIs from
    /// @return An array of token URIs
    function getTokenUrisForAddress(address user) public view returns (string[] memory) {
        require(s_whitelist[user], ByteTheCookiesNFTCollection__UserIsNotWhitelisted());
        return s_ownershipUris[user];
    }

    /// @notice Check if an address is whitelisted
    /// @dev Check if an address is whitelisted by checking the mapping
    /// @param user The address to check if it is whitelisted
    /// @return A boolean value indicating if the address is whitelisted
    function isWhitelisted(address user) public view returns (bool) {
        return s_whitelist[user];
    }

    /// @notice Set the URI of the token
    /// @dev Set the URI of the token providing the tokenId used in the minting process. Event is emitted to notify the change
    /// @param tokenId The tokenId assosiated with the NFT token
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual override {
        require(ownerOf(tokenId) == msg.sender, "ByteTheCookiesNFTCollection__Unauthorized");
        _tokenURIs[tokenId] = _tokenURI;
        emit MetadataUpdate(tokenId);
    }

    /// @notice Get the URI of the token
    /// @dev Get the URI of the token providing the tokenId used in the minting process. Event is emitted to notify the change
    /// @param tokenId The tokenId assosiated with the NFT token
    function _getTokenURI(uint256 tokenId) internal view returns (string memory) {
        return _tokenURIs[tokenId];
    }
}
