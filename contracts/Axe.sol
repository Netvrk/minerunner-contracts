// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract Axe is ERC721Enumerable, Ownable, Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string internal _baseTokenURI;
    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory baseTokenURI) ERC721("AXE", "AXE") {
        _baseTokenURI = baseTokenURI;
        _tokenIds.increment();
    }

    // Mint game item
    function mintItem(address player, string memory axeType)
        public
        onlyOwner
        returns (uint256)
    {
        uint256 itemId = _tokenIds.current();

        _mint(player, itemId);

        string memory itemURI = string.concat(
            Strings.toString(itemId),
            "/",
            axeType
        );

        _setTokenURI(itemId, itemURI);

        _tokenIds.increment();

        return itemId;
    }

    // Burn game item
    function burnItem(uint256 itemId) public onlyOwner returns (uint256) {
        require(
            _isApprovedOrOwner(_msgSender(), itemId),
            "NOT_OWNER_OR_APPROVED"
        );
        _burn(itemId);
        return itemId;
    }

    // Set base URI
    function setBaseURI(string memory baseTokenURI) external onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(_exists(tokenId), "TOKEN_DOESNT_EXIST");
        _tokenURIs[tokenId] = _tokenURI;
    }

    // Get base URI
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }
}
