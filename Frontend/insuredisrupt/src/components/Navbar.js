import "./NavbarStyle.css";
import { Link } from "react-router-dom";
import logo8 from "../Images/LOGO_8_TRANSPARENT.png";

import React, { Component } from "react";

class Navbar extends Component {
	render() {
		return (
			<div style={{ display: "flex" }}>
				<img
					className="navbar-logo"
					height="5%"
					width="5%"
					src={logo8}
				/>

				<ul className="nav-container">
					<li className="nav-txt">
						<Link to="/" className="nav-link">
							Home
						</Link>
					</li>
					<li className="nav-txt">
						<Link to="/owner" className="nav-link">
							Owner
						</Link>
					</li>
					<li className="nav-txt">
						<Link to="/buy" className="nav-link">
							Buy
						</Link>
					</li>
					<li className="nav-txt">
						<Link to="/oracle" className="nav-link">
							Oracle
						</Link>
					</li>
					<li className="nav-txt">
						<Link to="/example" className="nav-link">
							Example
						</Link>
					</li>
				</ul>
			</div>
		);
	}
}

export default Navbar;
