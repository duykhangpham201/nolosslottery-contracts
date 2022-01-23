//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {LotteryPool} from "./LotteryPool.sol";

contract Factory is Ownable {
    address[] public pools;

    event PoolCreated(address token);

    function createPool(address _token, address _cToken) public onlyOwner returns (LotteryPool){
        LotteryPool pool = new LotteryPool(_token, _cToken);
        pools.push(address(pool));

        emit PoolCreated(_token);
        return pool;
    }

}