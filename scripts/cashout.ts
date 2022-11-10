import { ethers, upgrades } from "hardhat";

async function main() {
  const tokenAddress = "0x73A4dC4215Dc3eb6AaE3C7AaFD2514cB34e5D983";
  const managerAddress = "0x88d87c6fEFEAEA269823699e0d4F6900B2F2A9E8";

  const MRCashOut = await ethers.getContractFactory("MRCashOut");
  const cashout = await upgrades.deployProxy(
    MRCashOut,
    [tokenAddress, managerAddress],
    {
      kind: "uups",
    }
  );

  await cashout.deployed();

  console.log("MRCashOut deployed to:", cashout.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
