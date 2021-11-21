import { CONTRACT_ADDRESS, ABI } from "../config";

import React, { Component } from "react";
import Web3 from "web3";
import MeetTheTeam from "../components/MeetTheTeam";

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

					<MeetTheTeam />
				</div>
			</div>
		);
	}
}

export default Home;
