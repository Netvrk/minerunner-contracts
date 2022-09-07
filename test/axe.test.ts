import { time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Axe } from "../typechain-types";

describe("Mine Runner Axe Minting", function () {
  let axe: Axe;
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

  it("Deploy Axe contract", async function () {
    const Axe = await ethers.getContractFactory("Axe");
    const baseURI = "https://api.netvrk.co/api/mine-runner/axe/";
    axe = await Axe.deploy(baseURI);
    await axe.deployed();
  });

  it("Mint axe", async function () {
    await axe.mintItem(ownerAddress, "basic");
    const baseURI = "https://api.netvrk.co/api/mine-runner/axe/";
    expect(await axe.tokenURI(1)).to.be.equal(baseURI + "1/basic");
  });
});
