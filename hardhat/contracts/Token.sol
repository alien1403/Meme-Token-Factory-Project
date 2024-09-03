// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address owner;

    constructor(
        string memory _name,
        string memory _symbol,
        uint initialMintValue
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, initialMintValue);
        owner = msg.sender;
    }

    function mint(uint qty, address receiver) external returns (uint) {
        require(msg.sender == owner, "Not the owner");

        _mint(receiver, qty);
        return 1;
    }
}
