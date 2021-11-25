const { expect } = require("chai");
const { ethers } = require("hardhat");
provider = ethers.provider;

// checks // 
// BUYER-MAKE-POLICY
// 1 Oracle_Date > 0: [X], integration test
// 2 policySigner == 0: [IP]
// 3 msg.value == (1 x 10^16): [Y? line 50]
// 4 OpenWeiToEnsure > 0: [IP]
// if true... 
// 5 OpenWeiToEnsure -= 1*(10**18): [IP]
// 6 LockedWeiToPolicies += 1*(10**18): [IP]
// 7 policysigner = msg.sender, int coordinates, Year[oracle], Month [oracle], day [oracle]: [X], integration
// 8 payable(owner).transfer(1*(10^16)): [IP]
// if false... back to options

// BUYER-GET-REWARD
// 9 Oracle_Data > 0: [X], integration test
// 10 policies[msg.sender].AwardAmount > 0: [IP]
// 11 LAT/LONG tolernace check: [X], integration test
// 12 DatePolicySigned < EruptTime [oracle]: [X]. integration test
// if true...
// 13 LockedWeitoPolicies -= 1*(10**18) [IP]
// 14 PolicySigner + Year + Month + Day = 0: [IP]
// 15 payable(msg.snder).transfer(1*(10**18)): [IP]
// if false... back to options

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
        it("Fail tx if msg.value = 0.", async function () {
        await expect(VolcanoInsuranceDeployed.BuyerCreatePolicy()).to.be.reverted;
        });
        it("Fail tx if insurance purchased already [msg.value = (1 * 10**16)].", async function () {
                await VolcanoInsuranceDeployed.BuyerCreatePolicy({ value: ethers.utils.parseEther( ('0.001') )  } )
                await expect( VolcanoInsuranceDeployed.BuyerCreatePolicy({ value: ethers.utils.parseEther( ('0.001') )  } )   ).to.be.revertedWith('Gold is sold out already!');//'With("");
        });
      });

      describe("BuyerClaimReward", function () {
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
