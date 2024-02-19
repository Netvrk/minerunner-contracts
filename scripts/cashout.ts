import { ethers, upgrades } from "hardhat";

async function main() {
  const proxyAddress = "0xb1eBca91C5384A6ff126311328C64286265d849e";
  if (proxyAddress) {
    const MRCashOut = await ethers.getContractFactory("MRCashOut");

    // const imported = await upgrades.forceImport(proxyAddress, MRCashOut);
    // console.log("MRCashOut imported from:", imported.address);

    // return;
    const cashout = await upgrades.upgradeProxy(proxyAddress, MRCashOut, {
      kind: "uups",
    });

    await cashout.deployed();

    console.log("MRCashOut upgraded to:", cashout.address);
  } else {
    const tokenAddress = "0x4a87b8dda8784DceE58D4516a098810d8d382284";
    const managerAddress = "0xF3d66FFc6E51db57A4d8231020F373A14190567F";

    const MRCashOut = await ethers.getContractFactory("MRCashOut");
    const cashout = await upgrades.deployProxy(MRCashOut, [tokenAddress, managerAddress], {
      kind: "uups",
    });

    await cashout.deployed();

    console.log("MRCashOut deployed to:", cashout.address);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
