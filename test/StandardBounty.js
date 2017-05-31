/* global web3 describe before artifacts assert it contract:true*/
const StandardBounty = artifacts.require('./StandardBounty.sol');

const fs = require('fs');

let bounty;
let bountyObj;

async function generateBounty(bountyObjParam) {
  return await StandardBounty.new(
    bountyObjParam.deadline,
    bountyObjParam.issuerContact,
    bountyObjParam.data,
    bountyObjParam.fullfilmentAmount
  );
}

contract('StandardBounty', (accounts) => {
  let config = JSON.parse(fs.readFileSync('./test/conf/configObjects.json'));
  let [issuer, normalBountyHunter, maliciousBountyHunter] = accounts;

  describe('Good Bounty Instantiation', () => {
    before(async () => {
      bountyObj = config.exampleStandardBounties.good;
      console.log(bountyObj);
      bounty = await generateBounty(bountyObj);
    });

    it(`should instantiate with ${issuer} as issuer.`, async () => {
      const issuer = await bounty.issuer.call();
      assert.equal(name, issuer);
    });

    // it(`should instantiate with ${bountyObj.deadline} as deadline.`, async () => {
    //   const dealine = await bounty.dealine.call();
    //   assert.equal(name, bountyObj.deadline);
    // });

    // it(`should instantiate with ${bountyObj.issuerContact} as issuerContact.`, async () => {
    //   const issuerContact = await bounty.issuerContact.call();
    //   assert.equal(name, bountyObj.issuerContact);
    // });

    // it(`should instantiate with ${bountyObj.data} as data.`, async () => {
    //   const issuer = await bounty.issuer.call();
    //   assert.equal(name, bountyObj.data);
    // });

    // it(`should instantiate with ${bountyObj.fullfilmentAmount} as fullfilmentAmount.`, async () => {
    //   const issuer = await bounty.issuer.call();
    //   assert.equal(name, bountyObj.fullfilmentAmount);
    // });
  });
});
