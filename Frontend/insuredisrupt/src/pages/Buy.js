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
		};
	}
	componentDidMount() {
		this.loadBlockchainData();
		this.handleChangeUserInput = this.handleChangeUserInput.bind(this);
		this.handleBuyPolicy = this.handleBuyPolicy.bind(this);
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
			.OpenETHtoEnsure()
			.call();
		this.setState({ getAvailableEth: availableEth });
		console.log(this.state.getAvailableEth, "avail eth:");

		///----Event will automatically read data
		//this.eventListener(volcanoContract);
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

					<div class="form-container-buy">
						<button
							type="button"
							class="btn btn-dark-buy"
							onClick={this.handleBuyPolicy}
						>
							Buy Policy
						</button>
						<p style={{ textAlign: "center" }} className="v-txt">
							Available ETH to insure:
						</p>
						<p style={{ textAlign: "center" }} className="v-txt">
							{this.state.getAvailableEth}
						</p>

						<div className="lat-long-container">
							<input
								class="form-control-buy"
								type="text"
								placeholder="Latitude . . . "
								onChange={this.handleChangeUserInput}
								data-name="lat"
								value={this.state.lat}
							></input>
							<div className="label-container"></div>

							<input
								class="form-control-buy"
								type="text"
								placeholder="Longitude . . ."
								onChange={this.handleChangeUserInput}
								value={this.state.long}
								data-name="long"
							></input>
						</div>

						<div>
							<button
								type="button"
								class="btn btn-dark-buy"
								onClick={this.handleSetContract}
							>
								Claim Reward
							</button>

							<h4 style={{ textAlign: "center" }}>
								display success msg here
							</h4>

							<div style={{ textAlign: "center" }}></div>
						</div>
					</div>
				</div>
			</div>
		);
	}
}

export default Buy;
