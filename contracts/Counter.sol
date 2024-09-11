// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract Counter {
    uint public counter;
    address public owner;
    mapping(address => bool) public allowedBy;

    constructor() {
        owner = msg.sender;
        allowedBy[msg.sender] = true;
    }

    function update() external {
        require(allowedBy[msg.sender] == true, "Invalid caller");
        counter++;
    }

    function addAllowed(address user) external {
        require(owner == msg.sender, "Invalid caller");
        allowedBy[user] = true;
    }
}
