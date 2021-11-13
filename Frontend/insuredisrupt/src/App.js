import "./App.css";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";

import React, { Component } from "react";

class App extends Component {
	render() {
		return (
			<div className="App-background">
				<Navbar />
				<div className="center-container ">
					<div class="circle">V</div>

					<h3 className="v-txt">Welcome</h3>
					<p className="v-txt">This site is under construction.</p>
				</div>

				<Footer />
			</div>
		);
	}
}

export default App;
