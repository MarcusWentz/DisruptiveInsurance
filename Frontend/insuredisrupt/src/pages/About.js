import { CONTRACT_ADDRESS, ABI } from "../config";

import React, { Component } from "react";
import Web3 from "web3";
import logo7 from "../Images/logo7transparent.png";
import logo8 from "../Images/LOGO_8_TRANSPARENT.png";

class About extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: "default",
			userGetData: {},
			userSetData: "",
			todoList: {},
			storedDataResult: null,
			userInput: "",
			loading: false,
		};
	}

	componentDidMount() {
		this.loadBlockchainData();
		this.handleSendEth = this.handleSendEth.bind(this);
		this.handleSetContract = this.handleSetContract.bind(this);
		this.loadBlockchainData = this.loadBlockchainData.bind(this);
		this.eventListener = this.eventListener.bind(this);
		this.handleUserInput = this.handleUserInput.bind(this);
	}

	async loadBlockchainData() {
		const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
		const network = await web3.eth.net.getNetworkType();
		await window.ethereum.enable();
		//Fetch account data:
		const accountFromMetaMask = await web3.eth.getAccounts();
		this.setState({ account: accountFromMetaMask });
		//Load the smart contract
		const todoList = new web3.eth.Contract(ABI, CONTRACT_ADDRESS);
		this.setState({ todoList: todoList });
		console.log(this.state.todoList, "");

		//Set state for the result from storedData() Q: this is what i did before with await?
		todoList.methods.storedData().call((err, result) => {
			if (result === undefined) {
				console.log(err, "ERR");
			} else {
				this.setState({ storedDataResult: result });
				console.log(
					result,
					this.state.storedDataResult,
					"result returned storedData()"
				);
			}
		});

		///----Event will automatically read data
		this.eventListener(todoList);
	}

	eventListener(todoList) {
		let that = this;
		todoList.events
			.setValueUpdatedViaWebjs(
				{
					fromBlock: "latest",
				},
				function (error, eventResult) {}
			)
			.on("data", function (eventResult) {
				//Call the get function to get the most accurate present state for the value.
				todoList.methods.storedData().call((err, result) => {
					that.setState({ storedDataResult: result, loading: false });
					console.log(result, "Eventlistener result");
				});
			})
			.on("changed", function (eventResult) {
				// remove event from local database
			})
			.on("error", console.error);
	}

	handleSendEth() {
		console.log("Bääääää send eth");
		let web3js = new Web3(window.web3.currentProvider);
		web3js.eth.sendTransaction({
			to: "0xc1202e7d42655F23097476f6D48006fE56d38d4f",
			from: this.state.account[0],
			value: web3js.utils.toWei("1", "ether"),
		});
	}

	handleSetContract() {
		console.log("Buuuuu set contract", this.state.todoList);
		let web3js = new Web3(window.web3.currentProvider);
		web3js.eth.sendTransaction({
			to: CONTRACT_ADDRESS,
			data: this.state.todoList.methods
				.set(this.state.userInput)
				.encodeABI(),
			from: this.state.account[0],
		});

		this.setState({ loading: true });
	}

	_whenToRenderSpinner() {
		if (this.state.loading) {
			return <div class="spinner-border text-light" role="status"></div>;
		}
	}

	handleUserInput(event) {
		this.setState({ userInput: event.target.value });
		console.log(this.state.userInput, "user input handle change");
	}

	render() {
		return (
			<div className="App-background">
				<div className="center-container ">
					<h2 style={{ textAlign: "center" }}>Set Contract Data</h2>

					<div class="form-container">
						<button
							type="button"
							class="btn btn-dark"
							onClick={this.handleSendEth}
						>
							Send Eth
						</button>

						<input
							class="form-control"
							type="text"
							placeholder="Set your value . . . "
							onChange={this.handleUserInput}
							value={this.state.userInput}
						></input>

						<div>
							<button
								type="button"
								class="btn btn-dark"
								onClick={this.handleSetContract}
							>
								Set contract data
							</button>

							<p
								style={{ textAlign: "center" }}
								className="v-txt"
							>
								Data you got back from the contract:
								<h4 style={{ textAlign: "center" }}>
									{" " + this.state.storedDataResult}
								</h4>
							</p>
							<div style={{ textAlign: "center" }}>
								{this._whenToRenderSpinner()}
							</div>
						</div>
					</div>
				</div>
			</div>
		);
	}
}

export default About;
