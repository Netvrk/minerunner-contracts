import { time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";

import { Signer } from "ethers";
import { ethers, upgrades } from "hardhat";
import { VRK } from "../typechain-types";

describe("Mine Runner Cash In Process", function () {
  let vrk: VRK;
  let cashIn: any;
  let owner: Signer;
  let user: Signer;
  let ownerAddress: string;
  let userAddress: string;
  let now: number;

  function getWei(ethAmt: number) {
    return ethers.utils.parseEther(ethAmt.toString());
  }

  // Get signer
  before(async function () {
    [owner, user] = await ethers.getSigners();
    ownerAddress = await owner.getAddress();
    userAddress = await user.getAddress();
    now = await time.latest();
  });

  it("Deploy VRK Token and Cashin Contract.", async function () {
    const VRK = await ethers.getContractFactory("VRK");
    vrk = await VRK.deploy();
    await vrk.deployed();

    const MRCashIn = await ethers.getContractFactory("MRCashIn");
    cashIn = await upgrades.deployProxy(MRCashIn, [vrk.address], {
      kind: "uups",
    });

    await cashIn.deployed();
  });

  it("Check balance and allowance", async function () {
    await expect(cashIn.cashIn(getWei(1))).to.be.revertedWith("NO_ALLOWANCE");
    await vrk.approve(cashIn.address, getWei(100));

    await cashIn.cashIn(getWei(1));

    const cashInSize = await cashIn.getCashInOrdersSize();

    expect(cashInSize + "").to.equal("1");

    await expect(cashIn.connect(user).cashIn(getWei(1))).to.be.revertedWith(
      "NO_BALANCE"
    );
  });

  it("Withdraw collected tokens", async function () {
    await expect(cashIn.connect(user).withdraw(ownerAddress)).to.be.reverted;

    await cashIn.withdraw(ownerAddress);
    const balance = (await vrk.balanceOf(cashIn.address)) + "";
    expect(balance).to.equal("0");

    await expect(cashIn.withdraw(ownerAddress)).to.be.revertedWith(
      "ZERO_BALANCE"
    );
  });
});
