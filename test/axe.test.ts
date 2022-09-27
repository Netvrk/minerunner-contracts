import { time } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { Signer } from "ethers";
import { ethers, upgrades } from "hardhat";
import { Axe } from "../typechain-types";

describe("Mine Runner Axe Minting", function () {
  let axe: Axe;
  let owner: Signer;
  let user: Signer;
  let ownerAddress: string;
  let userAddress: string;
  let now: number;

  // Get signer
  before(async function () {
    [owner, user] = await ethers.getSigners();
    ownerAddress = await owner.getAddress();
    userAddress = await user.getAddress();
    now = await time.latest();
  });

  it("Deploy Axe contract", async function () {
    const baseURI = "https://api.netvrk.co/api/mine-runner/axe/";

    const Axe = await ethers.getContractFactory("Axe");

    axe = (await upgrades.deployProxy(Axe, [baseURI, ownerAddress], {
      kind: "uups",
    })) as Axe;
    await axe.deployed();
  });

  it("Mint axe", async function () {
    await axe.mintItem(ownerAddress, "basic");
    const baseURI = "https://api.netvrk.co/api/mine-runner/axe/";
    expect(await axe.tokenURI(1)).to.be.equal(baseURI + "1/basic");
  });

  it("Non manager can't mint axe", async function () {
    await expect(axe.connect(user).mintItem(ownerAddress, "basic")).to.be
      .reverted;
  });

  it("Burn axe", async function () {
    await expect(axe.connect(user).burnItem(1)).to.be.reverted;
    await axe.burnItem(1);
    await expect(axe.tokenURI(1)).to.be.revertedWith(
      "ERC721: invalid token ID"
    );
  });
});
