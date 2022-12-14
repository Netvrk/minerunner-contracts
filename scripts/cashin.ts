import { ethers, upgrades } from "hardhat";

async function main() {
  const tokenAddress = "0xC515cf29a5781692DFa8D26f41E4e5f01E9F41eB";

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
