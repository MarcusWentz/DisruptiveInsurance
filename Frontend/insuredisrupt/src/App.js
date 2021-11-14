import "./App.css";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import About from "./pages/About";
import Home from "./pages/Home";
import Service from "./pages/Service";

import React, { Component } from "react";

class App extends Component {
	constructor(props) {
		super(props);
		this.state = {
			account: "default",
		};
	}

	render() {
		return (
			<div className="App-background">
				<Router>
					<Navbar />
					<Switch>
						<Route exact path="/" component={Home} />
						<Route path="/about" component={About} />
						<Route path="/service" component={Service} />
					</Switch>

					<Footer />
				</Router>
			</div>
		);
	}
}

export default App;
