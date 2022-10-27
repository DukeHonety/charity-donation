import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { ethers } from "hardhat";

describe("DDAContract Test goerli network", () => {
  let Token;
  let tusdtToken: Contract,
    deployer: SignerWithAddress,
    admin: SignerWithAddress;
//   describe("Work doDonation", () => {
//     it("Should deploy the contracts", async () => {
//       [deployer] = await ethers.getSigners(); //??
//       console.log("deployer: ", deployer.address);
//       // console.log("admin: ", admin.address);
//       Token = await ethers.getContractFactory("DDAContract");
//       tusdtToken = await Token.deploy(deployer.address);
//       console.log("tusdtToken address: ", tusdtToken.address);
//       console.log(
//         "tusdtToken verify: ",
//         `npx hardhat verify --contract "contracts/DDAContract.sol:DDAContract" --network goerli ${tusdtToken.address} ${deployer.address}`
//       );
//     });
//   });

  describe("Deploy", () => {
    it("Should deploy the contracts", async () => {
      [deployer] = await ethers.getSigners();  //??
      console.log("deployer: ", deployer.address);
      // console.log("admin: ", admin.address);
      Token = await ethers.getContractFactory("TUSDT");
      tusdtToken = await Token.deploy(deployer.address);
      console.log("tusdtToken address: ", tusdtToken.address);
      console.log(
        "tusdtToken verify: ",
        `npx hardhat verify --contract "contracts/TUSDT.sol:TUSDT" --network goerli ${tusdtToken.address} ${deployer.address}`
      );
    });
  });

  describe("TUSDT Token Mint", () => {
    it("Should mint tokens between accounts", async () => {
      let tx = await tusdtToken
        .connect(deployer)
        .mint(deployer.address, "1000000000000000000000000");
      await tx.wait();
      // tx = await tusdtToken
      //   .connect(admin)
      //   .mint(admin.address, "10000000000000000000000000000");
      // await tx.wait();
    });
  });
});
