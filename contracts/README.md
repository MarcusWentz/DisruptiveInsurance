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

### Fork Base Sepolia for tests
```shell
forge coverage --fork-url $baseSepoliaHTTPS --report lcov && genhtml lcov.info -o report --branch-coverage
```
### For Mac OS
```shell
forge coverage --fork-url $baseSepoliaHTTPS --report lcov && genhtml lcov.info -o report --branch-coverage --ignore-errors inconsistent,corrupt lcov.info
```

### Deploy and Verify on Base Sepolia
```shell
forge create src/VolcanoInsurance.sol:VolcanoInsurance \
--private-key $devTestnetPrivateKey \
--rpc-url $baseSepoliaHTTPS \
--etherscan-api-key $basescanApiKey \
--verify 
```