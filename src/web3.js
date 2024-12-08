const Web3 = require("web3");
const NODE_ENV = process.env.NODE_ENV || "development";
const NETWORK = process.env.NETWORK || "development";

let web3;

if (NODE_ENV === "development") {
  const { ganacherServer } = require("./ganache.js");
  web3 = new Web3(ganacherServer.provider);
} else {
  // For production networks, use the appropriate provider
  switch (NETWORK) {
    case "sepolia":
      web3 = new Web3(
        `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`
      );
      break;
    case "base-sepolia":
      web3 = new Web3("https://sepolia.base.org");
      break;
    case "zkevm-cardona":
      web3 = new Web3("https://rpc.cardona.zkevm-rpc.com");
      break;
    default:
      throw new Error(`Unsupported network: ${NETWORK}`);
  }
}

// handleRevert required to return the call errors
web3.eth.handleRevert = true;

module.exports = web3;
