pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.1/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.1/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.8.1/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.8.1/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.1/utils/Counters.sol";

contract MyToken is ERC721, ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 MAX_SUPPLY = 1000;
    mapping (address => uint256) private _mintCount;
    mapping (address => uint256) private _purchaseCount;


    constructor() ERC721("MyToken", "MTK") {}

    function safeMint(address to, string memory uri) public  {
        require(_tokenIdCounter.current() <= MAX_SUPPLY, "I'm sorry we reached the cap");
        require(_mintCount[to] <= 5, "The maximum number of mints per wallet has been reached");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _mintCount[to]++;
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory tokenIds) public {
        require(tokenIds.length <= 3, "The maximum number of NFTs that can be purchased at once is 3");
        require(_purchaseCount[to] + tokenIds.length <= 4, "The maximum number of purchases per wallet has been reached");

        // reveal mechanism
        uint256 length = tokenIds.length;
        uint256 revealedTokenIds = 0;
        for (uint256 i = 0; i < length; i++) {
            if (_exists(tokenIds[i])) {
                revealedTokenIds++;
            }
        }
        require(revealedTokenIds == length, "One or more of the NFTs you are trying to purchase do not exist");

        // transfer NFTs to the buyer
        for (uint256 i = 0; i < length; i++) {
            transferFrom(from, to, tokenIds[i]);
        }
        _purchaseCount[to] += tokenIds.length;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
