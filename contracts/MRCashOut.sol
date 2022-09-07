// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract MRCashOut is AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
    }

    //  CashOut Orders
    struct CashOutOrder {
        bytes32 id;
        address player;
        uint256 amount;
        bool executed;
        uint256 requestedTime;
    }

    CashOutOrder[] public cashOutOrders;

    function requestCashOut(address player, uint256 amount)
        public
        onlyRole(MANAGER_ROLE)
        returns (CashOutOrder memory)
    {
        bytes32 orderId = keccak256(
            abi.encodePacked(
                block.timestamp,
                player,
                amount,
                cashOutOrders.length
            )
        );

        CashOutOrder memory newCashOutOrder = CashOutOrder({
            id: orderId,
            player: player,
            amount: amount,
            executed: false,
            requestedTime: block.timestamp
        });

        cashOutOrders.push(newCashOutOrder);

        return newCashOutOrder;
    }

    function executeCashOut(uint256 index)
        public
        onlyRole(MANAGER_ROLE)
        returns (bool)
    {
        require(cashOutOrders[index].executed == false, "ALREADY_REDEEMED");

        // TODO: Transfer VRK token.
        cashOutOrders[index].executed = true;

        return true;
    }

    function getCashOutOrdersSize() public view returns (uint256) {
        return cashOutOrders.length;
    }
}
