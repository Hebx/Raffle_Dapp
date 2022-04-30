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

	event RaffleEnter(address indexed player);

	constructor(uint256 entranceFee) {
		i_entranceFee = entranceFee;
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
	
}

