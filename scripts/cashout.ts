import { ethers, upgrades } from "hardhat";

async function main() {
  const tokenAddress = "0x73A4dC4215Dc3eb6AaE3C7AaFD2514cB34e5D983";
  const managerAddress = "0x0417fb78c0aC3fc728C13bE94d606B36f3486A01";

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
