const axios = require("axios");

getJsonValues()

async function getJsonValues() {

    // let baseUrl = "http://127.0.0.1:8080/"
	// let baseUrl = "https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam";
    // Removed "www." and the request still works.
	let baseUrl = "https://timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam";
    let responseRawJSON = await axios.get(baseUrl);
    let responseDataJSON = responseRawJSON.data;
    console.log(responseRawJSON)
    console.log(responseDataJSON)
    console.log(responseDataJSON.year)
    console.log(responseDataJSON.month)
    console.log(responseDataJSON.day)
}