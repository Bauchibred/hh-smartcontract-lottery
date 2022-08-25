const { getNamedAccounts, deployments, network, ethers } = require("hardhat")

const BASE_FEE = "250000000000000000" // 0.25 is this the premium in LINK? Also unlike the pricefeed where there are already a group of people paying for that information we are the only ones requesting this random number which is why we pay for iot
const GAS_PRICE_LINK = 1e9 // link per gas, is this the gas lane? // 0.000000001 LINK per gas. And this is a calculated value so chainlink never goes bankrupt, in the sense that if the price of the native token of the chain we are on skyrockets, there is going to be the need for the gas price to also skyrocket, and since chainlink pays for this, it's going to need more money to make this tx

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    // If we are on a local development network, we need to deploy mocks!
    if (chainId == 31337) {
        log("Local network detected! Deploying mocks...")
        await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            log: true,
            args: [BASE_FEE, GAS_PRICE_LINK],
        })

        log("Mocks Deployed!")
        log("----------------------------------------------------------")
        log("You are deploying to a local network, you'll need a local network running to interact")
        log(
            "Please run `yarn hardhat console --network localhost` to interact with the deployed smart contracts!"
        )
        log("----------------------------------------------------------")
    }
}
module.exports.tags = ["all", "mocks"]
