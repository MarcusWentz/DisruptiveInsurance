import { ADDRESS, ABI } from "../config";

import React, { Component } from "react";
import Web3 from "web3";

class Home extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: "default",
			userGetData: {},
			userSetData: {},
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
		this.setState({ todoList });
		console.log("The contract we connected to:", todoList);
		//Read the taskcount from the smart contract method
		const userSetData = await todoList.methods.set(5).call();
		this.setState({ userSetData });
		const userGetData = await todoList.methods.storedData().call();
		this.setState({ userGetData });
		console.log(
			this.state.userSetData,
			"<-- userSetData and userGetData ->",
			this.state.userGetData
		);
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
					This site is under construction. TaskCount:{" "}
				</p>
			</div>
		);
	}
}

export default Home;
