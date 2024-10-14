# Disruptive Insurance

## Overview 

Disruptive Insurance is an exotic insurance service that allows users to buy insurance against volcano eruptions.\
No other insurance business on Earth offers volcano eruption insurance.

## Website

Fleek (IPFS+FILECOIN): 

https://disruptiveinsurance.on.fleek.co/

[Github Pages Backup]: 

https://marcuswentz.github.io/DisruptiveInsurance/

## Contract

Verified contract code on Etherscan using Foundry: 

### Chainlink Functions 

#### No Input Arguments (Single Eruption Event Example)

https://sepolia.basescan.org/address/0x8122cceafd962445aeea21a9fb44dec1390015c0#code

#### Input Arguments (Filter Eruption Events)

???

## Video demo: 

https://www.youtube.com/watch?v=zM4xjX2BJxg

[![Watch the video](https://github.com/MarcusWentz/InsureDisruption/blob/main/Images/structure.png)](https://www.youtube.com/watch?v=zM4xjX2BJxg)

## Buyer

### Buy policy:
```
1. Record address, time, input coordinates and locked Owner ETH for policy.
```
  
### Claim Reward from qualified policy:
```
1. Oracle: Get filtered volcano eruption data (time, coordinates)
2. Check if policy is older than eruption date and the coordinates are within + or - 1 coordinate point.
3. Policy holder claims 1 ETH if Step 2 checks are true then deletes policy data.
```
## Owner:

Get paid ETH directly after a policy is bought.

### Attract Buyers:
```
1.Add funds to make policies available with OwnerSendOneEthToContractFromInsuranceBusiness.
```
### Claim ETH
   
#### Expired Claim:
```
1.Check if policy connected to a mapped address is over 1 year old.
2.Liquidate ETH from policy and delete policy data.
``` 
#### Claim ETH not tied to policy
```
1.Check if OpenETHtoInsure is greater than 0.
2.Claim one ETH from contract.
``` 
## Foundry 

:warning: Note: you might need to add libraries in forge with remappings.txt :warning:

## Install Chainlink libraries
```
forge install smartcontractkit/chainlink-brownie-contracts --no-commit
```
### Install Solmate Library
```
forge install rari-capital/solmate --no-commit
```
### Install BokkyPooBahsDateTimeLibrary
```
forge install https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary --no-commit
```
### Deploy contract on Base Sepolia testnet:
```
forge create src/VolcanoInsurance.sol:VolcanoInsurance \
--private-key $devTestnetPrivateKey \
--rpc-url $baseSepoliaHTTPS \
--etherscan-api-key $basescanApiKey \
--verify 
```
### Verify contract manually if it fails to verify 
```
forge verify-contract \
--chain-id 84532 \
--watch \
--etherscan-api-key $basescanApiKey \
<sepolia_contract_address> \
src/VolcanoInsurance.sol:VolcanoInsurance
```
