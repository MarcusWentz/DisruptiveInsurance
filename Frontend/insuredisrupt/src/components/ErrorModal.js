import React, { Component } from "react";
import { Modal } from "react-bootstrap";

class ErrorModal extends Component {
	_isMounted = false;
	constructor(props) {
		super(props);
		this.state = {
			showToast: true,
		};
		this._openToast = this._openToast.bind(this);
		this._closeToast = this._closeToast.bind(this);
	}

	componentDidMount() {
		this._isMounted = true;
		let that = this;
	}

	componentWillUnmount() {
		this._isMounted = false;
	}

	_openToast() {
		this.setState({ showToast: true });
	}

	_closeToast() {
		this.setState({ showToast: false });
	}

	_renderInviteToast() {
		return (
			<Modal
				show={this.state.showToast}
				onHide={this._closeToast}
				aria-labelledby="contained-modal-title-vcenter"
				centered
			>
				<Modal.Header>Warning</Modal.Header>
				<Modal.Body>
					<div className="inv-toast-body">
						You have to connect to Metamask before doing this!
					</div>
				</Modal.Body>
			</Modal>
		);
	}

	render() {
		return <div> {this._renderInviteToast()}</div>;
	}
}

export default ErrorModal;
