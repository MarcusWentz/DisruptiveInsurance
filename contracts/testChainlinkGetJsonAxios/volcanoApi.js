const axios = require("axios");

getJsonValues()

async function getJsonValues() {

    // let baseUrl = "http://127.0.0.1:8080/"
    // // Filter interface:
    // https://userclub.opendatasoft.com/explore/dataset/les-eruptions-volcaniques-dans-le-monde/api/?disjunctive.country&refine.country=Iceland&refine.date=1727%2F08%2F03
	let baseUrl = 
    "https://userclub.opendatasoft.com/api/explore/v2.1/catalog/datasets/les-eruptions-volcaniques-dans-le-monde/records?limit=20&refine=country%3A%22Iceland%22&refine=date%3A%221727%2F08%2F03%22";
    let responseRawJSON = await axios.get(baseUrl);
    let responseDataJSON = responseRawJSON.data;
    console.log(responseRawJSON)
    console.log(responseDataJSON)
    console.log(responseDataJSON.results[0])
    console.log(responseDataJSON.results[0].country)
    console.log(responseDataJSON.results[0].date)
    console.log(responseDataJSON.results[0].coordinates)
    console.log(responseDataJSON.results[0].coordinates.lat)
    console.log(responseDataJSON.results[0].coordinates.lon)

}