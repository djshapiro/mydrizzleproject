const WeightWagers = artifacts.require('./WeightWagers.sol');

function logWatchPromise(_event) {
  return new Promise((resolve, reject) => {
    _event.watch((error, log) => {
      _event.stopWatching();
      if (error !== null)
        reject(error);

      resolve(log);
    });
  });
}

//helper function for waiting for the creation and activation of wagers
//DJSFIXME Try this at some point
function createAndActivateWager(contract, args, txDetails) {

  //Wait for create
  const createResponse = await contract.createWager(args.exp, args.target, args.goal, args.scaleID, txDetails);

  //Wait for activate
  const logScaleWatcher = logWatchPromise(contract.WagerActivated({ fromBlock: 'latest'} ));
  const activateResponse = await logScaleWatcher;

  //Great!
  return { createResponse, activateResponse };
}

function verifyWagerAndWaitForEvent(contract, args, txDetails, eventToWaitFor) {
  //Verify
  const verifyResponse = await contract.verifyWager(args.wagerIndex, txDetails);

  //Promisify
  const logScaleWatcher = logWatchPromise(contract[eventToWaitFor]({ fromBlock: 'latest'} ));
  const eventResponse = await logScaleWatcher;

  //Bye!
  return { verifyResponse, eventResponse };
}

contract('WeightWagers', accounts => {
  const owner = accounts[0];
  const alice = accounts[1];
  const bob = accounts[2];

  it('calling createWager should emit a WagerCreated event follow by a WagerActivated event', async () => {
    const weightWagers = await WeightWagers.deployed();

    //Alice creates a wager.
    const response = await weightWagers.createWager(30, 210, 0, 'scaleBelongingToAlice', {from: alice});
    let log = response.logs[0];
    assert.equal(log.event, 'WagerCreated', 'WagerCreated not emitted.');

    //Set up listener to make sure the wager gets
    //activated once the oracle returns data.
    const logScaleWatcher = logWatchPromise(weightWagers.WagerActivated({ fromBlock: 'latest'} ));
    log = await logScaleWatcher;
    assert.equal(log.event, 'WagerActivated', 'WagerActivated not emitted.');

    //Finally, call getWagers() for Alice to ensure
    //that she has a wager.
    const aliceWagers = await weightWagers.getWagers({from: alice});
    assert.equal(aliceWagers[0][0], 30, 'alice does not have the correct expiration date on her wager');
    assert.equal(aliceWagers[1][0], 210, 'alice does not have the correct target weight');
    assert.equal(aliceWagers[2][0], 0, 'alice does not have the correct goal');
    assert.equal(aliceWagers[3][0], 0, 'alice does not have the correct amount');

    //Just for a reality check, make sure bob has no wagers.
    const bobWagers = await weightWagers.getWagers();
    assert.deepEqual(bobWagers[0], [], "bob's expiration dates are not an empty array");
    assert.deepEqual(bobWagers[1], [], "bob's target weights are not an empty array");
    assert.deepEqual(bobWagers[2], [], "bob's goals are not an empty array");
    assert.deepEqual(bobWagers[3], [], "bob's wager amounts are not an empty array");

  });
  
  //DJSFIXME delete this test after it passes a few times
  it('verify that tests do not carry side effects from other tests', async () => {
    const weightWagers = await WeightWagers.deployed();

    //Finally, call getWagers() for Alice to ensure
    //that she has a wager.
    const aliceWagers = await weightWagers.getWagers({from: alice});
    assert.deepEqual(aliceWagers[0], [], "alice's expiration dates are not an empty array");
    assert.deepEqual(aliceWagers[1], [], "alice's target weights are not an empty array");
    assert.deepEqual(aliceWagers[2], [], "alice's goals are not an empty array");
    assert.deepEqual(aliceWagers[3], [], "alice's wager amounts are not an empty array");

    //Just for a reality check, make sure bob has no wagers.
    const bobWagers = await weightWagers.getWagers();
    assert.deepEqual(bobWagers[0], [], "bob's expiration dates are not an empty array");
    assert.deepEqual(bobWagers[1], [], "bob's target weights are not an empty array");
    assert.deepEqual(bobWagers[2], [], "bob's goals are not an empty array");
    assert.deepEqual(bobWagers[3], [], "bob's wager amounts are not an empty array");
  });

  it('create a wager and attempt to verify it without having lost the weight', async () => {
    const weightWagers = await WeightWagers.deployed();

    //Alice creates a wager that expires very far in the future
    const response = await weightWagers.createWager(10000, 210, 0, 'scaleBelongingToAlice', {from: alice});
    let log = response.logs[0];
    assert.equal(log.event, 'WagerCreated', 'WagerCreated not emitted.');

    //Set up listener so we can pause execution
    //until wager is activated
    const logScaleWatcher = logWatchPromise(weightWagers.WagerActivated({ fromBlock: 'latest'} ));
    log = await logScaleWatcher;

    const verifyResponse = await weightWagers.verifyWager(0, {from: alice});
  });

  it('create a wager and attempt to verify it after having lost the weight', async () => {
    const weightWagers = await WeightWagers.deployed();
  });

  it('create a wager and attempt to verify it after it has expired', async () => {
    const weightWagers = await WeightWagers.deployed();
  });

  it('attempt to verify a wager that does not exist', async () => {
    const weightWagers = await WeightWagers.deployed();
  });

});



