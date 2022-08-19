import { ethers } from "hardhat";

async function main() {
  const MRCashOut = await ethers.getContractFactory("MRCashOut");
  const cashout = await MRCashOut.deploy();

  await cashout.deployed();

  console.log("MRCashOut deployed to:", cashout.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
