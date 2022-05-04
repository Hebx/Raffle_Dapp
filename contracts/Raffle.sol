// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

	import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
	import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

	error Raffle__SendMoreToEnterRaffle();
	error Raffle__NotOpen();
	error Raffle_UpKeepNeeded();
	error Raffle_TransferFailed();
contract Raffle is VRFConsumerBaseV2 {
	enum RaffleState {
		Open,
		Calculating
	}

	RaffleState public s_raffleState;

	uint256 public immutable i_entranceFee;
	address payable[] public s_players;
	uint256 public immutable i_interval;
	uint256 public s_lastTimeStamp;
	VRFCoordinatorV2Interface public immutable i_vrfCoordinator;
	bytes32 public i_gasLane;
	uint64 public i_subscriptionId;
	uint16 public constant REQUEST_CONFIRMATIONS = 3;
	uint32 i_callBackgasLimit;
	uint32 public constant NUM_WORDS = 1;
	address public s_recentWinner;

	event RaffleEnter(address indexed player);
	event RequestRaffleWinner(uint256 indexed requestId);
	event WinnerPicked(address indexed winner);

	constructor(uint256 entranceFee, uint256 interval, address vrfCoordinatorV2, bytes32 gasLane, uint64 subscriptionId, uint32 callBackGasLimit) VRFConsumerBaseV2(vrfCoordinatorV2) {
		i_entranceFee = entranceFee;
		i_interval = interval;
		s_lastTimeStamp = block.timestamp;
		i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
		i_gasLane = gasLane; //keyHash
		i_subscriptionId = subscriptionId;
		i_callBackgasLimit = callBackGasLimit;
	}

	function enterRaffle() external payable {
		// require(msg.value > i_entranceFee, "Not enough money sent!");
		if (msg.value < i_entranceFee) {
			revert Raffle__SendMoreToEnterRaffle();
		}
		// Open, Calculate a winner
		if (s_raffleState != RaffleState.Open) {
			revert Raffle__NotOpen();
		}
		// You can enter
		s_players.push(payable(msg.sender));
		emit RaffleEnter(msg.sender);
	}

	// automation of raffle
	// real random generator
	//1 Be true after some time interval
	// 2 the lottery to be open
	// 3 contract has eth
	// 4 keeps has LINK
	function checkUpKeep(bytes memory /* check data */ ) public view returns(bool upKeepNeeded, bytes memory /* perform data */ ) {
		bool isOpen = RaffleState.Open == s_raffleState;
		bool timePassed =  (block.timestamp - s_lastTimeStamp) > i_interval;// keep track of time
		bool hasBalance = address(this).balance > 0;
		bool hasPlayers = s_players.length > 0;
		upKeepNeeded = timePassed && hasBalance && isOpen && hasPlayers;
		return (upKeepNeeded, "0x0");
	}

	function performUpKeep(bytes calldata /* perform data */) external {
		(bool upKeepNeeded, ) = checkUpKeep("");
		if (!upKeepNeeded) {
			revert Raffle_UpKeepNeeded();
		}
		s_raffleState = RaffleState.Calculating;
		uint256 requestId = i_vrfCoordinator.requestRandomWords(
			i_gasLane,
			i_subscriptionId,
			REQUEST_CONFIRMATIONS,
			i_callBackgasLimit,
			NUM_WORDS
		);
		emit RequestRaffleWinner(requestId);
	}

	function fulfillRandomWords(uint256, /*requestId*/ uint256[] memory randomWords) internal override {
		uint256 indexOfWinenr = randomWords[0] % s_players.length;
		address payable recentWinner = s_players[indexOfWinenr];
		s_players = new address payable[](0);
		s_raffleState = RaffleState.Open;
		s_recentWinner = recentWinner;
		s_lastTimeStamp = block.timestamp;
		(bool success, ) = recentWinner.call{value: address(this).balance}("");
		if(!success) {
			revert Raffle_TransferFailed();
		}
		emit WinnerPicked(recentWinner);
	}
}
// Decentralized escrow for the entry fee
// Decentralized winner picker
