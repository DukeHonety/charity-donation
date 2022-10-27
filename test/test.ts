import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { ethers } from "hardhat";
describe("DDAContract Test network", () => {
  let Token;
  let ddaContract: Contract,
    tusdtToken: Contract,
    deployer: SignerWithAddress,
    admin: SignerWithAddress;
  describe("Deploying", () => {
    it("Deployed test currencies", async () => {
      [deployer] = await ethers.getSigners(); //??
      console.log("deployer: ", deployer.address);
      // console.log("admin: ", admin.address);
      Token = await ethers.getContractFactory("TUSDT");
      tusdtToken = await Token.deploy(deployer.address);
      await tusdtToken.deployed();
      console.log("TUSDT address: ", tusdtToken.address);
      console.log(
        "tusdtToken verify: ",
        `npx hardhat verify --contract "contracts/TUSDT.sol:TUSDT" --network goerli ${tusdtToken.address} ${deployer.address}`
      );
      let tx = await tusdtToken
        .connect(deployer)
        .mint(deployer.address, "10000000000000000000000000000");
      await tx.wait();
    });

    it("Deployed DDAContract", async () => {
      [deployer] = await ethers.getSigners(); //??
      console.log("deployer: ", deployer.address);
      // console.log("admin: ", admin.address);
      Token = await ethers.getContractFactory("DDAContract");
      ddaContract = await Token.deploy(deployer.address);
      await ddaContract.deployed();
      console.log("DDAContract address: ", ddaContract.address);
      console.log(
        "ddaContract verify: ",
        `npx hardhat verify --contract "contracts/DDAContract.sol:DDAContract" --network goerli ${ddaContract.address} ${deployer.address}`
      );
    });
  });
  describe("Doing Registers", () => {
    ddaContract.connect(env.)
    ddaContract.method.createDonater();
  });

  // describe("Deploy", () => {
  //   it("Should deploy the contracts", async () => {
  //     [deployer] = await ethers.getSigners();  //??
  //     console.log("deployer: ", deployer.address);
  //     // console.log("admin: ", admin.address);
  //     Token = await ethers.getContractFactory("TUSDT");
  //     tusdtToken = await Token.deploy(deployer.address);
  //     await tusdtToken.deployed();
  //     console.log("tusdtToken address: ", tusdtToken.address);
  //     console.log(
  //       "tusdtToken verify: ",
  //       `npx hardhat verify --contract "contracts/TUSDT.sol:TUSDT" --network bscTestnet ${tusdtToken.address} ${deployer.address}`
  //     );
  //   });
  // });

  // describe("TUSDT Token Mint", () => {
  //   it("Should mint tokens between accounts", async () => {
  //     let tx = await tusdtToken
  //       .connect(deployer)
  //       .mint(deployer.address, "1000000000000000000000000");
  //     await tx.wait();
  //     // tx = await tusdtToken
  //     //   .connect(admin)
  //     //   .mint(admin.address, "10000000000000000000000000000");
  //     // await tx.wait();
  //   });
  // });
});
