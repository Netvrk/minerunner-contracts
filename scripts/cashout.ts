import { ethers, upgrades } from "hardhat";

async function main() {
  const tokenAddress = "0xBdf9d08524b4fa44811db044dA4328467aa14A09";
  const managerAddress = "0xF3d66FFc6E51db57A4d8231020F373A14190567F";

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
