import { ethers, upgrades } from "hardhat";

async function main() {
  const tokenAddress = "0x26b02E156F8C5968A6c2c3B8112CC89552DAF3a2";

  const MRCashIn = await ethers.getContractFactory("MRCashIn");
  const cashin = await upgrades.deployProxy(MRCashIn, [tokenAddress], {
    kind: "uups",
  });

  await cashin.deployed();

  console.log("MRCashIn deployed to:", cashin.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
