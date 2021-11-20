const main = async () => {
    
    /**
     * Constructor values for RandomNumberConsumer.sol (inherits VRFConsumerBase)
     * 
     * Network: Rinkeby
     * Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK token address:                0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */

    // const randomContractFactory = await hre.ethers.getContractFactory('RandomNumberConsumer');
    // const randomContract = await randomContractFactory.deploy();
    // await randomContract.deployed();
    // console.log("RandomNumberConsumer contract deployed to:", randomContract.address);
    
    const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
    const nftContract = await nftContractFactory.deploy('0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B',
        '0x01BE23585060835E02B77ef475b0Cc51aA1e0709',
        '0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311',
        '100000000000000000');
    await nftContract.deployed();
    console.log("MyEpicNFT contract deployed to:", nftContract.address);
    

    // // Call the function
    // let txn = await nftContract.makeAnEpicNFT()
    // // Wait for it to be mined
    // await txn.wait()
    // console.log("Minted NFT #1")

    // txn = await nftContract.makeAnEpicNFT()
    // // Wait for it to be mined
    // await txn.wait()
    // console.log("Minted NFT #2")
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