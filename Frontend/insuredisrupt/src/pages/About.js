import React, { Component } from "react";
import logo7 from "../Images/logo7transparent.png";
import logo8 from "../Images/LOGO_8_TRANSPARENT.png";

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
					<img src={logo8} />
					<h2 style={{ textAlign: "center" }}>About this project</h2>
				</div>
			</div>
		);
	}
}

export default About;
