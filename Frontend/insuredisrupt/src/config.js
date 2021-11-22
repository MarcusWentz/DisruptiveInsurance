//THis is the contract address as deployed on rinkeby
export const CONTRACT_ADDRESS = "0xAc62B615451f227905b65D621308E77861132eF3";

export const ABI = [
	{ inputs: [], stateMutability: "nonpayable", type: "constructor" },
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: "bytes32",
				name: "id",
				type: "bytes32",
			},
		],
		name: "ChainlinkCancelled",
		type: "event",
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: "bytes32",
				name: "id",
				type: "bytes32",
			},
		],
		name: "ChainlinkFulfilled",
		type: "event",
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: "bytes32",
				name: "id",
				type: "bytes32",
			},
		],
		name: "ChainlinkRequested",
		type: "event",
	},
	{
		anonymous: false,
		inputs: [
			{
				indexed: true,
				internalType: "address",
				name: "from",
				type: "address",
			},
		],
		name: "recordMessageSender",
		type: "event",
	},
	{
		inputs: [],
		name: "AccountsInsured",
		outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [
			{ internalType: "address", name: "policyHolder", type: "address" },
		],
		name: "BuyerClaimReward",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [
			{ internalType: "int256", name: "inputLat", type: "int256" },
			{ internalType: "int256", name: "inputLong", type: "int256" },
		],
		name: "BuyerCreatePolicy",
		outputs: [],
		stateMutability: "payable",
		type: "function",
	},
	{
		inputs: [],
		name: "DayEruption",
		outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [],
		name: "DayPresent",
		outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [],
		name: "LatitudeEruption",
		outputs: [{ internalType: "int256", name: "", type: "int256" }],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [],
		name: "LongitudeEruption",
		outputs: [{ internalType: "int256", name: "", type: "int256" }],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [],
		name: "MonthEruption",
		outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [],
		name: "MonthPresent",
		outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [],
		name: "OpenETHtoInsure",
		outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [],
		name: "OracleRequestPresentTime",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [
			{ internalType: "string", name: "filterYear", type: "string" },
			{ internalType: "string", name: "filterMonth", type: "string" },
			{ internalType: "string", name: "filterDay", type: "string" },
			{ internalType: "string", name: "filterCountry", type: "string" },
		],
		name: "OracleRequestVolcanoEruptionData",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [],
		name: "Owner",
		outputs: [{ internalType: "address", name: "", type: "address" }],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [
			{ internalType: "address", name: "policyHolder", type: "address" },
		],
		name: "OwnerClaimExpiredPolicyETH",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [],
		name: "OwnerLiquidtoOpenETHToWithdraw",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [],
		name: "OwnerSelfDestructClaimETH",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [],
		name: "OwnerSendOneEthToContractFromInsuranceBusiness",
		outputs: [],
		stateMutability: "payable",
		type: "function",
	},
	{
		inputs: [],
		name: "YearEruption",
		outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [],
		name: "YearPresent",
		outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [],
		name: "convert",
		outputs: [
			{ internalType: "contractConvert", name: "", type: "address" },
		],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [
			{ internalType: "bytes32", name: "_requestId", type: "bytes32" },
			{
				internalType: "uint256",
				name: "oracleDayPresent",
				type: "uint256",
			},
		],
		name: "fulfill_request_DayPresent",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [
			{ internalType: "bytes32", name: "_requestId", type: "bytes32" },
			{
				internalType: "bytes32",
				name: "oracleDayEruption",
				type: "bytes32",
			},
		],
		name: "fulfill_request_Day_Eruption",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [
			{ internalType: "bytes32", name: "_requestId", type: "bytes32" },
			{
				internalType: "int256",
				name: "oracleLatitudeEruption",
				type: "int256",
			},
		],
		name: "fulfill_request_Latitude",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [
			{ internalType: "bytes32", name: "_requestId", type: "bytes32" },
			{
				internalType: "int256",
				name: "oracleLongitudeEruption",
				type: "int256",
			},
		],
		name: "fulfill_request_Longitude",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [
			{ internalType: "bytes32", name: "_requestId", type: "bytes32" },
			{
				internalType: "uint256",
				name: "oracleMonthPresent",
				type: "uint256",
			},
		],
		name: "fulfill_request_MonthPresent",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [
			{ internalType: "bytes32", name: "_requestId", type: "bytes32" },
			{
				internalType: "bytes32",
				name: "oracleMonthEruption",
				type: "bytes32",
			},
		],
		name: "fulfill_request_Month_Eruption",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [
			{ internalType: "bytes32", name: "_requestId", type: "bytes32" },
			{
				internalType: "uint256",
				name: "oracleYearPresent",
				type: "uint256",
			},
		],
		name: "fulfill_request_YearPresent",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [
			{ internalType: "bytes32", name: "_requestId", type: "bytes32" },
			{
				internalType: "uint256",
				name: "oracleYearEruption",
				type: "uint256",
			},
		],
		name: "fulfill_request_Year_Eruption",
		outputs: [],
		stateMutability: "nonpayable",
		type: "function",
	},
	{
		inputs: [{ internalType: "address", name: "", type: "address" }],
		name: "policies",
		outputs: [
			{ internalType: "int256", name: "LatitudeInsured", type: "int256" },
			{
				internalType: "int256",
				name: "LongitudeInsured",
				type: "int256",
			},
			{ internalType: "uint256", name: "YearSigned", type: "uint256" },
			{ internalType: "uint256", name: "MonthSigned", type: "uint256" },
			{ internalType: "uint256", name: "DaySigned", type: "uint256" },
			{
				internalType: "uint256",
				name: "EthereumAwardTiedToAddress",
				type: "uint256",
			},
		],
		stateMutability: "view",
		type: "function",
	},
	{
		inputs: [],
		name: "urlRebuiltJSON",
		outputs: [{ internalType: "string", name: "", type: "string" }],
		stateMutability: "view",
		type: "function",
	},
];
