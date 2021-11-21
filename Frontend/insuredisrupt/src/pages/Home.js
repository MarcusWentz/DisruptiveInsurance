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
						<h3 className="about-header">About</h3>
						<p className="project-description">Explore our</p>
					</form>
				</div>

				<MeetTheTeam />
			</div>
		);
	}
}

export default Home;
