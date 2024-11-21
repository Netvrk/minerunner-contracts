// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title MRCashIn
 * @dev This contract handles a "Cash-In" mechanism where players can deposit an ERC20 token into the contract.
 * It supports upgradeability through UUPS, ownership management, and pausing functionality.
 * The contract keeps track of all "Cash-In" orders and allows the owner to withdraw the deposited tokens.
 */
contract MRCashIn is OwnableUpgradeable, PausableUpgradeable, UUPSUpgradeable {
    // ERC20 token used for cash-in transactions
    IERC20 cashInToken;

    // Event emitted when a new cash-in order is created
    event CashIn(bytes32 indexed id);

    /**
     * @dev Structure to represent a "Cash-In" order.
     * @param id Unique identifier of the cash-in order.
     * @param player Address of the player making the cash-in.
     * @param amount Amount of tokens being deposited.
     * @param timestamp Time when the cash-in order was created.
     */
    struct CashInOrder {
        bytes32 id;
        address player;
        uint256 amount;
        uint256 timestamp;
    }

    // Mapping to store cash-in orders by their unique ID
    mapping(bytes32 => CashInOrder) public cashInOrder;

    // List to store all cash-in order IDs
    bytes32[] public cashInOrdersList;

    /**
     * @dev Initializes the contract with the specified ERC20 token.
     * Sets up the owner and enables upgradeability and pausing functionalities.
     * @param _token Address of the ERC20 token to be used for cash-in transactions.
     */
    function initialize(IERC20 _token) public initializer {
        __UUPSUpgradeable_init();
        __Context_init_unchained();
        __Ownable_init_unchained();
        __Pausable_init_unchained();

        cashInToken = _token;
    }

    /**
     * @dev Allows a player to create a cash-in order by transferring a specified amount of the ERC20 token to the contract.
     * The function is paused if the contract is in a paused state.
     * @param _amount The amount of tokens to be transferred.
     * Emits a `CashIn` event upon successful execution.
     */
    function cashIn(uint256 _amount) external whenNotPaused {
        require(cashInToken.balanceOf(_msgSender()) >= _amount, "NO_BALANCE"); // Ensure the player has sufficient balance
        require(
            cashInToken.allowance(_msgSender(), address(this)) >= _amount,
            "NO_ALLOWANCE"
        ); // Ensure the contract has sufficient allowance

        // Generate a unique ID for the cash-in order
        bytes32 orderId = keccak256(
            abi.encodePacked(
                block.timestamp,
                _msgSender(),
                _amount,
                cashInOrdersList.length
            )
        );

        // Create and store the cash-in order
        CashInOrder memory newCashInOrder = CashInOrder({
            id: orderId,
            player: _msgSender(),
            amount: _amount,
            timestamp: block.timestamp
        });

        cashInOrder[orderId] = newCashInOrder;
        cashInOrdersList.push(orderId);

        // Transfer tokens from the player to the contract
        cashInToken.transferFrom(_msgSender(), address(this), _amount);

        emit CashIn(orderId); // Emit the CashIn event
    }

    /**
     * @dev Updates the ERC20 token address used for cash-in transactions.
     * Can only be called by the owner of the contract.
     * @param _token The new ERC20 token address.
     */
    function updateToken(IERC20 _token) external onlyOwner {
        cashInToken = _token;
    }

    /**
     * @dev Allows the owner to withdraw all tokens held by the contract to a specified treasury address.
     * Can only be called by the owner of the contract.
     * @param treasury The address where the tokens will be sent.
     */
    function withdraw(address treasury) external virtual onlyOwner {
        uint256 _amount = cashInToken.balanceOf(address(this)); // Get the contract's token balance
        require(_amount > 0, "ZERO_BALANCE"); // Ensure there are tokens to withdraw
        cashInToken.transfer(treasury, _amount); // Transfer the tokens to the treasury address
    }

    /**
     * @dev Pauses the contract, preventing certain functions from being executed.
     * Can only be called by the owner when the contract is not already paused.
     */
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    /**
     * @dev Unpauses the contract, allowing paused functions to be executed.
     * Can only be called by the owner when the contract is paused.
     */
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    /**
     * @dev Returns the total number of cash-in orders created so far.
     * @return The total number of cash-in orders.
     */
    function getCashInOrdersSize() public view returns (uint256) {
        return cashInOrdersList.length;
    }

    /**
     * @dev Returns the address of the ERC20 token used for cash-in transactions.
     * @return The address of the cash-in token.
     */
    function cashinToken() public view returns (address) {
        return address(cashInToken);
    }

    /**
     * @dev Internal function required for UUPS proxy upgradeability.
     * Ensures only the owner can authorize upgrades to the contract.
     * @param newImplementation Address of the new implementation.
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
