import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contract } from "ethers";
import { ethers } from "hardhat";
import env from 'dotenv'

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
    it("Deployed test currencies", async () => {
      [deployer, donater1, donater2, fundRaiser1, fundRaiser2, charity1] = await ethers.getSigners(); //??
      console.log("deployer: ", deployer.address);
      Token = await ethers.getContractFactory("TUSDT");
      tusdtToken = await Token.deploy(deployer.address);
      await tusdtToken.deployed();
      console.log("[TUSDT address] : ", tusdtToken.address);
      console.log(
        "tusdtToken verify: ",
        `npx hardhat verify --contract "contracts/TUSDT.sol:TUSDT" --network goerli ${tusdtToken.address} ${deployer.address}`
      );
      await tusdtToken.connect(deployer).mint(deployer.address, "10000000000000000000000000000"); // 10000000000 ether
      await tusdtToken.connect(deployer).mint(donater1.address, "10000000000000000000000000000");
      await tusdtToken.connect(deployer).mint(donater2.address, "10000000000000000000000000000");
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
    it("Create Donater", async () => {
      console.log('////////////////Create two donaters with anme First and Second////////////////////////');
      await ddaContract.connect(donater1).createDonater('First');
      await ddaContract.connect(donater2).createDonater('Second');
      // await ddaContract.connect(donater1).createDonater('First');
      console.log(await ddaContract.donaters(donater1.address));
      console.log(await ddaContract.donaters(donater2.address));
    });

    it("Create Charity", async () => {
      console.log('////////////////Create on charity "healthcare charity"////////////////////////');
      /**
       * @param string memory name
       * @param string memory vip
       * @param string memory website
       * @param string memory email
       * @param string memory country
       * @param string memory summary
       * @param string memory detail
       * @param string memory photo
       */
      await ddaContract.connect(charity1)
            .createCharity('Healthcare Charity',
            'cnc-12332322',
            'http://healthcare.com',
            'HelpBrian@gmail.com',
            'US',
            'On October 24, our godson Brian was in health class at Central Visual Performing Arts (VPA) high school in St. Louis, Missouri, when his school went on lockdown',
            'On October 24, our godson Brian was in health class at Central Visual Performing Arts (VPA) high school in St. Louis, Missouri, when his school went on lockdown. Minutes later, a shooter entered his classroom, killing his teacher and wounding Brian and several classmates.\nBrian was shot through his hands and a bullet lodged in his jaw, missing a major artery by centimeters. After being shot, Brian and several classmates miraculously escaped through a second-story window, jumping from the building and over a fence to get to safety. Brian was treated at St. Louis Children\'s Hospital by an incredible medical team and was discharged this evening to begin his longer-term recovery and healing at home.',
            'file:///');
      console.log(await ddaContract.charities(charity1.address));
    });

    // it("Created fundRaiser", async() => {
    //   console.log('//////////////////////////////Create fundRaiser');
    //   /**
    //    * 
    //    * @param string memory title
    //    * @param string string memory name
    //    * @param string string memory email
    //    * @param string string memory country
    //    * @param string string memory location
    //    * @param string string memory summary
    //    * @param string string memory story
    //    * @param string string memory _type
    //    * @param string uint256 goal
    //    * @param string string memory photo
    //    */
    //   await ddaContract.connect(fundRaiser1)
    //         .createFundRaiser('Help Brian Heal After Surviving a School Shooting',
    //         'Brian',
    //         'HelpBrian@gmail.com',
    //         'US',
    //         'San Diego',
    //         'On October 24, our godson Brian was in health class at Central Visual Performing Arts (VPA) high school in St. Louis, Missouri, when his school went on lockdown',
    //         'On October 24, our godson Brian was in health class at Central Visual Performing Arts (VPA) high school in St. Louis, Missouri, when his school went on lockdown. Minutes later, a shooter entered his classroom, killing his teacher and wounding Brian and several classmates.\nBrian was shot through his hands and a bullet lodged in his jaw, missing a major artery by centimeters. After being shot, Brian and several classmates miraculously escaped through a second-story window, jumping from the building and over a fence to get to safety. Brian was treated at St. Louis Children\'s Hospital by an incredible medical team and was discharged this evening to begin his longer-term recovery and healing at home.',
    //         'Accident',
    //         '100000000000000000000000',
    //         'file:///');
    //   console.log(await ddaContract.fundRaisers(fundRaiser1.address));
    // });

    it("Transfer Donation", async() => {
      console.log('//////////////////////////////Do Donation');
      /**
       * @param string memory title
       */
      console.log('[Donater1 currency:]', (await tusdtToken.balanceOf(donater1.address)).toString());
      console.log('[Donater1 transfer donation 2 times: 100 TUSDT and 60000 TUSDT]');
      const tUsdtPrice = '1200000000000000000';
      console.log('[TUSDT price] : $1.2');

      // await tusdtToken.connect(donater1).approve(ddaContract.address, '10000000000000000000000');
      let val = await ddaContract.connect(donater1).donate(charity1.address, tusdtToken.address, ethers.utils.parseUnits('100', 'ethers'), tUsdtPrice); // 10000 ether
      let charityFund = (await ddaContract.charities(charity1.address))['fund'];
      console.log('[Charity fund]', await ethers.utils.formatEther(charityFund));

      // await ddaContract.connect(donater1).donate(fundRaiser1.address, tusdtToken.address, '60000000000000000000000'); // 10000 ether
      // console.log('[FundRaiser fund]',(await ddaContract.fundRaisers(fundRaiser1.address))['fund'].toString());

      console.log('[Donater1 currency:]', (await tusdtToken.balanceOf(donater1.address)).toString());
    });
  });

});
