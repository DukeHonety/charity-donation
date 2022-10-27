import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { ethers } from "hardhat";

const hre = require("hardhat");

async function main() {
  let deployer: SignerWithAddress;
  [deployer] = await ethers.getSigners();  //??

  console.log("Deploying DDAContract");
  const Token = await hre.ethers.getContractFactory("DDAContract");
  const ddAContract = await Token.deploy(deployer.address);
  await ddAContract.deployed();
  console.log("Deployer address: ", deployer.address);
  console.log("DDAContract address: ", ddAContract.address);
  await run("verify:verify", {
    address: ddAContract.address,
    constructorArguments: [deployer.address],
  });
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
