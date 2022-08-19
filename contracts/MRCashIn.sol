// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/TransferHelper.sol";

contract MRCashIn is AccessControl {
    bytes32 public constant WORKER_ROLE = keccak256("WORKER");

    IERC20 token;

    event CashIn(
        bytes32 indexed id,
        address indexed player,
        uint256 indexed amount
    );

    constructor(IERC20 _token) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(WORKER_ROLE, _msgSender());
        token = _token;
    }

    //  CashOut Orders
    struct CashInOrder {
        bytes32 id;
        address player;
        uint256 amount;
        bool executed;
        uint256 requestedTime;
    }

    CashInOrder[] public cashInOrders;

    function cashIn(uint256 _amount) public {
        require(token.balanceOf(msg.sender) >= _amount, "NO_BALANCE");

        require(
            token.allowance(msg.sender, address(this)) >= _amount,
            "NO_ALLOWANCE"
        );

        token.transferFrom(msg.sender, address(this), _amount);

        bytes32 orderId = keccak256(
            abi.encodePacked(
                block.timestamp,
                msg.sender,
                _amount,
                cashInOrders.length
            )
        );

        CashInOrder memory newCashInOrder = CashInOrder({
            id: orderId,
            player: msg.sender,
            amount: _amount,
            executed: true,
            requestedTime: block.timestamp
        });

        cashInOrders.push(newCashInOrder);

        emit CashIn(orderId, msg.sender, _amount);
    }
}
