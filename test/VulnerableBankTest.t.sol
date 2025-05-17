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

    /**
     * @notice Deploys the contracts before each test
     */
    function setUp() public {
        vulnerableBank = new VulnerableBank();
        vm.startPrank(attacker);
        attack = new Attack(address(vulnerableBank));
        vm.stopPrank();
    }

    /**
     * @notice Ensures contracts are deployed correctly
     */
    function testInitialDeploy() public view {
        assert(address(vulnerableBank) != address(0) && address(attack) != address(0));
    }

    /**
     * @notice Verifies that a valid deposit updates the user's balance and the contract's balance correctly
     */
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

    /**
     * @notice Ensures that a deposit below the minimum required amount is rejected
     */
    function testCannotDepositEther() public {
        uint256 underMinimumDeposit = 0.5 ether;
        vm.startPrank(user);
        vm.deal(user, underMinimumDeposit);
        vm.expectRevert("Minimum deposit not reached");
        vulnerableBank.deposit{value: underMinimumDeposit}();
        vm.stopPrank();
    }

    /**
     * @notice Tests that a valid user can withdraw their entire balance
     */
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

    /**
     * @notice Ensures users without funds cannot withdraw
     */
    function testCannotWithdrawEther() public {
        vm.startPrank(user);
        vm.expectRevert("No available balance");
        vulnerableBank.withdraw();
        vm.stopPrank();
    }

    /**
     * @notice Verifies contract balance via totalBalance() before and after withdrawal
     */
    function testBankBalance() public {
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

    /**
     * @notice Simulates a reentrancy attack using the Attack contract
     */
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

    /**
     * @notice Allows attacker to drain stolen funds from the Attack contract
     */
    function testWithdrawStolenFunds() public {
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

    /**
     * @notice Ensures that only the owner of the Attack contract can withdraw stolen funds
     */
    function testCannotWithdrawStolenFundsIfNotOwner() public {
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

    /**
     * @notice Ensures that if the bank is empty, any withdraw attempt is reverted
     */
    function testNoBankBalance() public {
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
        vm.expectRevert("Bank has no funds");
        vulnerableBank.withdraw();
        vm.stopPrank();
    }
}
