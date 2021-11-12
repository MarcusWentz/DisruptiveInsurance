import "./App.css";
import Navbar from "./components/Navbar";

import React, { Component } from "react";

class App extends Component {
	render() {
		return (
			<div className="App-background">
				<span
					role="img"
					aria-label="volcano"
					style={{ size: 30, display: "flex" }}
				>
					🌋
				</span>
				<Navbar />
			</div>
		);
	}
}

export default App;
