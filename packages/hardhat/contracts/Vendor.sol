pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    YourToken public yourToken;
    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:

    function buyTokens() external payable {
        require(msg.value > 0, "The value needs to be greater than zero");

        uint256 _amountToTransfer = msg.value * tokensPerEth;
        yourToken.transfer(msg.sender, _amountToTransfer);
        emit BuyTokens(msg.sender, msg.value, _amountToTransfer);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH

    function withdraw() public onlyOwner {
        uint256 balanceOfOwner = address(this).balance;
        require(balanceOfOwner > 0, "Owner balance cannot be less than zero.");
        (bool sent, ) = msg.sender.call{value: balanceOfOwner}("");
        require(sent, "Not able to send balance");
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 tokensToSell) public {
        require(
            tokensToSell > 0,
            "The amount of tokens has to be greater than zero"
        );

        uint256 userBalance = yourToken.balanceOf(msg.sender);
        require(
            userBalance >= tokensToSell,
            "Insufficient token balance to sell"
        );

        uint256 ethAmountToTransfer = tokensToSell / tokensPerEth; // How much Ether to transfer

        uint256 ownerBalance = address(this).balance;
        require(
            ownerBalance >= ethAmountToTransfer,
            "Unable to transfer. The owner's balance is insufficient."
        );

        yourToken.transferFrom(msg.sender, address(this), tokensToSell);

        (bool sent, ) = msg.sender.call{value: ethAmountToTransfer}("");
        require(sent, "Failed to send ETH to the user!");
    }
}
