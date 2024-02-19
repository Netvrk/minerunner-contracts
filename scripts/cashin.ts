import { ethers, upgrades } from "hardhat";

async function main() {
  const proxyAddress = "0x9725c61fe06aa00cFE0ac8689A7C99fbcd85d4Df";
  if (proxyAddress) {
    const MRCashIn = await ethers.getContractFactory("MRCashIn");
    // const imported = await upgrades.forceImport(proxyAddress, MRCashIn);
    // console.log("MRCashIn imported from:", imported.address);
    // return;

    const cashin = await upgrades.upgradeProxy(proxyAddress, MRCashIn, {
      kind: "uups",
    });
    console.log("MRCashIn upgraded to:", cashin.address);
  } else {
    const tokenAddress = "0x73A4dC4215Dc3eb6AaE3C7AaFD2514cB34e5D983";

    const MRCashIn = await ethers.getContractFactory("MRCashIn");
    const cashin = await upgrades.deployProxy(MRCashIn, [tokenAddress], {
      kind: "uups",
    });

    await cashin.deployed();
    console.log("MRCashIn deployed to:", cashin.address);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
