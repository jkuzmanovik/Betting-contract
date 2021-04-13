// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


contract Betting {
    

    constructor(uint[] memory _outcomes) public{
        for(uint i=0;i<_outcomes.length;i++){
            outcomes[i] = _outcomes[i];
        }
        owner = msg.sender;
    }


    address  public owner;
    address payable public gamblerA;
    address payable public gamblerB;
    address payable public oracle;



    struct Bet{
        uint outcome;
        uint amount;
        bool initialized; 
    }

    mapping(address => Bet) bets;

    mapping(address => uint) winnings;

    mapping(uint => uint) public outcomes;

    event BetMade(address gambler);
    event BetClosed();



    modifier onlyOwner{
        require(msg.sender == owner,
        "Only owner can call this function"
        );
        _;
    }
    modifier onlyOracle{
        require(msg.sender == oracle,
        "Only oracle can call this function"
        );
        _;
    }


    function chooseOracle(address payable _oracle) public onlyOwner() returns (address){
        oracle = _oracle;
        return oracle;
    }

    function makeBet(uint _outcome) public payable returns (bool){
        if(msg.value <= 0)
            return false;
        Bet memory bet;
        bet = Bet(_outcome,msg.value,true);
        bets[msg.sender] = bet;
        return true;
    }


    function makeDecision(uint _outcome) public onlyOracle(){
        uint pot = bets[gamblerA].amount + bets[gamblerB].amount;

        if (bets[gamblerA].outcome == _outcome && bets[gamblerB].outcome == _outcome) {
            gamblerA.transfer(bets[gamblerA].amount);
            gamblerB.transfer(bets[gamblerB].amount);
        } else if (bets[gamblerA].outcome == _outcome) {
            winnings[gamblerA] += pot;
        } else if (bets[gamblerB].outcome == _outcome) {
            winnings[gamblerB] += pot;
        } else {
            winnings[oracle] += pot;
        }

    }

    function withdraw(uint withdrawAmount)public payable returns (uint) {
        address payable sender = payable(msg.sender);
        if(winnings[msg.sender] > withdrawAmount){
            winnings[msg.sender]-=withdrawAmount;
            sender.transfer(withdrawAmount);
            return withdrawAmount;
        }
    }

    function checkOutcomes(uint outcome) public view returns(uint){
       return outcomes[outcome]; 
    }

    function checkWinnings() public view returns(uint){
        return winnings[msg.sender];
    }
      function contractReset() public {
        delete gamblerA;
        delete gamblerB;
        delete oracle;
    }


}