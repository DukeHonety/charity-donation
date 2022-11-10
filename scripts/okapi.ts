import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import hre, { ethers } from "hardhat";
import env from "dotenv";
async function main() {
  let deployer: SignerWithAddress, okapiToken:Contract;
  [deployer] = await ethers.getSigners();  //??

  // console.log('network: ', hre.network);

  const networkName = hre.network.name

  console.log("Deploying OkapiToken");
  console.log("Deployer address: ", deployer.address);
  console.log('name: ', networkName);
  const OKAPI = await ethers.getContractFactory("TOKAPI");
  okapiToken = await OKAPI.deploy(deployer.address);
  await okapiToken.deployed();
  console.log("[OKAPI address] : ", okapiToken.address);
  await run("verify:verify", {
    address: okapiToken.address,
    constructorArguments: [deployer.address],
  });
  await okapiToken.connect(deployer).mint(deployer.address, Web3.utils.toWei('1000000000000', 'ether'));
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
