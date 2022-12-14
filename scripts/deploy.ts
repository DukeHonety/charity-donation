import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import hre, { ethers } from "hardhat";
import env from "dotenv";
async function main() {
  let deployer: SignerWithAddress;
  [deployer] = await ethers.getSigners();  //??

  // console.log('network: ', hre.network);

  const networkName = hre.network.name

  console.log("Deploying DDAContract");
  console.log("Deployer address: ", deployer.address);
  console.log('name: ', networkName);
  const DDAcontract = await ethers.getContractFactory("DDAContract");
  const ddaContract = await DDAcontract.deploy(deployer.address, process.env.SWAP_ROUTER_ADDRESS, process.env.USDT_ADDRESS, process.env.OKAPI_ADDRESS, process.env.ETH_USD_PRICE_ADDRESS);
  await ddaContract.deployed();
  console.log("DDAContract address: ", ddaContract.address);
  // run("verify:verify", {
  //   address: ddAContract.address,
  //   constructorArguments: [deployer.address, process.env.SWAP_ROUTER_ADDRESS, process.env.USDT_ADDRESS, process.env.OKAPI_ADDRESS, process.env.ETH_USD_PRICE_ADDRESS],
  // });
  console.log(
    "DDAContract verify:",
    `npx hardhat verify --contract "contracts/DDAContract.sol:DDAContract" --network mainnet ${ddaContract.address} ${deployer.address} ${process.env.SWAP_ROUTER_ADDRESS} ${process.env.USDT_ADDRESS} ${process.env.OKAPI_ADDRESS} ${process.env.ETH_USD_PRICE_ADDRESS}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
