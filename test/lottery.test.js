const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LotteryPool contract", () => {

  let PoolContract;
  let Pool;
  let DAI;
  let cDAI;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async () => {
    PoolContract = await ethers.getContractFactory("LotteryPool");
    [owner, addr1, addr2 ] = await ethers.getSigners();

    const MockERC20Contract = await ethers.getContractFactory("MockERC20");
    DAI = await MockERC20Contract.deploy("DAI", "DAI", 0);
    cDAI = await MockERC20Contract.deploy("cDAI", "cDAI", 0);

    await DAI.connect(addr1).mint(100000);
    await DAI.connect(addr2).mint(100000);

    Pool = await PoolContract.deploy(DAI.address,cDAI.address);
  });


  describe("Initialize", () => {
    it("Factory Owner", async () => {
        expect(await Pool.getFactory()).to.equal(owner.address);
    });

    it("Owner Balance == 0", async () => {
        const balance = await Pool.getBalance(owner.address);
        expect(balance).to.equal(0);
    });

    it("Players List == empty", async () => {
        expect(await Pool.getPlayersLength()).to.equal(0);
    });

  });

  describe("Enter Lottery", () => {
    beforeEach(async() =>{
        await DAI.connect(addr1).approve(Pool.address, ethers.utils.parseEther("100"));
        await DAI.connect(addr2).approve(Pool.address, ethers.utils.parseEther("100"));
    });

    it("Pool Balance", async() => {
        const txn = await Pool.connect(addr1).enterLottery(5);
        txn.wait();
        expect(await cDAI.balanceOf(Pool.address)).to.be.equal(5);
        expect(await Pool.totalValue()).to.be.equal(5);
    });

    it("Player registry", async() => {
        let txn;

        txn = await Pool.connect(addr1).enterLottery(5);
        txn.wait();

        txn = await Pool.connect(addr2).enterLottery(2);
        txn.wait(); 

        expect(await Pool.getPlayersLength()).to.be.equal(2);
        expect(await Pool.players(0)).to.be.equal(addr1.address);
        expect(await Pool.players(1)).to.be.equal(addr2.address);
    });

    it("Check balance", async() => {
        let txn;

        txn = await Pool.connect(addr1).enterLottery(5);
        txn.wait();

        txn = await Pool.connect(addr1).enterLottery(2);
        txn.wait(); 

        expect(await Pool.balance(addr1.address)).to.be.equal(7);
    });
  });
})