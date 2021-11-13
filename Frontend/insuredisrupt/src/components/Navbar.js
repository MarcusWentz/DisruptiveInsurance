import "./NavbarStyle.css";

import React, { Component } from "react";

class Navbar extends Component {
	render() {
		return (
			<ul className="nav-container">
				<li className="nav-txt">
					<a className="nav-link" href="#">
						Home
					</a>
				</li>
				<li className="nav-txt">
					<a className="nav-link" href="#">
						About
					</a>
				</li>
				<li className="nav-txt">
					<a className="nav-link" href="#">
						Service
					</a>
				</li>
			</ul>
		);
	}
}

export default Navbar;
