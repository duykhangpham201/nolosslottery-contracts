//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILendingManager {
    event LendingLog(string, uint256);

    function deposit(
        address _erc20Contract,
        address _cErc20Contract,
        uint256 _numTokensToSupply
    ) external returns (uint);

     function redeem(
        uint256 amount,
        bool redeemType,
        address _cErc20Contract
    ) external returns (bool);
}