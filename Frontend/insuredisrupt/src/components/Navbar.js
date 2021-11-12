import "../App.css";

import React, { Component } from "react";

class Navbar extends Component {
	render() {
		return (
			<ul>
				<li>
					<a href="#">Home</a>
				</li>
				<li>
					<a href="#">About</a>
				</li>
				<li>
					<a href="#">Service</a>
				</li>
			</ul>
		);
	}
}

export default Navbar;
