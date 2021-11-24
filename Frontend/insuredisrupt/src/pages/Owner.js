import React, { Component } from "react";
import Web3 from "web3";
import { CONTRACT_ADDRESS, ABI } from "../config";
class Owner extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: this.props.account,
			successMsg: "",
			availableEth: "",
			volcanoContract: null,
			policyaddress: "0x0000000000000000000000000000000000000000",
			allPolicyData: "",
			accountsInsured: "",
			errorMsg: "",
		};
	}
	componentDidMount() {
		this.loadBlockchainData();
		this.handleChangeUserInput = this.handleChangeUserInput.bind(this);
		this.handleFundContract = this.handleFundContract.bind(this);
		this.handleClaimExpiredPolicy =
			this.handleClaimExpiredPolicy.bind(this);

		this.setInitialValues = this.setInitialValues.bind(this);
		this.handleSelfDestruct = this.handleSelfDestruct.bind(this);
		this.handleGetPolicyAddressData =
			this.handleGetPolicyAddressData.bind(this);

		this.handleClaimNotConnectedPolicy =
			this.handleClaimNotConnectedPolicy.bind(this);

		//this.handleBuyPolicy = this.handleBuyPolicy.bind(this);
	}

	async loadBlockchainData() {
		const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
		//const network = await web3.eth.net.getNetworkType();
		//await window.ethereum.enable();
		const volcanoContract = new web3.eth.Contract(ABI, CONTRACT_ADDRESS);
		this.setState({ volcanoContract: volcanoContract });
		console.log(this.state.volcanoContract, "CONTRAACT");

		//GET inital values
		this.setInitialValues(volcanoContract);

		///----Event will automatically read data
		this.eventListener(volcanoContract);
	}

	componentDidUpdate(prevProps, prevState) {
		if (prevProps.account !== this.props.account) {
			this.loadBlockchainData();
		}
	}

	setInitialValues(volcanoContract) {
		let that = this;
		volcanoContract.methods
			.OpenETHtoInsure()
			.call()
			.then((res) => {
				that.setState({
					getAvailableEth: res,
				});
				console.log(that.state.getAvailableEthToInsure, "avail eth:");
			});

		volcanoContract.methods
			.AccountsInsured()
			.call()
			.then((res) => {
				that.setState({
					accountsInsured: res,
				});
				console.log(res, "accountsinsured res");
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
				that.setInitialValues(volcanoContract);
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
		console.log(this.state.policyaddress, "policy addr from user inptu");
	}

	handleFundContract() {
		if (this.props.account[0]) {
			let web3js = new Web3(window.web3.currentProvider);
			web3js.eth.sendTransaction({
				to: CONTRACT_ADDRESS,
				data: this.state.volcanoContract.methods
					.OwnerSendOneEthToContractFromInsuranceBusiness()
					.encodeABI(),
				value: 1000000000000000000,
				from: this.props.account[0],
			});
		} else
			this.setState({
				errorMsg: "You have to connect to metamask!",
			});
	}

	handleClaimNotConnectedPolicy() {
		if (this.props.account[0]) {
			let web3js = new Web3(window.web3.currentProvider);
			web3js.eth.sendTransaction({
				to: CONTRACT_ADDRESS,
				data: this.state.volcanoContract.methods
					.OwnerLiquidtoOpenETHToWithdraw()
					.encodeABI(),
				from: this.props.account[0],
			});
		} else
			this.setState({
				errorMsg: "You have to connect to metamask!",
			});
	}

	handleClaimExpiredPolicy() {
		if (this.props.account[0]) {
			console.log(this.state.policyaddress, "policy address sent in:");
			let web3js = new Web3(window.web3.currentProvider);
			web3js.eth.sendTransaction({
				to: CONTRACT_ADDRESS,
				data: this.state.volcanoContract.methods
					.OwnerClaimExpiredPolicyETH(this.state.policyaddress)
					.encodeABI(),
				from: this.props.account[0],
			});
		} else
			this.setState({
				errorMsg: "You have to specify a policy address!",
			});
	}

	handleSelfDestruct() {
		if (this.props.account[0]) {
			let web3js = new Web3(window.web3.currentProvider);
			web3js.eth.sendTransaction({
				to: CONTRACT_ADDRESS,
				data: this.state.volcanoContract.methods
					.OwnerSelfDestructClaimETH()
					.encodeABI(),
				from: this.props.account[0],
			});
		} else
			this.setState({
				errorMsg: "You have to specify a policy address!",
			});
	}

	async handleGetPolicyAddressData() {
		if (this.props.account[0]) {
			let allPolicyData = await this.state.volcanoContract.methods
				.policies(this.state.policyaddress)
				.call();
			this.setState({
				allPolicyData: allPolicyData,
				errorMsg: "",
			});
			console.log(this.state.allPolicyData.DaySigned, "all policy data");
		} else
			this.setState({
				errorMsg: "You have to specify a policy address!",
			});
	}

	render() {
		const { allPolicyData } = this.state;
		return (
			<div className="App-background">
				<div className="center-container-buy ">
					<h2 style={{ textAlign: "center" }}>Owner</h2>

					<form class="form-container-buy">
						<div class="available-eth-container owner">
							<h5
								style={{ textAlign: "center" }}
								className="v-txt"
							>
								ETH availble for insurance:
							</h5>
							<h6
								style={{ textAlign: "center" }}
								className="v-txt"
							>
								{this.state.getAvailableEth}
							</h6>
						</div>
						<br />

						<button
							type="button"
							class="btn btn-dark-fund-contract"
							onClick={this.handleFundContract}
						>
							Fund Contract
						</button>
						<div>
							<button
								type="button"
								class="btn btn-dark-not-connected"
								onClick={this.handleClaimNotConnectedPolicy}
							>
								Claim 1 ETH not connected to a policy
							</button>
						</div>
						<div class="available-eth-container">
							<p>
								Accounts Insured: {this.state.accountsInsured}
							</p>
						</div>

						<div className="container policyaddress">
							<div class="label-input-container">
								<label for="long">POLICY ADDRESS</label>
								<input
									type="text"
									name="policyaddress"
									placeholder="Policy Address . . ."
									onChange={this.handleChangeUserInput}
									value={this.state.policyaddress}
									data-name="policyaddress"
									style={{ width: 500 }}
								></input>
							</div>
						</div>
						<div>
							<p style={{ color: "orange" }}>
								{this.state.errorMsg}
							</p>
							<button
								type="button"
								class="btn btn-dark-policy-data"
								onClick={this.handleGetPolicyAddressData}
							>
								Get Policy Data
							</button>

							<p>
								{" "}
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
							</p>
						</div>
						<div>
							<button
								type="button"
								class="btn btn-dark-expired-policy"
								onClick={this.handleClaimExpiredPolicy}
							>
								Claim 1 ETH from expired policy
							</button>
						</div>
						<div></div>
						<div>
							<button
								type="button"
								class="btn btn-dark-self-destruct"
								onClick={this.handleSelfDestruct}
							>
								Claim all ETH from a self-destruct attack
							</button>
						</div>
					</form>
				</div>
			</div>
		);
	}
}

export default Owner;
