let CodeBugBountyFactory = artifacts.require("./CodeBugBountyFactory.sol")
let BountyFactory = artifacts.require("./BountyFactory.sol")
let StandardBounty = artifacts.require("./StandardBounty.sol")

module.exports = function(deployer) {
	deployer.deploy(CodeBugBountyFactory);
	deployer.deploy(BountyFactory);
	deployer.deploy(StandardBounty, 10000, 'test', 'somedata', 200);
};
