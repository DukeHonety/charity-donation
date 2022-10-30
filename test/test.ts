import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { ethers } from "hardhat";
const { expect } = require("chai");
import Web3 from "web3";

describe("DDAContract Test network", () => {
  let Token;
  let ddaContract: Contract,
    tUsdtToken: Contract,
    okapiToken: Contract,
    tethToken: Contract,
    deployer: SignerWithAddress,
    donater1: SignerWithAddress,
    donater2: SignerWithAddress,
    fundRaiser1: SignerWithAddress,
    fundRaiser2: SignerWithAddress,
    charity1: SignerWithAddress;

  describe("Deploying Contracts", () => {
    it("Set accounts", async () => {
      [deployer, donater1, donater2, fundRaiser1, fundRaiser2, charity1] = await ethers.getSigners();
      console.log("deployer: ", deployer.address);
    });
    it("Deployed test usdt token", async () => {
      console.log("Deploying TUSDT token");
      const TUSDT = await ethers.getContractFactory("TUSDT");
      tUsdtToken = await TUSDT.deploy(deployer.address);
      await tUsdtToken.deployed();
      console.log("[TUSDT address] : ", tUsdtToken.address);
      console.log(
        "tusdtToken verify: ",
        `npx hardhat verify --contract "contracts/TUSDT.sol:TUSDT" --network bscTestnet ${tUsdtToken.address} ${deployer.address}`
      );
      await tUsdtToken.connect(deployer).mint(deployer.address, Web3.utils.toWei('1000000000000', 'ether')); // 10000000000 ether
      await tUsdtToken.connect(deployer).mint(donater1.address, Web3.utils.toWei('10000000000', 'ether'));
      await tUsdtToken.connect(deployer).mint(donater2.address, Web3.utils.toWei('10000000000', 'ether'));

      console.log("Deploying TETH token");
      const TETH = await ethers.getContractFactory("TETH");
      tethToken = await TETH.deploy(deployer.address);
      await tethToken.deployed();
      console.log("[TETH address] : ", tethToken.address);
      console.log(
        "tethToken verify: ",
        `npx hardhat verify --contract "contracts/TOKAPI.sol:TOKAPI" --network bscTestnet ${tethToken.address} ${deployer.address}`
      );
      await tethToken.connect(deployer).mint(deployer.address, Web3.utils.toWei('1000000000000', 'ether'));
      
      console.log("Deploying TOKAPI token");
      const OKAPI = await ethers.getContractFactory("TOKAPI");
      okapiToken = await OKAPI.deploy(deployer.address);
      await okapiToken.deployed();
      console.log("[OKAPI address] : ", okapiToken.address);
      console.log(
        "okapiToken verify: ",
        `npx hardhat verify --contract "contracts/TOKAPI.sol:TOKAPI" --network bscTestnet ${okapiToken.address} ${deployer.address}`
      );
      await okapiToken.connect(deployer).mint(deployer.address, Web3.utils.toWei('1000000000000', 'ether'));

      console.log("Deploying DDAContract token");
      // console.log("admin: ", admin.address);
      const DDAContract = await ethers.getContractFactory("DDAContract");
      ddaContract = await DDAContract.deploy(deployer.address, deployer.address, deployer.address, tUsdtToken.address, okapiToken.address);
      await ddaContract.deployed();
      console.log("DDAContract address: ", ddaContract.address);
      console.log(
        "ddaContract verify: ",
        `npx hardhat verify --contract "contracts/DDAContract.sol:DDAContract" --network bscTestnet ${ddaContract.address} ${deployer.address}`
        );
    });

  });
  describe("Doing Donates", () => {
    it("Create Charity", async () => {
      const information = {
        vip: '',
        website: '',
        name: 'Brian',
        email: 'Brian@gmail.com',
        country: 'US',
        summary: 'Help Brian Heal After Surviving a School Shooting',
        detail: 'On October 24, our godson Brian was in health class at Central Visual Performing Arts (VPA) high school in St. Louis, Missouri, when his school went on lockdown. Minutes later, a shooter entered his classroom, killing his teacher and wounding Brian and several classmates',
        photo: 'http://ipfs',
        title: 'Help Brian Heal After Surviving a School Shooting',
        location: 'Washington'
      };
      await ddaContract.connect(charity1).createCharity('0', information);
      await ddaContract.connect(fundRaiser1).createCharity('1', information);
      console.log(await ddaContract.connect(charity1).charities(0));
    });

    it("Transfer Donation", async() => {
      console.log('//////////////////////////////Do Donation//////////////////////////////');
      let weiCurrency = await tUsdtToken.balanceOf(donater1.address);
      console.log('[Donater1 currency (TUSDT):]', ethers.utils.formatEther(weiCurrency));
      const donation1 = '100';
      const donation2 = '60000';
      console.log('[Transfer donation 2 times: ' + donation1 + ' TUSDT and ' + donation2 + ' TUSDT]');

      await tUsdtToken.connect(donater1).approve(ddaContract.address, Web3.utils.toWei(donation1, 'ether'));
      await ddaContract.connect(donater1).donate('0', tUsdtToken.address, Web3.utils.toWei(donation1, 'ether')); // 10000 ether
      let charityFund = (await ddaContract.charities(0))['fund'];
      console.log('[Charity fund]', ethers.utils.formatEther(charityFund));

      await tUsdtToken.connect(donater1).approve(ddaContract.address, Web3.utils.toWei(donation2, 'ether'));
      await ddaContract.connect(donater1).donate('0', tUsdtToken.address, Web3.utils.toWei(donation2, 'ether')); // 10000 ether
      const charityVal = await tUsdtToken.balanceOf(charity1.address);

      weiCurrency = await tUsdtToken.balanceOf(donater1.address);
      console.log('[Donater1 currency (TUSDT):]', ethers.utils.formatEther(weiCurrency));
    });
  });

});

function getFinalDonation(donation){
  let val = parseInt(donation);
  if (val >= 250000) {
    val *= 0.999;
  } else if (val >= 100000) {
    val *= 0.997
  } else if (val >= 50000) {
    val *= 0.995
  } else if ( val >= 10000) {
    val *= 0.993
  } else {
    val *= 0.9;
  }
  return val;
}