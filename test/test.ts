import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { ethers } from "hardhat";
import env from 'dotenv';
import Web3 from "web3";

describe("DDAContract Test network", () => {
  let Token;
  let ddaContract: Contract,
    tusdtToken: Contract,
    deployer: SignerWithAddress,
    donater1: SignerWithAddress,
    donater2: SignerWithAddress,
    fundRaiser1: SignerWithAddress,
    fundRaiser2: SignerWithAddress,
    charity1: SignerWithAddress;

  describe("Deploying", () => {
    // it("Deployed test currencies", async () => {
    //   [deployer, donater1, donater2, fundRaiser1, fundRaiser2, charity1] = await ethers.getSigners(); //??
    //   console.log("deployer: ", deployer.address);

    //   Token = await ethers.getContractFactory("TOKAPI");
    //   tusdtToken = await Token.deploy(deployer.address);
    //   await tusdtToken.deployed();
    //   console.log("[TUSDT address] : ", tusdtToken.address);
    //   console.log(
    //     "tusdtToken verify: ",
    //     `npx hardhat verify --contract "contracts/TUSDT.sol:TOKAPI" --network goerli ${tusdtToken.address} ${deployer.address}`
    //   );
      // await tusdtToken.connect(deployer).mint(deployer.address, Web3.utils.toWei('1000000000000', 'ether')); // 10000000000 ether
      // await tusdtToken.connect(deployer).mint(donater1.address, Web3.utils.toWei('10000000000', 'ether'));
      // await tusdtToken.connect(deployer).mint(donater2.address, Web3.utils.toWei('10000000000', 'ether'));
      // await tusdtToken.connect(deployer).mint('0x61207ECa7F1C578584566c042CD15fc21801C307', Web3.utils.toWei('100000000', 'ether'));
      // await tusdtToken.connect(deployer).mint('0xb1Ae08169aa8f7F7486C71af2Cd66Ec3C15165cD', Web3.utils.toWei('100000000', 'ether'));
    // });

    it("Deployed DDAContract", async (done) => {
      [deployer] = await ethers.getSigners(); //??
      console.log("deployer: ", deployer.address);
      // console.log("admin: ", admin.address);
      const DDAContract = await ethers.getContractFactory("DDAContract");
      ddaContract = await DDAContract.deploy(deployer.address);
      await ddaContract.deployed();
      console.log("DDAContract address: ", ddaContract.address);
      console.log(
        "ddaContract verify: ",
        `npx hardhat verify --contract "contracts/DDAContract.sol:DDAContract" --network goerli ${ddaContract.address} ${deployer.address}`
        );
    });

  });
  // describe("Doing Registers", () => {
  //   it("Create Donater", async () => {
  //     console.log('////////////////Create two donaters with anme First and Second////////////////////////');
  //     await ddaContract.connect(donater1).createDonater('First');
  //     await ddaContract.connect(donater2).createDonater('Second');
  //     // await ddaContract.connect(donater1).createDonater('First');
  //     console.log(await ddaContract.donaters(donater1.address));
  //     console.log(await ddaContract.donaters(donater2.address));
  //   });

  //   it("Create Charity", async () => {
  //     console.log('////////////////Create on charity "healthcare charity"////////////////////////');
  //     /**
  //      * @param string memory name
  //      * @param string memory vip
  //      * @param string memory website
  //      * @param string memory email
  //      * @param string memory country
  //      * @param string memory summary
  //      * @param string memory detail
  //      * @param string memory photo
  //      */
  //     await ddaContract.connect(charity1)
  //           .createCharity('Healthcare Charity',
  //           'cnc-12332322',
  //           'http://healthcare.com',
  //           'HelpBrian@gmail.com',
  //           'US',
  //           'On October 24, our godson Brian was in health class at Central Visual Performing Arts (VPA) high school in St. Louis, Missouri, when his school went on lockdown',
  //           'On October 24, our godson Brian was in health class at Central Visual Performing Arts (VPA) high school in St. Louis, Missouri, when his school went on lockdown. Minutes later, a shooter entered his classroom, killing his teacher and wounding Brian and several classmates.\nBrian was shot through his hands and a bullet lodged in his jaw, missing a major artery by centimeters. After being shot, Brian and several classmates miraculously escaped through a second-story window, jumping from the building and over a fence to get to safety. Brian was treated at St. Louis Children\'s Hospital by an incredible medical team and was discharged this evening to begin his longer-term recovery and healing at home.',
  //           'file:///');
  //     console.log(await ddaContract.charities(charity1.address));
  //   });

  //   // it("Created fundRaiser", async() => {
  //   //   console.log('//////////////////////////////Create fundRaiser');
  //   //   /**
  //   //    * 
  //   //    * @param string memory title
  //   //    * @param string string memory name
  //   //    * @param string string memory email
  //   //    * @param string string memory country
  //   //    * @param string string memory location
  //   //    * @param string string memory summary
  //   //    * @param string string memory story
  //   //    * @param string string memory _type
  //   //    * @param string uint256 goal
  //   //    * @param string string memory photo
  //   //    */
  //   //   await ddaContract.connect(fundRaiser1)
  //   //         .createFundRaiser('Help Brian Heal After Surviving a School Shooting',
  //   //         'Brian',
  //   //         'HelpBrian@gmail.com',
  //   //         'US',
  //   //         'San Diego',
  //   //         'On October 24, our godson Brian was in health class at Central Visual Performing Arts (VPA) high school in St. Louis, Missouri, when his school went on lockdown',
  //   //         'On October 24, our godson Brian was in health class at Central Visual Performing Arts (VPA) high school in St. Louis, Missouri, when his school went on lockdown. Minutes later, a shooter entered his classroom, killing his teacher and wounding Brian and several classmates.\nBrian was shot through his hands and a bullet lodged in his jaw, missing a major artery by centimeters. After being shot, Brian and several classmates miraculously escaped through a second-story window, jumping from the building and over a fence to get to safety. Brian was treated at St. Louis Children\'s Hospital by an incredible medical team and was discharged this evening to begin his longer-term recovery and healing at home.',
  //   //         'Accident',
  //   //         '100000000000000000000000',
  //   //         'file:///');
  //   //   console.log(await ddaContract.fundRaisers(fundRaiser1.address));
  //   // });

  //   it("Transfer Donation", async() => {
  //     console.log('//////////////////////////////Do Donation//////////////////////////////');
  //     /**
  //      * @param string memory title
  //      */
  //     let weiCurrency = await tusdtToken.balanceOf(donater1.address);
  //     console.log('[Donater1 currency (TUSDT):]', ethers.utils.formatEther(weiCurrency));
  //     const tUsdtPrice = '1.4';
  //     const donation1 = '100';
  //     const donation2 = '60000';
  //     console.log('[Donater1 transfer donation 2 times: '+donation1+' TUSDT and '+donation2+' TUSDT]');
  //     console.log('[TUSDT price] : $'+tUsdtPrice);

  //     // await tusdtToken.connect(donater1).approve(ddaContract.address, '10000000000000000000000');
  //     let val = await ddaContract.connect(donater1).donate(charity1.address, tusdtToken.address, Web3.utils.toWei(donation1, 'ether'), Web3.utils.toWei(tUsdtPrice, 'ether')); // 10000 ether
  //     let charityFund = (await ddaContract.charities(charity1.address))['fund'];
  //     console.log('[Charity fund]', ethers.utils.formatEther(charityFund));

  //     // await ddaContract.connect(donater1).donate(fundRaiser1.address, tusdtToken.address, '60000000000000000000000'); // 10000 ether
  //     // console.log('[FundRaiser fund]',(await ddaContract.fundRaisers(fundRaiser1.address))['fund'].toString());
  //     weiCurrency = await tusdtToken.balanceOf(donater1.address);
  //     console.log('[Donater1 currency (TUSDT):]', ethers.utils.formatEther(weiCurrency));
  //   });
  // });

});
