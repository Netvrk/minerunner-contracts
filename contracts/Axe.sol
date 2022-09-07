// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "hardhat/console.sol";

contract Axe is
    ERC2981,
    ERC721EnumerableUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    UUPSUpgradeable
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER");

    string internal _baseTokenURI;
    mapping(uint256 => string) private _tokenURIs;

    function initialize(string memory baseTokenURI, address manager)
        public
        initializer
    {
        __ERC721_init("AXE", "AXE");
        __ERC721Enumerable_init_unchained();
        __UUPSUpgradeable_init_unchained();
        __Context_init_unchained();
        __AccessControl_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, manager);

        _baseTokenURI = baseTokenURI;
        _tokenIds.increment();
    }

    // Mint game item
    function mintItem(address player, string memory axeType)
        public
        onlyRole(MANAGER_ROLE)
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
    function burnItem(uint256 itemId)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (uint256)
    {
        require(
            _isApprovedOrOwner(_msgSender(), itemId),
            "NOT_OWNER_OR_APPROVED"
        );
        _burn(itemId);
        return itemId;
    }

    // Set base URI
    function setBaseURI(string memory baseTokenURI)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC2981, ERC721EnumerableUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        if (interfaceId == type(IERC2981).interfaceId) {
            return true;
        }

        return super.supportsInterface(interfaceId);
    }

    // UUPS proxy function
    function _authorizeUpgrade(address)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
