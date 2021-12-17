// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/** @author tony-stark.eth */
contract AirdroppableContract is ERC721, Ownable {
    using Strings for uint256;
    
    bool public publicSaleActive;
    
    uint256 public maxSupply;
    uint256 public airdroppedSupply;
    uint256 public mintPrice;
    
    uint256 private _tokenIds;
    
    string private baseURI;
    string[] private _tokenUris;
    
    modifier whenPublicSaleActive() {
        require(publicSaleActive, "Public sale is not active");
        _;
    }
    
    /** @dev https://eth-converter.com _mintPrice is wei | constructor arguments encoding for contract verification: https://abi.hashex.org */
    constructor(string memory name_, string memory symbol_, uint256 _maxSupply, uint256 _airdroppedSupply, uint256 _mintPrice) ERC721(name_, symbol_) {
        maxSupply = _maxSupply;
        airdroppedSupply = _airdroppedSupply;
        mintPrice = _mintPrice;

        _tokenUris = new string[](maxSupply);
    }
    
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
        require(_tokenIds + numNfts <= maxSupply - airdroppedSupply, "Minting would exceed max supply");
        require(numNfts > 0, "Must mint at least one NFT");
        require(mintPrice * numNfts <= msg.value, "Payable amount sent is not correct");

        for (uint i = 0; i < numNfts; i++){
            _mint(msg.sender, _tokenIds);
            _tokenIds += 1;
        }
    }
    
    function mintTo(uint256 numNfts, address[] memory addresses)
        external
        onlyOwner
    {
        require(_tokenIds + (numNfts * addresses.length) <= maxSupply, "Minting would exceed max supply");
        require(numNfts > 0, "Must mint at least one NFT");

        for (uint aIndex = 0; aIndex < addresses.length; aIndex++){
            for (uint bIndex = 0; bIndex < numNfts; bIndex++){
                _mint(addresses[aIndex], _tokenIds);
                _tokenIds += 1;
            }
        }
    }
}