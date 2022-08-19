import { ethers } from "hardhat";

async function main() {
  const tokenAddress = "0xceF87024a2CD1E29CdBf85eFCeBd5b78d74A640d";

  const MRCashIn = await ethers.getContractFactory("MRCashIn");
  const cashin = await MRCashIn.deploy(tokenAddress);

  await cashin.deployed();

  console.log("MRCashIn deployed to:", cashin.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
