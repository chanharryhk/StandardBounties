pragma solidity ^0.4.11;
import "./StandardBounty.sol";
import "./StandardToken.sol";


/// @title TokenBounty
/// @dev extension of StandardBounty to pay out bounties with a given ERC20 token
/// @author Mark Beylin <mark.beylin@consensys.net>
contract TokenBounty is StandardBounty {

	/*
     * Storage
     */

    StandardToken public tokenContract;

    /*
     * Modifiers
     */


    modifier amountEqualsValue(uint value) {
        require(value  == tokenContract.allowance(msg.sender, this));
        require(tokenContract.transferFrom(msg.sender, this, value));

        _;
    }

    modifier validateFunding() {

        uint total = 0;
        for (uint i = 0 ; i < numMilestones; i++){
            total += fulfillmentAmounts[i];
        }

        require (tokenContract.balanceOf(this) >= total);

        _;
    }


	/*
     * Public functions
     */

    /// @dev TokenBounty(): instantiates a new draft token bounty
    /// @param _deadline the unix timestamp after which fulfillments will no longer be accepted
    /// @param _contactInfo the contact information of the issuer
    /// @param _data the requirements of the bounty
    /// @param _fulfillmentAmount the amount of wei to be paid out for each successful fulfillment
    /// @param _numMilestones the total number of milestones which can be paid out
    /// @param _tokenAddress the address of the token contract
    function TokenBounty(
        uint _deadline,
        string _contactInfo,
        string _data,
        uint[] _fulfillmentAmounts,
        address _arbiter,
        address _tokenAddress
    )
    	StandardBounty(
    		_deadline,
    		_contactInfo,
      	_data,
      	_fulfillmentAmounts,
        _numMilestones,
        _arbiter
    	)
    {
        tokenContract = StandardToken(_tokenAddress);
    }


    /// @dev acceptFulfillment(): accept a given fulfillment, and send
    /// the fulfiller their owed funds
    /// @param _fulfillmentId the index of the fulfillment being accepted
    /// @param _milestoneId the id of the milestone being paid
    function fulfillmentPayment(uint _fulfillmentId, uint _milestoneId)
        public
        validateFulfillmentArrayIndex(_fulfillmentId, _milestoneId)
        validateMilestoneIndex(_milestoneId)
        onlyFulfiller(_fulfillmentId, _milestoneId)
        checkFulfillmentIsApprovedAndUnpaid(_fulfillmentId, _milestoneId)
    {
        tokenContract.transfer(fulfillments[_milestoneId][_fulfillmentId].fulfiller, fulfillmentAmounts[_milestoneId]);
        fulfillments[_milestoneId][_fulfillmentId].paid = true;

        numPaid[_milestoneId]++;

        FulfillmentPaid(msg.sender, fulNum);
    }

    /// @dev killBounty(): drains the contract of it's remaining
    /// funds, and moves the bounty into stage 3 (dead) since it was
    /// either killed in draft stage, or never accepted any fulfillments
    function killBounty()
        public
        onlyIssuer
    {
        tokenContract.transfer(tokenContract.balanceOf(this) - unpaidAmount());

        transitionToState(BountyStages.Dead);

        BountyKilled();
    }

}
