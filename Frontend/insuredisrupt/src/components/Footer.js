import "./FooterStyle.css";

import React, { Component } from "react";
import logo8 from "../Images/LOGO_8_TRANSPARENT.png";

class Footer extends Component {
	render() {
		return (
			<footer>
				<div class="content">
					<div class="link-boxes">
						<ul class="box">
							<li class="link_name">InsureDisruption</li>
							<li>
								<img width="50%" src={logo8} />
							</li>
						</ul>
						<ul class="box">
							<li class="link_name">Project</li>
							<li>
								<a href="#">Team</a>
							</li>
							<li>
								<a href="#">Chainlink</a>
							</li>
							<li>
								<a href="#">Terms of Service</a>
							</li>
							<li>
								<a href="#">Privacy Policy</a>
							</li>
						</ul>
						<ul class="box">
							<li class="link_name">Support</li>
							<li>
								<a href="#">FAQ</a>
							</li>
							<li>
								<a href="#">Contact</a>
							</li>
						</ul>
						<ul class="box">
							<li class="link_name">Social</li>
							<li>
								<a href="#">Github</a>
							</li>
							<li>
								<a href="#">Discord</a>
							</li>
							<li>
								<a href="#"></a>
							</li>
						</ul>
					</div>
				</div>
			</footer>
		);
	}
}

export default Footer;
