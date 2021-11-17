//THis is the contract address as deployed on rinkeby
export const CONTRACT_ADDRESS = "0x135aaCB165Ff9100D268d3aa2E1c7bBEFc8b9086";

export const ABI = [
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: "uint256",
				name: "date",
				type: "uint256",
			},
			{
				indexed: true,
				internalType: "address",
				name: "from",
				type: "address",
			},
			{
				indexed: false,
				internalType: "uint256",
				name: "valueChangeEventWenjs",
				type: "uint256",
			},
		],
		name: "setValueUpdatedViaWebjs",
		type: "event",
	},
	{
		inputs: [{ internalType: "uint256", name: "x", type: "uint256" }],
		name: "set",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [],
		name: "storedData",
		outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
		stateMutability: "view",
		type: "function",
	},
];
