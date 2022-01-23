//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ILendingManager} from "../interfaces/ILendingManager.sol";
import {MockERC20} from "./MockERC20.sol";

contract MockLendingManager {
    function deposit(
        address _erc20Contract,
        address _cErc20Contract,
        uint256 _numTokensToSupply
    ) public returns (uint256) {
        MockERC20 underlying = MockERC20(_erc20Contract);
        MockERC20 cToken = MockERC20(_cErc20Contract);

        underlying.approve(_cErc20Contract, _numTokensToSupply);

        underlying.burn(_numTokensToSupply);
        cToken.mint(_numTokensToSupply);
        return _numTokensToSupply;
    }

    function redeem(
        uint256 amount,
        bool redeemType,
        address _cErc20Contract,
        address _erc20Contract
    ) public returns (bool) {
        MockERC20 cToken = MockERC20(_cErc20Contract);
        MockERC20 underlying = MockERC20(_erc20Contract);

        
        if (redeemType == true) {
           cToken.burn(amount);
           underlying.mint(amount);
        } 

        return true;
    }
}