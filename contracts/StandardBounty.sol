pragma solidity ^0.4.11;


/// @title StandardBounty
/// @dev can be used to facilitate transactions on qualitative data
/// @author Mark Beylin <mark.beylin@consensys.net>, Gonçalo Sá <goncalo.sa@consensys.net>
contract StandardBounty {

    uint constant public MAX_FULFILLMENTS = 254;

    /*
     * Events
     */

    event BountyActivated(address issuer);
    event BountyFulfilled(address indexed fulfiller, uint256 indexed fulNum);
    event FulfillmentAccepted(address indexed fulfiller, uint256 indexed fulNum);
    event FulfillmentPaid(address indexed fulfiller, uint256 indexed fulNum);
    event BountyKilled();
    event ContributionAdded(address indexed contributor, uint256 value);
    event DeadlineExtended(uint newDeadline);

    /*
     * Storage
     */

    address public issuer; //the creator of the bounty
    string public issuerContact; //string of a contact method used to reach the issuer in case it is needed

    BountyStages public bountyStage;

    uint public deadline; //unix timestamp for deadline
    string public data; //data representing the requirements for the bounty, and any associated files - this is commonly an IPFS hash but in reality could be anything the bounty creator desires

    uint public fulfillmentAmount; // the amount of wei to be rewarded to the user who fulfills the bounty

    Fulfillment[] public fulfillments; // the list of submitted fulfillments
    uint public numFulfillments; // the number of submitted fulfillments

    uint[] public accepted; // the list of accepted fulfillments
    uint public numAccepted; // the number of accepted fulfillments
    uint public numPaid; // the number of paid fulfillments

    /*
     * Enums
     */

    enum BountyStages {
        Draft,
        Active,
        Dead // bounties past deadline with no accepted fulfillments
    }

    /*
     * Structs
     */

    struct Fulfillment {
        bool paid;
        bool accepted;
        address fulfiller;
        string data;
        string dataType;
    }

    /*
     * Modifiers
     */

    modifier onlyIssuer() {
        require(msg.sender == issuer);
        _;
    }
    modifier notIssuer() {
        require(msg.sender != issuer);
        _;
    }

    modifier onlyFulfiller(uint fulNum) {
        require(msg.sender == fulfillments[fulNum].fulfiller);
        _;
    }

    modifier amountIsNotZero(uint amount) {
        require(amount != 0);
        _;
    }

    modifier amountEqualsValue(uint amount) {
        require((amount * 1 ether) != msg.value);
        _;
    }

    modifier isBeforeDeadline() {
        require(now < deadline);
        _;
    }

    modifier newDeadlineIsValid(uint newDeadline) {
        require(newDeadline > deadline);
        _;
    }

    modifier isAtStage(BountyStages desiredStage) {
        require(bountyStage == desiredStage);
        _;
    }

    modifier checkFulfillmentsNumber() {
        require(numFulfillments < MAX_FULFILLMENTS);
        _;
    }

    modifier validateFulfillmentArrayIndex(uint index) {
        require(index < numFulfillments);
        _;
    }

    modifier checkFulfillmentIsApprovedAndUnpaid(uint fulNum) {
        require(fulfillments[fulNum].accepted && !fulfillments[fulNum].paid);
        _;
    }


    modifier validateFunding() {

        // Funding is validated right before a bounty is moved into the active
        // stage, thus all funds which are surplus to paying out those bounties
        // are refunded. After this, new funds may also be added on an ad-hoc
        // basis
        if ( (msg.value + this.balance) % fulfillmentAmount > 0) {
            msg.sender.transfer((msg.value + this.balance) % fulfillmentAmount);
        }

        _;
    }


    /*
     * Public functions
     */

    /// @dev StandardBounty(): instantiates a new draft bounty
    /// @param _deadline the unix timestamp after which fulfillments will no longer be accepted
    /// @param _contactInfo a string with contact info of the issuer, for them to be contacted if needed
    /// @param _data the requirements of the bounty
    /// @param _fulfillmentAmount the amount of wei to be paid out for each successful fulfillment
    function StandardBounty(
        uint _deadline,
        string _contactInfo,
        string _data,
        uint _fulfillmentAmount
    )
        amountIsNotZero(_fulfillmentAmount)
    {
        issuer = msg.sender;
        issuerContact = _contactInfo;
        bountyStage = BountyStages.Draft;
        deadline = _deadline;
        data = _data;
        fulfillmentAmount = _fulfillmentAmount;
    }



    /// @dev contribute(): a function allowing anyone to contribute ether to a
    /// bounty, as long as it is still before its deadline. Shouldn't
    /// keep ether by accident (hence 'value').
    /// @notice Please note you funds will be at the mercy of the issuer
    ///  and can be drained at any moment. Be careful!
    /// @param value the amount being contributed in ether to prevent
    /// accidental deposits
    function contribute (uint value)
        payable
        isBeforeDeadline
        amountIsNotZero(value)
        amountEqualsValue(value)
        validateFunding
    {
        ContributionAdded(msg.sender, msg.value);
    }

    /// @notice Send funds to activate the bug bounty
    /// @dev activateBounty(): activate a bounty so it may continue to pay out
    function activateBounty()
        payable
        public
        isBeforeDeadline
        onlyIssuer
        validateFunding
    {
        transitionToState(BountyStages.Active);

        BountyActivated(msg.sender);
    }

    /// @dev fulfillBounty(): submit a fulfillment for the given bounty
    /// @param _data the data artifacts representing the fulfillment of the bounty
    /// @param _dataType a meaningful description of the type of data the fulfillment represents
    function fulfillBounty(string _data, string _dataType)
        public
        isAtStage(BountyStages.Active)
        isBeforeDeadline
        checkFulfillmentsNumber
        notIssuer
    {
        fulfillments[numFulfillments] = Fulfillment(false, false, msg.sender, _data, _dataType);

        BountyFulfilled(msg.sender, numFulfillments++);
    }

    /// @dev acceptFulfillment(): accept a given fulfillment, and send
    /// the fulfiller their owed funds
    /// @param fulNum the index of the fulfillment being accepted
    function acceptFulfillment(uint fulNum)
        public
        onlyIssuer
        isAtStage(BountyStages.Active)
        validateFulfillmentArrayIndex(fulNum)
    {
        fulfillments[fulNum].accepted = true;
        accepted[numAccepted++] = fulNum;

        FulfillmentAccepted(msg.sender, fulNum);
    }

    /// @dev acceptFulfillment(): accept a given fulfillment, and send
    /// the fulfiller their owed funds
    /// @param fulNum the index of the fulfillment being accepted
    function fulfillmentPayment(uint fulNum)
        public
        validateFulfillmentArrayIndex(fulNum)
        onlyFulfiller(fulNum)
        checkFulfillmentIsApprovedAndUnpaid(fulNum)
    {
        fulfillments[fulNum].fulfiller.transfer(fulfillmentAmount);

        numPaid++;

        FulfillmentPaid(msg.sender, fulNum);
    }

    /// @dev killBounty(): drains the contract of it's remaining
    /// funds, and moves the bounty into stage 3 (dead) since it was
    /// either killed in draft stage, or never accepted any fulfillments
    function killBounty()
        public
        onlyIssuer
    {
        issuer.transfer(this.balance - unpaidAmount());

        transitionToState(BountyStages.Dead);

        BountyKilled();
    }

    /// @dev extendDeadline(): allows the issuer to add more time to the
    /// bounty, allowing it to continue accepting fulfillments
    /// @param _newDeadline the new deadline in timestamp format
    function extendDeadline(uint _newDeadline)
        public
        onlyIssuer
        newDeadlineIsValid(_newDeadline)
    {
        deadline = _newDeadline;

        DeadlineExtended(_newDeadline);
    }



    /*
     * Internal functions
     */


    /// @dev unpaidAmount(): calculates the amount which
    /// the bounty has yet to pay out
    function unpaidAmount()
        public
        constant
        returns (uint unpaidAmount)
    {
        unpaidAmount = fulfillmentAmount * (numAccepted - numPaid);
    }

    /// @dev transitionToState(): transitions the contract to the
    /// state passed in the parameter `_newStage` given the
    /// conditions stated in the body of the function
    /// @param _newStage the new stage to transition to
    function transitionToState(BountyStages _newStage)
        internal
    {
        bountyStage = _newStage;
    }
}
