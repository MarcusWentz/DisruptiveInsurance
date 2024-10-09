## Foundry

### Fork Base Sepolia for tests
```shell
forge coverage --fork-url $baseSepoliaHTTPS --report lcov && genhtml lcov.info -o report --branch-coverage
```
### Deploy and Verify on Base Sepolia
```shell
forge create src/VolcanoInsurance.sol:VolcanoInsurance \
--private-key $devTestnetPrivateKey \
--rpc-url $baseSepoliaHTTPS \
--etherscan-api-key $basescanApiKey \
--verify 
```