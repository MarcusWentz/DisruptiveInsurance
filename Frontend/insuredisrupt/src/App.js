import "./App.css";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";
import { BrowserRouter as Router, Switch, Route } from "react-router-dom";
import Owner from "./pages/Owner";
import Home from "./pages/Home";
import Buy from "./pages/Buy";
import Oracle from "./pages/Oracle";
import Example from "./pages/Example";

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
						<Route path="/owner" component={Owner} />
						<Route path="/buy" component={Buy} />
						<Route path="/oracle" component={Oracle} />
						<Route path="/example" component={Example} />
					</Switch>
					<Footer />
				</Router>
			</div>
		);
	}
}

export default App;
