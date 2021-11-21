import React, { Component } from "react";
import Web3 from "web3";
import { CONTRACT_ADDRESS, ABI } from "../config";

class Buy extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: "default",
			successMsg: "",
			availableEth: "",
			volcanoContract: null,
			lat: 0,
			long: 0,
			getAvailableEth: null,
			currentPolicySignedYearStruct: null,
		};
	}
	componentDidMount() {
		this.loadBlockchainData();
		this.handleChangeUserInput = this.handleChangeUserInput.bind(this);
		this.handleBuyPolicy = this.handleBuyPolicy.bind(this);
		this.handleClaimReward = this.handleClaimReward.bind(this);

		//handleClaimReward();
	}

	async loadBlockchainData() {
		const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
		const network = await web3.eth.net.getNetworkType();
		await window.ethereum.enable();
		//Fetch account data:
		const accountFromMetaMask = await web3.eth.getAccounts();
		this.setState({ account: accountFromMetaMask });
		console.log(this.state.account[0], "user metamask address");
		//Load the smart contract
		const volcanoContract = new web3.eth.Contract(ABI, CONTRACT_ADDRESS);
		this.setState({ volcanoContract: volcanoContract });
		console.log(this.state.volcanoContract, "CONTRAACT");

		//Set state for the result from storedData() Q: this is what i did before with await?
		volcanoContract.methods.urlRebuiltJSON().call((err, result) => {
			if (result === undefined) {
				console.log(err, "ERR");
			} else {
				//this.setState({ storedDataResult: result });
				console.log(result, "result returned storedData()");
			}
		});

		//GET inital values
		let availableEth = await volcanoContract.methods
			.OpenETHtoInsure()
			.call();
		this.setState({ getAvailableEth: availableEth });
		console.log(this.state.getAvailableEth, "avail eth:");

		//Get if user has policy and when signed
		let currentPolicySignedYearStruct = await volcanoContract.methods
			.policies(this.state.account[0])
			.call();
		console.log(currentPolicySignedYearStruct, ".......");
		this.setState({
			currentPolicySignedYearStruct: currentPolicySignedYearStruct,
		});
		console.log(
			this.state.currentPolicySignedYearStruct,
			"cUrrentPolicy signed year"
		);
		this.helperSetYearPolicySignedWithStructData();

		//	var salaryInfoContract = web3.eth.contract(salaryInfoCompiled.SalaryInfo.info.abiDefinition);
		// var salaryInfo = salaryInfoContract.new({from:web3.eth.accounts[0], data: salaryInfoCompiled.SalaryInfo.code, gas: 1000000},

		///----Event will automatically read data
		//this.eventListener(volcanoContract);
	}

	helperSetYearPolicySignedWithStructData() {
		let struct = this.state.currentPolicySignedYearStruct;
		console.log(
			this.state.currentPolicySignedYearStruct.YearSigned,
			"ÄÄÄÄÄÄÄÄÄ"
		);

		console.log();

		/* 	let keysOfStruct = Object.keys(struct);
		console.log(keysOfStruct, "keysofstruct");
		keysOfStruct.forEach((keyName) => {
			if (
				keyName === "DaySigned" ||
				keyName === "EthereumAwardTiedToAddress"
			) {
			}
		}); */
	}

	eventListener(volcanoContract) {
		let that = this;
		volcanoContract.events
			.setValueUpdatedViaWebjs(
				{
					fromBlock: "latest",
				},
				function (error, eventResult) {}
			)
			.on("data", function (eventResult) {
				//Call the get function to get the most accurate present state for the value.
				volcanoContract.methods
					.OpenETHtoEnsure()
					.call((err, result) => {
						that.setState({
							getAvailableEth: result,
							loading: false,
						});
						console.log(result, "Eventlistener result");
					});
			})
			.on("changed", function (eventResult) {
				// remove event from local database
			})
			.on("error", console.error);
	}

	handleBuyPolicy() {
		console.log(
			"Buu Buy policy",
			this.state.volcanoContract,
			this.state.lat,
			this.state.long
		);
		let web3js = new Web3(window.web3.currentProvider);
		web3js.eth.sendTransaction({
			to: CONTRACT_ADDRESS,
			data: this.state.volcanoContract.methods
				.BuyerCreatePolicy(this.state.lat, this.state.long)
				.encodeABI(),
			value: 10000000000000000,
			from: this.state.account[0],
		});
	}

	handleClaimReward() {
		console.log("Handle claim reward");

		let web3js = new Web3(window.web3.currentProvider);
		web3js.eth.sendTransaction({
			to: CONTRACT_ADDRESS,
			data: this.state.volcanoContract.methods
				.BuyerClaimReward(this.state.account[0])
				.encodeABI(),
			from: this.state.account[0],
		});
	}

	handleChangeUserInput(event) {
		let value = event.target.value;
		let name = event.target.dataset.name;
		this.setState({ [name]: value });
		console.log(this.state.lat, this.state.long, "handleChange?");
	}

	render() {
		return (
			<div className="App-background">
				<div className="center-container-buy ">
					<h2 style={{ textAlign: "center" }}>Buy Insurance</h2>

					<form class="form-container-buy">
						<div className="container longLat">
							<div class="label-input-container">
								<label for="lat">Latitude</label>
								<input
									type="text"
									name="lat"
									placeholder="Latitude . . . "
									onChange={this.handleChangeUserInput}
									data-name="lat"
									value={this.state.lat}
								></input>
							</div>
							<div class="label-input-container">
								<label for="long">Longitude</label>
								<input
									type="text"
									name="long"
									placeholder="Longitude . . ."
									onChange={this.handleChangeUserInput}
									value={this.state.long}
									data-name="long"
								></input>
							</div>
						</div>

						<div className="container">
							<button
								type="button"
								class="btn btn-dark-buy-policy"
								onClick={this.handleBuyPolicy}
							>
								Buy Policy
							</button>

							<button
								type="button"
								class="btn btn-dark-claim"
								onClick={this.handleClaimReward}
							>
								Claim Reward
							</button>
						</div>

						<div class="available-eth-container">
							<h3
								style={{ textAlign: "center" }}
								className="v-txt"
							>
								Available ETH to insure:
							</h3>
							<h3
								style={{ textAlign: "center" }}
								className="v-txt"
							>
								{this.state.getAvailableEth}
							</h3>
						</div>
					</form>
				</div>
			</div>
		);
	}
}

export default Buy;
