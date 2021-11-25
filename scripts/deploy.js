const main = async () => {
    
    const volcanoInsuranceContractFactory = await hre.ethers.getContractFactory('VolcanoInsurance');
    const volcanoInsuranceContract = await volcanoInsuranceContractFactory.deploy();
    await volcanoInsuranceContract.deployed();
    console.log("VolcanoInsurance contract deployed to:", volcanoInsuranceContract.address);

};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(0);
    }
};

runMain();