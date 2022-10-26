// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const adminAddress = "0xF5EB5549306b4c05B7D40b91500d3eB440c4576a";

  const Token = await hre.ethers.getContractFactory("OKAPI");
  const OKAPI = await Token.deploy(adminAddress);
  await OKAPI.deployed();

  await run("verify:verify", {
    address: OKAPI.address,
    constructorArguments: [adminAddress],
  });
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
