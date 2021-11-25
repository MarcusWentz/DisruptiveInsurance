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
          await VolcanoInsuranceDeployed.mockOwnerAddFunds(new ethers.BigNumber.from('1000000000000000000') )
          await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2020)
          await expect(VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(500,-500)).to.be.revertedWith("Error: Please submit your request with insurance contribution of 0.001 Ether");
        });
        it("locked", async function () {
          await VolcanoInsuranceDeployed.mockOwnerAddFunds(new ethers.BigNumber.from('1000000000000000000') )
          await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2020)
          const transaction = await VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(500,-500, { value: ethers.utils.parseEther("0.01") } )
          const tx_receipt = await transaction.wait()
          result1 = await VolcanoInsuranceDeployed.OpenWEItoInsure();
          result2 = await VolcanoInsuranceDeployed.LockedWEItoPolicies();
          console.log('OPEN:  ' + new ethers.BigNumber.from(result1._hex).toString())
          expect((new ethers.BigNumber.from(result1._hex).toString())).to.be.a.bignumber.that.is.equal(new ethers.BigNumber.from('0').toString())
          console.log('LOCKED:  ' + new ethers.BigNumber.from(result2._hex).toString())
          expect((new ethers.BigNumber.from(result2._hex).toString())).to.be.a.bignumber.that.is.equal(new ethers.BigNumber.from('1000000000000000000').toString())
        });
        it("Check all states for valid transaction", async function () {
          await VolcanoInsuranceDeployed.mockOwnerAddFunds(new ethers.BigNumber.from('1000000000000000000') )
          await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2020)
          await VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(500,-500, { value: ethers.utils.parseEther("0.01") }   );
          await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2020)
          await VolcanoInsuranceDeployed.mockOwnerAddFunds(new ethers.BigNumber.from('1000000000000000000'))
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
          // it("convert.DateCompareForm(policies[msg.sender].YearSigned,policies[msg.sender].MonthSigned,policies[msg.sender].DaySigned) < convert.DateCompareForm(YearEruption,MonthEruption,DayEruption)", async function () {
          //   await VolcanoInsuranceDeployed.mockOracleVolcano(0,100,2,1,1)
          //   await VolcanoInsuranceDeployed.mockOwnerAddFunds(new ethers.BigNumber.from('1000000000000000000'))
          //   await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,1)
          //   await VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(0,100, { value: ethers.utils.parseEther("0.01") }   );
          //   await expect(VolcanoInsuranceDeployed.connect(buyer1).BuyerClaimReward()).to.be.revertedWith("Policy was signed after eruption");
          // });
          it("policies[msg.sender].LongitudeInsured >=  (LongitudeEruption-100) && policies[msg.sender].LongitudeInsured <=  (LongitudeEruption+100)", async function () {
            await VolcanoInsuranceDeployed.mockOracleVolcano(0,2,1,1,2020)
            await VolcanoInsuranceDeployed.mockOwnerAddFunds(new ethers.BigNumber.from('1000000000000000000'))
            await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2019)
            await VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(0,1000, { value: ethers.utils.parseEther("0.01") }   );
            await expect(VolcanoInsuranceDeployed.connect(buyer1).BuyerClaimReward()).to.be.revertedWith("Must be within 1 long coordinate point.");
          });
          it("policies[msg.sender].LatitudeInsured >=  (LatitudeEruption-100) && policies[msg.sender].LatitudeInsured <=  (LatitudeEruption+100)", async function () {
            await VolcanoInsuranceDeployed.mockOracleVolcano(0,2,1,1,2020)
            await VolcanoInsuranceDeployed.mockOwnerAddFunds(new ethers.BigNumber.from('1000000000000000000'))
            await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2019)
            await VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(1000,2, { value: ethers.utils.parseEther("0.01") }   );
            await expect(VolcanoInsuranceDeployed.connect(buyer1).BuyerClaimReward()).to.be.revertedWith("Must be within 1 lat coordinate point.");
          });
          it("LockedWEItoPolicies -=(1*(10**18));", async function () {
            await VolcanoInsuranceDeployed.mockOracleVolcano(3,2,1,1,2020)
            await VolcanoInsuranceDeployed.mockOwnerAddFunds(new ethers.BigNumber.from('1000000000000000000'))
            await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2019)
            await VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(3,2, { value: ethers.utils.parseEther("0.01") }   );
            const transaction = await VolcanoInsuranceDeployed.connect(buyer1).BuyerClaimReward();
            const tx_receipt = await transaction.wait()
            const result1 = await VolcanoInsuranceDeployed.LockedWEItoPolicies();
            // const result2 = await provider.getBalance(VolcanoInsuranceDeployed.address);
          // console.log('LOCKED:  ' + new ethers.BigNumber.from(result2._hex).toString())
            expect((new ethers.BigNumber.from(result1._hex).toString())).to.be.a.bignumber.that.is.equal(new ethers.BigNumber.from('0').toString())
            // expect(await provider.getBalance(VolcanoInsuranceDeployed.address)).to.equal(0);
            // expect((new ethers.BigNumber.from(result2._hex).toString())).to.be.a.bignumber.that.is.equal(new ethers.BigNumber.from('0').toString())


          });
          // it("LockedWEItoPolicies", async function () {
          //   await VolcanoInsuranceDeployed.mockOracleVolcano(3,2,1,1,2020)
          //   await VolcanoInsuranceDeployed.mockOwnerAddFunds(1)
          //   await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2019)
          //   await VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(3,2, { value: ethers.utils.parseEther("0.01") }   );
          //   result2 = await VolcanoInsuranceDeployed.YearEruption();
          //   // console.log('LOCKED:  ' + new ethers.BigNumber.from(result1._hex).toString())
          //   expect((new ethers.BigNumber.from(result2._hex).toString())).to.be.a.bignumber.that.is.equal(new ethers.BigNumber.from('0').toString())
          //   // expect(await provider.getBalance(VolcanoInsuranceDeployed.address)).to.equal(0);
          // });
          // it("Final", async function () {
          //   await VolcanoInsuranceDeployed.mockOracleVolcano(3,2,1,1,2020)
          //   await VolcanoInsuranceDeployed.mockOwnerAddFunds(1)
          //   await VolcanoInsuranceDeployed.mockOraclePresentTime(1,1,2019)
          //   await VolcanoInsuranceDeployed.connect(buyer1).BuyerCreatePolicy(3,2, { value: ethers.utils.parseEther("0.01") }   );
          //   await VolcanoInsuranceDeployed.connect(buyer1).BuyerClaimReward()
          //
          //   expect(await provider.getBalance(VolcanoInsuranceDeployed.address)).to.equal(0);
          // });
      });

});
