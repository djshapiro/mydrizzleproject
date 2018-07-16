pragma solidity ^0.4.24;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract Bank is usingOraclize{

  enum Goals { ChangeWeight }

  struct Wager {
    uint expiration; //timestamp after which the wager needs to be evaluated
    uint target; //target of person attempting to meet goal
    Goals goal; //fitness goal of person
    uint wagerAmount; //amount this person wagered
  }

  mapping(address => Wager[]) private wagers;

  event WagerCreated(uint, uint, Goals, uint);
  event inCallback(bytes32, string);

  function createWager(uint _expirationInDays, uint _target, Goals _goal) public payable {
    // In _days, _who will _goal to _target
    //e.g. in 5 days, Jeff will lose weight to 180 lbs

    oraclize_query("URL", "json(http://api.fixer.io/latest?symbols=USD,GBP).rates.GBP");
    //wagers[msg.sender].push(Wager(_expirationInDays, _target, _goal, msg.value));
    //emit WagerCreated(_expirationInDays, _target, _goal, msg.value);
  }
  
  function __callback(bytes32 myid, string result) {
    if (msg.sender != oraclize_cbAddress()) revert();
    emit inCallback(myid, result);
  }

  function getWagers() returns (uint[], uint[], Goals[], uint[]) {
    uint[] memory expirations = new uint[](wagers[msg.sender].length);
    uint[] memory targets = new uint[](wagers[msg.sender].length);
    Goals[] memory goals = new Goals[](wagers[msg.sender].length);
    uint[] memory values = new uint[](wagers[msg.sender].length);

    for (uint ii = 0; ii < wagers[msg.sender].length; ii++) {
        Wager memory wager = wagers[msg.sender][ii];
        expirations[ii] = wager.expiration;
        targets[ii] = wager.target;
        goals[ii] = wager.goal;
        values[ii] = wager.wagerAmount;
    }

    return (expirations, targets, goals, values);
  }

}

