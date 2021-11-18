// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract buildStringOnContract {

    // string public askYear = "https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=";
    // string public askMonth = "&refine.month=";
    // string public askDay = "&refine.day=";
    // string public askCountry = "&refine.country=";
    string public urlRebuiltJSON;
    
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
    
    function urlRebuiltJSONUpdate(string memory filterYear, string memory filterMonth, string memory filterDay, string memory filterCountry) public {
        require(bytes(filterMonth).length == 2, "JSON must have MonthPresent as 2 characters at all times!");
        require(bytes(filterDay).length == 2, "JSON must have DayPresent as 2 characters at all times!");
        urlRebuiltJSON= string( abi.encodePacked("https://public.opendatasoft.com/api/records/1.0/search/?dataset=significant-volcanic-eruption-database&q=&refine.year=",filterYear,
        "&refine.month=",filterMonth,"&refine.day=",filterDay,"&refine.country=",filterCountry) );
    }    

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

