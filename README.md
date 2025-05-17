# 💥 Reentrancy - Simulating and Exploiting a Vulnerable Smart Contract

## 📌 Description

This is a Solidity-based smart contract project designed to **demonstrate a reentrancy vulnerability** and its exploitation using a malicious contract. This educational project includes:

- A **vulnerable bank contract** with a naive withdrawal logic.
- A **malicious attacker contract** that exploits the vulnerability.
- A complete **test suite** using **Foundry**, covering both regular user interaction and the exploit flow.

This project aims to help developers understand **how reentrancy attacks work** in Ethereum smart contracts and **why proper withdrawal patterns and reentrancy guards** are essential.

Built with **Solidity 0.8.28**, and tested with **Foundry**.

---

## 🧩 Features

| **Feature**               | **Description**                                                                            |
|---------------------------|--------------------------------------------------------------------------------------------|
| 🏦 **VulnerableBank**      | Contract that allows deposits and withdrawals, but is vulnerable to reentrancy.           |
| 🧨 **Reentrancy Exploit**  | Attack contract exploits the flaw to drain all ETH from the vulnerable bank.              |
| 🔬 **Full Test Suite**     | Comprehensive Foundry tests to simulate deposits, withdrawals, and attacks.              |
| 👤 **Access Control**      | Attack contract uses OpenZeppelin’s `Ownable` for secure withdrawal by the attacker.      |

---

## 🔍 How It Works

This project consists of two core smart contracts that simulate a typical reentrancy scenario:

### 🧱 Smart Contracts Overview

| **Contract**        | **Purpose**                                                                                                                                              |
|---------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| [📄 `VulnerableBank`](https://github.com/aflores255/Reentrancy/blob/master/src/VulnerableBank.sol) | Accepts user deposits and enables withdrawals — but is vulnerable due to incorrect order of state updates and external calls.            |
| [⚔️ `Attack`](https://github.com/aflores255/Reentrancy/blob/master/src/Attack.sol)                   | A malicious contract that exploits the reentrancy bug in `VulnerableBank` by recursively calling `withdraw()` before the balance is reset. |

---

### 🔁 Flow Diagram

+----------------+          deposit()           +------------------+
|    Attacker    | --------------------------> |  VulnerableBank  |
+----------------+                             +------------------+
       |                                               |
       |          withdraw()                           |
       | --------------------------------------------> |
       |                                               |
       |    send Ether to Attacker (external call)     |
       | <-------------------------------------------- |
       |                                               |
       |    fallback() triggered in Attacker           |
       | --------------------------------------------> |
       |                                               |
       |    re-enter withdraw()                        |
       | --------------------------------------------> |
       |                                               |
       |    repeat until VulnerableBank is drained     |
       | <-------------------------------------------- |
       |                                               |
+----------------+                             +------------------+
|    Attacker    |                             |  VulnerableBank  |
+----------------+                             +------------------+

---

### 🔑 Summary

- The **`VulnerableBank`** lets users deposit and withdraw Ether.
- Its **flawed `withdraw()` logic** calls `msg.sender.call{value: ...}` before updating internal balances.
- The **`Attack` contract** receives ETH, and during the fallback (`receive()`), re-enters the `withdraw()` function before the state is updated, draining funds in a loop.
- The attacker finally calls `withdrawStolenFunds()` to move the stolen ETH out of their own contract.

---

## 🧪 Testing with Foundry

The test suite validates both normal behavior and the exploit.

### ✅ Implemented Tests

| **Test**                           | **Description**                                                         |
|------------------------------------|-------------------------------------------------------------------------|
| `testInitialDeploy`                | Verifies contracts are deployed correctly.                              |
| `testDepositEther`                | Checks that deposits are recorded and stored.                           |
| `testCannotDepositEther`          | Validates enforcement of minimum deposit requirement.                   |
| `testWithdrawEther`               | Simulates a successful user withdrawal.                                 |
| `testCannotWithdrawEther`         | Fails if user balance is 0.                                             |
| `testBankBalance`                 | Validates total balance tracking.                                       |
| `testAttack`                      | Executes the reentrancy attack and drains the bank.                     |
| `testWithdrawStolenFunds`         | Attacker withdraws stolen ETH.                                          |
| `testCannotWithdrawStolenFundsIfNotOwner` | Ensures only the attacker owner can withdraw stolen ETH.        |
| `testNoBankBalance`               | Validates proper reverts when the bank has no ETH to withdraw.          |

### 📊 Coverage Report

| File                    | % Lines         | % Statements     | % Branches      | % Functions     |
|-------------------------|------------------|-------------------|------------------|------------------|
| `src/Attack.sol ` | 100.00% (11/11) | 100.00% (8/8) | 66.67% (2/3) | 100.00% (4/4)   |
| `src/VulnerableBank.sol ` | 100.00% (11/11) | 100.00% (9/9) | 87.50% (7/8) | 100.00% (3/3)   |

> 🔍 **Note**: Coverage is not 100% for branches due to one specific edge case — the branch that reverts with `"Tx Failed"` on failed Ether transfers. Simulating that revert requires a test using a contract that intentionally rejects Ether. 
---

## 🔗 Dependencies

- [OpenZeppelin Ownable](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [Foundry Framework](https://book.getfoundry.sh/)

---

## 🛠️ How to Use

### 🔧 Prerequisites

- Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Clone the repository

---

### 🧪 Run Tests

```bash
forge test
```

---

### 🚀 Deploy Contracts (Locally)

```solidity
VulnerableBank vulnerableBank = new VulnerableBank();
Attack attack = new Attack(address(vulnerableBank));
```

---

## ⚠️ Educational Purpose Only

This project is for **educational and security auditing practice only**. Do **not** use vulnerable patterns in production. Always:

- Follow **Checks-Effects-Interactions** pattern
- Use **`ReentrancyGuard`** from OpenZeppelin when needed

---

## 📄 License

This project is licensed under the **MIT License**.
