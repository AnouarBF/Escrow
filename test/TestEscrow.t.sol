// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Escrow} from "../src/Escrow.sol";
import {DeployEscrow} from "../script/DeployEscrow.s.sol";
import {Test, console} from "../lib/forge-std/src/Test.sol";

contract TestEscrow is Test {
    Escrow escrow;

    address public USER = makeAddr("user");
    uint public INITIAL_BALANCE = 10 ether;
    uint public AMOUNT = 1.1 ether;

    function setUp() public {
        DeployEscrow deployer = new DeployEscrow();
        escrow = deployer.run();
        vm.deal(USER, 10 ether);
    }

    modifier ArrangeTest() {
        vm.prank(USER);
        escrow.deposit{value: AMOUNT}();
        _;
    }

    function testDeposit() public ArrangeTest {
        assert(escrow.getDepositAmount(USER) == AMOUNT);
    }

    function testDepositRevertOnlyOwner() public {
        vm.expectRevert(Escrow.Escrow__Only_Buyer.selector);
        escrow.deposit{value: AMOUNT}();
    }

    function testDepositTransferToBuyer() public {
        vm.prank(USER);
        escrow.deposit{value: 0.9 ether};
        assert(escrow.getDepositAmount(USER) == 0);
    }

    function testReleaseFunds() public ArrangeTest {
        uint startingBuyerBalance = escrow.getDepositAmount(USER);
        console.log(startingBuyerBalance);
        uint startingSellerBalance = escrow.getSellerBalance();
        console.log(startingSellerBalance);

        vm.prank(escrow.getSeller());
        escrow.confirmReceipt();
        escrow.releaseFunds();

        uint endedSellerBalance = escrow.getSellerBalance();
        console.log(escrow.getSellerBalance());

        assert(
            endedSellerBalance == startingSellerBalance + startingBuyerBalance
        );
    }

    function testConfirmReceipt() public {
        vm.prank(escrow.getSeller());
        escrow.confirmReceipt();
        assert(escrow.checkIsReceipt() == true);
    }
}
