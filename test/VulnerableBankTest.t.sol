//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/VulnerableBank.sol";
import "../src/Attack.sol";

contract VulnerableBankTest is Test {
    
    VulnerableBank vulnerableBank;
    Attack attack;
    uint256 initialAttackerBalance = 1 ether;
    address attacker = vm.addr(1);
    address user = vm.addr(2);
    uint256 amount = 5 ether;

    function setUp() public {
        vulnerableBank = new VulnerableBank();
        attack = new Attack(address(vulnerableBank));

    }

    
    function testInitialDeploy() public view{

       assert(address(vulnerableBank)!=address(0)&&address(attack)!=address(0));

    }

    function testDepositEther() public{

        vm.startPrank(user);
        vm.deal(user,amount);
        uint256 userBalanceBefore = address(user).balance;
        vulnerableBank.deposit{value: amount}();
        uint256 userBalanceAfter = address(user).balance;
        assert(address(vulnerableBank).balance == amount);
        assert(userBalanceAfter - userBalanceBefore == amount);
        
        vm.stopPrank();
    }
    
    function testAtack() public {
        uint256 amount_ = 1 ether;
        vm.deal(attacker, initialAttackerBalance);
        vm.startPrank(attacker);
        vulnerableBank.deposit{value: amount_}();
        vulnerableBank.withdraw();
        vm.stopPrank();
    }

}
