import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { ethers } from "hardhat";

const hre = require("hardhat");

async function main() {
  let deployer: SignerWithAddress;
  [deployer] = await ethers.getSigners();  //??

  const Token = await hre.ethers.getContractFactory("TUSDT");
  const OKAPI = await Token.deploy(deployer.address);
  await OKAPI.deployed();

  await run("verify:verify", {
    address: OKAPI.address,
    constructorArguments: [deployer.address],
  });
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
