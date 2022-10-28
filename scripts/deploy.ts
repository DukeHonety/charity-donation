import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import hre, { ethers } from "hardhat";


async function main() {
  let deployer: SignerWithAddress;
  [deployer] = await ethers.getSigners();  //??

  console.log('network: ', hre.network);


  const networkName = hre.network.name

  console.log("Deploying DDAContract");
  console.log("Deployer address: ", deployer.address);
  console.log('name: ', networkName);
  const DDAcontract = await ethers.getContractFactory("DDAContract");
  const ddAContract = await DDAcontract.deploy(deployer.address);
  await ddAContract.deployed();
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
