import "./TeamStyle.css";

import React, { Component } from "react";
import logo8 from "../Images/LOGO_8_TRANSPARENT.png";

class MeetTheTeam extends Component {
	render() {
		return (
			<div class="container-team">
				<div class="team">
					<div class="member">
						<img
							src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"
							alt="member_image"
						/>
						<h3>Marcus Wentz</h3>
						<span>Fullstack</span>
						<p>
							Lorem ipsum dolor sit amet consectetur adipisicing
							elit.amet consecteturamet consecteturamet Laboriosam
							voluptatum fuga iure. Est, dicta voluptatum.
						</p>
						<div class="btn">
							<a href="#">follow</a>
						</div>
					</div>
					<div class="member">
						<img
							src="https://images.unsplash.com/photo-1527980965255-d3b416303d12?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=800&q=80"
							alt="member_image"
						/>
						<h3>Johanna Fransson</h3>
						<span>Frontend</span>
						<p>
							Lorem ipsum dolor sit amet consectetur adipisicing
							elit.amet consecteturamet consecteturamet Laboriosam
							voluptatum fuga iure. Est, dicta voluptatum.
						</p>
						<div class="btn">
							<a href="#">follow</a>
						</div>
					</div>
					<div class="member">
						<img
							src="https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"
							alt="member_image"
						/>
						<h3>Giovanni Sanchez</h3>
						<span>Backend</span>
						<p>
							Lorem ipsum dolor sit amet consectetur adipisicing
							elit.amet consecteturamet consecteturamet Laboriosam
							voluptatum fuga iure. Est, dicta voluptatum.
						</p>
						<div class="btn">
							<a href="#">follow</a>
						</div>
					</div>
					<div class="member">
						<img
							src="https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80"
							alt="member_image"
						/>
						<h3>Ilyssa Evans</h3>
						<span>Backend</span>
						<p>
							Lorem ipsum dolor sit amet consectetur adipisicing
							elit.amet consecteturamet consecteturamet Laboriosam
							voluptatum fuga iure. Est, dicta voluptatum.
						</p>
						<div class="btn">
							<a href="#">follow</a>
						</div>
					</div>
				</div>
			</div>
		);
	}
}

export default MeetTheTeam;
