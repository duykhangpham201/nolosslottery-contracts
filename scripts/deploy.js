const { ethers } = require("hardhat");

async function main() {
    const FactoryContract = await ethers.getContractFactory("Factory");
    const Factory = await FactoryContract.deploy();
    await Factory.deployed();
    console.log("Factory deployed to:", Factory.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
