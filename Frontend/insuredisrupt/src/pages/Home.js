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

					<p className="v-txt">
						This site is under construction. storedData :
					</p>
					<p className="v-txt">Check out demo on /About</p>
				</div>
			</div>
		);
	}
}

export default Home;
