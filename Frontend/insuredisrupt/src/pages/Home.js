import { ADDRESS, ABI } from "../config";

import React, { Component } from "react";
import Web3 from "web3";

class Home extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: "default",
			userGetData: {},
			userSetData: "",
		};
	}

	async loadBlockchainData() {
		const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
		const network = await web3.eth.net.getNetworkType();
		await window.ethereum.enable();
		console.log("network UU", network);

		//Fetch account data:
		const accountFromMetaMask = await web3.eth.getAccounts();
		this.setState({ account: accountFromMetaMask });
		console.log(accountFromMetaMask, "whats acc????");
		//Load the smart contract
		const todoList = new web3.eth.Contract(ABI, ADDRESS);

		todoList.methods.storedData().call((err, result) => {
			if (result === undefined) {
				console.log(err, "ERR");
			} else {
				console.log(result, "result returned storedData()");
				//state here to result variable
			}
		});

		console.log("The contract we connected to:", todoList);
		//Read the taskcount from the smart contract method
		//const userSetData = await todoList.methods.set(5).call();
		//this.setState({ userSetData });

		console.log(
			this.state.userSetData,
			"<-- userSetData and userGetData ->",
			typeof this.state.userGetData,
			this.state.userGetData,
			Object.values(this.state.userGetData)
		);

		///----Event will automatically read data
		todoList.events
			.setValueUpdatedViaWebjs(
				{
					fromBlock: "latest",
				},
				function (error, eventResult) {}
			)
			.on("data", function (eventResult) {
				console.log(eventResult);
				//Call the get function to get the most accurate present state for the value.

				todoList.methods.storedData().call((err, balance) => {
					this.setSet({ todoList });
				});
			})
			.on("changed", function (eventResult) {
				// remove event from local database
			})
			.on("error", console.error);
		///-----
	}

	componentDidMount() {
		this.loadBlockchainData();
	}

	render() {
		return (
			<div className="center-container ">
				<div class="circle">V</div>

				<h3 className="v-txt">Welcome address: {this.state.account}</h3>

				<p className="v-txt">
					This site is under construction. storedData :{" "}
				</p>
			</div>
		);
	}
}

export default Home;
