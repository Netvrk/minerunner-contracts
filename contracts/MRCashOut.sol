// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MRCashOut is AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER");
    IERC20 cashOutToken;

    event CashOut(
        bytes32 indexed id,
        address indexed player,
        uint256 indexed amount
    );

    //  CashOut Orders
    struct CashOutOrder {
        bytes32 id;
        address player;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(bytes32 => CashOutOrder) public cashOutOrder;
    bytes32[] public cashOutOrdersList;

    function initialize(IERC20 _token) public initializer {
        __UUPSUpgradeable_init();
        __Context_init_unchained();
        __AccessControl_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());

        cashOutToken = _token;
    }

    function cashOut(address player, uint256 amount)
        external
        onlyRole(MANAGER_ROLE)
    {
        require(cashOutToken.balanceOf(address(this)) >= amount, "NO_BALANCE");

        bytes32 orderId = keccak256(
            abi.encodePacked(
                block.timestamp,
                player,
                amount,
                cashOutOrdersList.length
            )
        );

        CashOutOrder memory newCashOutOrder = CashOutOrder({
            id: orderId,
            player: player,
            amount: amount,
            timestamp: block.timestamp
        });

        cashOutOrder[orderId] = newCashOutOrder;
        cashOutOrdersList.push(orderId);

        cashOutToken.transfer(player, amount);

        emit CashOut(orderId, player, amount);
    }

    function withdraw(address treasury)
        external
        virtual
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        uint256 _amount = cashOutToken.balanceOf(address(this));
        require(_amount > 0, "ZERO_BALANCE");
        cashOutToken.transfer(treasury, _amount);
    }

    function getCashOutOrdersSize() public view returns (uint256) {
        return cashOutOrdersList.length;
    }

    // UUPS proxy function
    function _authorizeUpgrade(address)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
