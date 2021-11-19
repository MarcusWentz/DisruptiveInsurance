import React, { Component } from "react";

class Owner extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: "default",
			successMsg: "",
			availableEth: "",
		};
	}

	render() {
		return (
			<div className="App-background">
				<div className="center-container ">
					<h2 style={{ textAlign: "center" }}>Owner</h2>

					<div class="form-container">
						<button
							type="button"
							class="btn btn-dark"
							onClick={this.handleSendEth}
						>
							Fund Contract
						</button>
						<p
							style={{ textAlign: "center", margin: 0 }}
							className="v-txt"
						>
							Available Eth:
						</p>
						<p style={{ textAlign: "center" }} className="v-txt">
							1
						</p>
						<button
							type="button"
							class="btn btn-dark"
							onClick={this.handleSetContract}
						>
							Claim ETH from expired policy
						</button>

						<div>
							<input
								class="form-control"
								type="text"
								placeholder="Policy address. . . "
								onChange={this.handleUserInput}
								value={this.state.userInput}
								style={{ textAlign: "center" }}
							></input>

							<button
								type="button"
								class="btn btn-dark"
								onClick={this.handleSetContract}
							>
								Claim 1 ETH not connected to a Policy
							</button>

							<button
								type="button"
								class="btn btn-dark"
								onClick={this.handleSetContract}
							>
								Claim all ETH from a self destruct attack
							</button>

							<p
								style={{ textAlign: "center" }}
								className="v-txt"
							>
								Success message goes here
								<h4 style={{ textAlign: "center" }}>Success</h4>
							</p>
							<div style={{ textAlign: "center" }}></div>
						</div>
					</div>
				</div>
			</div>
		);
	}
}

export default Owner;
