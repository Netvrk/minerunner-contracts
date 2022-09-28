import { ethers, upgrades } from "hardhat";

async function main() {
  const tokenAddress = "0x57A070070Ca386f8Ea72ffB771141f031364EFDD";

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
