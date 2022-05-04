require("hardhat-deploy")
require("dotenv").config()
require("@nomiclabs/hardhat-waffle")


/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  network: {
    rinkeby: {
      url: process.env.RINKEBY_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      chainID: 4,
      saveDeployments: true,
    },
  },
  namedAccounts:{
    deployer: {
      default: 0,
    },
  },
  solidity: "0.8.7",
};
