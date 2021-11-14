// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract buildStringOnContract {

    string public askYear = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=";
    string public askMonth = "&refine.month=";
    string public askDay = "&refine.day=";
    string public askCountry = "&refine.country=";
    string public urlRebuiltJSON;
    
    function inputValues(string memory year, string memory month, string memory day, string memory country) public
    {
        urlRebuiltJSON= string( abi.encodePacked(askYear,year,askMonth,month,askDay,day,askCountry,country) );
    }


}


