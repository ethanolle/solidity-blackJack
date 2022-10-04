// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract BlackJack {
    struct Game { 
        uint256 id;
        uint256[] playerHand;
        uint256[] dealerHand;
        uint256 createdAt;
        uint256 updatedAt;
        bool playerWon;
        uint256[] bets;
    }

    address payable public owner;

    mapping(address => uint256) public balances;
    mapping(address => Game) public games;

    event Withdrawal(uint amount, uint when);

    constructor() payable {
        owner = payable(msg.sender);
    }

    receive() external payable {}
    fallback() external payable {}

    function deposit() public payable {
        require(msg.value > 0, "You need to send some Ether");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint _amount) public {
        require(msg.sender == owner, "Only owner can withdraw");
        require(address(this).balance >= _amount, "Not enough funds in the smart contract");
        (bool success, ) = owner.call{value: _amount}("");
        require(success, "Failed to withdraw Ether");
        emit Withdrawal(_amount, block.timestamp);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function  getPlayerBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function getPlayerGameInfo() public view returns (Game memory) {
        return games[msg.sender];
    }

    function startGame( uint256 _initialBet) public returns (uint,uint){
        address _player = msg.sender;
        require(balances[_player] >= 0.1 ether, "You need to have at least 0.1 ether to play");
        require(_initialBet >= 0.1 ether, "You need to bet at least 0.1 ether");
        if (games[_player].createdAt > 0 && games[_player].createdAt + 24 hours < block.timestamp) {
            delete games[_player];
        }
        balances[_player] -= _initialBet;
        games[_player] = Game({
            id: block.timestamp,
            playerHand: new uint256[](0),
            dealerHand: new uint256[](0),
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            playerWon: false,
            bets: new uint256[](0)
        });
        games[_player].bets.push(_initialBet);
        games[_player].playerHand.push(randomNumber(0, 52));
        games[_player].dealerHand.push(randomNumber(0, 52));
        return (games[_player].playerHand[0], games[_player].dealerHand[0]);
    }

    function hit() public returns (uint) {
        address _player = msg.sender;
        require(games[_player].createdAt > 0, "You need to start a game first");
        require(games[_player].createdAt + 24 hours > block.timestamp, "Game has expired");
        games[_player].playerHand.push(randomNumber(0, 52));
        return games[_player].playerHand[games[_player].playerHand.length - 1];
    }

    // stand function returns that array of dealer and player hand and if won or lost if won transfer the money if lost keep it in 

    function stand() public returns (uint[] memory, uint[] memory, bool) {
        address _player = msg.sender;
        require(games[_player].createdAt > 0, "You need to start a game first");
        require(games[_player].createdAt + 24 hours > block.timestamp, "Game has expired");
        while (getHandValue(games[_player].dealerHand) < 17) {
            games[_player].dealerHand.push(randomNumber(0, 52));
        }
        uint256 _playerHandValue = getHandValue(games[_player].playerHand);
        uint256 _dealerHandValue = getHandValue(games[_player].dealerHand);
        while (_dealerHandValue < 17) {
            games[_player].dealerHand.push(randomNumber(0, 52));
            _dealerHandValue = getHandValue(games[_player].dealerHand);
        }
        if (_playerHandValue > 21) {
            games[_player].playerWon = false;
        } else if (_dealerHandValue > 21) {
            games[_player].playerWon = true;
        } else if (_playerHandValue > _dealerHandValue) {
            games[_player].playerWon = true;
        } else {
            games[_player].playerWon = false;
        }
        if (games[_player].playerWon) {
            uint256 _totalBet = 0;
            for (uint256 i = 0; i < games[_player].bets.length; i++) {
                _totalBet += games[_player].bets[i];
            }
            balances[_player] += _totalBet * 2;
        }
        return (games[_player].playerHand, games[_player].dealerHand, games[_player].playerWon);
    }




   function getHandValue(uint256[] memory _hand) public pure returns (uint256) {
        uint256 _handValue = 0;
        for (uint256 i = 0; i < _hand.length; i++) {
            uint256 _cardValue = _hand[i] % 13;
            if (_cardValue == 0) {
                _cardValue = 13;
            }
            if (_cardValue > 10) {
                _cardValue = 10;
            }
            _handValue += _cardValue;
        }
        return _handValue;
    }



    function randomNumber(uint256 _min, uint256 _max) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp))) % _max + _min;
    }
}



