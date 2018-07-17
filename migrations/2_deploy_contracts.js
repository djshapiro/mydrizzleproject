var SimpleStorage = artifacts.require("SimpleStorage");
var TutorialToken = artifacts.require("TutorialToken");
var ComplexStorage = artifacts.require("ComplexStorage");
var Bank = artifacts.require("Bank");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(TutorialToken);
  deployer.deploy(ComplexStorage);
  //deployer.deploy(Bank, { from: accounts[9], gas:6721975, value: 500000000000000000 });
  deployer.deploy(Bank);
};
