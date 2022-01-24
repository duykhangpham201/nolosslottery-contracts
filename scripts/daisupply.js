const { ethers } = require("hardhat");

async function main() {
    const FactoryAddress = "0x97bb7e81e6fFCE94dac6D29eaF047ea505d352EF"

    const Factory = await ethers.getContractAt("Factory", FactoryAddress);

    const DAI = "0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa";
    const cDAI = "0x6d7f0754ffeb405d23c51ce938289d4835be3b14";

    await Factory.createPool(DAI, cDAI );
    const pool = await Factory.lotteryPools(0);
    console.log("Pool created at:", pool);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
