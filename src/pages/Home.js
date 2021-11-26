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
							<br />
							<br />
							<h2 className="about-header">What it does</h2>
							The contract owner sends ETH to the insurance
							contract. Anyone with a Metamask wallet can buy an
							insurance policy which is then tied to their
							address, defined by their coordinates and the date
							they purchased the policy. One ETH sent to the
							contract is then locked for the policy’s duration [1
							year] to be paid out in the event a claim needs to
							be made. <br />
							<br /> If a volcano erupts within 1 coordinate point
							from the policy holder’s location before the
							expiration of the contract, the holder can then
							claim the ETH that was initially locked to their
							policy as their insurance payout. <br />
							<br />
							However, if the policy expires without a relevant
							volcano eruption, the contract owner can claim the
							ETH that was locked to the policy. Owners can remove
							ETH they added to the contract if a policy isn’t
							tied to it as a savings account. Owners can even
							claim ETH from self destruct attacks!
						</p>
					</form>
					<form
						style={{ marginTop: 100 }}
						class="form-container-about"
					>
						<h2 className="about-header">Instructions</h2>
						<p className="project-description">
							<h3>Buyer:</h3>
							Buy policy
							<p style={{ marginLeft: 20 }}>
								1.Oracle: Get present time <br />
								2.Record address, time, input coordinates and
								locked Owner ETH for policy.
							</p>
							Claim Reward from qualified policy:
							<p style={{ marginLeft: 20 }}>
								1. Oracle: Get filtered volcano eruption data
								(time, coordinates)
								<br />
								2. Check if policy is older than eruption date
								and the coordinates are within + or - 1
								coordinate point.
								<br />
								3. Policy holder claims 1 ETH if Step 2 checks
								are true then deletes policy data.
								<br />
							</p>
							<h3> Owner:</h3>
							Get paid directly after a policy is bought.
							<br /> Attract Buyers:
							<p style={{ marginLeft: 20 }}>
								1.Add funds to make policies available with
								OwnerSendOneEthToContractFromInsuranceBusiness.
							</p>
							Claim ETH <br />
							Expired Claim:
							<p style={{ marginLeft: 20 }}>
								1.Oracle: Get present time <br />
								2.Check if policy connected to a mapped address
								is over 1 year old. <br />
								3.Liquidate ETH from policy and delete policy
								data.
							</p>
							Claim ETH not tied to policy
							<p style={{ marginLeft: 20 }}>
								1.Check if OpenETHtoInsure is greater than 0.
								<br />
								2.Claim one ETH from contract.
							</p>
							Self Destruct
							<p style={{ marginLeft: 20 }}>
								1.If the sum of AccountsInsured and
								OpenETHtoInsure is greater than smart contract
								ETH balance, then a self destruct attack
								occurred and you can claim that ETH.
							</p>
						</p>
					</form>
				</div>

				<MeetTheTeam />
			</div>
		);
	}
}

export default Home;
