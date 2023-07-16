// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Escrow {
    error Escrow__Buyer_should_not_be_seller();
    error Escrow__Only_Buyer();
    error Escrow__Not_Confirmed();
    error Escrow__Release_date_has_not_passed_yet();
    error Escrow__Amount_Not_Deposited_Yet();
    error Escrow__Failed_Tx();
    error Escrow__Only_Seller();

    address private immutable s_buyer;
    address private immutable s_seller;
    bool private s_isReceipt;

    struct Agreements {
        uint price;
        uint delivery_date;
        bool isGoodQuality;
    }

    Agreements private s_agreements;
    mapping(address => uint) private s_DepositAmount;

    constructor(
        address _buyer,
        address _seller,
        uint _price,
        uint _date,
        bool _isGoodQuality
    ) {
        if (!(_buyer != _seller)) revert Escrow__Buyer_should_not_be_seller();
        s_buyer = _buyer;
        s_seller = _seller;
        s_agreements.price = _price;
        s_agreements.delivery_date = _date;
        s_agreements.isGoodQuality = _isGoodQuality;
    }

    modifier fulfillAgreements() {
        if (
            s_agreements.price >= s_DepositAmount[s_buyer] &&
            s_agreements.delivery_date >= block.timestamp &&
            s_agreements.isGoodQuality
        ) {
            _;
        } else {
            payable(s_buyer).transfer(s_DepositAmount[s_buyer]);
        }
    }

    modifier OnlyBuyer() {
        if (!(msg.sender == s_buyer)) revert Escrow__Only_Buyer();
        _;
    }

    function deposit() external payable OnlyBuyer fulfillAgreements {
        s_DepositAmount[s_buyer] = msg.value;
    }

    function releaseFunds() external fulfillAgreements OnlyBuyer {
        if (!s_isReceipt) revert Escrow__Not_Confirmed();

        if (!(s_agreements.delivery_date >= block.timestamp))
            revert Escrow__Release_date_has_not_passed_yet();

        if (!(s_DepositAmount[s_buyer] > 0))
            revert Escrow__Amount_Not_Deposited_Yet();

        (bool success, ) = s_seller.call{value: s_DepositAmount[s_buyer]}("");
        if (!success) revert Escrow__Failed_Tx();

        s_DepositAmount[s_buyer] = 0;
    }

    function confirmReceipt() external {
        if (!(msg.sender == s_seller)) revert Escrow__Only_Seller();
        s_isReceipt = true;
    }

    function getBuyer() public view returns (address) {
        return s_buyer;
    }

    function getSeller() public view returns (address) {
        return s_seller;
    }

    function checkIsReceipt() public view returns (bool) {
        return s_isReceipt;
    }

    function getDepositAmount(address buyer) public view returns (uint) {
        return s_DepositAmount[buyer];
    }

    function getAgreements() public view returns (Agreements memory) {
        return s_agreements;
    }

    function getSellerBalance() public view returns (uint) {
        return s_seller.balance;
    }
}
