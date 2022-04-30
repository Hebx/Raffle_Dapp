// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

	error Raffle__SendMoreToEnterRaffle();
	error Raffle__NotOpen();
contract Raffle {
	enum RaffleState {
		Open,
		Calculating
	}

	RaffleState public s_raffleState;

	uint256 public immutable i_entranceFee;
	address payable[] public s_players;
	uint256 public immutable i_interval;
	uint256 public s_lastTimeStamp;

	event RaffleEnter(address indexed player);

	constructor(uint256 entranceFee, uint256 interval) {
		i_entranceFee = entranceFee;
		i_interval = interval;
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
	// 3 ontract has eth
	// 4 keeps has LINK
	function checkUpKeep(bytes memory /* check data */ ) public view returns(bool upKeepNeeded, bytes memory /* perform data */ ) {
		bool isOpen = RaffleState.Open == s_raffleState;
		bool timePassed =  (block.timestamp - s_lastTimeStamp) > i_interval;// keep track of time
	}
}

