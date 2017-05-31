/* global web3 describe before artifacts assert it contract:true*/
const StandardBounty = artifacts.require('./StandardBounty.sol');

const fs = require('fs');
const utils = require('./helpers/utils');

let bounty;
let bountyObj;

async function generateBounty(bountyObjParam) {
  return StandardBounty.new(
    bountyObjParam.deadline,
    bountyObjParam.issuerContact,
    bountyObjParam.data,
    bountyObjParam.fulfillmentAmount
  );
}

contract('StandardBounty', (accounts) => {
  let config = JSON.parse(fs.readFileSync('./test/conf/configObjects.json'));
  let [issuer, normalBountyHunter, maliciousBountyHunter] = accounts;

  describe('\nGood Bounty Instantiation', () => {
    before(async () => {
      bountyObj = config.exampleStandardBounties.good;
      
      console.log(`\nInstantiating good bounty with the following parameters: `);
      console.log(bountyObj);
      console.log(`\t`);

      bounty = await generateBounty(bountyObj);
    });

    it(`should instantiate with ${issuer} as issuer.`, async () => {
      let issuerCur = await bounty.issuer.call();
      assert.equal(issuerCur, issuer);
    });

    it(`should instantiate with correct deadline.`, async () => {
      let deadline = await bounty.deadline.call();
      assert.equal(deadline, bountyObj.deadline);
    });

    it(`should instantiate with correct issuerContact.`, async () => {
      let issuerContact = await bounty.issuerContact.call();
      assert.equal(issuerContact, bountyObj.issuerContact);
    });

    it(`should instantiate with correct data.`, async () => {
      let data = await bounty.data.call();
      assert.equal(data, bountyObj.data);
    });

    it(`should instantiate with correct fulfillmentAmount.`, async () => {
      let fulfillmentAmount = await bounty.fulfillmentAmount.call();
      assert.equal(fulfillmentAmount, bountyObj.fulfillmentAmount);
    });
  });

  describe('\nBad 0-Data-Bounty Instantiation', () => {
    before(async () => {
      bountyObj = config.exampleStandardBounties.bad.zeroData;
      
      console.log(`\nInstantiating bad bounty with the following parameters: `);
      console.log(bountyObj);
      console.log(`\t`);

      bounty = await generateBounty(bountyObj);
    });

    it(`should instantiate with ${issuer} as issuer.`, async () => {
      let issuerCur = await bounty.issuer.call();
      assert.equal(issuerCur, issuer);
    });

    it(`should instantiate with correct deadline.`, async () => {
      let deadline = await bounty.deadline.call();
      assert.equal(deadline, bountyObj.deadline);
    });

    it(`should instantiate with correct issuerContact.`, async () => {
      let issuerContact = await bounty.issuerContact.call();
      assert.equal(issuerContact, bountyObj.issuerContact);
    });

    it(`should instantiate with correct data.`, async () => {
      let data = await bounty.data.call();
      assert.equal(data, bountyObj.data);
    });

    it(`should instantiate with correct fulfillmentAmount.`, async () => {
      let fulfillmentAmount = await bounty.fulfillmentAmount.call();
      assert.equal(fulfillmentAmount, bountyObj.fulfillmentAmount);
    });
  });

  describe('\nBad 0-Deadline-Bounty Instantiation', () => {
    before(async () => {
      bountyObj = config.exampleStandardBounties.bad.zeroDeadline;
      
      console.log(`\nInstantiating bad bounty with the following parameters: `);
      console.log(bountyObj);
      console.log(`\t`);

      bounty = await generateBounty(bountyObj);
    });

    it(`should instantiate with ${issuer} as issuer.`, async () => {
      let issuerCur = await bounty.issuer.call();
      assert.equal(issuerCur, issuer);
    });

    it(`should instantiate with correct deadline.`, async () => {
      let deadline = await bounty.deadline.call();
      assert.equal(deadline, bountyObj.deadline);
    });

    it(`should instantiate with correct issuerContact.`, async () => {
      let issuerContact = await bounty.issuerContact.call();
      assert.equal(issuerContact, bountyObj.issuerContact);
    });

    it(`should instantiate with correct data.`, async () => {
      let data = await bounty.data.call();
      assert.equal(data, bountyObj.data);
    });

    it(`should instantiate with correct fulfillmentAmount.`, async () => {
      let fulfillmentAmount = await bounty.fulfillmentAmount.call();
      assert.equal(fulfillmentAmount, bountyObj.fulfillmentAmount);
    });
  });

  describe('\nBad 0-Fulfillment-Amount-Bounty Instantiation', () => {
    it(`should throw when instantiating with correct data.`, async () => {
      bountyObj = config.exampleStandardBounties.bad.zeroFulfillmentAmount;

      console.log(`\nInstantiating bad bounty with the following parameters: `);
      console.log(bountyObj);
      console.log(`\t`);

      try {
        bounty = await generateBounty(bountyObj);
      }
      catch (error) {
        return utils.ensureException(error);
      }
    });
  });
});
