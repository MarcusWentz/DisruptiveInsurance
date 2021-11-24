import "./App.css";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import Owner from "./pages/Owner";
import Home from "./pages/Home";
import Buy from "./pages/Buy";
import Oracle from "./pages/Oracle";
import Example from "./pages/Example";
import Web3 from "web3";

import React, { Component } from "react";

class App extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: [],
			ConnectButtonValue: "Connect to Metamask",
		};
		this.handleConnectMetamask = this.handleConnectMetamask.bind(this);
		this.loadConnectMetamask = this.loadConnectMetamask.bind(this);
	}

	componentDidMount() {
		//this.loadConnectMetamask();
	}

	async loadConnectMetamask() {
		let that = this;
		const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
		const network = await web3.eth.net.getNetworkType();
		await window.ethereum.enable();
		//Fetch account data:
		const accountFromMetaMask = await web3.eth.getAccounts();
		console.log(accountFromMetaMask, "account in app.js");
		this.setState({ account: accountFromMetaMask });
		this.setState({
			ConnectButtonValue:
				String(accountFromMetaMask).substr(0, 5) +
				"..." +
				String(accountFromMetaMask).substr(38, 4),
		});
		console.log(this.state.account[0], "user metamask address");
	}

	async handleConnectMetamask() {
		let that = this;
		const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
		const network = await web3.eth.net.getNetworkType();
		await window.ethereum.enable();
		//Fetch account data:
		const accountFromMetaMask = await web3.eth.getAccounts();
		console.log(accountFromMetaMask, "account in app.js");
		this.setState({
			account: accountFromMetaMask,
			ConnectButtonValue:
				String(accountFromMetaMask).substr(0, 5) +
				"..." +
				String(accountFromMetaMask).substr(38, 4),
		});
		console.log(this.state.account[0], "user metamask address");
	}

	render() {
		return (
			<div className="App-background">
				<Router>
					<Navbar account={this.state.account} />
					<Switch>
						<Route exact path="/">
							<Home account={this.state.account} />
						</Route>
						<Route path="/owner">
							<Owner account={this.state.account} />
						</Route>
						<Route path="/buy">
							<Buy account={this.state.account} />
						</Route>
						<Route path="/oracle">
							<Oracle account={this.state.account} />
						</Route>
					</Switch>
					<Footer />
				</Router>
				<div className="metamask-addr-container">
					<button
						className="btn btn-dark"
						onClick={this.handleConnectMetamask}
					>
						Connect
						<img
							width="50"
							height="50"
							style={{ marginLeft: 10 }}
							src="https://cdn.discordapp.com/attachments/908513230714982410/913132016365633596/aaaaa.png"
						></img>
					</button>
				</div>
			</div>
		);
	}
}

export default App;
