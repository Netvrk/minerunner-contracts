import { ethers, upgrades } from "hardhat";
import { Axe } from "../typechain-types";

async function main() {
  const managerAddress = "0x0417fb78c0aC3fc728C13bE94d606B36f3486A01";
  const baseURI = "https://api.netvrk.co/api/mine-runner/axe/";

  const Axe = await ethers.getContractFactory("Axe");

  const axe = (await upgrades.deployProxy(Axe, [baseURI, managerAddress], {
    kind: "uups",
  })) as Axe;

  await axe.deployed();

  console.log("AXE deployed to:", axe.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
