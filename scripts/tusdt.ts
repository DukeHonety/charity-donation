import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import hre, { ethers } from "hardhat";
import env from "dotenv";
async function main() {
  let deployer: SignerWithAddress, tUsdtToken:Contract;
  [deployer] = await ethers.getSigners();  //??

  // console.log('network: ', hre.network);

  const networkName = hre.network.name

  console.log("Deploying TUSDT token");
  const TUSDT = await ethers.getContractFactory("TUSDT");
  tUsdtToken = await TUSDT.deploy(deployer.address);
  await tUsdtToken.deployed();
  console.log("[TUSDT address] : ", tUsdtToken.address);
  await run("verify:verify", {
    address: tUsdtToken.address,
    constructorArguments: [deployer.address],
  });
  await tUsdtToken.connect(deployer).mint(deployer.address, Web3.utils.toWei('1000000000000', 'ether')); // 10000000000 ether
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
