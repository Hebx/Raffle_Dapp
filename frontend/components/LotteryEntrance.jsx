import { useEffect, useState } from "react";
import { useMoralis, useWeb3Contract } from "react-moralis";
import abi from "../constants/abi.json"

const CONTRACT_ADDRESS = "0x3eAEA181d5CC53D53cDae06e96f29A6705C52553"

export default function LotteryEntrance() {
	const {isWeb3Enabled} = useMoralis()
	const [recentWinner, setRecentWinner] = useState("0")

	// Enter Lottery Button
	const {runContractFunction: enterRaffle}  = useWeb3Contract({
		abi: abi,
		contractAddress: CONTRACT_ADDRESS,
		functionName: "enterRaffle",
		msgValue: "100000000000000000", // 0.1ETH
		params: {},
	});

	// View Function
	const {runContractFunction: getRecentWinner} = useWeb3Contract({
		abi: abi,
		contractAddress: CONTRACT_ADDRESS,
		functionName: "s_recentWinner",
		params: {},
	})

	useEffect(() => {
		async function updateUI() {
			const recentWinnerFromCall = await getRecentWinner()
			setRecentWinner(recentWinnerFromCall)
		}
		if(isWeb3Enabled) {
			updateUI()
		}
	}, [isWeb3Enabled])

	return (
		<div>
			<button className= "rounded ml-auto font-bold bg-red-500"
			onClick={async () => {
				await enterRaffle()
			}} >
				Enter Lottery
			</button>
			<div>The Recent Winner was : {recentWinner}</div>
		</div>
	)
}
