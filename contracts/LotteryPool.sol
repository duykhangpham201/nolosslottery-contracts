//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ILotteryPool} from "./interfaces/ILotteryPool.sol";
import {LendingManager} from "./LendingManager.sol";
import {ICErc20} from "./interfaces/ICErc20.sol";

import {MockLendingManager} from "./mocks/MockLendingManager.sol";

contract LotteryPool is ILotteryPool, Ownable, MockLendingManager {
    IERC20 public token;
    ICErc20 public cToken;

    uint256 public totalValue;
    uint256 public POOL_FEE = 10 ** 17; //10%

    address[] public players;
    address public factory;

    mapping(address => uint256) public balance;

    constructor(address _token, address _cToken) {
        token = IERC20(_token);
        cToken = ICErc20(_cToken);
        factory = msg.sender;
    }

    function enterLottery(uint256 _amount) override public {
        require(_amount >= 0, "AMOUNT_ENTERED_INVALID");

        if (balance[msg.sender] == 0) {
            players.push(msg.sender);
            balance[msg.sender] += _amount;
        } else {
            balance[msg.sender] += _amount;
        }

        totalValue += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
        deposit(address(token), address(cToken), _amount);
        emit LotteryEntered(msg.sender, _amount);
    }

    function withdrawLottery(uint256 _amount) override public {
        require(_amount >= 0, "AMOUNT_ENTERED_INVALID");
        require(
            balance[msg.sender] > 0 && balance[msg.sender] >= _amount,
            "BALANCE_INVALID"
        );

        balance[msg.sender] -= _amount;
        emit LotteryWithdrawn(msg.sender, _amount);

        _redeemPrize(_amount);
        token.transfer(msg.sender, _amount);
    }

    function finalized() override public onlyOwner {
        address winner = _pickWinner();
        uint256 cTokenBalance = _getCTokenBalance();

        _redeemPrize(cTokenBalance);

        uint256 curBalance = token.balanceOf(address(this));
        uint256 feeBalance = curBalance * POOL_FEE;
        uint256 winnerBalance = curBalance-feeBalance;

        token.transfer(factory, feeBalance);
        token.transfer(winner, winnerBalance);
    }

    function setPoolFee(uint256 _amount) public onlyOwner {
        POOL_FEE = _amount;
    }

    function getPlayers() override public view returns (address[] memory) {
        return players;
    }

    function getBalance(address _player) override public view returns (uint256) {
        return balance[_player];
    }

    function getFactory() override public view returns (address) {
        return factory;
    }

    function getPoolFee() public view returns (uint256) {
        return POOL_FEE;
    }

    function getPlayersLength() public view returns (uint256) {
        return players.length;
    }

    function _pseudoRandomize() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, players)
                )
            );
    }

    function _pickWinner() private onlyOwner returns (address) {
        uint256 rand = _pseudoRandomize() % totalValue;
        uint256 winningIndex;

        for (uint256 i = 0; i < players.length; i++) {
            if (totalValue < rand) {
                winningIndex = i;
            } else {
                totalValue = totalValue - balance[players[i]];
            }
        }

        emit WinnerPicked(players[winningIndex]);

        return players[winningIndex];
    }

    function _redeemPrize(uint256 _amount) private {
        redeem(_amount, true, address(cToken),address(0));
    }

    function _getCTokenBalance() private view returns (uint256) {
        return cToken.balanceOf(address(this));
    }

    function mockFinalized() public onlyOwner {
        address winner = _pickWinner();
        uint256 cTokenBalance = _getCTokenBalance();

        redeem(cTokenBalance, true, address(cToken), address(token));

        uint256 curBalance = token.balanceOf(address(this));
        uint256 feeBalance = curBalance * 0;
        uint256 winnerBalance = curBalance-feeBalance;

        token.transfer(factory, feeBalance);
        token.transfer(winner, winnerBalance);
    }

}