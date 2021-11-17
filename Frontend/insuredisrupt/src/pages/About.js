import React, { Component } from "react";

class About extends Component {
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
					<img
						width="300"
						height="400"
						src="https://cryptologos.cc/logos/chainlink-link-logo.svg?v=014"
					/>
					<h2 style={{ textAlign: "center" }}>About this project</h2>
				</div>
			</div>
		);
	}
}

export default About;
