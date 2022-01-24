//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILotteryPool {
    event LotteryEntered(address player, uint256 balance);
    event LotteryWithdrawn(address player, uint256 balance);

    event WinnerPicked(address winner);

    function enterLottery(uint256 amount) external;
    function finalized() external;

    function getPlayers() external returns (address[] memory);
    function getBalance(address player) external returns (uint256);
    function getFactory() external returns (address);

}