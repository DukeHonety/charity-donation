import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { ethers } from "hardhat";

describe("DDAContract Test bsctest network", () => {
  let Token;
  let tusdtToken: Contract,
    deployer: SignerWithAddress,
    admin: SignerWithAddress;
  describe("Deploy", () => {
    it("Should deploy the contracts", async () => {
      [deployer, admin] = await ethers.getSigners();  //??
      console.log("deployer: ", deployer.address);
      // console.log("admin: ", admin.address);
      Token = await ethers.getContractFactory("DDAContract");
      tusdtToken = await Token.deploy(deployer.address);
      console.log("tusdtToken address: ", tusdtToken.address);
      console.log(
        "tusdtToken verify: ",
        `npx hardhat verify --contract "contracts/DDAContract.sol:DDAContract" --network bscTestnet ${tusdtToken.address} ${deployer.address}`
      );
    });
  });

  // describe("TUSDT Token Mint", () => {
  //   it("Should mint tokens between accounts", async () => {
  //     let tx = await tusdtToken
  //       .connect(deployer)
  //       .mint(deployer.address, "10000000000000000000000000000");
  //     await tx.wait();
  //     // tx = await tusdtToken
  //     //   .connect(admin)
  //     //   .mint(admin.address, "10000000000000000000000000000");
  //     // await tx.wait();
  //   });
  // });


});