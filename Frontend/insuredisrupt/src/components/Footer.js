import "./FooterStyle.css";

import React, { Component } from "react";

class Footer extends Component {
	render() {
		return (
			<footer>
				<div class="content">
					<div class="link-boxes">
						<ul class="box">
							<div class="logo-details">
								<span class="logo_name">InsureDisruption</span>
							</div>
							<li>
								<span
									className="our-logo"
									role="img"
									aria-label="volcano"
									style={{ size: 30, display: "flex" }}
								>
									🌋
								</span>
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
