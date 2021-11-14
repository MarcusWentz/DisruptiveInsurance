import "./NavbarStyle.css";
import { Link } from "react-router-dom";

import React, { Component } from "react";

class Navbar extends Component {
	render() {
		return (
			<ul className="nav-container">
				<li className="nav-txt">
					<Link to="/" className="nav-link">
						Home
					</Link>
				</li>
				<li className="nav-txt">
					<Link to="/about" className="nav-link">
						About
					</Link>
				</li>
				<li className="nav-txt">
					<Link to="/service" className="nav-link">
						Service
					</Link>
				</li>
			</ul>
		);
	}
}

export default Navbar;
