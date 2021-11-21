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
				<div className="center-container-buy ">
					<h2 style={{ textAlign: "center" }}>
						Disruptive Volcano Insurance
					</h2>

					<form class="form-container-about">
						<h2 className="about-header">About</h2>
						<p className="project-description">
							Disruptive Insurance is an exotic insurance service
							that allows users to buy insurance against volcano
							eruptions. No other insurance business on Earth
							offers volcano eruption insurance.
						</p>
					</form>
				</div>

				<MeetTheTeam />
			</div>
		);
	}
}

export default Home;
