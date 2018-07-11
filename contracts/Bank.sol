pragma solidity ^0.4.24;

contract Bank {

  enum Goals { LoseWeight }

  struct Wager {
    uint expiration; //timestamp after which the wager needs to be evaluated
    uint target; //target of person attempting to meet goal
    Goals goal; //fitness goal of person
    uint wagerAmount; //amount this person wagered
    address who; //address of person attempting to meet goal
  }

  Wager[] wagers;
  
  event WagerCreated(uint, uint, Goals, uint, address);

  function createWager(uint _expiration, uint _target, Goals _goal) public payable {
    // In _days, _who will _goal to _target
    //e.g. in 5 days, Jeff will lose weight to 180 lbs
    emit WagerCreated(_expiration, _target, _goal, msg.value, msg.sender);
    wagers.push(Wager(_expiration, _target, _goal, msg.value, msg.sender));
  }

  function getWager(uint _index) returns (address) {
    return wagers[_index].who;
  }

}

