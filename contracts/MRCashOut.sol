// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract MRCashOut is AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER");
    IERC20 cashOutToken;

    event CashOut(bytes32 indexed orderId);

    //  CashOut Orders

    struct CashOutOrder {
        bytes32 id;
        address player;
        uint256 metacrite;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(bytes32 => CashOutOrder) public cashOutOrder;
    bytes32[] public cashOutOrdersList;

    function initialize(IERC20 _token, address manager) public initializer {
        __UUPSUpgradeable_init();
        __Context_init_unchained();
        __AccessControl_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, manager);

        cashOutToken = _token;
    }

    /**
    ////////////////////////////////////////////////////
    // Public functions
    ///////////////////////////////////////////////////
    */

    // Cashout order to player

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
            );
            require(
                cashOutToken.balanceOf(address(this)) >= amounts[idx],
                "NO_BALANCE"
            );
            bytes32 orderId = orderIds[idx];
            CashOutOrder memory newCashOutOrder = CashOutOrder({
                id: orderId,
                player: players[idx],
                metacrite: metacrites[idx],
                amount: amounts[idx],
                timestamp: block.timestamp
            });
            cashOutOrder[orderId] = newCashOutOrder;
            cashOutOrdersList.push(orderId);
            cashOutToken.transfer(players[idx], amounts[idx]);
            emit CashOut(orderId);
        }
    }

    // Update token address
    function updateToken(IERC20 _token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        cashOutToken = _token;
    }

    // Withdraw all tokens from contract by owner
    function withdraw(
        address treasury
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 _amount = cashOutToken.balanceOf(address(this));
        require(_amount > 0, "ZERO_BALANCE");
        cashOutToken.transfer(treasury, _amount);
    }

    /**
    ////////////////////////////////////////////////////
    // View only functions
    ///////////////////////////////////////////////////
    */

    function getCashOutOrdersSize() public view returns (uint256) {
        return cashOutOrdersList.length;
    }

    // Return token address
    function tokenUsed() public view returns (address) {
        return address(cashOutToken);
    }

    /**
    ////////////////////////////////////////////////////
    // Internal functions
    ///////////////////////////////////////////////////
    */

    // UUPS proxy function

    function _authorizeUpgrade(
        address
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}
}
