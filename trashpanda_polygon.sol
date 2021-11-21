// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Trashpanda is ERC721, Ownable {
    using SafeERC20 for IERC20;
    using Strings for uint256;
    
    address public constant WETH_CONTRACT = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    
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
    
    function mint(uint256 numNfts, uint256 _mintPrice)
        external
        whenPublicSaleActive
    {
        require(_tokenIds + numNfts <= MAX_SUPPLY, "Minting would exceed max supply");
        require(numNfts > 0, "Must mint at least one NFT");
        require(mintPrice * numNfts <= _mintPrice, "Ether value sent is not correct");
        
        IERC20 weth = IERC20(address(WETH_CONTRACT));
        
        weth.safeTransferFrom(msg.sender, address(this), _mintPrice * numNfts);

        for (uint i = 0; i < numNfts; i++){
            _mint(msg.sender, _tokenIds);
            _tokenIds += 1;
        }
    }
    
    function mintTo(uint256 numNfts, address toAddress)
        external
        onlyOwner
        whenPublicSaleActive
    {
        require(_tokenIds + numNfts <= MAX_SUPPLY, "Minting would exceed max supply");
        require(numNfts > 0, "Must mint at least one NFT");

        for (uint i = 0; i < numNfts; i++){
            _mint(toAddress, _tokenIds);
            _tokenIds += 1;
        }
    }
}