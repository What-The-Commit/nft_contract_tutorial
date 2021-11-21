// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Trashpanda is ERC721, Ownable {
    using Strings for uint256;
    
    bool public publicSaleActive;
    
    uint256 public constant MAX_SUPPLY = 10;
    
    uint public mintPrice = 0.01 ether;
    
    uint256 private _tokenIds;
    
    string private baseURI;
    
    string[MAX_SUPPLY] private _tokenUris;
    
    modifier whenPublicSaleActive() {
        require(publicSaleActive, "Public sale is not active");
        _;
    }
    
    constructor() ERC721("Trashpanda", "RACOON") {}
    
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }
    
    function addTokenUri(uint256 tokenId, string memory uri) external onlyOwner {
        _tokenUris[tokenId] = uri;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        
        if (bytes(_tokenUris[tokenId]).length > 0) {
            return _tokenUris[tokenId];
        }

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    
    function startPublicSale()
        external
        onlyOwner
    {
        require(!publicSaleActive, "Public sale has already begun");
        publicSaleActive = true;
    }

    function pausePublicSale() external onlyOwner whenPublicSaleActive {
        publicSaleActive = false;
    }
    
    function mint(uint256 numNfts)
        external
        payable
        whenPublicSaleActive
    {
        require(_tokenIds + numNfts <= MAX_SUPPLY, "Minting would exceed max supply");
        require(numNfts > 0, "Must mint at least one NFT");
        require(mintPrice * numNfts <= msg.value, "Ether value sent is not correct");

        for (uint i = 0; i < numNfts; i++){
            _mint(msg.sender, _tokenIds);
            _tokenIds += 1;
        }
    }
    
    function mintTo(uint256 numNfts, address toAddress)
        external
        onlyOwner
    {
        require(!publicSaleActive, "Public sale has already begun");
        require(_tokenIds + numNfts <= MAX_SUPPLY, "Minting would exceed max supply");
        require(numNfts > 0, "Must mint at least one NFT");

        for (uint i = 0; i < numNfts; i++){
            _mint(toAddress, _tokenIds);
            _tokenIds += 1;
        }
    }
}