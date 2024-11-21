// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title MRCashOut
 * @dev This contract manages "Cash-Out" operations where tokens are transferred from the contract to players.
 * It supports role-based access control for managing cash-out operations and uses UUPS upgradeability for contract upgrades.
 */
contract MRCashOut is AccessControlUpgradeable, UUPSUpgradeable {
    // Role identifier for managers who can execute cash-out operations
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER");

    // ERC20 token used for cash-out operations
    IERC20 cashOutToken;

    // Event emitted when a cash-out operation is executed
    event CashOut(bytes32 indexed orderId);

    /**
     * @dev Structure to represent a "Cash-Out" order.
     * @param id Unique identifier of the cash-out order.
     * @param player Address of the player receiving the tokens.
     * @param metacrite Arbitrary value representing additional information about the cash-out.
     * @param amount Amount of tokens being transferred.
     * @param timestamp Time when the cash-out order was created.
     */
    struct CashOutOrder {
        bytes32 id;
        address player;
        uint256 metacrite;
        uint256 amount;
        uint256 timestamp;
    }

    // Mapping to store cash-out orders by their unique ID
    mapping(bytes32 => CashOutOrder) public cashOutOrder;

    // List to store all cash-out order IDs
    bytes32[] public cashOutOrdersList;

    /**
     * @dev Initializes the contract with the specified ERC20 token and manager address.
     * Sets up the default admin and manager roles for access control.
     * @param _token Address of the ERC20 token to be used for cash-out operations.
     * @param manager Address of the manager role.
     */
    function initialize(IERC20 _token, address manager) public initializer {
        __UUPSUpgradeable_init();
        __Context_init_unchained();
        __AccessControl_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, manager);

        cashOutToken = _token;
    }

    /**
     * @dev Executes a batch of cash-out orders, transferring tokens from the contract to specified players.
     * Only callable by accounts with the `MANAGER_ROLE`.
     * @param orderIds List of unique identifiers for the cash-out orders.
     * @param players List of addresses of players receiving the tokens.
     * @param metacrites List of additional values representing extra information about each cash-out.
     * @param amounts List of amounts of tokens to be transferred for each cash-out.
     * Emits a `CashOut` event for each order upon successful execution.
     */
    function cashOut(
        bytes32[] memory orderIds,
        address[] memory players,
        uint256[] memory metacrites,
        uint256[] memory amounts
    ) external onlyRole(MANAGER_ROLE) {
        require(orderIds.length > 0, "INVALID_INPUT_SIZE");
        require(orderIds.length == players.length, "INVALID_INPUT_SIZE");
        require(orderIds.length == metacrites.length, "INVALID_INPUT_SIZE");
        require(orderIds.length == amounts.length, "INVALID_INPUT_SIZE");

        for (uint256 idx = 0; idx < orderIds.length; idx++) {
            require(
                cashOutOrder[orderIds[idx]].player == address(0),
                "ORDER_EXISTS"
            ); // Ensure the order ID does not already exist
            require(
                cashOutToken.balanceOf(address(this)) >= amounts[idx],
                "NO_BALANCE"
            ); // Ensure the contract has sufficient tokens

            bytes32 orderId = orderIds[idx];

            // Create and store the cash-out order
            CashOutOrder memory newCashOutOrder = CashOutOrder({
                id: orderId,
                player: players[idx],
                metacrite: metacrites[idx],
                amount: amounts[idx],
                timestamp: block.timestamp
            });
            cashOutOrder[orderId] = newCashOutOrder;
            cashOutOrdersList.push(orderId);

            // Transfer tokens to the player
            cashOutToken.transfer(players[idx], amounts[idx]);

            emit CashOut(orderId); // Emit the CashOut event
        }
    }

    /**
     * @dev Updates the ERC20 token address used for cash-out operations.
     * Can only be called by accounts with the `DEFAULT_ADMIN_ROLE`.
     * @param _token The new ERC20 token address.
     */
    function updateToken(IERC20 _token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        cashOutToken = _token;
    }

    /**
     * @dev Allows the admin to withdraw all tokens held by the contract to a specified treasury address.
     * Can only be called by accounts with the `DEFAULT_ADMIN_ROLE`.
     * @param treasury The address where the tokens will be sent.
     */
    function withdraw(
        address treasury
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 _amount = cashOutToken.balanceOf(address(this)); // Get the contract's token balance
        require(_amount > 0, "ZERO_BALANCE"); // Ensure there are tokens to withdraw
        cashOutToken.transfer(treasury, _amount); // Transfer the tokens to the treasury address
    }

    /**
     * @dev Returns the total number of cash-out orders created so far.
     * @return The total number of cash-out orders.
     */
    function getCashOutOrdersSize() public view returns (uint256) {
        return cashOutOrdersList.length;
    }

    /**
     * @dev Returns the address of the ERC20 token used for cash-out operations.
     * @return The address of the cash-out token.
     */
    function cashoutToken() public view returns (address) {
        return address(cashOutToken);
    }

    /**
     * @dev Internal function required for UUPS proxy upgradeability.
     * Ensures only accounts with the `DEFAULT_ADMIN_ROLE` can authorize upgrades to the contract.
     * @param newImplementation Address of the new implementation.
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
