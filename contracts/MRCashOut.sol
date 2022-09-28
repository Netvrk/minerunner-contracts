// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MRCashOut is AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER");
    IERC20 cashOutToken;

    event CashOutRequest(
        bytes32 indexed id,
        address indexed player,
        uint256 indexed amount
    );

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
        uint256 requestedTime;
        bool executed;
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

    function requestCashOut(uint256 _amount)
        external
        returns (CashOutOrder memory)
    {
        bytes32 orderId = keccak256(
            abi.encodePacked(
                block.timestamp,
                _msgSender(),
                _amount,
                cashOutOrdersList.length
            )
        );

        CashOutOrder memory newCashOutOrder = CashOutOrder({
            id: orderId,
            player: _msgSender(),
            amount: _amount,
            requestedTime: block.timestamp,
            executed: false
        });

        cashOutOrder[orderId] = newCashOutOrder;
        cashOutOrdersList.push(orderId);

        emit CashOutRequest(orderId, _msgSender(), _amount);

        return newCashOutOrder;
    }

    function cashOut(bytes32 orderId)
        external
        onlyRole(MANAGER_ROLE)
        returns (bool)
    {
        CashOutOrder memory order = cashOutOrder[orderId];
        require(order.executed == false, "ALREADY_CASHED_OUT");
        require(
            cashOutToken.balanceOf(address(this)) >= order.amount,
            "NO_BALANCE"
        );

        cashOutOrder[orderId].executed = true;

        cashOutToken.transfer(_msgSender(), order.amount);

        emit CashOut(orderId, _msgSender(), order.amount);

        return true;
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
