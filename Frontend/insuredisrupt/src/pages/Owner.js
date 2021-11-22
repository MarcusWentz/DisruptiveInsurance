import React, { Component } from "react";
import Web3 from "web3";
import { CONTRACT_ADDRESS, ABI } from "../config";
class Owner extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: "default",
			successMsg: "",
			availableEth: "",
			volcanoContract: null,
		};
	}
	componentDidMount() {
		this.loadBlockchainData();
		//this.handleChangeUserInput = this.handleChangeUserInput.bind(this);
		//this.handleBuyPolicy = this.handleBuyPolicy.bind(this);
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

		//GET inital values
		let availableEth = await volcanoContract.methods
			.OpenETHtoInsure()
			.call();
		this.setState({ getAvailableEth: availableEth });
		console.log(this.state.getAvailableEthToInsure, "avail eth:");

		///----Event will automatically read data
		//this.eventListener(volcanoContract);
	}

	render() {
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
								get: openETHtoInsure:
							</h5>
							<h6
								style={{ textAlign: "center" }}
								className="v-txt"
							>
								{this.state.getAvailableEth}
							</h6>
						</div>
						<br />
						<div className="container policyaddress">
							<div class="label-input-container">
								<label for="long">POLICY ADDRESS</label>
								<input
									type="text"
									name="long"
									placeholder="Policy Address . . ."
									onChange={this.handleChangePolicyAddress}
									value=""
									data-name="long"
								></input>
							</div>
						</div>

						<button
							type="button"
							class="btn btn-dark-fund-contract"
							onClick={this.handleBuyPolicy}
						>
							Fund Contract
						</button>
						<div>
							<button
								type="button"
								class="btn btn-dark-policy-data"
								onClick={this.handleBuyPolicy}
							>
								Get Policy Data
							</button>
							<p>get: policies policyData</p>
						</div>
						<div>
							<button
								type="button"
								class="btn btn-dark-expired-policy"
								onClick={this.handleBuyPolicy}
							>
								Claim 1 ETH from expired policy
							</button>
							<p>get: accountsInsured</p>
						</div>
						<div>
							<button
								type="button"
								class="btn btn-dark-not-connected"
								onClick={this.handleBuyPolicy}
							>
								Claim 1 ETH not connected to a policy
							</button>
							<p>optional get:</p>
						</div>
						<div>
							<button
								type="button"
								class="btn btn-dark-self-destruct"
								onClick={this.handleBuyPolicy}
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
