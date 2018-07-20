pragma solidity ^0.4.24;

import "installed_contracts/oraclize-api/contracts/usingOraclize.sol";

contract WeightWagers is usingOraclize{

  enum Goals { ChangeWeight }

  struct Wager {
    uint expiration; //timestamp after which the wager needs to be evaluated
    uint targetValue; //target of person attempting to meet goal
    Goals goal; //fitness goal of person
    uint wagerAmount; //amount this person wagered
    string smartScaleID; //The user's "credentials" for their smart scale
    address wagerer; //the address of the person making the wager
    uint startValue; //the starting value of the fitness goal of the person
  }

  // The official mapping of all active wagers
  mapping(address => Wager[]) private wagers;

  // The mapping used to keep track of wagers as we
  // wait for the oraclized scale data to return
  mapping(bytes32 => Wager) private activeCalls;

  // event for when a user attempts to create a wager
  event WagerCreated(uint expiration, uint targetValue, Goals goal, uint wagerAmount, string smartScaleID);
  // event for when the oraclized smart scale returns
  // data for a wager that a user is trying to create
  event WagerActivated(bytes32 myid);

  function WeightWagers() {
    OAR = OraclizeAddrResolverI(0xaC7630deAbE0Ddd6414b320Ba446B0EfD790a370);
  }

  function createWager(uint _expirationInDays, uint _target, Goals _goal, string _smartScaleID) public payable {
    //This payable function should automatically receive the ether
    //which is fine! because now if there are problems we can just revert.
    //But we need to remember to send the ether back in case the callback fails for some reason.

    // In _days, _who will _goal to _target
    //e.g. in 5 days, Jeff will lose weight to 180 lbs

    bytes32 myID = oraclize_query("URL", "json(https://api.coinbase.com/v2/prices/ETH-USD/spot).data.amount");
    activeCalls[myID] = Wager(_expirationInDays, _target, _goal, msg.value, _smartScaleID, msg.sender, 0);
    emit WagerCreated(_expirationInDays, _target, _goal, msg.value, _smartScaleID);
    //wagers[msg.sender].push(Wager(_expirationInDays, _target, _goal, msg.value, _smartScaleID));
  }
  
  function __callback(bytes32 myid, string result) {
    if (msg.sender != oraclize_cbAddress()) revert();
    Wager memory newWager = activeCalls[myid];
    //DJSFIXME Delete wager from activeCalls
    newWager.startValue = parseInt(result);
    wagers[newWager.wagerer].push(newWager);
    emit WagerActivated(myid);
  }

  function getWagers() returns (uint[], uint[], Goals[], uint[]) {
    uint[] memory expirations = new uint[](wagers[msg.sender].length);
    uint[] memory targets = new uint[](wagers[msg.sender].length);
    Goals[] memory goals = new Goals[](wagers[msg.sender].length);
    uint[] memory values = new uint[](wagers[msg.sender].length);

    for (uint ii = 0; ii < wagers[msg.sender].length; ii++) {
        Wager memory wager = wagers[msg.sender][ii];
        expirations[ii] = wager.expiration;
        targets[ii] = wager.targetValue;
        goals[ii] = wager.goal;
        values[ii] = wager.wagerAmount;
    }

    return (expirations, targets, goals, values);
  }

}

