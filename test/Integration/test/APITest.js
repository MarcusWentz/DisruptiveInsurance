const { expect } = require('chai');
const LinkTokenABI = '[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"},{"name":"_data","type":"bytes"}],"name":"transferAndCall","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_subtractedValue","type":"uint256"}],"name":"decreaseApproval","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_addedValue","type":"uint256"}],"name":"increaseApproval","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"},{"indexed":false,"name":"data","type":"bytes"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]'

var chai = require('chai');
const BN = require('bn.js');
chai.use(require('chai-bn')(BN));

  describe('VolcanoInsurance Integration Tests', async function () {

    let apiConsumer

    beforeEach(async () => {
      const APIConsumer = await ethers.getContractFactory('VolcanoInsurance');
      apiConsumer = await APIConsumer.deploy();
      await apiConsumer.deployed();
    })
    it('OracleRequestVolcanoEruptionData: YearEruption,MonthEruption,DayEruption,LatitudeEruption,LongitudeEruption updated.', async () => {
      const accounts = await ethers.getSigners()
      const signer = accounts[0]
      const linkTokenContract = new ethers.Contract('0x01BE23585060835E02B77ef475b0Cc51aA1e0709',LinkTokenABI, signer)
      var transferTransaction = await linkTokenContract.transfer(apiConsumer.address,'50000000000000000')
      await transferTransaction.wait()
      console.log('hash:' + transferTransaction.hash)
      const transaction = await apiConsumer.OracleRequestVolcanoEruptionData("1727","08","03","Iceland")
      const tx_receipt = await transaction.wait()
      const requestId = tx_receipt.events[0].topics[1]
      await new Promise(resolve => setTimeout(resolve, 30000))
      const resultYear = await apiConsumer.YearEruption()
      const resultMonth = await apiConsumer.MonthEruption()
      const resultDay = await apiConsumer.DayEruption()
      const resultLAT = await apiConsumer.LatitudeEruption()
      const resultLONG = await apiConsumer.LongitudeEruption()
      console.log("DayEruption: ", new ethers.BigNumber.from(resultDay._hex).toString())
      expect(new ethers.BigNumber.from(resultDay._hex).toString()).to.be.a.bignumber.that.is.greaterThan(new ethers.BigNumber.from(0).toString())
      console.log("MonthEruption: ", new ethers.BigNumber.from(resultMonth._hex).toString())
      expect(new ethers.BigNumber.from(resultMonth._hex).toString()).to.be.a.bignumber.that.is.greaterThan(new ethers.BigNumber.from(0).toString())
      console.log("DayEruption: ", new ethers.BigNumber.from(resultYear._hex).toString())
      expect(new ethers.BigNumber.from(resultYear._hex).toString()).to.be.a.bignumber.that.is.greaterThan(new ethers.BigNumber.from(0).toString())
      console.log("LatitudeEruption: ", new ethers.BigNumber.from(resultLAT._hex).toString())
      expect(new ethers.BigNumber.from(resultLAT._hex).toString()).to.be.a.bignumber.that.is.greaterThan(new ethers.BigNumber.from(0).toString())
      console.log("LongitudeEruption: ", new ethers.BigNumber.from(resultLONG._hex).toString())
      expect(new ethers.BigNumber.from(resultLONG._hex).toString()).to.be.a.bignumber.that.is.lessThan(new ethers.BigNumber.from(0).toString())
    })
    it('OracleRequestPresentTime: PresentYear,PresentMonth,PresentDay updated.', async () => {
      const accounts = await ethers.getSigners()
      const signer = accounts[0]
      const linkTokenContract = new ethers.Contract('0x01BE23585060835E02B77ef475b0Cc51aA1e0709',LinkTokenABI, signer)
      var transferTransaction = await linkTokenContract.transfer(apiConsumer.address,'30000000000000000')
      await transferTransaction.wait()
      console.log('hash:' + transferTransaction.hash)
      const transaction = await apiConsumer.OracleRequestPresentTime()
      const tx_receipt = await transaction.wait()
      const requestId = tx_receipt.events[0].topics[1]
      await new Promise(resolve => setTimeout(resolve, 30000))
      const resultYear = await apiConsumer.YearPresent()
      const resultMonth = await apiConsumer.MonthPresent()
      const resultDay = await apiConsumer.DayPresent()
      console.log("YearPresent: ", new ethers.BigNumber.from(resultDay._hex).toString())
      expect(new ethers.BigNumber.from(resultDay._hex).toString()).to.be.a.bignumber.that.is.greaterThan(new ethers.BigNumber.from(0).toString())
      console.log("MonthPresent: ", new ethers.BigNumber.from(resultMonth._hex).toString())
      expect(new ethers.BigNumber.from(resultMonth._hex).toString()).to.be.a.bignumber.that.is.greaterThan(new ethers.BigNumber.from(0).toString())
      console.log("DayPresent: ", new ethers.BigNumber.from(resultYear._hex).toString())
      expect(new ethers.BigNumber.from(resultYear._hex).toString()).to.be.a.bignumber.that.is.greaterThan(new ethers.BigNumber.from(0).toString())
    })
  })
