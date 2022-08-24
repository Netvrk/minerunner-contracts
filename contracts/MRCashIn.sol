// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/TransferHelper.sol";

contract MRCashIn is Ownable {
    IERC20 token;

    event CashIn(
        bytes32 indexed id,
        address indexed player,
        uint256 indexed amount
    );

    constructor(IERC20 _token) {
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

    mapping(bytes32 => CashInOrder) public cashInOrder;
    bytes32[] public cashInOrdersList;

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
                cashInOrdersList.length
            )
        );

        CashInOrder memory newCashInOrder = CashInOrder({
            id: orderId,
            player: msg.sender,
            amount: _amount,
            executed: true,
            requestedTime: block.timestamp
        });

        cashInOrder[orderId] = newCashInOrder;
        cashInOrdersList.push(orderId);

        emit CashIn(orderId, msg.sender, _amount);
    }

    function getCashInOrdersSize() public view returns (uint256) {
        return cashInOrdersList.length;
    }
}
