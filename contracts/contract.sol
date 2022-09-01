pragma solidity ^0.8.13;

contract CardGame {
    mapping(address => uint256) public deposits;

    struct Player {
        address addr;
        uint256 chips;
    }

    uint64 num_players;
    Player[] current_players;

    struct Card {
        string name;
        uint8 suit;
    }

    Card[] public deck = [
        // hearts
        Card("2", HEARTS),
        Card("3", HEARTS),
        Card("4", HEARTS),
        Card("5", HEARTS),
        Card("6", HEARTS),
        Card("7", HEARTS),
        Card("8", HEARTS),
        Card("9", HEARTS),
        Card("10", HEARTS),
        Card("J", HEARTS),
        Card("Q", HEARTS),
        Card("K", HEARTS),
        Card("A", HEARTS),
        // diamonds
        Card("2", DIAMONDS),
        Card("3", DIAMONDS),
        Card("4", DIAMONDS),
        Card("5", DIAMONDS),
        Card("6", DIAMONDS),
        Card("7", DIAMONDS),
        Card("8", DIAMONDS),
        Card("9", DIAMONDS),
        Card("10", DIAMONDS),
        Card("J", DIAMONDS),
        Card("Q", DIAMONDS),
        Card("K", DIAMONDS),
        Card("A", DIAMONDS),
        // clubs
        Card("2", CLUBS),
        Card("3", CLUBS),
        Card("4", CLUBS),
        Card("5", CLUBS),
        Card("6", CLUBS),
        Card("7", CLUBS),
        Card("8", CLUBS),
        Card("9", CLUBS),
        Card("10", CLUBS),
        Card("J", CLUBS),
        Card("Q", CLUBS),
        Card("K", CLUBS),
        Card("A", CLUBS),
        // spades
        Card("2", SPADES),
        Card("3", SPADES),
        Card("4", SPADES),
        Card("5", SPADES),
        Card("6", SPADES),
        Card("7", SPADES),
        Card("8", SPADES),
        Card("9", SPADES),
        Card("10", SPADES),
        Card("J", SPADES),
        Card("Q", SPADES),
        Card("K", SPADES),
        Card("A", SPADES)
    ];

    uint8 offset = 0;

    uint8 constant HEARTS = 0;
    uint8 constant DIAMONDS = 1;
    uint8 constant CLUBS = 2;
    uint8 constant SPADES = 3;

    mapping(address => Card[2]) public hole_cards;

    function encryptCards() internal {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
    }

    function _shuffleCards() internal {
        for (uint256 i = 0; i < deck.length; i++) {
            uint256 n = (uint256(keccak256(abi.encodePacked(block.timestamp))) %
                (deck.length - i)) + i;
            Card memory temp = deck[n];
            deck[n] = deck[i];
            deck[i] = temp;
        }
    }

    function _setStartingChips() internal {
        for (uint256 i = 0; i < num_players; i++) {
            address player_addr = current_players[i].addr;
            current_players[i].chips = deposits[player_addr];
        }
    }

    function _distributeCards() internal {
        for (uint256 i = 0; i < num_players; i++) {
            address player_addr = current_players[i].addr;
        }
    }

    function startGame() external {
        require(num_players > 1);
        _shuffleCards();
        _setStartingChips();
    }

    function deposit() external payable {
        require(msg.value > 0);
        if (deposits[msg.sender] == 0) {
            num_players += 1;
            current_players.push(Player(msg.sender, 0));
        }
        deposits[msg.sender] += msg.value;
    }
}
