const { ethers } = await import('npm:ethers@6.10.0');
const apiResponse = await Functions.makeHttpRequest({url: `https://userclub.opendatasoft.com/api/explore/v2.1/catalog/datasets/les-eruptions-volcaniques-dans-le-monde/records?limit=20&refine=country%3A%22United%20States%22&refine=date%3A%221980%2F05%22`});
if (apiResponse.error) {console.error(apiResponse.error);throw Error('Request failed');}
const { data } = apiResponse;
console.log('API response data:');
const dateNow = data.results[0].date;
console.log(dateNow);
const timeUnix = Math.floor(new Date(dateNow).getTime() / 1000);
console.log(timeUnix);
const latRaw = data.results[0].coordinates.lat;
console.log(latRaw);
const latScaled = latRaw*100;
console.log(latScaled);
const lonRaw = data.results[0].coordinates.lon;
console.log(lonRaw);
const lonScaled = lonRaw*100;
console.log(lonScaled);
console.log('Ethers.js version: ', ethers.version); 
const abiCoder = ethers.AbiCoder.defaultAbiCoder();
const encodedAbiString = abiCoder.encode(['uint256', 'int16', 'int16'],[ 327456000 , 4620 , -12218 ]);
console.log(encodedAbiString);
console.log(ethers.getBytes(encodedAbiString));
return ethers.getBytes(encodedAbiString);
// // For Chainlink Functions playground, use the return string to simulate.
// // In the contract we will need to return the bytes value though.
// // You can switch the return type on the drop down by clicking it on the right.
// return Functions.encodeString(encodedAbi);

// Encoded value should be:
// const encodedAbi = "0x0000000000000000000000000000000000000000000000000000000013849500000000000000000000000000000000000000000000000000000000000000120cffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd046"

// Script on 1 line:
// "const { ethers } = await import('npm:ethers@6.10.0'); const apiResponse = await Functions.makeHttpRequest({url: `https://userclub.opendatasoft.com/api/explore/v2.1/catalog/datasets/les-eruptions-volcaniques-dans-le-monde/records?limit=20&refine=country%3A%22United%20States%22&refine=date%3A%221980%2F05%22`}); if (apiResponse.error) {console.error(apiResponse.error);throw Error('Request failed');} const { data } = apiResponse; console.log('API response data:'); const dateNow = data.results[0].date; console.log(dateNow); const timeUnix = Math.floor(new Date(dateNow).getTime() / 1000); console.log(timeUnix); const latRaw = data.results[0].coordinates.lat; console.log(latRaw); const latScaled = latRaw*100; console.log(latScaled); const lonRaw = data.results[0].coordinates.lon; console.log(lonRaw); const lonScaled = lonRaw*100; console.log(lonScaled); console.log('Ethers.js version: ', ethers.version); const abiCoder = ethers.AbiCoder.defaultAbiCoder(); const encodedAbiString = abiCoder.encode(['uint256', 'int16', 'int16'],[ 327456000 , 4620 , -12218 ]); console.log(encodedAbiString); console.log(ethers.getBytes(encodedAbiString)); return ethers.getBytes(encodedAbiString);"