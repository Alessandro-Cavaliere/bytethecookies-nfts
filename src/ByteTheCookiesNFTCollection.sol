// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {console} from "forge-std/Test.sol";
contract ByteTheCookiesNFTCollection is ERC721,Ownable{
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 private s_tokenCounter;
    mapping(address => bool) private s_whitelist;
    mapping(address => string) private s_ownershipUris;
    mapping(uint256 tokenId => string) private _tokenURIs;
    uint256 public constant MINT_PRICE = 0.001 ether;
    
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event CreatedNFT(uint256 indexed tokenId);
    event MetadataUpdate(uint256 indexed tokenId);
    event ByteTheCookiesNFTCollection__Received(address indexed sender, uint256 value);

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
    constructor() ERC721("ByteTheCookiesNFTCollection", "BTC") Ownable(msg.sender){
        s_tokenCounter = 1000; // Starting tokenId Counter
        s_whitelist[msg.sender] = true; // Owner is whitelisted by default
    }

    /*//////////////////////////////////////////////////////////////
                           START OF FUNCTIONS
    //////////////////////////////////////////////////////////////*/
     function mintNft(string memory tokenUri) public payable{
        require(s_whitelist[msg.sender], ByteTheCookiesNFTCollection__UserIsNotWhitelisted());
        require(msg.value >= MINT_PRICE, ByteTheCookiesNFTCollection__InvalidPayment());
        
        uint256 tokenCounter = s_tokenCounter;
        _safeMint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, tokenUri);
        console.log("msg.valie: ", msg.value);
        console.log(owner());
        uint256 ownerShare = msg.value / 2; // Calcola il 50% del pagamento
        console.log("ownerShare: ", ownerShare);
        (bool success, ) = payable(owner()).call{value: ownerShare}("");
        require(success, "Transfer to owner failed");
        (bool success2, ) = payable(address(this)).call{value: ownerShare}("");
        require(success2, "Transfer to NFT contract failed");
        s_ownershipUris[msg.sender] = tokenUri;
        s_tokenCounter = s_tokenCounter + 1;
        emit CreatedNFT(tokenCounter);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(ownerOf(tokenId) != address(0), OZ_ERC721__NoExistentToken());
        require(bytes(s_ownershipUris[ownerOf(tokenId)]).length != 0, ByteTheCookiesNFTCollection__NoNFTUriForAddress());
        string memory imageURI = s_ownershipUris[ownerOf(tokenId)];
        return imageURI;
    }

    function addToWhitelist(address user) external onlyOwner {
        s_whitelist[user] = true;
    }

    function removeFromWhitelist(address user) external onlyOwner {
        s_whitelist[user] = false;
    }

    function getTokenUriForAddress(address user) public view returns (string memory) {
        require(s_whitelist[user], ByteTheCookiesNFTCollection__UserIsNotWhitelisted());
        require(bytes(s_ownershipUris[user]).length != 0, ByteTheCookiesNFTCollection__NoNFTUriForAddress());
        return s_ownershipUris[user];
    }

    function isWhitelisted(address user) public view returns (bool) {
        return s_whitelist[user];
    }   

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenURIs[tokenId] = _tokenURI;
        emit MetadataUpdate(tokenId);
    }

    fallback() external payable {
        emit ByteTheCookiesNFTCollection__Received(msg.sender, msg.value);
    }

 
}