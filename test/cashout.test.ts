import { time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";

import { Signer } from "ethers";
import { ethers, upgrades } from "hardhat";
import { VRK } from "../typechain-types";

describe("Mine Runner Cash Out Process", function () {
  let vrk: VRK;
  let cashOut: any;
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

    const MRCashOut = await ethers.getContractFactory("MRCashOut");
    cashOut = await upgrades.deployProxy(MRCashOut, [vrk.address], {
      kind: "uups",
    });

    await cashOut.deployed();
  });

  it("Shouldn't cashout if contract has no VRK token", async function () {
    await expect(cashOut.cashOut(userAddress, getWei(1))).to.be.revertedWith(
      "NO_BALANCE"
    );
  });

  it("Only manager account can cashout the reqquest", async function () {
    await expect(cashOut.connect(user).cashOut(userAddress, getWei(1))).to.be
      .reverted;
  });

  it("Cashout once contract has token", async function () {
    await vrk.transfer(cashOut.address, getWei(1000));
    await cashOut.cashOut(userAddress, getWei(1));
  });

  it("Owner withdraws remaining tokens", async function () {
    await expect(cashOut.connect(user).withdraw(ownerAddress)).to.be.reverted;

    await cashOut.withdraw(ownerAddress);
    const balance = (await vrk.balanceOf(cashOut.address)) + "";
    expect(balance).to.equal("0");

    await expect(cashOut.withdraw(ownerAddress)).to.be.revertedWith(
      "ZERO_BALANCE"
    );
  });
});
