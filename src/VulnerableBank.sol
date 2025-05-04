//SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

contract VulnerableBank {

    mapping(address=>uint256) public userBalance;
    uint256 minimumDeposit = 1 ether;

    function deposit() public payable{
        require(msg.value >= minimumDeposit, "Minimum deposit not reached");
        userBalance[msg.sender]+= msg.value; 

    }

    function withdraw() public{

        require(userBalance[msg.sender] >= 1, "No available balance");
        require(address(this).balance > 0, "Bank has no funds");

        (bool success,) = msg.sender.call{value: userBalance[msg.sender]}("");
        require(success,"Tx failed");

        userBalance[msg.sender] = 0; // vulnerability

    }

    function totalBalance() public view returns(uint256){

        return address(this).balance;

    }

}
