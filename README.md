# Hardhat Smartcontract Lottery (Raffle) FCC

This is a section of the Javascript Blockchain/Smart Contract FreeCodeCamp Course.

*[⌨️ (13:41:02) Lesson 9: Hardhat Smart Contract Lottery](https://www.youtube.com/watch?v=gyMwXuJrbJQ&t=49262s)*

[Full Repo](https://github.com/smartcontractkit/full-blockchain-solidity-course-js)

- [Hardhat Smartcontract Lottery (Raffle) FCC](#hardhat-smartcontract-lottery-raffle-fcc)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
  - [Typescript](#typescript)
- [Usage](#usage)
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
- [Deployment to a testnet or mainnet](#deployment-to-a-testnet-or-mainnet)
    - [Estimate gas cost in USD](#estimate-gas-cost-in-usd)
  - [Verify on etherscan](#verify-on-etherscan)
    - [Typescript differences](#typescript-differences)
- [Linting](#linting)
- [Thank you!](#thank-you)

This project is apart of the Hardhat FreeCodeCamp video.

Checkout the full blockchain course video [here.](https://www.youtube.com/watch?v=gyMwXuJrbJQ)

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [Nodejs](https://nodejs.org/en/)
  - You'll know you've installed nodejs right if you can run:
    - `node --version` and get an ouput like: `vx.x.x`
- [Yarn](https://yarnpkg.com/getting-started/install) instead of `npm`
  - You'll know you've installed yarn right if you can run:
    - `yarn --version` and get an output like: `x.x.x`
    - You might need to [install it with `npm`](https://classic.yarnpkg.com/lang/en/docs/install/) or `corepack`

## Quickstart

```
git clone https://github.com/PatrickAlphaC/hardhat-smartcontract-lottery-fcc
cd hardhat-smartcontract-lottery-fcc
yarn
```

## Typescript

If you want to get to typescript and you cloned the javascript version, just run:

```
git checkout typescript
yarn 
```

# Usage

Deploy:

```
yarn hardhat deploy
```

## Testing

```
yarn hardhat test
```

### Test Coverage

```
yarn hardhat coverage
```



# Deployment to a testnet or mainnet

1. Setup environment variabltes

You'll want to set your `RINKEBY_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [metamask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
  - You can [learn how to export it here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).
- `RINKEBY_RPC_URL`: This is url of the rinkeby testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

2. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some tesnet ETH & LINK. You should see the ETH and LINK show up in your metamask. [You can read more on setting up your wallet with LINK.](https://docs.chain.link/docs/deploy-your-first-contract/#install-and-fund-your-metamask-wallet)

3. Setup a Chainlink VRF Subscription ID

Head over to [vrf.chain.link](https://vrf.chain.link/) and setup a new subscription, and get a subscriptionId. You can reuse an old subscription if you already have one. 

[You can follow the instructions](https://docs.chain.link/docs/get-a-random-number/) if you get lost. You should leave this step with:

1. A subscription ID
2. Your subscription should be funded with LINK

3. Deploy

In your `helper-hardhat-config.js` add your `subscriptionId` under the section of the chainId you're using (aka, if you're deploying to rinkeby, add your `subscriptionId` in the `subscriptionId` field under the `4` section.)

Then run:
```
yarn hardhat deploy --network rinkeby
```

And copy / remember the contract address. 

4. Add your contract address as a Chainlink VRF Consumer

Go back to [vrf.chain.link](https://vrf.chain.link) and under your subscription add `Add consumer` and add your contract address. You should also fund the contract with a minimum of 1 LINK. 

5. Register a Chainlink Keepers Upkeep

[You can follow the documentation if you get lost.](https://docs.chain.link/docs/chainlink-keepers/compatible-contracts/)

Go to [keepers.chain.link](https://keepers.chain.link/new) and register a new upkeep. Choose `Custom logic` as your trigger mechanism for automation. Your UI will look something like this once completed:

![Keepers](./img/keepers.png)

6. Enter your raffle!

You're contract is now setup to be a tamper proof autonomous verifiably random lottery. Enter the lottery by running:

```
yarn hardhat run scripts/enter.js --network rinkeby
```

### Estimate gas cost in USD

To get a USD estimation of gas cost, you'll need a `COINMARKETCAP_API_KEY` environment variable. You can get one for free from [CoinMarketCap](https://pro.coinmarketcap.com/signup). 

Then, uncomment the line `coinmarketcap: COINMARKETCAP_API_KEY,` in `hardhat.config.js` to get the USD estimation. Just note, everytime you run your tests it will use an API call, so it might make sense to have using coinmarketcap disabled until you need it. You can disable it by just commenting the line back out. 



## Verify on etherscan

If you deploy to a testnet or mainnet, you can verify it if you get an [API Key](https://etherscan.io/myapikey) from Etherscan and set it as an environemnt variable named `ETHERSCAN_API_KEY`. You can pop it into your `.env` file as seen in the `.env.example`.

In it's current state, if you have your api key set, it will auto verify kovan contracts!

However, you can manual verify with:

```
yarn hardhat verify --constructor-args arguments.js DEPLOYED_CONTRACT_ADDRESS
```

### Typescript differences
1. `.js` files are now `.ts`
2. We added a bunch of typescript and typing packages to our `package.json`. They can be installed with:
   1. `yarn add @typechain/ethers-v5 @typechain/hardhat @types/chai @types/node ts-node typechain typescript`
3. The biggest one being [typechain](https://github.com/dethcrypto/TypeChain)
   1. This gives your contracts static typing, meaning you'll always know exactly what functions a contract can call. 
   2. This gives us `factories` that are specific to the contracts they are factories of. See the tests folder for a version of how this is implemented. 
4. We use `imports` instead of `require`. Confusing to you? [Watch this video](https://www.youtube.com/watch?v=mK54Cn4ceac)
5. Add `tsconfig.json`

# Linting

To check linting / code formatting:
```
yarn lint
```
or, to fix: 
```
yarn lint:fix
```

# Thank you!

If you appreciated this, feel free to follow me or donate!

ETH/Polygon/Avalanche/etc Address: 0x9680201d9c93d65a3603d2088d125e955c73BD65

[![Patrick Collins Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/PatrickAlphaC)
[![Patrick Collins YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/channel/UCn-3f8tw_E1jZvhuHatROwA)
[![Patrick Collins Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/patrickalphac/)
[![Patrick Collins Medium](https://img.shields.io/badge/Medium-000000?style=for-the-badge&logo=medium&logoColor=white)](https://medium.com/@patrick.collins_58673/)


this is a decentralized lottery that fixes the macdonalds issue
we are going to be using chainlinnk vrf to get a random number, then we pick a winner


prettierrc
printwidth of 100 just changes how long words can be on a line before we move to the next line.
semi: false this is so we don't have semi columns at the end of our lines
what we want to do in our raffle.sol file 
Raffle
Enter the lottery (paying some amount)
Pick a random winner (verifiably random)
Winner to be selected every X minutes -» completly automate
Chainlink Oracle -> Randomness, Automated Exeeution (Chaintink Keeper

Introduction to Event
Evm makes a lot  of our blockchain work like ethereum, and the evm has what's called the logging functionality so when things happen on a blockchain it gerts stored in the log and inside the log is what we call events
Events allows us to print stuff to this log in a way that's more gas efficient and it isn't accessible to smart contracts which is why it's cheaper
And this is how a lot of offchain interactions work and it's really important for front end and chainlink
When we emit events in our code there are 2 types of parameters the indexed parameters and the non indexed parameters, there can be upto 3 indexed parameters which are also known as TOPICS, and indexed parameters are much more easier to search for than non indexed ones
emitting an event looks very similar to calling a function
A good syntax for naming events is with the function name reversed,check raffle.sol for our event

Introduction to Chainlink VRF
randomness in web3
this is used for when we want to pick the random winner
CHAINLINK VRF2
instead of vrf1 module where you fund contracts with link here, you are going to be paying for subscriptions which is like an accout that allows you to fund and maintain balance for multiple projects

Using the random number ish in vrfv2
so we connect our wallet inorder to run the subscription
then jumping on remix inorder to create the contract for the vrfv2 consumer address 
in the contracts we've got some imports, the keyhash is  the way you set the gas limit for the random number request
vrfv2 gives a lot more user experience we can get
And when deploying you add the subscriptionId
So after deploying to the testnet on remix we then take the address the contract was deployed to and add it to our consumer address on chainlink
So now to after making a request for randomness, on our vrf app we see that we had some transactions and the amout we spent to run these transactions

Implementing Chainlink V~RF
funtion pick randomnum
know that chainlink vrf is a 2 transactional process 
and this is intentional cause if it was just one transaction people can try to simulate this and it wouldn't be fair so we want to make sure this transaction is fair which is why we are using 2
of course to use this don't forget to import the chainlink code, we add  it to our raffle.sol file and the add it from our terminal

there is a fulfillrandomwords function in our vrf which is in virtual mode cause vrf knows it's going to be over written, so 

HARDHAT SHORTHAND
This is a shorthand and auto complete for us to write shorter codes in our terminal
added by running the command line yarn globald add hardhat-shorthand
after this yarn ahrdhat compile is same as hh compile

IMPLEMENTING CHAINLINK VRF
So this is for us requesting our random user

IMPLEMENTING CHAINLINK VRF
The fulfill
Modulo after getting the random number we need to pick a random winner, which is what we do by using the modulo function
A random number is potentially massive and could be in the billions for all we know and our array can only be so big, so for us to get a random user from our array we use what we call the modulo function
The modulo funciton provides the remainder after the division or
so if our s_players array is 10 and we have a random number of 202 then our modulo is 2
so 2o2 % 10 = 2
so we can set this as the indes of our winner

Introduction to chainlink keepeers
This is used to automatically trigger an account when an event happens or an offchain event occurs or what have you
so if you open the keeper cointract on remix, we can see how we can set our update interval to what we want
Checkupkeep is special because this is where the offchain computation works
so if the checkupkeep returns that upkeep is needed then we are going to then run the upkeep on chain
The performupkeep is where we want to verify that things are okay and that things should actually be modified
After compilation and deployment on the test network, so after it's live i.e the contract, we take the contract address and we pass it to the chainlink and register a new upkeep
After it's registered we can no w wait for the interval we placed to see that our contract gets upkept and registered by chainlnk

Implementing chainlink keepers
checkupkeep
so the checkupkeep in our code is just for us to check and see if it's time for us to send money to our random winner

ENUM 
this can be used to create custom types with a finite set of constant values, so now we create an enum for our code and this is like a uint256
block.timestamp this returns the currrent time stamp of the block chain, but to know if  we've passed our block time we need to pass the last block time which is why we need to create a variable that keeps track of this
Implementing Chainlink Keepers
perform upkeep

Dont forget to add NatSpec before the contract to give your code reader an idea of what's going on.

Deploy
Just like previous we are going to add the needed scripts,
for example since we are going to need to interact with an interface or like the vrfcoordinator that's outside of our project so we need to create a mock for this

Don't forget to use mocks if we are on a deelopment chain and the actual contract for when we are on our test netor a live network, and this is done in the helper hardhat config file, where we add the address for each of this networks regarding interface by grabbing it from chainlink
Deploy mocks is our mock deployment incase we are working on a loval network

We can also navigate our way to github repo of chainlink when we neeed to look at the hardcode for some of these stuffs for e.g, we go to chaininlink, develop, contracts, src, v0.8, mocks vrfv2 mocks and here we can see how the mocks was gotten


On a local network it's going to be harder for us to run the subscription id through the website and it's going to be better if we can get it programmatically, cause by hard coding it practically just boils down to creating the subscription and then funding the subscription

TESTS
Also dont forget that if you want to run a particular test you use the grep keyword and add a specific quote from the test

here  we are testing if an event is emitted
it("emits event on enter", async () => {
                  await expect(raffle.enterRaffle({ value: raffleEntranceFee })).to.emit( // emits RaffleEnter event if entered to index player(s) address
                      raffle,
                      "RaffleEnter"
                  )
              })

              here .to.emit we pass the event we are expecting to emit

HArdhat methods and time travelling
This is done when we make our code think that we are chainlink so we can process the test, this is our test on checkupkeep and the rest. for example if our test on check up keep needs us tohave an interval of 10 days we cant wait 10 days to run a test so we can try to manipulate this using hardhat
Under Hardhat Network reference 
for example there is evm increase time which auto allows us to increaste the time of our blockchain and then there is evm mine which allows us to mine or create new blocks, and now we can fforward to our time interval to check what we want
                  await network.provider.send("evm_increaseTime", [interval.toNumber() + 1])//so this helps us incrrease the blocknumber at the time

Callstatic
THIS IS WHEN WE SIMULATE running a transaction instead of calling it in essence
    const { upkeepNeeded } = await raffle.callStatic.checkUpkeep("0x") // upkeepNeeded = (timePassed && isOpen && hasBalance && hasPlayers)

    A string of "0x" is going to be translated by hardhat into an empty  byte object which is same as ([])

    All our describe block are normal functions but for our its remember they have to be async functions as there is going to be need for us to use await

    Also we need to create a new describeblock for perform upkeep in our test code

    dont forget the command click too inorder to go deeper ino the code or function for example on here with our vrfcoordinator

    Staging test
    note that most of our staging test is going to look similar to our unit test

    ?  ( )  :  ( )   -  THIS MEANS IF CONDITION IS TRUE DO SOMETHING : IF NOT DO ANOTHER THING


    Testing on a test net 
    to do this we need to 
    1. get our subid for the vrf
    2. Deploy the contracts using the subid
    3.Register the cotracts with chainlink vrf and it's subId
    4. Register the cotracts with chainlink keepers
    5. we now run the staging tests

    we go to the faucets link and we get eth and link tokens 
    After creating the subscription we can now take the subid and add it to the subid in our helperhardhat conifg
    then we add funds into the account so we can pay the oracle gas to get our random numbers
    dont forget about adding everything we need in our .env file

    so after deploying to a test net we should see everything regarding our code with the functions and maybe it's already verified after which we then can check the raffle state already and see that its still open
    then we add the consumer address on our chainlink vrf and the address we add is going to be thecontract address to which our contract was deployed
    After everything has gone through
    and when you go back and chek we can see our upkeeps and see what the balance is and what not
    running our staging test is the same as us running an enter script
    hh test --network rinkeby
    the first tx is entering the raffle and we do see that after a while we can see it in our tx history on etherscan
    after the tests run we cant find our performupkeep function and check upkeep on etherscan until we check the internal txns section and then we can see them and this is cause these txs are called by our vrf internally
    hh test only runs our unit test