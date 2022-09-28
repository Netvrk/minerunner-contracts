import { ethers, upgrades } from "hardhat";

async function main() {
  const tokenAddress = "0x57A070070Ca386f8Ea72ffB771141f031364EFDD";

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
