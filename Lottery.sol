//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Lottery {

    address payable public manager;
    address payable public winner;
    uint public playerCount=0;
    address payable[] public players; 
    
    constructor(){ 
    /*
    The msg.sender is the address that has called or initiated a function or created a transaction 
    (manager in this case).
    */
        manager = payable(msg.sender); 
    }

    //Below function ensures unique users have entered.
    function alreadyEntered() view private returns(bool){ 
        for (uint i=0; i<players.length; i++){
            if (players[i]==msg.sender)
            return true;
        }
        return false;
    }
    
    //Below function checks all the constraints and pushes valid player into the array.
    function participate() payable public {

        /*
        We need the contract to recieve funds in the form of ether.If ether is recieved successfully,
        i.e. the lottery is bought, add the participant in the array.
        */

        require(msg.sender != manager, "Sorry! Manager cannot participate.");
        require(alreadyEntered() == false, "Sorry! You can enter the lottery only once.");
        require(msg.value >= 1 ether, "Please pay the minimum amount [1 ETHER]");
        playerCount++;
        players.push(payable(msg.sender));
    }

    //Below function returns a randomly generated uint value based on the players list.
    function random() view private returns(uint) { 

        /*
        players.length: Length of the players list
        block.number: Current block number
        block.difficulty: Difficulty of the block to be mined at the moment
        abi.encodePacked(arg): Used to simply concatenate the arguments into one without spaces
        sha256: Hashing algorithm
        As all the above factors keep changing, the randomness increases, hence it is used to 
        generate a random number which can't be predicted.
        */

        return uint(sha256(abi.encodePacked(block.difficulty,block.number,players.length)));
    }

    //Below function follows certain rules and conditions and picks up the winner.
    function pickWinner() public {
        require(msg.sender == manager, "Sorry! Only manager can pick the winner.");
        require(players.length >=2, "Atleast 2 players required for the Lottery!");
        uint index = random()%players.length; 
        winner = players[index];
        sendReward(winner);        
    }

    //Below function returns all players address.
    function getPlayers() view public returns(address payable[] memory){
        return players;
    }

    //Below function is used to know the amount of ether that are present in contract's fund.
    function balance() view public returns (uint){
        return address(this).balance;
    }

    //Below function is used to transfer ether to the winner's address and an incentive to the manager.
    function sendReward(address payable winnerAddress) internal {

        uint bal = balance();
        uint div = 100;
        uint mul = 10;
        uint incentive = bal / div * mul; //Calculate the incentive manager gets (10%).
        bal = bal-incentive;
        winnerAddress.transfer(bal);
        manager.transfer(incentive);
        //After the reward has been transfered, empty the players list for next lottery session.
        players = new address payable[](0);
        playerCount=0;
    }

}




