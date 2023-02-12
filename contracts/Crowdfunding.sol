// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 <0.9.0;

import "@OpenZeppelin/contracts/token/ERC20/ERC20.sol";
contract Crowdfunding {
    ERC20 public token;
    uint256 public fundingGoal;
    uint256 public totalRaised;
    mapping (address => uint256) public pledges;
    event LogStateChange(address backer, uint256 amount);
    address public owner;

    
    constructor(ERC20 _token, uint256 _fundingGoal) public   {
        token = _token;
        fundingGoal = _fundingGoal;
        owner = msg.sender;
    }

    function pledge(uint256 amount) public payable {
    require(token.balanceOf(msg.sender) >= amount, "Insufficient token balance");
    require(msg.value == 0, "Do not send ether");
    token.transferFrom(msg.sender, address(this), amount);
    totalRaised += amount;
    pledges[msg.sender] = amount;
    emit LogStateChange(msg.sender, amount);
}


    function refund() public {
        require(totalRaised < fundingGoal, "Funding goal has been met");
        uint256 amount = pledges[msg.sender];
        require(payable(msg.sender).send(amount), "Transfer failed");
        totalRaised -= amount;
        delete pledges[msg.sender];
        emit LogStateChange(msg.sender, 0);
    }
    

    function upgrade(address newContract) public {
        require(msg.sender == owner, "Only the contract owner can upgrade");
        payable(newContract).transfer(address(this).balance);

    }

}