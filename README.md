# 💥 Reentrancy

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

## 🛠️ Contracts

### ⚙️ VulnerableBank

```solidity
function withdraw() public {
    require(userBalance[msg.sender] >= 1, "No available balance");
    require(address(this).balance > 0, "Bank has no funds");

    (bool success,) = msg.sender.call{value: userBalance[msg.sender]}("");
    require(success, "Tx failed");

    userBalance[msg.sender] = 0; // ❌ Vulnerability: State update happens after external call
}
```

- Implements a **classic reentrancy vulnerability** by transferring funds before updating user balance.
- Exposes `deposit`, `withdraw`, and `totalBalance` functions.

---

### ⚔️ Attack Contract

```solidity
receive() external payable {
    if (address(vulnerableBank).balance >= 1 ether) {
        vulnerableBank.withdraw();
    }
}
```

- Attacker recursively **calls `withdraw()` via fallback function** before the balance is set to 0.
- Drains funds from the vulnerable contract in a **reentrant loop**.

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
