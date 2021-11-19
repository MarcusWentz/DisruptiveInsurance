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
		};
	}
	componentDidMount() {
		this.loadBlockchainData();
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

		///----Event will automatically read data
		//this.eventListener(volcanoContract);
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
							onClick={this.handleSendEth}
						>
							Buy Policy
						</button>
						<p style={{ textAlign: "center" }} className="v-txt">
							Available ETH to insure:
						</p>
						<p style={{ textAlign: "center" }} className="v-txt">
							5
						</p>

						<div className="lat-long-container">
							<input
								class="form-control-buy"
								type="text"
								placeholder="Set your value . . . "
								onChange={this.handleUserInput}
								value={this.state.userInput}
							></input>
							<div className="label-container"></div>

							<input
								class="form-control-buy"
								type="text"
								placeholder="Set your value . . . "
								onChange={this.handleUserInput}
								value={this.state.userInput}
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
