// hardhat.config.js
require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');


module.exports = {
  solidity: "0.8.20",
  networks: {
    bsctest: {
      url: `https://bsc-testnet.publicnode.com`,
      accounts: ["YOUR_WALLET_PRIVATE_KEY"]
    }
  },
  etherscan: { // to verify using harhat
    apiKey: "",
  },


};
