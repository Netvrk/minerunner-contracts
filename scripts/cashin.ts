import { ethers, upgrades } from "hardhat";

async function main() {
  const tokenAddress = "0xFc0d6Cf33e38bcE7CA7D89c0E292274031b7157A";

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
