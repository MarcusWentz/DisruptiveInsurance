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
			</div>
		);
	}
}

export default Navbar;
