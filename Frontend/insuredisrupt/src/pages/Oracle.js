import React, { Component } from "react";

class Oracle extends Component {
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
				<div className="center-container-buy ">
					<h2 style={{ textAlign: "center" }}>Set Oracle Data</h2>

					<div class="form-container-buy">
						<button
							type="button"
							class="btn btn-dark-buy"
							onClick={this.handleSendEth}
						>
							Request Time Now
						</button>
						<p style={{ textAlign: "center" }} className="v-txt">
							WAIT 30s Get: Year Month Date
						</p>

						<button
							type="button"
							class="btn btn-dark-buy"
							onClick={this.handleSendEth}
						>
							Request Eruption Coordinates
						</button>

						<div className="lat-long-container">
							<input
								class="form-control-oracle"
								type="text"
								placeholder="Year"
								onChange={this.handleUserInput}
								value={this.state.userInput}
							></input>
							<div className="label-container"></div>

							<input
								class="form-control-oracle"
								type="text"
								placeholder="Month"
								onChange={this.handleUserInput}
								value={this.state.userInput}
							></input>
							<input
								class="form-control-oracle"
								type="text"
								placeholder="Date"
								onChange={this.handleUserInput}
								value={this.state.userInput}
							></input>
							<input
								class="form-control-oracle"
								type="text"
								placeholder="Country "
								onChange={this.handleUserInput}
								value={this.state.userInput}
							></input>
						</div>

						<div>
							<h4 style={{ textAlign: "center" }}>
								(30s) LatEruption, LongEruption,
							</h4>
							<p>urlRebuiltJSON</p>

							<p>Year/Month/Day of Eruption</p>

							<div style={{ textAlign: "center" }}></div>
						</div>
					</div>
				</div>
			</div>
		);
	}
}

export default Oracle;
