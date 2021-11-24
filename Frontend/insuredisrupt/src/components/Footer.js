import "./FooterStyle.css";

import React, { Component } from "react";
import { Link } from "react-router-dom";

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
								{" "}
								<a>
									<Link
										to="/"
										className="nav-link"
										style={{ marginLeft: -17 }}
									>
										Team
									</Link>
								</a>
							</li>
							<li>
								<a target="_blank" href="https://chain.link/">
									Chainlink
								</a>
							</li>
						</ul>
						<ul class="box">
							<li class="link_name">Support</li>
							<li>
								<a
									href="https://chain.link/hackathon"
									target="_blank"
								>
									FAQ
								</a>
							</li>
							<li>
								<Link
									to="/"
									className="nav-link"
									style={{ marginLeft: -17 }}
								>
									Contact
								</Link>
							</li>
						</ul>
						<ul class="box">
							<li class="link_name">Social</li>
							<li>
								<a
									target="_blank"
									href="https://github.com/MarcusWentz/DisruptiveInsurance/"
								>
									Github
								</a>
							</li>
							<li>
								<a
									target="_blank"
									href="https://discord.com/app"
								>
									Discord
								</a>
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
