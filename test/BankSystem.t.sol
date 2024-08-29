// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {BankSystem} from "../src/BankSystem.sol";

contract BankSystemTest is Test {
    BankSystem public bank;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");

    function setUp() public {
        bank = new BankSystem("BankToken", "BTK", alice);
    }

    function test_Deposit() public {
        vm.prank(alice);
        bank.deposit(bob, 100);
        (address a, address b, uint c) = bank.requests(0);
        assertEq(a, address(0));
        assertEq(c, 100);
        vm.prank(alice);
        bank.approve(0);
        uint bal = bank.balanceOf(bob);
        assertEq(bal, 100);
    }

    function test_Transfer() public {
        vm.prank(alice);
        bank.transferFrom(alice, bob, 500);
        vm.prank(alice);
        bank.approve(0);
        uint bal = bank.balanceOf(bob);
        assertEq(bal, 500);
        uint balAlice = bank.balanceOf(alice);
        assertEq(balAlice, 999999500);
    }
}
