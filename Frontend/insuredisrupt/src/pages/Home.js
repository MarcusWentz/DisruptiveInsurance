import { CONTRACT_ADDRESS, ABI } from "../config";

import React, { Component } from "react";
import Web3 from "web3";

class Home extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: "default",
			userGetData: {},
			userSetData: "",
			todoList: {},
			storedDataResult: null,
		};
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

		console.log("The contract we connected to:", todoList);
		//Read the taskcount from the smart contract method
		const storedDataRes = await todoList.methods.storedData().call();
		console.log(typeof storedDataRes, "--------");

		///----Event will automatically read data
		this.eventListener(todoList);

		///-----
	}

	componentDidMount() {
		this.loadBlockchainData();
		this.handleSendEth = this.handleSendEth.bind(this);
		this.handleSetContract = this.handleSetContract.bind(this);
		this.loadBlockchainData = this.loadBlockchainData.bind(this);
		this.eventListener = this.eventListener.bind(this);
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
					that.setState({ storedDataResult: result });
					console.log(result, "Eventlistener result");
				});
			})
			.on("changed", function (eventResult) {
				// remove event from local database
			})
			.on("error", console.error);
	}

	handleSetContract() {
		console.log("Buuuuu set contract", this.state.todoList);
		let web3js = new Web3(window.web3.currentProvider);
		web3js.eth.sendTransaction({
			to: CONTRACT_ADDRESS,
			data: this.state.todoList.methods.set(60).encodeABI(),
			from: this.state.account[0],
		});
	}

	render() {
		return (
			<div className="center-container ">
				<div class="circle">V</div>

				<h3 className="v-txt">Welcome address: {this.state.account}</h3>

				<p className="v-txt">
					This site is under construction. storedData :
					{this.state.storedDataResult}
				</p>

				<button
					type="button"
					class="btn btn-dark"
					onClick={this.handleSendEth}
				>
					Send Eth
				</button>

				<button
					type="button"
					class="btn btn-dark"
					onClick={this.handleSetContract}
				>
					Set contract state
				</button>

				<input
					class="form-control"
					type="text"
					placeholder="Value: 10"
					value="60"
				></input>
			</div>
		);
	}
}

export default Home;
