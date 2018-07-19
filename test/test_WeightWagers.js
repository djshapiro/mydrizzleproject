const WeightWagers = artifacts.require('./WeightWagers.sol');

contract('WeightWagers', accounts => {
  it('should eventually emit a wagerCreated event', async () => {
    const weightWagers = await WeightWagers.new();
    const response = await weightWagers.createWager(30, 210, 0, 'scaleBelongingToJeff');
    let log = response.logs[0];
    assert.equal(log.event, 'WagerCreated', 'WagerCreated not emitted.');
    const logScaleWatcher = logWatchPromise(weightWagers.WagerActivated({ fromBlock: 'latest' }));
    log = await logScaleWatcher;
    assert.equal(log.event, 'WagerActivated', 'WagerActivated not emitted.');
  });
});

function logWatchPromise(_event) {
  return new Promise((resolve, reject) => {
    _event.watch((error, log) => {
      _event.stopWatching();
      if (error !== null) {
        reject(error);
      }
      resolve(log);
    });
  });
}

