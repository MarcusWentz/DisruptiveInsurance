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
			.OpenETHtoEnsure()
			.call();
		this.setState({ getAvailableEth: availableEth });
		console.log(this.state.getAvailableEthToInsure, "avail eth:");

		///----Event will automatically read data
		//this.eventListener(volcanoContract);
	}

	render() {
		return (
			<div className="App-background">
				<div className="center-container ">
					<h2 style={{ textAlign: "center" }}>Owner</h2>

					<div class="form-container">
						<button
							type="button"
							class="btn btn-dark"
							onClick={this.handleSendEth}
						>
							Fund Contract
						</button>
						<p
							style={{ textAlign: "center", margin: 0 }}
							className="v-txt"
						>
							Available ETH to insure:
						</p>
						<p style={{ textAlign: "center" }} className="v-txt">
							put get value here
						</p>
						<button
							type="button"
							class="btn btn-dark"
							onClick={this.handleSetContract}
						>
							Claim ETH from expired policy
						</button>

						<div>
							<input
								class="form-control"
								type="text"
								placeholder="Policy address. . . "
								onChange={this.handleUserInput}
								value={this.state.userInput}
								style={{ textAlign: "center" }}
							></input>

							<button
								type="button"
								class="btn btn-dark"
								onClick={this.handleSetContract}
							>
								Claim 1 ETH not connected to a Policy
							</button>

							<button
								type="button"
								class="btn btn-dark"
								onClick={this.handleSetContract}
							>
								Claim all ETH from a self destruct attack
							</button>

							<p
								style={{ textAlign: "center" }}
								className="v-txt"
							>
								Success message goes here
								<h4 style={{ textAlign: "center" }}>Success</h4>
							</p>
							<div style={{ textAlign: "center" }}></div>
						</div>
					</div>
				</div>
			</div>
		);
	}
}

export default Owner;
