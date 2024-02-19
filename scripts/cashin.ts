import { ethers, upgrades } from "hardhat";

async function main() {
  const proxyAddress = "0x0CbFDD0D3554dB71d3b7b4787d708A8E364EAf75";
  if (proxyAddress) {
    const MRCashIn = await ethers.getContractFactory("MRCashIn");
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
