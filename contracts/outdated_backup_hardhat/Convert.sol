// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.10;

// contract Convert{
    
//     function DateCompareForm(uint YearInput, uint MonthInput, uint DayInput) public pure returns(uint){
//         return ( (YearInput<<9) + (MonthInput<<5) + DayInput ) ;
//     }
    
//     function bytes32ToUint(bytes32 oracleBytes32Convert) public pure returns(uint){
//         return stringToUint(bytes32ToString(oracleBytes32Convert));
//     }
        
//     function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) { //CREDIT https://ethereum.stackexchange.com/questions/2519/how-to-convert-a-bytes32-to-string/2834
//         uint8 i = 0;
//         while(i < 32 && _bytes32[i] != 0) {
//             i++;
//         }
//         bytes memory bytesArray = new bytes(i);
//         for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
//             bytesArray[i] = _bytes32[i];
//         }
//         return string(bytesArray);
//     }
    
//     function stringToUint(string memory numString) public pure returns(uint) { //CREDIT: https://stackoverflow.com/questions/68976364/solidity-converting-number-strings-to-numbers
//         uint  val=0;
//         bytes   memory stringBytes = bytes(numString);
//         for (uint  i =  0; i<stringBytes.length; i++) {
//             uint exp = stringBytes.length - i;
//             bytes1 ival = stringBytes[i];
//             uint8 uval = uint8(ival);
//            uint jval = uval - uint(0x30);
   
//            val +=  (uint(jval) * (10**(exp-1))); 
//         }
//       return val;
//     }
    
// }
