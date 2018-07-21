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

contract('WeightWagers', accounts => {
  const owner = accounts[0];
  const alice = accounts[1];
  const bob = accounts[2];

  it('calling createWager should emit a WagerCreated event follow by a WagerActivated event', async () => {
    const weightWagers = await WeightWagers.deployed();

    let wagerActivated = false;

    //Alice creates a wager
    const response = await weightWagers.createWager(30, 210, 0, 'scaleBelongingToAlice', {from: alice});
    let log = response.logs[0];
    assert.equal(log.event, 'WagerCreated', 'WagerCreated not emitted.');

    //Set up listener to make sure the wager gets
    //activated once the oracle returns data
    const logScaleWatcher = logWatchPromise(weightWagers.WagerActivated({ fromBlock: 'latest'} ));
    log = await logScaleWatcher;
    assert.equal(log.event, 'WagerActivated', 'WagerActivated not emitted.');

    //Finally, call getWagers() for Alice to ensure
    //that she has a wager
    const aliceWagers = await weightWagers.getWagers({from: alice});
    assert.equal(aliceWagers[0][0], 30, 'alice does not have the correct expiration date on her wager');
    assert.equal(aliceWagers[1][0], 210, 'alice does not have the correct target weight');
    assert.equal(aliceWagers[2][0], 0, 'alice does not have the correct goal');
    assert.equal(aliceWagers[3][0], 0, 'alice does not have the correct amount');

    //Just for a realite check, make sure bob has no wagers.
    const bobWagers = await weightWagers.getWagers();
    assert.deepEqual(bobWagers[0], [], "bob's expiration dates are not an empty array");
    assert.deepEqual(bobWagers[1], [], "bob's target weights are not an empty array");
    assert.deepEqual(bobWagers[2], [], "bob's goals are not an empty array");
    assert.deepEqual(bobWagers[3], [], "bob's wager amounts are not an empty array");

  });
});



