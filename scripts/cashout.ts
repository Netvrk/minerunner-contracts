import { ethers, upgrades } from "hardhat";

async function main() {
  const tokenAddress = "0xceF87024a2CD1E29CdBf85eFCeBd5b78d74A640d";

  const MRCashOut = await ethers.getContractFactory("MRCashOut");
  const cashout = await upgrades.deployProxy(MRCashOut, [tokenAddress], {
    kind: "uups",
  });

  await cashout.deployed();

  console.log("MRCashOut deployed to:", cashout.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
