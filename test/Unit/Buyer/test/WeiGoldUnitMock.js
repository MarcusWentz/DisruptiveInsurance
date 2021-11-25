const { expect } = require("chai");
const { ethers } = require("hardhat");
provider = ethers.provider;

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
          await expect(VolcanoInsuranceDeployed.BuyerCreatePolicy(500,-500)).to.be.revertedWith("DayPresent not recorded yet by oracle.");
        });
        it("Fail tx if insurance purchased already [msg.value = (1 * 10**16)].", async function () {
                await VolcanoInsuranceDeployed.BuyerCreatePolicy({ value: ethers.utils.parseEther( ('0.001') )  } )
                await expect( VolcanoInsuranceDeployed.BuyerCreatePolicy({ value: ethers.utils.parseEther( ('0.001') )  } )   ).to.be.revertedWith('Gold is sold out already!');//'With("");
        });
      });

      describe("BuyerClaimReward", function () {
        it("Day<0.", async function () {
            await expect(VolcanoInsuranceDeployed.BuyerClaimReward()).to.be.revertedWith("DayPresent not recorded yet by oracle.");
        });
          it("Fail tx if Owner address is not used for tx.", async function () {
            await expect(VolcanoInsuranceDeployed.connect(buyer2).BuyerClaimReward(7)).to.be.revertedWith('Only contract owner (deployer) can access this function.');
          });
          it("Fail tx if input matches Scale_Fee already.", async function () {
            await expect(VolcanoInsuranceDeployed.BuyerClaimReward(0)).to.be.revertedWith('Input value is already the same as Scale_Fee!');
          });
          it("Test if updating Scale_Fee = 1000 is 8000.", async function () {
            await expect( VolcanoInsuranceDeployed.BuyerClaimReward(1000))
            .to.emit(VolcanoInsuranceDeployed, "ScaleFee_StateChangeEvent")
            .withArgs(owner.address, 8000);
          });
      });

});
