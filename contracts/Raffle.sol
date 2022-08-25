// SPDX-License-Identifier: MIT

// Raffle
// Enter the lottery (paying some amount)
// Pick a random winner (verifiably random)
// Winner to be selected every X minutes -» completly automate
// Chaintink Oracle -> Randomness, Automated Exeeution (Chaintink Keeper
// this is like a brainstorming and it's usually good to do this so we know what we want to do with this contract, have a good idea of what we are tryig to build
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol"; //this imported so we can use the coordinator in our cod
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol"; //so we can use our checkupkeep and
import "hardhat/console.sol";

error Raffle__UpkeepNotNeeded(uint256 currentBalance, uint256 numPlayers, uint256 raffleState); //explanatiion of the error
error Raffle__TransferFailed();
error Raffle__SendMoreToEnterRaffle();
error Raffle__RaffleNotOpen();

/**@title A sample Raffle Contract
 * @author Patrick Collins, more detailed explanation by Abdullahi Suleiman Aliyu
 * @notice This contract is for creating a sample intemperable raffle contract
 * @dev This implements the Chainlink VRF Version 2
 */
contract Raffle is
    VRFConsumerBaseV2,
    KeeperCompatibleInterface //we are saying is vrfconsumerbase2 so we can go and overwrite some of the function, then the KeeperCompatibleInterface judt mskes sure that we can add checkupkeep and performupkeep
{
    /* Type declarations */
    enum RaffleState {
        OPEN,
        CALCULATING
    } //this means uint256-o means open and1 mwans calculating
    /* State variables */
    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // Lottery Variables
    uint256 private immutable i_interval; //imutable cause we are not changing it
    uint256 private immutable i_entranceFee;
    uint256 private s_lastTimeStamp;
    address private s_recentWinner; //to show who the recent winner is
    address payable[] private s_players; //this address is payable cause when one o fthe players win we are going to have to pay them, and also it's got to be
    RaffleState private s_raffleState;

    /* Events */
    event RequestedRaffleWinner(uint256 indexed requestId);
    event RaffleEnter(address indexed player); //its taking one parameter which is the adress of the indexed player
    event WinnerPicked(address indexed player); //this is just so there's a show of who won, and don't forget to emit the winner picked

    /* Functions */
    constructor(
        address vrfCoordinatorV2, //also address vrfcoordinator is passed so we can work with the address providing the random number
        uint64 subscriptionId,
        bytes32 gasLane,
        // keyHash,
        uint256 interval,
        uint256 entranceFee,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        //the vrfcoordinator is the adress that provides the random number
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2); //that way we can work with i_vrfCoordinator now since we've equated it to VRFCoordinatorV2Interface(vrfCoordinatorV2
        i_gasLane = gasLane;
        i_interval = interval;
        i_subscriptionId = subscriptionId;
        i_entranceFee = entranceFee;
        s_raffleState = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp; //so that immediately we deploy we set our timestamp to the last time stamp that way we can check later on to see if it's passed
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterRaffle() public payable {
        //cause want anyone to be able to enter the raffle
        // require(msg.value >= i_entranceFee, "Not enough value sent");
        // require(s_raffleState == RaffleState.OPEN, "Raffle is not open");
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle(); //best option since we want to save gas, so using custom errors is better than the first 2 required methods, but don't forget that we have to add the error at the top of the file
        }
        if (s_raffleState != RaffleState.OPEN) {
            //cause we only want run this function whent he raffle is open
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender)); //msg.sender isn't a payable address which is why we need to type cast it as payable
        // Emit an event when we update a dynamic array or mapping
        emit RaffleEnter(msg.sender);
    }

    /**
     * @dev This is the function that the Chainlink Keeper nodes call
     * they look for `upkeepNeeded` to return True.
     * the following should be true for this to return true:
     * 1. The time interval has passed between raffle runs.
     * 2. The lottery is open.
     * 3. The contract has ETH.
     * 4. Implicity, your subscription is funded with LINK.
     * 5. Also lottery should be in an open state, and this is used in order to curb people from joining the lottery when the function of getting our random is being processed, i.e when the ship has sailed haha
     */
    function checkUpkeep(
        bytes memory /* checkData */ //check data is commented out and this is casue we don't really need it but we need it stored, we cant use calldata cause it's a string so which is why we use memory
    )
        public
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        bool isOpen = RaffleState.OPEN == s_raffleState; //so this means boolean is true if raffle state is in a open stae and it's false if it's in any other state i'e s_rafflestate
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval); //basic you should understand this
        bool hasPlayers = s_players.length > 0; //checking to see if we have enough players
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (timePassed && isOpen && hasBalance && hasPlayers); //this is the boolean that gets returned but since we've initialised it in the parentheses, no need to write bool here again, so if all these conditions comeback as true then we can run our upkeep
        return (upkeepNeeded, "0x0"); // can we comment this out?
    }

    /**
     * @dev Once `checkUpkeep` is returning `true`, this function is called
     * and it kicks off a Chainlink VRF call to get a random winner.
     */
    function performUpkeep(
        //external function is more gas efficient
        bytes calldata /* performData */
    ) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        // require(upkeepNeeded, "Upkeep not needed");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            ); //for this error we are passing in some values just so when someone calls this function and it doesn't go throught the person can have an idea of what might be wrong, i.e the balance might be zero, or the players might be zero, or maybe the state of the raffle is not  open
        }
        s_raffleState = RaffleState.CALCULATING; //so that no one can enter when we are runningthe tx of getting the random winner and number
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, //this is also known as key hash, and this just tells the chainlink node the maximum money we are williing to pay for the gas
            i_subscriptionId, //from chainlink and we need to get the id too pay the link oracle gas
            REQUEST_CONFIRMATIONS, //the amount of blocks we are willing to wait for transaction to run and that's why it's set to constant of just 3
            i_callbackGasLimit, //this is the limit for how much we use for our call back function
            NUM_WORDS //how many randod words we want, so we only want one and cause of that we just make it a constant
        ); //this is all wrapped in and saved as our requestId
        // Quiz... is this redundant?
        emit RequestedRaffleWinner(requestId); //and after this line it means we now have a function that can request a random number.
    }

    /**
     * @dev This is the function that Chainlink VRF node
     * calls to send the money to the random winner.
     */
    function fulfillRandomWords(
        //this means we are fulfilling random numbers
        uint256,
        /* requestId */
        uint256[] memory randomWords
    ) internal override {
        // s_players size 10
        // randomNumber 202
        // 202 % 10 ? what's doesn't divide evenly into 202?
        // 20 * 10 = 200
        // 2
        // 202 % 10 = 2
        uint256 indexOfWinner = randomWords[0] % s_players.length; //randomWords[o] cause we only get one random word
        address payable recentWinner = s_players[indexOfWinner]; //now we get the adress using th index of the winner and make it payable so we can transfer the funds
        s_recentWinner = recentWinner;
        s_players = new address payable[](0); //so after we win we need to set the array to zero again
        s_raffleState = RaffleState.OPEN; //and we are setting it back to open so we can then have a new session
        s_lastTimeStamp = block.timestamp;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        // require(success, "Transfer failed"); this wouldn't be gas efficient so we use if !
        if (!success) {
            revert Raffle__TransferFailed();
        }
        emit WinnerPicked(recentWinner);
    }

    /** Getter Functions */

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }

    function getNumWords() public pure returns (uint256) {
        return NUM_WORDS;
    } //this is pure cause we are getting this from the byte code and it is a constant

    function getRequestConfirmations() public pure returns (uint256) {
        return REQUEST_CONFIRMATIONS;
    } //pure also cause it's a constant

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getLastTimeStamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }

    function getInterval() public view returns (uint256) {
        return i_interval;
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }
}
