import { ethers, upgrades } from "hardhat";
import { Axe } from "../typechain-types";

async function main() {
  const managerAddress = "0xF3d66FFc6E51db57A4d8231020F373A14190567F";
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
