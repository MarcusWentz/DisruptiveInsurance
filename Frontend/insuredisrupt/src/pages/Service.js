import React, { Component } from "react";

class Service extends Component {
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
					<h2 style={{ textAlign: "center" }}>Buy Insurance</h2>

					<div class="form-container-buy">
						<button
							type="button"
							class="btn btn-dark-buy"
							onClick={this.handleSendEth}
						>
							Buy Policy
						</button>
						<p style={{ textAlign: "center" }} className="v-txt">
							Available ETH to insure:
						</p>
						<p style={{ textAlign: "center" }} className="v-txt">
							5
						</p>

						<div className="lat-long-container">
							<label for="username">Username</label>
							<input
								class="form-control-buy"
								type="text"
								placeholder="Set your value . . . "
								onChange={this.handleUserInput}
								value={this.state.userInput}
							></input>
							<div className="label-container">
								<label for="username">Username</label>
							</div>

							<input
								class="form-control-buy"
								type="text"
								placeholder="Set your value . . . "
								onChange={this.handleUserInput}
								value={this.state.userInput}
							></input>
						</div>

						<div>
							<button
								type="button"
								class="btn btn-dark-buy"
								onClick={this.handleSetContract}
							>
								Claim Reward
							</button>

							<h4 style={{ textAlign: "center" }}>
								display success msg here
							</h4>

							<div style={{ textAlign: "center" }}></div>
						</div>
					</div>
				</div>
			</div>
		);
	}
}

export default Service;
