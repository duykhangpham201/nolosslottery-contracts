//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ILendingManager} from "../interfaces/ILendingManager.sol";
import {MockERC20} from "./MockERC20.sol";

contract MockLendingManager is ILendingManager {
    function deposit(
        address _erc20Contract,
        address _cErc20Contract,
        uint256 _numTokensToSupply
    ) public returns (uint256) {
        MockERC20 underlying = MockERC20(_erc20Contract);
        MockERC20 cToken = MockERC20(_cErc20Contract);

        underlying.approve(_cErc20Contract, _numTokensToSupply);

        cToken.burn(_numTokensToSupply);
        return _numTokensToSupply;
    }

    function redeem(
        uint256 amount,
        bool redeemType,
        address _cErc20Contract
    ) public returns (bool) {
        MockERC20 cToken = MockERC20(_cErc20Contract);

        if (redeemType == true) {
           cToken.mint(amount);
        } 

        return true;
    }
}