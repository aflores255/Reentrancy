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
    uint256 amountToDeposit = 5 ether;

    function setUp() public {
        vulnerableBank = new VulnerableBank();
        vm.startPrank(attacker);
        attack = new Attack(address(vulnerableBank));
        vm.stopPrank();
    }

    function testInitialDeploy() public view {
        assert(address(vulnerableBank) != address(0) && address(attack) != address(0));
    }

    function testDepositEther() public {
        vm.startPrank(user);
        vm.deal(user, amountToDeposit);
        uint256 userBalanceBefore = address(user).balance;
        vulnerableBank.deposit{value: amountToDeposit}();
        uint256 userBalanceAfter = address(user).balance;
        assert(address(vulnerableBank).balance == amountToDeposit);
        assert(userBalanceBefore - userBalanceAfter == amountToDeposit);

        vm.stopPrank();
    }

    function testWithdrawEther() public {
        vm.startPrank(user);
        vm.deal(user, amountToDeposit);
        uint256 userBalanceBefore = address(user).balance;
        vulnerableBank.deposit{value: amountToDeposit}();
        uint256 userBalanceAfter = address(user).balance;
        assert(address(vulnerableBank).balance == amountToDeposit);
        assert(userBalanceBefore - userBalanceAfter == amountToDeposit);

        vulnerableBank.withdraw();
        uint256 userBalanceAfterWd = address(user).balance;
        assert(address(vulnerableBank).balance == 0);
        assert(userBalanceAfterWd == amountToDeposit);
        assert(vulnerableBank.userBalance(user) == 0);

        vm.stopPrank();
    }

    function testBankBalance() public{

        vm.startPrank(user);
        vm.deal(user, amountToDeposit);
        uint256 userBalanceBefore = address(user).balance;
        vulnerableBank.deposit{value: amountToDeposit}();
        uint256 userBalanceAfter = address(user).balance;
        uint256 bankBalance = vulnerableBank.totalBalance();
        assert(bankBalance == amountToDeposit);
        assert(userBalanceBefore - userBalanceAfter == amountToDeposit);

        vulnerableBank.withdraw();
        uint256 userBalanceAfterWd = address(user).balance;
        bankBalance = vulnerableBank.totalBalance();
        assert(bankBalance == 0);
        assert(userBalanceAfterWd == amountToDeposit);
        assert(vulnerableBank.userBalance(user) == 0);

        vm.stopPrank();

    }


    function testAttack() public {
        uint256 attackAmount = 1 ether;
        vm.startPrank(user);
        vm.deal(user, amountToDeposit);
        uint256 userBalanceBefore = address(user).balance;
        vulnerableBank.deposit{value: amountToDeposit}();
        uint256 userBalanceAfter = address(user).balance;
        assert(address(vulnerableBank).balance == amountToDeposit);
        assert(userBalanceBefore - userBalanceAfter == amountToDeposit);
        vm.stopPrank();

        vm.deal(address(attack), attackAmount);
        vm.startPrank(attacker);
        attack.getFunds(attackAmount);
        assert(address(attack).balance == amountToDeposit + attackAmount);
        assert(address(vulnerableBank).balance == 0);
        
        vm.stopPrank();
    }

    function testWithdrawStolenFunds() public{
        
        uint256 attackAmount = 1 ether;
        vm.startPrank(user);
        vm.deal(user, amountToDeposit);
        uint256 userBalanceBefore = address(user).balance;
        vulnerableBank.deposit{value: amountToDeposit}();
        uint256 userBalanceAfter = address(user).balance;
        assert(address(vulnerableBank).balance == amountToDeposit);
        assert(userBalanceBefore - userBalanceAfter == amountToDeposit);
        vm.stopPrank();

        vm.deal(address(attack), attackAmount);
        vm.startPrank(attacker);
        attack.getFunds(attackAmount);
        assert(address(attack).balance == amountToDeposit + attackAmount);
        assert(address(vulnerableBank).balance == 0);

        attack.withdrawFunds();

        assert(address(attacker).balance == amountToDeposit + attackAmount);
        
        vm.stopPrank();

    }

      function testCannotWithdrawStolenFundsIfNotOwner() public{
        
        uint256 attackAmount = 1 ether;
        vm.startPrank(user);
        vm.deal(user, amountToDeposit);
        uint256 userBalanceBefore = address(user).balance;
        vulnerableBank.deposit{value: amountToDeposit}();
        uint256 userBalanceAfter = address(user).balance;
        assert(address(vulnerableBank).balance == amountToDeposit);
        assert(userBalanceBefore - userBalanceAfter == amountToDeposit);
        vm.stopPrank();

        vm.deal(address(attack), attackAmount);
        vm.startPrank(attacker);
        attack.getFunds(attackAmount);
        assert(address(attack).balance == amountToDeposit + attackAmount);
        assert(address(vulnerableBank).balance == 0);
        vm.stopPrank();
        vm.startPrank(user);
        vm.expectRevert();
        attack.withdrawFunds();
        vm.stopPrank();
    }


}
