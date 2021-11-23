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
							src="https://challengepost-s3-challengepost.netdna-ssl.com/photos/production/user_photos/001/750/177/datas/profile.jpeg"
							alt="member_image"
						/>
						<h3>Marcus Wentz</h3>
						<span>
							<b>Fullstack</b>
						</span>
						<p></p>
						<div class="btn">
							<a
								href="https://www.linkedin.com/in/marcus-wentz-a91351102/"
								target="_blank"
							>
								Linkedin
							</a>
						</div>
					</div>
					<div class="member">
						<img
							src="https://lh3.googleusercontent.com/a-/AOh14GhAxtEsIL_SZ9hVWuCvs1N0T93jtOjrM02L3ubb=s96-c?height=180&width=180"
							alt="member_image"
						/>
						<h3>Johanna Fransson</h3>

						<span>
							<b>Frontend</b>
						</span>
						<p></p>
						<div class="btn">
							<a
								href="https://www.linkedin.com/in/franssonjohanna/"
								target="_blank"
							>
								Linkedin
							</a>
						</div>
					</div>
					<div class="member">
						<img
							src="https://challengepost-s3-challengepost.netdna-ssl.com/photos/production/user_photos/001/719/909/datas/profile.png"
							alt="member_image"
						/>
						<h3>Giovanni Sanchez</h3>
						<span>
							<b>Backend</b>
						</span>
						<p></p>
						<div class="btn">
							<a
								href="https://www.linkedin.com/in/sanchezgiovanni/"
								target="_blank"
							>
								Linkedin
							</a>
						</div>
					</div>
					<div class="member">
						<img
							src="https://challengepost-s3-challengepost.netdna-ssl.com/photos/production/user_photos/001/740/512/datas/profile.jpg"
							alt="member_image"
						/>
						<h3>Ilyssa Evans</h3>
						<span>
							<b>Backend</b>
						</span>
						<p></p>
						<div class="btn">
							<a
								href="https://www.linkedin.com/in/ilyssaevans/"
								target="_blank"
							>
								Linkedin
							</a>
						</div>
					</div>
				</div>
			</div>
		);
	}
}

export default MeetTheTeam;
