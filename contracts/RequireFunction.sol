// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
library Date {
    function checkBidStartDate(uint256 _bidStartDate) internal view {
        require(
            block.timestamp < _bidStartDate,
            "Start Date is greater than current timeStamp"
        );
    }

    function checkBidEndDate(uint256 _bidStartDate, uint256 _bidEndDate)
        internal
        view
    {
        require(
            block.timestamp < _bidEndDate && _bidEndDate > _bidStartDate,
            "End Date is greater than current timeStamp and bidStartDate"
        );
    }

    function checkBidAfterStartDate(uint256 _bidStartDate) internal view {
        // require(
        //     block.timestamp > _bidStartDate,
        //     "Start Date is less than current timeStamp"
        // );
    }
}