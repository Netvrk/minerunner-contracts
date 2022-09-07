// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "hardhat/console.sol";

contract MRCashIn is OwnableUpgradeable, UUPSUpgradeable {
    IERC20 cashInToken;

    event CashIn(
        bytes32 indexed id,
        address indexed player,
        uint256 indexed amount
    );

    function initialize(IERC20 _token) public initializer {
        __UUPSUpgradeable_init();
        __Context_init_unchained();
        __Ownable_init_unchained();
        cashInToken = _token;
    }

    //  CashIn Orders
    struct CashInOrder {
        bytes32 id;
        address player;
        uint256 amount;
        bool executed;
        uint256 requestedTime;
    }

    mapping(bytes32 => CashInOrder) public cashInOrder;
    bytes32[] public cashInOrdersList;

    function cashIn(uint256 _amount) external {
        require(cashInToken.balanceOf(msg.sender) >= _amount, "NO_BALANCE");

        require(
            cashInToken.allowance(msg.sender, address(this)) >= _amount,
            "NO_ALLOWANCE"
        );

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

        cashInToken.transferFrom(msg.sender, address(this), _amount);

        emit CashIn(orderId, msg.sender, _amount);
    }

    function withdraw(address treasury) external virtual onlyOwner {
        require(address(this).balance > 0, "ZERO_BALANCE");
        uint256 _amount = cashInToken.balanceOf(address(this));
        cashInToken.transfer(treasury, _amount);
    }

    function getCashInOrdersSize() public view returns (uint256) {
        return cashInOrdersList.length;
    }

    // UUPS proxy function
    function _authorizeUpgrade(address) internal override onlyOwner {}
}
