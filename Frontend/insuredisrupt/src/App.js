import "./App.css";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";

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
				<Navbar />
				<Navbar />
				<Navbar />
				<Navbar />
				<Footer />
			</div>
		);
	}
}

export default App;
