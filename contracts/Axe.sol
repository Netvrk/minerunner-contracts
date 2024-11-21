// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/**
 * @title Axe
 * @dev A contract for managing game items as ERC-721 tokens with support for metadata, royalties, and upgradeability.
 * Includes functionality for minting, burning, and querying game items, with access control and enumerable features.
 */
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract Axe is
    ERC2981,
    ERC721EnumerableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    using Counters for Counters.Counter;

    // Counter for tracking the token IDs
    Counters.Counter private _tokenIds;

    // Role for managers who can mint and manage items
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER");

    // Base URI for the token metadata
    string internal _baseTokenURI;

    // URI for contract-level metadata
    string private _contractURI;

    // Mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    // Mapping from axe IDs (game-specific identifiers) to token IDs
    mapping(string => uint256) private _axeIdToTokenId;

    // Mapping from token IDs to axe IDs
    mapping(uint256 => string) private _tokenIdToAxeId;

    /**
     * @dev Initializes the contract with a base token URI and a manager address.
     * Sets up access control roles and increments the token ID counter to start at 1.
     * @param baseTokenURI The base URI for the token metadata.
     * @param manager The address of the manager who will have the MANAGER_ROLE.
     */
    function initialize(
        string memory baseTokenURI,
        address manager
    ) public initializer {
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

    /**
     * @dev Mints a new game item.
     * Assigns a unique token ID, sets metadata, and maps the axe ID to the token ID.
     * Only callable by addresses with the MANAGER_ROLE.
     * @param player The address of the recipient.
     * @param axeId The unique identifier for the game item.
     * @param axeType The type of the axe, used in constructing the metadata URI.
     */
    function mintItem(
        address player,
        string memory axeId,
        string memory axeType
    ) public onlyRole(MANAGER_ROLE) {
        require(_axeIdToTokenId[axeId] == 0, "AXE_ALREADY_MINTED");

        uint256 itemId = _tokenIds.current();

        string memory itemURI = string.concat(
            Strings.toString(itemId),
            "/",
            axeType
        );

        _mint(player, itemId);

        _axeIdToTokenId[axeId] = itemId;
        _tokenIdToAxeId[itemId] = axeId;

        _setTokenURI(itemId, itemURI);

        _tokenIds.increment();
    }

    /**
     * @dev Burns a game item, removing it from the blockchain.
     * Only callable by addresses with the DEFAULT_ADMIN_ROLE.
     * @param itemId The token ID of the item to be burned.
     * @return The token ID of the burned item.
     */
    function burnItem(
        uint256 itemId
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256) {
        _burn(itemId);
        return itemId;
    }

    /**
     * @dev Sets the base URI for token metadata.
     * Only callable by addresses with the DEFAULT_ADMIN_ROLE.
     * @param baseTokenURI The new base URI.
     */
    function setBaseURI(
        string memory baseTokenURI
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenURI = baseTokenURI;
    }

    /**
     * @dev Sets the default royalty information for secondary sales.
     * Only callable by addresses with the DEFAULT_ADMIN_ROLE.
     * @param receiver The address to receive royalty payments.
     * @param royalty The royalty percentage (in basis points, e.g., 500 = 5%).
     */
    function setDefaultRoyalty(
        address receiver,
        uint96 royalty
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDefaultRoyalty(receiver, royalty);
    }

    /**
     * @dev Sets the contract-level metadata URI.
     * Only callable by addresses with the MANAGER_ROLE.
     * @param newContractURI The new contract URI.
     */
    function setContractURI(
        string memory newContractURI
    ) external virtual onlyRole(MANAGER_ROLE) {
        _contractURI = newContractURI;
    }

    /**
     * @dev Returns the metadata URI for a given token ID.
     * Overrides the ERC721 `tokenURI` function to include base URI logic.
     * @param tokenId The token ID to query.
     * @return The metadata URI for the token.
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }

        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Returns the contract-level metadata URI.
     * @return The contract URI.
     */
    function contractURI() external view virtual returns (string memory) {
        return _contractURI;
    }

    /**
     * @dev Retrieves the token ID associated with a given axe ID.
     * @param axeId The unique identifier for the game item.
     * @return The token ID corresponding to the axe ID.
     */
    function axeIdToTokenId(
        string memory axeId
    ) external view returns (uint256) {
        return _axeIdToTokenId[axeId];
    }

    /**
     * @dev Retrieves the axe ID associated with a given token ID.
     * @param tokenId The token ID to query.
     * @return The axe ID corresponding to the token ID.
     */
    function tokenIdToAxeId(
        uint256 tokenId
    ) external view returns (string memory) {
        return _tokenIdToAxeId[tokenId];
    }

    /**
     * @dev Internal function to set the metadata URI for a token.
     * @param tokenId The token ID.
     * @param _tokenURI The metadata URI to associate with the token.
     */
    function _setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    ) internal virtual {
        require(_exists(tokenId), "TOKEN_DOESNT_EXIST");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Retrieves the base URI for token metadata.
     * @return The base URI string.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Checks if the contract supports a specific interface.
     * Includes support for ERC-2981 and inherited interfaces.
     * @param interfaceId The interface identifier.
     * @return True if the interface is supported, false otherwise.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
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

    /**
     * @dev Authorizes upgrades to the contract.
     * Only callable by addresses with the DEFAULT_ADMIN_ROLE.
     * @param newImplementation The address of the new implementation contract.
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
