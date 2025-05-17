//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

contract VulnerableBank {
    mapping(address => uint256) public userBalance;
    uint256 minimumDeposit = 1 ether;

    /**
     * @notice Deposit ETH into the contract
     */
    function deposit() public payable {
        require(msg.value >= minimumDeposit, "Minimum deposit not reached");
        userBalance[msg.sender] += msg.value;
    }

    /**
     * @notice Withdraw all ETH previously deposited by the caller
     * @custom:warning Do not use in production – unsafe withdrawal pattern
     */
    function withdraw() public {
        require(userBalance[msg.sender] >= 1, "No available balance");
        require(address(this).balance > 0, "Bank has no funds");

        (bool success,) = msg.sender.call{value: userBalance[msg.sender]}("");
        require(success, "Tx failed");

        userBalance[msg.sender] = 0; // vulnerability
    }

    /**
     * @notice Returns the total ETH balance held by the contract
     * @return balance ETH balance of the contract
     */
    function totalBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
