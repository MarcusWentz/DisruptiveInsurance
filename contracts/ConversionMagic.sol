// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract buildStringOnContract {
    
        uint[] public array;
        
        function push(uint i) public {
            array.push(i);
        }
        
        function getElementValue(uint i) public view returns (uint) {
            return array[i];
        }
        
        function getAllArrayValues() public view returns (uint[] memory) {
            return array;
        }
        
        // function setIndexAsZero(uint index) public {
        //     delete array[index];//Does not change array length. Costs too much gas to rebuild array after a pop reorder.
        // }
    
//     string public askYear = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=";
//     string public askMonth = "&refine.month=";
//     string public askDay = "&refine.day=";
//     string public askCountry = "&refine.country=";
//     string public urlRebuiltJSON;
//     uint public value;


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
    
//     //
    
// // Code example:https://stackoverflow.com/questions/68976364/solidity-converting-number-strings-to-numbers
// function st2num(string memory numString) public pure returns(uint) {
//         uint  val=0;
//         bytes   memory stringBytes = bytes(numString);
//         for (uint  i =  0; i<stringBytes.length; i++) {
//             uint exp = stringBytes.length - i;
//             bytes1 ival = stringBytes[i];
//             uint8 uval = uint8(ival);
//           uint jval = uval - uint(0x30);
   
//           val +=  (uint(jval) * (10**(exp-1))); 
//         }
//       return val;
//     }
//
    
    // //CREDIT: https://stackoverflow.com/questions/47129173/how-to-convert-uint-to-string-in-solidity
    // function uint2str(uint _i) public pure returns (string memory) {
    //     if (_i == 0) {
    //         return "0";
    //     }
    //     uint j = _i;
    //     uint len;
    //     while (j != 0) {
    //         len++;
    //         j /= 10;
    //     }
    //     bytes memory bstr = new bytes(len);
    //     uint k = len;
    //     while (_i != 0) {
    //         k = k-1;
    //         uint8 temp = (48 + uint8(_i - _i / 10 * 10));
    //         bytes1 b1 = bytes1(temp);
    //         bstr[k] = b1;
    //         _i /= 10;
    //     }
    //     return string(bstr);
    // }
    
    // function inputValues(string memory year, string memory month, string memory day, string memory country) public
    // {
    //     require(bytes(month).length == 2, "JSON must have month as 2 characters at all times!");
    //     require(bytes(day).length == 2, "JSON must have day as 2 characters at all times!");
    //     urlRebuiltJSON= string( abi.encodePacked(askYear,year,askMonth,month,askDay,day,askCountry,country) );
         
    // }
    
    // function inputValuesRaw(string memory year, string memory month, string memory day, string memory country) public
    // {
    //     require(bytes(month).length == 2, "JSON must have month as 2 characters at all times!");
    //     require(bytes(day).length == 2, "JSON must have day as 2 characters at all times!");
    //     urlRebuiltJSON= string( abi.encodePacked("https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=",year,
    //     "&refine.month=",month,"&refine.day=",day,"&refine.country=",country) );
    // }
    
    // function urlRebuiltJSONUpdate(string memory filterYear, string memory filterMonth, string memory filterDay, string memory filterCountry) public {
    //     require(bytes(filterMonth).length == 2, "JSON must have MonthPresent as 2 characters at all times!");
    //     require(bytes(filterDay).length == 2, "JSON must have DayPresent as 2 characters at all times!");
    //     urlRebuiltJSON= string( abi.encodePacked("https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=",filterYear,
    //     "&refine.month=",filterMonth,"&refine.day=",filterDay,"&refine.country=",filterCountry) );
    // }    

    // int public YearS = 2020;
    // int public MonthS = 12;
    // int public DayS = 31;
    // int public YearRed;
    // int public MonthRed;
    // int public DayRed;
    // int public CompressedValue;
    
    // function TimeCompressed() public
    // {
    //     CompressedValue = (YearS<<9)+ (MonthS<<5) + DayS;
    // }

    // function TimeDecompressed() public
    // {
    //     YearRed = (CompressedValue>>9);
    //     MonthRed = (CompressedValue>>5)&15;
    //     DayRed = CompressedValue&31;

    // }

}

