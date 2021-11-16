// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract buildStringOnContract {

    string public askYear = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=";
    string public askMonth = "&refine.month=";
    string public askDay = "&refine.day=";
    string public askCountry = "&refine.country=";
    string public urlRebuiltJSON;
    
    function inputValues(string memory year, string memory month, string memory day, string memory country) public
    {
        require(bytes(month).length == 2, "JSON must have month as 2 characters at all times!");
        require(bytes(day).length == 2, "JSON must have day as 2 characters at all times!");
        urlRebuiltJSON= string( abi.encodePacked(askYear,year,askMonth,month,askDay,day,askCountry,country) );
    }


}

