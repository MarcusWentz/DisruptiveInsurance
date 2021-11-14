import React, { Component } from "react";

class Service extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: "default",
		};
	}

	render() {
		return <div className="App-background">Service Component</div>;
	}
}

export default Service;
