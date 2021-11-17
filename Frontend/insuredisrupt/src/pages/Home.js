import { CONTRACT_ADDRESS, ABI } from "../config";

import React, { Component } from "react";
import Web3 from "web3";

class Home extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: "default",
		};
	}

	render() {
		return (
			<div className="App-background">
				<div className="center-container ">
					<div class="circle">V</div>

					<h3 className="v-txt">
						Welcome address: {this.state.account}
					</h3>

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
			</div>
		);
	}
}

export default Home;
