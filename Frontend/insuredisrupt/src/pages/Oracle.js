import React, { Component } from "react";
import Web3 from "web3";
import {
	CONTRACT_ADDRESS,
	ABI,
	CONTRACT_ERC20_CHAINLINK_ADDRESS,
	CHAINLINK_ABI,
} from "../config";
import { CopyToClipboard } from "react-copy-to-clipboard";

class Oracle extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: "default",
			successMsg: "",
			availableEth: "",
			volcanoContract: null,
			yearEruption: null,
			monthEruption: null,
			dayEruption: null,
			country: "Iceland",
			yearUserInput: "1727",
			monthUserInput: "08",
			dayUserInput: "03",
			yearPresent: null,
			monthPresent: null,
			dayPresent: null,
			latEruption: null,
			longEruption: null,
			urlJSON: null,
			copied: false,
			value: "",
			chainlinkBalance: "",
			chainlinkContract: "",
		};
	}

	componentDidMount() {
		this.loadBlockchainData();
		this.handleChangeUserInput = this.handleChangeUserInput.bind(this);
		this.handleRequestTimeNow = this.handleRequestTimeNow.bind(this);
		this.handleRequestEruptionCoordinates =
			this.handleRequestEruptionCoordinates.bind(this);
	}

	async loadBlockchainData() {
		const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
		const network = await web3.eth.net.getNetworkType();
		await window.ethereum.enable();
		//Fetch account data:
		const accountFromMetaMask = await web3.eth.getAccounts();
		this.setState({ account: accountFromMetaMask });
		console.log(this.state.account[0], "CONTRact address");
		//Load the smart contract
		const volcanoContract = new web3.eth.Contract(ABI, CONTRACT_ADDRESS);
		this.setState({ volcanoContract: volcanoContract });

		//Load the chainlink contract
		const chainlinkContract = new web3.eth.Contract(
			CHAINLINK_ABI,
			CONTRACT_ERC20_CHAINLINK_ADDRESS
		);
		this.setState({ chainlinkContract: chainlinkContract });
		console.log(this.state.chainlinkContract, "CHAINLINK CONTRAACT");

		//get current time
		let yearPresent = await volcanoContract.methods.YearPresent().call();
		this.setState({ yearPresent: yearPresent });
		console.log(this.state.yearPresent, "YEAR present");

		let monthPresent = await volcanoContract.methods.MonthPresent().call();
		this.setState({ monthPresent: monthPresent });
		console.log(this.state.monthPresent, "MONTH present");

		let dayPresent = await volcanoContract.methods.DayPresent().call();
		this.setState({ dayPresent: dayPresent });
		console.log(this.state.dayPresent, "DAY present");

		//get initial long/lats/year/month/day of eruption
		let yearEruption = await volcanoContract.methods.YearEruption().call();
		this.setState({ yearEruption: yearEruption });
		console.log(this.state.yearEruption, "YEAR eruption");

		let monthEruption = await volcanoContract.methods
			.MonthEruption()
			.call();
		this.setState({ monthEruption: monthEruption });
		console.log(this.state.monthEruption, "MONTH eruption");

		let dayEruption = await volcanoContract.methods.DayEruption().call();
		this.setState({ dayEruption: dayEruption });
		console.log(this.state.dayEruption, "DAY eruption");

		let latEruption = await volcanoContract.methods
			.LatitudeEruption()
			.call();
		this.setState({ latEruption: latEruption });
		console.log(this.state.latEruption, "latEruption");

		let longEruption = await volcanoContract.methods
			.LongitudeEruption()
			.call();
		this.setState({ longEruption: longEruption });
		console.log(this.state.longEruption, "longEruption");

		//initial state of url
		let urlJSON = await volcanoContract.methods.urlRebuiltJSON().call();
		this.setState({ urlJSON: urlJSON });
		console.log(this.state.urlJSON, "longEruption");

		//get chainlink balance
		let chainlinkBalance = await chainlinkContract.methods
			.balanceOf(CONTRACT_ADDRESS)
			.call();
		this.setState({ chainlinkBalance: chainlinkBalance });
		console.log(this.state.chainlinkBalance, "chainlinkBalance");
	}

	handleChangeUserInput(event) {
		let value = event.target.value;
		let name = event.target.dataset.name;
		this.setState({ [name]: value });
	}

	handleRequestTimeNow() {
		console.log("Buuuuu set contract", this.state.volcanoContract);
		let web3js = new Web3(window.web3.currentProvider);
		web3js.eth.sendTransaction({
			to: CONTRACT_ADDRESS,
			data: this.state.volcanoContract.methods
				.OracleRequestPresentTime()
				.encodeABI(),
			from: this.state.account[0],
		});
		//Todo: get the values from eventlistener
		//YearPresent(); MonthPresent(); DayPresent()
		this.setState({ loading: true });
	}

	handleRequestEruptionCoordinates() {
		const { yearUserInput, monthUserInput, dayUserInput, country } =
			this.state;
		console.log(
			yearUserInput,
			monthUserInput,
			dayUserInput,
			"USER INPUT in handlerequesteruptioncordinates"
		);
		let web3js = new Web3(window.web3.currentProvider);
		web3js.eth.sendTransaction({
			to: CONTRACT_ADDRESS,
			data: this.state.volcanoContract.methods
				.OracleRequestVolcanoEruptionData(
					yearUserInput,
					monthUserInput,
					dayUserInput,
					country
				)
				.encodeABI(),
			from: this.state.account[0],
		});

		//Todo: get the values from eventlistener
		//YearPresent(); MonthPresent(); DayPresent()
		this.setState({ loading: true });
	}

	render() {
		return (
			<div className="App-background">
				<div className="center-container-buy ">
					<h2 style={{ textAlign: "center" }}>Set Oracle Data</h2>
					<form class="form-container-buy">
						<div>
							<div class="available-eth-container owner">
								<h5
									style={{ textAlign: "center" }}
									className="v-txt"
								>
									Contract address:{" "}
									{CONTRACT_ADDRESS.substr(0, 5) +
										"..." +
										CONTRACT_ADDRESS.substr(38, 4)}{" "}
									make clickable/copy
								</h5>
								<h6
									style={{ textAlign: "center" }}
									className="v-txt"
								>
									<label>chainlink balance</label>
									{this.state.chainlinkBalance /
										1000000000000000000}
								</h6>
							</div>
						</div>
						<p>Current Date:</p>

						<p style={{ textAlign: "center" }} className="v-txt">
							{this.state.yearPresent +
								"/" +
								this.state.monthPresent +
								"/" +
								this.state.dayPresent}
						</p>
						<button
							type="button"
							class="btn btn-dark-request-time"
							onClick={this.handleRequestTimeNow}
						>
							Request Time Now
						</button>

						<div>
							<h4 style={{ textAlign: "center" }}>
								Lat:{" "}
								{this.state.latEruption +
									" Long: " +
									this.state.longEruption}
							</h4>

							<p>Eruption Date:</p>
							<p>
								{this.state.yearEruption +
									"/" +
									this.state.monthEruption +
									"/" +
									this.state.dayEruption}
							</p>
							<div className="url-container">
								<a
									className="url-json"
									href={this.state.urlJSON}
									target="_blank"
								>
									Link to Volcano Data
								</a>
							</div>

							<br />
						</div>
						<div className="container oracle">
							<div class="label-input-container-oracle">
								<label for="lat">Year</label>
								<input
									type="text"
									placeholder="Year"
									onChange={this.handleChangeUserInput}
									data-name="yearUserInput"
									value={this.state.yearUserInput}
								></input>
							</div>
							<div class="label-input-container-oracle">
								<label for="long">Month</label>
								<input
									type="text"
									placeholder="Month"
									onChange={this.handleChangeUserInput}
									data-name="monthUserInput"
									value={this.state.monthUserInput}
								></input>
							</div>
							<div class="label-input-container-oracle">
								<label for="long">Day</label>
								<input
									type="text"
									placeholder="Day"
									onChange={this.handleChangeUserInput}
									data-name="dayUserInput"
									value={this.state.dayUserInput}
								></input>
							</div>
							<div class="label-input-container-oracle">
								<label for="long">Country</label>
								<input
									type="text"
									placeholder="Country"
									onChange={this.handleChangeUserInput}
									data-name="country"
									value={this.state.country}
								></input>
							</div>
						</div>

						<button
							type="button"
							class="btn btn-dark-request-eruption"
							onClick={this.handleRequestEruptionCoordinates}
						>
							Request Volcano Eruption Data
						</button>
					</form>
				</div>
			</div>
		);
	}
}

export default Oracle;
