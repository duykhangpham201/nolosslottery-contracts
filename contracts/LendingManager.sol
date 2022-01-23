//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICErc20} from "./interfaces/ICErc20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ILendingManager} from "./interfaces/ILendingManager.sol";

contract LendingManager is ILendingManager {
    function deposit(
        address _erc20Contract,
        address _cErc20Contract,
        uint256 _numTokensToSupply
    ) override public returns (uint256) {
        IERC20 underlying = IERC20(_erc20Contract);
        ICErc20 cToken = ICErc20(_cErc20Contract);

        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit LendingLog("Exchange Rate (scaled up): ", exchangeRateMantissa);

        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit LendingLog("Supply Rate: (scaled up)", supplyRateMantissa);

        underlying.approve(_cErc20Contract, _numTokensToSupply);

        uint256 mintResult = cToken.mint(_numTokensToSupply);
        return mintResult;
    }

    function redeem(
        uint256 amount,
        bool redeemType,
        address _cErc20Contract
    ) override public returns (bool) {
        ICErc20 cToken = ICErc20(_cErc20Contract);

        // `amount` is scaled up, see decimal table here:
        // https://compound.finance/docs#protocol-math

        uint256 redeemResult;

        if (redeemType == true) {
            redeemResult = cToken.redeem(amount);
        } else {
            redeemResult = cToken.redeemUnderlying(amount);
        }

        emit LendingLog("If this is not 0, there was an error", redeemResult);
        return true;
    }
}