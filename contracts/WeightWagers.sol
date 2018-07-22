pragma solidity ^0.4.24;

import "installed_contracts/oraclize-api/contracts/usingOraclize.sol";

contract WeightWagers is usingOraclize{

  enum Goals { LoseWeight }

  uint rewardMultiplier;

  struct Wager {
    uint expiration; //timestamp after which the wager needs to be evaluated
    uint targetValue; //target of person attempting to meet goal
    Goals goal; //fitness goal of person
    uint wagerAmount; //amount this person wagered
    string smartScaleID; //The user's "credentials" for their smart scale
    address wagerer; //the address of the person making the wager
    uint startValue; //the starting value of the fitness goal of the person
  }

  struct VerifyingWager {
    address wagerer; //the address of the person making the wager
    uint wagerIndex; //the index of the wager in the wagers array - we have to
                     //track this so the __callback function knows which wager
                     //to delete once the wager has been verified
  }

  // The official mapping of all activated wagers
  mapping(address => Wager[]) private wagers;

  // The mapping used to keep track of wagers as we
  // wait for the oraclized scale data to return so
  // that we can officially activate the wager
  mapping(bytes32 => Wager) private wagersBeingActivated;

  // The mapping used to keep track of wagers as we
  // wait for the oraclized scale data to return so
  // that we can officially verify the wager 
  mapping(bytes32 => VerifyingWager) private wagersBeingVerified;

  // event for when a user attempts to create a wager
  event WagerCreated(uint expiration, uint targetValue, Goals goal, uint wagerAmount, string smartScaleID);
  // event for when the oraclized smart scale returns
  // data for a wager that a user is trying to create
  event WagerActivated(address wagerer, uint wagerAmount);
  // event for when a user attempts to verify a wager
  event WagerBeingVerified(address verifierAddress, uint wagerIndex);
  // event for when a wager is verified
  event WagerVerified(address wagerer, uint wagerAmount);
  // event for when a wager is expired - called after a user
  // attempts to verify a wager and the contract discovers
  // that the wager has expired
  event WagerExpired(address wagerer, uint wagerAmount);
  // event for when the __callback recieves an invalid wager id
  event InvalidWager(bytes32 myid);
  // event for when the verify callback recieves a valid
  // wager but one where the user hasn't actually achieved
  // their goal yet
  event WagerUnchanged(bytes32 myid);
  // event for when the verify callback attempts to verify
  // a wager whose goal is an integer outside the enum's range
  event InvalidGoal(bytes32 myid);

  function WeightWagers() {
    rewardMultiplier = 100;
    OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
  }

  //The user calls this function when they want to create a wager
  function createWager(uint _expirationInDays, uint _target, Goals _goal, string _smartScaleID) public payable {
    //This payable function should automatically receive the ether
    //which is fine! because now if there are problems we can just revert.
    //But we need to remember to send the ether back in case the callback fails for some reason.

    // In _days, _who will _goal to _target
    //e.g. in 5 days, Jeff will lose weight to 180 lbs

    bytes32 myID = oraclize_query("URL", "json(https://api.coinbase.com/v2/prices/ETH-USD/spot).data.amount");
    wagersBeingActivated[myID] = Wager(_expirationInDays, _target, _goal, msg.value, _smartScaleID, msg.sender, 0);
    emit WagerCreated(_expirationInDays, _target, _goal, msg.value, _smartScaleID);
  }
  
  function __callback(bytes32 myid, string result) public {

    if (msg.sender != oraclize_cbAddress()) revert();
    //DJSFIXME If statement to see where myid is.
    //DJSFIXME If myid is in wagersBeingActivated
    Wager memory newWager = wagersBeingActivated[myid];
    //DJSFIXME Delete wager from wagersBeingActivated
    newWager.startValue = parseInt(result);
    wagers[newWager.wagerer].push(newWager);
    emit WagerActivated(newWager.wagerer, newWager.wagerAmount);
    //DJSFIXME Maybe include a modifier to delete the wager from wagersBeingActivated
    //         on function exit no matter what, so that wagersBeingActivated doesn't
    //         slowly bloat into tons of data that no one needs

    //DJSFIXME If myid is in wagersBeingVerified
    //VerifyingWager memory myVerifyingWager = wagersBeingVerified[myid];
    //Wager memory wagerToVerify = wagers[myVerifyingWager.wagerer][myVerifyingWager.wagerIndex];
    //If wagerToVerify.goal == Goals.LoseWeight
    //If parseInt(result) < wagerToVerify.startValue;
    //DJSFIXME then Send wagerToVerify.value * rewardMultipier / 100 to wagerToVerify.wagerer.
    //DJSFIXME emit WagerVerified(wagerToVerify.wagerer, wagerToVerify.wagerAmount);
    //DJSFIXME else (they didn't lose the weight)
    //DJSFIXME then do nothing (give them a chance to keep losing weight until the wager expires)
    //DJSFIXME emit WagerUnchanged(myid);
    //DJSFIXME else (the goal of this wager doesn't match any existing Goals)
    //DJSFIXME remove the wager from wagers
    //DJSFIXME emit InvalidGoal(myid);
    
    //DJSFIXME Maybe include a modifier to delete the wager from wagersBeingVerified
    //         on function exit no matter what, so that wagersBeingVerified doesn't
    //         slowly bloat into tons of data that no one needs

    //DJSFIXME else (if myid is nowhere)
    //DJSFIXME then emit InvalidWager(myid);
    //DJSFIXME then do nothing?
  }

  function verifyWager(uint _wagerIndex) public {
    Wager memory wagerToVerify = wagers[msg.sender][_wagerIndex];
    //DJSFIXME concat the smartScaleID from the wager onto the URL
    //DJSFIXME if statement to verify that this wager hasn't expired.
      //DJSFIXME If the wager has expired, delete it from the wagers
      //DJSFIXME emit WagerExpired(msg.sender, wagerToVerify.wagerAmount);
      //DJSFIXME If the wager has not expired, do the following.
    bytes32 myID = oraclize_query("URL", "json(https://api.coinbase.com/v2/prices/ETH-USD/spot).data.amount");
    wagersBeingVerified[myID] = VerifyingWager(msg.sender, _wagerIndex);
    emit WagerBeingVerified(msg.sender, _wagerIndex);
  }

  function getWagers() public view returns (uint[] expirations, uint[] targets, Goals[] goals, uint[] values) {
    expirations = new uint[](wagers[msg.sender].length);
    targets = new uint[](wagers[msg.sender].length);
    goals = new Goals[](wagers[msg.sender].length);
    values = new uint[](wagers[msg.sender].length);

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

