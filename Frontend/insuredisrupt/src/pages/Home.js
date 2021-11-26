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
						<h2 className="about-header">What it does</h2>
						<p className="project-description">
							Disruptive Insurance is an exotic insurance service
							that allows users to buy insurance against volcano
							eruptions. No other insurance business on Earth
							offers volcano eruption insurance.
							<br />
							<br /> The owner of the contract seeds ETH to the
							insurance contract. Anyone with a Metamask wallet
							can buy an insurance policy which is then tied to
							their address, defined by their coordinates and the
							date they purchased the policy. One ETH seeded to
							the contract is then locked for the duration of the
							policy to be paid out in the event a claim needs to
							be made. If a volcano erupts within 1 coordinate
							point from the policy holder’s location before the
							expiration of the contract, the holder can then
							claim the ETH that was initially locked to their
							policy as their insurance payout. However, if the
							policy expires without a relevant volcano eruption,
							the contract owner can claim the ETH that was locked
							to the policy. Owners can even claim ETH from self
							destruct attacks!
						</p>
					</form>
				</div>

				<MeetTheTeam />
			</div>
		);
	}
}

export default Home;
