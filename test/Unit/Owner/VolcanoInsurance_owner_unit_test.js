const { ethers } = require("hardhat");
const { expect } = require('chai');

var chai = require('chai');
const BN = require('bn.js');
chai.use(require('chai-bn')(BN));

provider = ethers.provider;


/*
 * Tests for owner-related functions in VolcanoInsurance contract
*/

describe('VolcanoCoordinate Owner Unit Tests', function () {

    let VolcanoCoordinate;
    let VolcanoCoordinateDeployed;
    let SelfDestructSendOneEthereum;
    let SelfDestructSendOneEthereumDeployed;
    let owner;

    beforeEach(async function () {
        VolcanoCoordinate = await ethers.getContractFactory('VolcanoInsuranceOwnerMock');
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        VolcanoCoordinateDeployed = await VolcanoCoordinate.deploy();
        SelfDestructSendOneEthereum = await ethers.getContractFactory("SelfDestructSendOneEthereumMock");
        SelfDestructSendOneEthereumDeployed = await SelfDestructSendOneEthereum.deploy(VolcanoCoordinateDeployed.address);
    });

    describe("Constructor", function () {
        it("Owner is equal to default ethers.getSigners() address.", async function () {
            expect(await VolcanoCoordinateDeployed.Owner()).to.equal(owner.address);
        });
        it("Another address is not contract owner.", async function () {
            expect(await VolcanoCoordinateDeployed.Owner()).not.equal(addr1.address);
        });
    });

    describe("OwnerSendOneEthToContractFromInsuranceBusiness", function () {
        it("Owner calls without sending ETH", async function () {
            await expect(VolcanoCoordinateDeployed.OwnerSendOneEthToContractFromInsuranceBusiness())
                .to.be.revertedWith("Value sent must equal 1 ETH");
        });
        it("Owner calls sending msg.value != 1 ETH", async function () {
            expect(VolcanoCoordinateDeployed.OwnerSendOneEthToContractFromInsuranceBusiness(
                { value: ethers.utils.parseEther('1.1') }
                    )
                )
                .to.be.revertedWith("Value sent must equal 1 ETH");
        });
        it("Owner calls sending msg.value == 1 ETH && OpenWEItoInsure == 1 after call", async function () {
            let oneEth = '1000000000000000000'
            await VolcanoCoordinateDeployed.OwnerSendOneEthToContractFromInsuranceBusiness(
                { value: ethers.utils.parseEther('1') }
                )
            expect(await VolcanoCoordinateDeployed.OpenWEItoInsure()).to.equal(ethers.BigNumber.from(oneEth));
        });
        it("Non-owner calls sending msg.value == 1 ETH -> reverts", async function () {
            await expect(VolcanoCoordinateDeployed.connect(addr1).OwnerSendOneEthToContractFromInsuranceBusiness(
                    { value: ethers.utils.parseEther('1')
                    })
                )
                .to.be.revertedWith("Only contract owner can interact with this contract");
        });
    });

    describe("OwnerLiquidtoOpenETHToWithdraw", function () {
        it("Non-owner calls -> reverts", async function() {
            await expect(VolcanoCoordinateDeployed.connect(addr1).OwnerLiquidtoOpenETHToWithdraw())
                .to.be.revertedWith("Only contract owner can interact with this contract");
        });
        it("Owner calls while OpenWEItoInsure == 0 -> reverts", async function() {
            await expect(VolcanoCoordinateDeployed.OwnerLiquidtoOpenETHToWithdraw())
                .to.be.revertedWith("There is no open ETH in the contract currently.");
        });
        it("Owner calls while OpenWEItoInsure > 0 -> success", async function() {
            await VolcanoCoordinateDeployed.OwnerSendOneEthToContractFromInsuranceBusiness(
                {value: ethers.utils.parseEther('1')
            })
            await expect(VolcanoCoordinateDeployed.OwnerLiquidtoOpenETHToWithdraw())
                .to.be.ok;
        });
    });

    describe("OwnerSelfDestructClaimETH", function () {
        it("Self destruct tx sending 1 ETH. Then Withdraw tx. Balance should be 0 after Withdraw.", async function () {
            await SelfDestructSendOneEthereumDeployed.attack(
                { value: ethers.utils.parseEther('1')});
            await VolcanoCoordinateDeployed.OwnerSelfDestructClaimETH();
            expect(await provider.getBalance(VolcanoCoordinateDeployed.address)).to.equal(0);
        });
        it("Call without sending ETH -> revert", async function () {
            await expect(VolcanoCoordinateDeployed.OwnerSelfDestructClaimETH())
                .to.be
                .revertedWith("No self destruct detected (address(this).balance == (LockedWEItoPolicies+OpenWEItoInsure))");
        });
    });

    describe("OwnerClaimExpiredPolicyETH", function () {
        it("No expired policies -> revert", async function () {
            await VolcanoCoordinateDeployed.OwnerSendOneEthToContractFromInsuranceBusiness(
                {value: ethers.utils.parseEther('1')}
                )
            await VolcanoCoordinateDeployed.connect(addr1).BuyerCreateMockPolicy(
                48, 8, 2021, 04, 19, {value: ethers.utils.parseEther('1')}
                )
            await VolcanoCoordinateDeployed.setMockPresentDates(2021, 11, 25);
            await expect(VolcanoCoordinateDeployed.OwnerClaimExpiredPolicyETH(addr1.address))
                .to.be.revertedWith("Policy has not yet expired");
        });
        it("Owner calls on address that's not tied to a policy", async function () {
            await VolcanoCoordinateDeployed.setMockPresentDates(2021, 11, 25);
            await expect(VolcanoCoordinateDeployed.OwnerClaimExpiredPolicyETH(addr1.address))
                .to.be.revertedWith("Policy does not exist.");
        });
        it("Owner calls on expired policy, but DayPresent == 0 -> revert", async function () {
            await VolcanoCoordinateDeployed.OwnerSendOneEthToContractFromInsuranceBusiness(
                {value: ethers.utils.parseEther('1')}
                )
            await VolcanoCoordinateDeployed.connect(addr1).BuyerCreateMockPolicy(
                48, 8, 2008, 10, 31, {value: ethers.utils.parseEther('1')}
                )
            await VolcanoCoordinateDeployed.setMockPresentDates(2021, 11, 0);
            await expect(VolcanoCoordinateDeployed.OwnerClaimExpiredPolicyETH(addr1.address))
                .to.be.revertedWith("DayPresent not recorded yet by oracle.");
        });
        it("Owner calls on expired policy, but MonthPresent == 0 -> revert", async function () {
            await VolcanoCoordinateDeployed.OwnerSendOneEthToContractFromInsuranceBusiness(
                {value: ethers.utils.parseEther('1')}
                )
            await VolcanoCoordinateDeployed.connect(addr1).BuyerCreateMockPolicy(
                48, 8, 2008, 10, 31, {value: ethers.utils.parseEther('1')}
                )
            await VolcanoCoordinateDeployed.setMockPresentDates(2021, 0, 25);
            await expect(VolcanoCoordinateDeployed.OwnerClaimExpiredPolicyETH(addr1.address))
                .to.be.revertedWith("MonthPresent not recorded yet by oracle.");
        });
        it("Owner calls on expired policy, but YearPresent == 0 -> revert", async function () {
            await VolcanoCoordinateDeployed.OwnerSendOneEthToContractFromInsuranceBusiness(
                {value: ethers.utils.parseEther('1')}
                )
            await VolcanoCoordinateDeployed.connect(addr1).BuyerCreateMockPolicy(
                48, 8, 2008, 10, 31, {value: ethers.utils.parseEther('1')}
                )
            await VolcanoCoordinateDeployed.setMockPresentDates(0, 11, 25);
            await expect(VolcanoCoordinateDeployed.OwnerClaimExpiredPolicyETH(addr1.address))
                .to.be.revertedWith("YearPresent not recorded yet by oracle.");
        });
        it("Owner calls on expired policy, claiming ETH from expired policy", async function () {
            await VolcanoCoordinateDeployed.OwnerSendOneEthToContractFromInsuranceBusiness(
                {value: ethers.utils.parseEther('1')}
                )
            await VolcanoCoordinateDeployed.connect(addr1).BuyerCreateMockPolicy(
                48, 8, 2008, 10, 31, {value: ethers.utils.parseEther('1')}
                )
            await VolcanoCoordinateDeployed.setMockPresentDates(2021, 11, 25);
            await expect(VolcanoCoordinateDeployed.OwnerClaimExpiredPolicyETH(addr1.address))
                .to.be.ok;
        });
    });
})