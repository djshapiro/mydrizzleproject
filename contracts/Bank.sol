pragma solidity ^0.4.24;

import "installed_contracts/oraclize-api/contracts/usingOraclize.sol";

contract Bank is usingOraclize{

  enum Goals { ChangeWeight }

  struct Wager {
    uint expiration; //timestamp after which the wager needs to be evaluated
    uint target; //target of person attempting to meet goal
    Goals goal; //fitness goal of person
    uint wagerAmount; //amount this person wagered
    string smartScaleID; //The user's "credentials" for their smart scale
  }

  mapping(address => Wager[]) private wagers;

  event WagerCreated(uint, uint, Goals, uint, string);
  event inCallback(bytes32, string);

  function Bank() {
    OAR = OraclizeAddrResolverI(0x6341f14C967270b641E6852235AB2B1dEF3f8E54);
  }

  function createWager(uint _expirationInDays, uint _target, Goals _goal, string _smartScaleID) public payable {
    // In _days, _who will _goal to _target
    //e.g. in 5 days, Jeff will lose weight to 180 lbs

    oraclize_query("URL", "json(https://api.coinbase.com/v2/prices/ETH-USD/spot).data.amount");
    //wagers[msg.sender].push(Wager(_expirationInDays, _target, _goal, msg.value, _smartScaleID));
    //emit WagerCreated(_expirationInDays, _target, _goal, msg.value, _smartScaleID);
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

