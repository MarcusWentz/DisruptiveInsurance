import React, { Component } from "react";
import Web3 from "web3";
import { CONTRACT_ADDRESS, ABI } from "../config";
import ErrorModal from "../components/ErrorModal";

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
			allPolicyData: "",
			errorMsg: "",
		};
	}
	componentDidMount() {
		this.loadBlockchainData();
		this.handleChangeUserInput = this.handleChangeUserInput.bind(this);
		this.handleBuyPolicy = this.handleBuyPolicy.bind(this);
		this.handleClaimReward = this.handleClaimReward.bind(this);
		this.eventListener = this.eventListener.bind(this);
	}

	componentDidUpdate(prevProps, prevState) {
		if (prevProps.account !== this.props.account) {
			this.loadBlockchainData();
		}
	}
	async loadBlockchainData() {
		const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
		//const network = await web3.eth.net.getNetworkType();
		//await window.ethereum.enable();

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
		if (this.props.account[0]) {
			let allPolicyData = await volcanoContract.methods
				.policies(this.props.account[0])
				.call();
			this.setState({
				allPolicyData: allPolicyData,
			});
		}

		this.eventListener(volcanoContract);
	}

	eventListener(volcanoContract) {
		let that = this;
		console.log("Inside event listner");
		volcanoContract.events
			.recordMessageSender(
				{
					fromBlock: "latest",
				},
				function (error, eventResult) {}
			)
			.on("data", function (eventResult) {
				//Call the get function to get the most accurate present state for the value.
				volcanoContract.methods
					.OpenETHtoInsure()
					.call((err, result) => {
						that.setState({
							getAvailableEth: result,
							loading: false,
						});
						console.log(result, "Eventlistener result");
					});

				volcanoContract.methods
					.policies(that.props.account[0])
					.call((err, result) => {
						that.setState({
							allPolicyData: result,
							loading: false,
						});
						console.log(result, "2Eventlistener result");
					});
			})
			.on("changed", function (eventResult) {
				// remove event from local database
			})
			.on("error", console.error);
	}

	handleBuyPolicy() {
		if (this.props.account[0]) {
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
				from: this.props.account[0],
			});
		} else
			this.setState({
				errorMsg: "You have to connect to metamask!",
			});
	}

	handleClaimReward() {
		console.log("Handle claim reward");
		if (this.props.account[0]) {
			let web3js = new Web3(window.web3.currentProvider);
			web3js.eth.sendTransaction({
				to: CONTRACT_ADDRESS,
				data: this.state.volcanoContract.methods
					.BuyerClaimReward(this.props.account[0])
					.encodeABI(),
				from: this.props.account[0],
			});
		} else
			this.setState({
				errorMsg: "You have to connect to metamask!",
			});
	}

	handleChangeUserInput(event) {
		let value = event.target.value;
		let name = event.target.dataset.name;
		this.setState({ [name]: value });
		console.log(this.state.lat, this.state.long, "handleChange?");
	}

	render() {
		const { allPolicyData } = this.state;
		console.log(this.state.allPolicyData, "All Policy data");
		return (
			<div className="App-background">
				{this.state.errorMsg ? <ErrorModal /> : null}

				<div className="center-container-buy ">
					<h2 style={{ textAlign: "center" }}>Buyer</h2>

					<form class="form-container-buy">
						<div class="available-eth-container">
							<label>Metamask connected policy:</label>
							<h6
								style={{ textAlign: "center" }}
								className="v-txt"
							>
								{"Lat: " +
									allPolicyData.LatitudeInsured +
									" Long: " +
									allPolicyData.LongitudeInsured +
									" Sign Date: " +
									allPolicyData.YearSigned +
									"/" +
									allPolicyData.MonthSigned +
									"/" +
									allPolicyData.DaySigned +
									" ETH Locked: " +
									allPolicyData.EthereumAwardTiedToAddress}
							</h6>
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
						<p style={{ color: "orange" }}>{this.state.errorMsg}</p>

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

						<div>
							<button
								type="button"
								class="btn btn-dark-buy-policy"
								onClick={this.handleBuyPolicy}
							>
								Buy Policy
							</button>
						</div>
						<div>
							<button
								type="button"
								class="btn btn-dark-claim"
								onClick={this.handleClaimReward}
							>
								Claim Reward
							</button>
						</div>
					</form>
				</div>
			</div>
		);
	}
}

export default Buy;
