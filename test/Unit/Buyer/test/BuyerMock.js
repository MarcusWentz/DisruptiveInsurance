const { expect } = require("chai");
const { ethers } = require("hardhat");
provider = ethers.provider;

var chai = require('chai');
const BN = require('bn.js');
chai.use(require('chai-bn')(BN));

describe("Volcano Insurance Tests:", function () {

      let VolcanoInsurance;
      let VolcanoInsuranceDeployed;
      let owner;
      let buyer1;
      let buyer2;
      let addrs;

      beforeEach(async function () {

        VolcanoInsurance = await ethers.getContractFactory('VolcanoInsurance');
        VolcanoInsuranceDeployed = await VolcanoInsurance.deploy();
        [owner, buyer1, buyer2, ...addrs] = await ethers.getSigners();
        await VolcanoInsuranceDeployed.deployed();
      });

      describe("Constructor", function () {
          it("Owner is equal to default ethers.getSigners() address.", async function () {
              expect(await VolcanoInsuranceDeployed.Owner()).to.equal(owner.address);
          });
       });

      describe("BuyerCreatePolicy", function () {
        it("Day<0.", async function () {
          await expect(VolcanoInsuranceDeployed.BuyerCreatePolicy(500,-500)).to.be.revertedWith("DayPresent not recorded yet by oracle.");
        });
        it("Month<0.", async function () {
          await VolcanoInsuranceDeployed.mockOraclePresentTime(1,0,0)
          await expect(VolcanoInsuranceDeployed.BuyerCreatePolicy(500,-500)).to.be.revertedWith("MonthPresent not recorded yet by oracle.");
        });
        it("Year<0.", async function () {
          await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,0)
          await expect(VolcanoInsuranceDeployed.BuyerCreatePolicy(500,-500)).to.be.revertedWith("YearPresent not recorded yet by oracle.");
        });
        it("Owner != msg.sender", async function () {
          await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2020)
          await expect(VolcanoInsuranceDeployed.BuyerCreatePolicy(500,-500)).to.be.revertedWith("Error: Owner cannot self-insure");
        });
        it("OpenWEItoInsure > 0", async function () {
          await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2020)
          await expect(VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(500,-500)).to.be.revertedWith("There is no open ETH in the contract currently.");
        });
        it("msg.value == (1*10**16)", async function () {
          const valueTest = "1000000000000000000"
          await VolcanoInsuranceDeployed.mockOwnerAddFunds(new ethers.BigNumber.from(valueTest) )
          await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2020)

          console.log("AAAAAAAAAAAA: ")

          const value1 = await VolcanoInsuranceDeployed.OpenWEItoInsure()
          console.log("OPEN: ", new ethers.BigNumber.from(value1._hex).toString())

          const value2 = await VolcanoInsuranceDeployed.LockedWEItoPolicies()
          console.log("LOCKED: ", new ethers.BigNumber.from(value2._hex).toString())

          console.log("AAAAAAAAAAAA: ")

          await expect(VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(500,-500)).to.be.revertedWith("Error: Please submit your request with insurance contribution of 0.001 Ether");
        });
        it("Check all states for valid transaction", async function () {
          await VolcanoInsuranceDeployed.mockOwnerAddFunds(1)
          await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2020)
          await VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(500,-500, { value: ethers.utils.parseEther("0.01") }   );
          await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2020)
          await VolcanoInsuranceDeployed.mockOwnerAddFunds(1)
          await expect(VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(500,-500, { value: ethers.utils.parseEther("0.01") } ) ).to.be.revertedWith("Error: You've already purchased insurance");
        });
      });

      describe("BuyerClaimReward", function () {
          it("Day<0.", async function () {
            await expect(VolcanoInsuranceDeployed.BuyerClaimReward()).to.be.revertedWith("DayEruption not recorded yet by oracle.");
          });
          it("Month<0.", async function () {
            await VolcanoInsuranceDeployed.mockOracleVolcano(0,0,1,0,0)
            await expect(VolcanoInsuranceDeployed.BuyerClaimReward()).to.be.revertedWith("MonthEruption not recorded yet by oracle.");
          });
          it("Year<0.", async function () {
            await VolcanoInsuranceDeployed.mockOracleVolcano(0,0,1,1,0)
            await expect(VolcanoInsuranceDeployed.BuyerClaimReward()).to.be.revertedWith("YearEruption not recorded yet by oracle.");
          });
          it("LatitudeEruption != 0 || LongitudeEruption != 0", async function () {
            await VolcanoInsuranceDeployed.mockOracleVolcano(0,0,1,1,2020)
            await expect(VolcanoInsuranceDeployed.BuyerClaimReward()).to.be.revertedWith("Lat and Long cannot both be 0. Wait for oracle response.");
          });
          it("policies[msg.sender].EthereumAwardTiedToAddress > 0", async function () {
            await VolcanoInsuranceDeployed.mockOracleVolcano(0,100,1,1,2020)
            await expect(VolcanoInsuranceDeployed.BuyerClaimReward()).to.be.revertedWith("Error: You don't have a policy");
          });
      });

});
