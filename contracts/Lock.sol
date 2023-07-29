// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "./RequireFunction.sol";

/*To Do list Start
1. Create Item List insertItems to add all the items
2. Check Item Detail items.
3. Create a function startBid and select bid item and add into the detail of bidusers.
4. Create external function checkBidDate to add in another sol file and link them.
5. checkBidDate is use for check bid date are _bidStartDate is bigger to current date and vice versa fo _bidEndDate.
To Do list End */

struct Item {
    uint256 id;
    string name;
    address owner;
    uint256 bidStartDate;
    uint256 bidEndDate;
    uint256 bidPrice;
    bool buyed;
}

struct BidUser {
    uint256 bidId;
    string bidName;
    uint256 amount;
    address userAddress;
}

struct HighestBid {
    uint256 bidId;
    address userAddress;
    uint256 bidAmount;
    bool completed;
}

contract Lock {
    address public admin;
    mapping(uint256 => Item) public items;
    mapping(address => mapping(uint256 => BidUser)) public bidusers;
    mapping(uint256 => HighestBid) public highestbids;

    uint256 public itemIndex;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(admin == msg.sender, "Only Admin can do this action!");
        _;
    }

    function addBidItems(
        string memory _name,
        uint256 _bidStartDate,
        uint256 _bidEndDate,
        uint256 _bidPrice
    ) public onlyAdmin {
        Date.checkBidStartDate(_bidStartDate);
        Date.checkBidEndDate(_bidStartDate, _bidEndDate);

        itemIndex++;
        items[itemIndex] = Item(
            itemIndex,
            _name,
            msg.sender,
            _bidStartDate,
            _bidEndDate,
            _bidPrice,
            false
        );
        highestbids[itemIndex] = HighestBid(
            itemIndex,
            msg.sender,
            _bidPrice,
            false
        );
    }

    function addBidUser(uint256 _bidId, uint256 _bidAmount) public {
        Item storage bidDetail = items[_bidId];
        require(bidDetail.id == _bidId, "Bid not found!");
        require(bidDetail.buyed != true, "Bid already Closed!");

        require(
            _bidAmount >= bidDetail.bidPrice,
            "Bid amount is greater than Bid Price"
        );
        //check bid date
        Date.checkBidAfterStartDate(bidDetail.bidStartDate);
        Date.checkBidEndDate(bidDetail.bidStartDate, bidDetail.bidEndDate);

        HighestBid storage highbid = highestbids[_bidId];

        if (_bidAmount >= highbid.bidAmount) {
            highbid.userAddress = msg.sender;
            highbid.bidAmount = _bidAmount;
        }

        bidusers[msg.sender][_bidId] = BidUser(
            _bidId,
            bidDetail.name,
            _bidAmount,
            msg.sender
        );
    }

    function updateBidDetail(
        uint256 _bidId,
        string memory _updateName,
        uint256 _updateBidStartDate,
        uint256 _updateBidEndDate,
        uint256 _updateBidPrice
    ) public view onlyAdmin {
        Item memory bidDetail = items[_bidId];
        require(bidDetail.id == _bidId, "Bid not found!");

        Date.checkBidStartDate(_updateBidStartDate);
        Date.checkBidEndDate(_updateBidStartDate, _updateBidEndDate);

        bidDetail.name = _updateName;
        bidDetail.bidStartDate = _updateBidStartDate;
        bidDetail.bidEndDate = _updateBidEndDate;
        bidDetail.bidPrice = _updateBidPrice;
    }

    function updateUserBidAmount(uint256 _bidId, uint256 _updateAmount) public {
        Item storage bidDetail = items[_bidId];
        require(bidDetail.id == _bidId, "Bid not found!");
        require(
            _updateAmount >= bidDetail.bidPrice,
            "Bid amount is greater than Bid Price"
        );

        require(bidDetail.buyed != true, "Bid already Closed!");

        BidUser storage userDetail = bidusers[msg.sender][_bidId];
        require(userDetail.userAddress == msg.sender, "Bid User not match!");

        HighestBid storage highbid = highestbids[_bidId];
        if (_updateAmount > highbid.bidAmount) {
            highbid.userAddress = msg.sender;
            highbid.bidAmount = _updateAmount;
        }

        userDetail.amount = _updateAmount;
    }

    function bitWinnerSelect(uint256 _bidId) public onlyAdmin {
        Item storage bidDetail = items[_bidId];
        require(bidDetail.id == _bidId, "Bid not found!");

        HighestBid storage highbid = highestbids[_bidId];
        address winnerAddress = highbid.userAddress;
        highbid.completed = true;

        require(block.timestamp >= bidDetail.bidEndDate, "Bid still running!");

        bidDetail.owner = winnerAddress;
        bidDetail.buyed = true;
    }

    function announceWinner(uint256 _bidId) public onlyAdmin view returns (address) {
        Item storage bidDetail = items[_bidId];
        require(bidDetail.id == _bidId, "Bid not found!");

        HighestBid storage highbid = highestbids[_bidId];
        require(highbid.completed == true, "Bid not Complete yet");
        return highbid.userAddress;
    }
}
