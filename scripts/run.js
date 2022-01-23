const { ethers } = require("hardhat");

async function main() {
    const FactoryContract = await ethers.getContractFactory("Factory");
    const Factory = await FactoryContract.deploy();
    await Factory.deployed();
    console.log("Factory deployed to:", Factory.address);

    const MockERC20Contract = await ethers.getContractFactory("MockERC20");

    const DAI = await MockERC20Contract.deploy("DAI", "DAI", ethers.utils.parseEther("1000"));
    await DAI.deployed();
    console.log("DAI deployed to:", DAI.address);

    const cDAI = await MockERC20Contract.deploy("cDAI", "cDAI", ethers.utils.parseEther("1000"));
    await cDAI.deployed();
    console.log("cDAI deployed to:", cDAI.address);

    await Factory.createPool(DAI.address, cDAI.address);
    const pool = await Factory.lotteryPools(0);
    console.log("Pool created");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
