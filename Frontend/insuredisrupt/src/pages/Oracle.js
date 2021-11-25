import React, { Component } from "react";
import Web3 from "web3";
import {
	CONTRACT_ADDRESS,
	ABI,
	CONTRACT_ERC20_CHAINLINK_ADDRESS,
	CHAINLINK_ABI,
} from "../config";
import { CopyToClipboard } from "react-copy-to-clipboard";
import ErrorModal from "../components/ErrorModal";

class Oracle extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: this.props.account,
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
			errorMsg: "",
			copied: false,
			contractAddrToCopy: CONTRACT_ADDRESS,
			loading: false,
			loadingVolcanoData: false,
		};
	}

	componentDidMount() {
		this.loadBlockchainData();
		this.handleChangeUserInput = this.handleChangeUserInput.bind(this);
		this.handleRequestTimeNow = this.handleRequestTimeNow.bind(this);
		this.handleRequestEruptionCoordinates =
			this.handleRequestEruptionCoordinates.bind(this);
		console.log(this.props, "Props in Oracle.js");
	}

	async loadBlockchainData() {
		const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
		//const network = await web3.eth.net.getNetworkType();
		//await window.ethereum.enable();
		const volcanoContract = new web3.eth.Contract(ABI, CONTRACT_ADDRESS);
		this.setState({ volcanoContract: volcanoContract });

		//Load the chainlink contract
		const chainlinkContract = new web3.eth.Contract(
			CHAINLINK_ABI,
			CONTRACT_ERC20_CHAINLINK_ADDRESS
		);
		this.setState({ chainlinkContract: chainlinkContract });

		this.setInitialValues(volcanoContract, chainlinkContract);
		this.eventListener(volcanoContract);
	}

	componentDidUpdate(prevProps, prevState) {
		if (prevProps.account !== this.props.account) {
			this.loadBlockchainData();
		}
	}

	setInitialValues(volcanoContract, chainlinkContract) {
		volcanoContract.methods
			.YearPresent()
			.call()
			.then((res) => {
				this.setState({ yearPresent: res });
				console.log(this.state.yearPresent, "YEAR present");
			});

		volcanoContract.methods
			.MonthPresent()
			.call()
			.then((res) => {
				this.setState({ monthPresent: res });
				console.log(this.state.monthPresent, "MONTH present");
			});

		volcanoContract.methods
			.DayPresent()
			.call()
			.then((res) => {
				this.setState({ dayPresent: res });
				console.log(this.state.dayPresent, "DAY present");
			});

		//get initial long/lats/year/month/day of eruption
		volcanoContract.methods
			.YearEruption()
			.call()
			.then((res) => {
				this.setState({ yearEruption: res });
				console.log(this.state.yearEruption, "YEAR eruption");
			});

		volcanoContract.methods
			.MonthEruption()
			.call()
			.then((res) => {
				this.setState({ monthEruption: res });
				console.log(this.state.monthEruption, "MONTH eruption");
			});

		volcanoContract.methods
			.DayEruption()
			.call()
			.then((res) => {
				this.setState({ dayEruption: res });
				console.log(this.state.dayEruption, "DAY eruption");
			});

		volcanoContract.methods
			.LatitudeEruption()
			.call()
			.then((res) => {
				this.setState({ latEruption: res });
				console.log(this.state.latEruption, "latEruption");
			});

		volcanoContract.methods
			.LongitudeEruption()
			.call()
			.then((res) => {
				this.setState({ longEruption: res });
				console.log(this.state.longEruption, "longEruption");
			});

		//initial state of url
		volcanoContract.methods
			.urlRebuiltJSON()
			.call()
			.then((res) => {
				this.setState({ urlJSON: res });
				console.log(this.state.urlJSON, "longEruption");
			});

		//get chainlink balance
		chainlinkContract.methods
			.balanceOf(CONTRACT_ADDRESS)
			.call()
			.then((res) => {
				this.setState({ chainlinkBalance: res });
				console.log(this.state.chainlinkBalance, "chainlinkBalance");
			});
	}

	eventListener(volcanoContract) {
		let that = this;
		volcanoContract.events
			.recordMessageSender(
				{
					fromBlock: "latest",
				},
				function (error, eventResult) {}
			)
			.on("data", function (eventResult) {
				//Call the get function to get the most accurate present state for the value.
				that.setInitialValues(
					volcanoContract,
					that.state.chainlinkContract
				);

				//Do a wait 30s here
				that.setState({ loading: false, loadingVolcanoData: false });
				console.log("eventlistner triggered!");
			})
			.on("changed", function (eventResult) {
				// remove event from local database
			})
			.on("error", console.error);
	}

	handleChangeUserInput(event) {
		let value = event.target.value;
		let name = event.target.dataset.name;
		this.setState({ [name]: value });
	}

	handleRequestTimeNow() {
		if (this.props.account[0]) {
			console.log("Buuuuu set contract", this.state.volcanoContract);
			let web3js = new Web3(window.web3.currentProvider);
			web3js.eth.sendTransaction({
				to: CONTRACT_ADDRESS,
				data: this.state.volcanoContract.methods
					.OracleRequestPresentTime()
					.encodeABI(),
				from: this.props.account[0],
			});
			//Todo: get the values from eventlistener
			//YearPresent(); MonthPresent(); DayPresent()
			this.setState({ loading: true });
		} else {
			this.setState({
				errorMsg: "You have to connect to metamask!",
			});
		}
	}

	handleRequestEruptionCoordinates() {
		if (this.props.account[0]) {
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
				from: this.props.account[0],
			});
			this.setState({ loadingVolcanoData: true });
		} else {
			this.setState({
				errorMsg: "You have to connect to metamask!",
			});
		}
	}

	onChange = ({ target: { contractAddrToCopy } }) => {
		this.setState({ contractAddrToCopy, copied: false });
	};

	onCopy = () => {
		this.setState({ copied: true });
	};

	_whenToRenderSpinner() {
		if (this.state.loading) {
			return <div class="spinner-border text-light" role="status"></div>;
		} else if (this.state.loadingVolcanoData) {
			return <div class="spinner-border text-light" role="status"></div>;
		}
	}

	_renderCopyAddress() {
		return (
			<div>
				<input
					className="contract-addr"
					onChange={this.onChange}
					disabled="true"
					value={this.state.contractAddrToCopy}
				/>

				<CopyToClipboard
					onCopy={this.onCopy}
					text={this.state.contractAddrToCopy}
				>
					<button className="btn btn-dark-copy">
						<span class="sc-jaq3xr-1 doRNia">
							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="16"
								height="16"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
								stroke-linecap="round"
								stroke-linejoin="round"
							>
								<rect
									x="9"
									y="9"
									width="13"
									height="13"
									rx="2"
									ry="2"
								></rect>
								<path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
							</svg>
						</span>{" "}
						Copy Contract Address
					</button>
				</CopyToClipboard>
			</div>
		);
	}

	render() {
		return (
			<div className="App-background">
				{this.state.errorMsg ? <ErrorModal /> : null}
				<div className="center-container-buy ">
					<h2 style={{ textAlign: "center" }}>Oracle</h2>
					<form class="form-container-buy">
						<div>
							<div class="available-eth-container owner">
								<label>CONTRACT ADDRESS</label>
								<div className="contract-addr-container">
									{this._renderCopyAddress()}
								</div>
								<h6
									style={{ textAlign: "center" }}
									className="v-txt"
								>
									<label>contract chainlink balance</label>
									{this.state.chainlinkBalance /
										1000000000000000000}
								</h6>
							</div>
						</div>
						<p>Current Date [GMT]:</p>

						{this.state.loading ? (
							<p
								style={{ textAlign: "center" }}
								className="v-txt"
							>
								{this._whenToRenderSpinner()}
							</p>
						) : (
							<p
								style={{ textAlign: "center" }}
								className="v-txt"
							>
								{this.state.yearPresent +
									"/" +
									this.state.monthPresent +
									"/" +
									this.state.dayPresent}
							</p>
						)}

						<button
							type="button"
							class="btn btn-dark-request-time"
							onClick={this.handleRequestTimeNow}
						>
							Request Time Now
							<label>[0.05 LINK]</label>
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
							<label>[0.05 LINK]</label>
						</button>
						{this.state.loadingVolcanoData ? (
							<p>{this._whenToRenderSpinner()}</p>
						) : null}
					</form>
				</div>
			</div>
		);
	}
}

export default Oracle;
