// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import Chainlink client from the OpenZeppelin library
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSwap {
    
    // Define the tokens that will be swapped
    address public token1;
    address public token2;
    
    // Define the Chainlink price oracle contract addresses for each token
    AggregatorV3Interface internal priceFeed1;
    AggregatorV3Interface internal priceFeed2;
    
    // Define the constructor function
    constructor(address _token1, address _token2, address _priceFeed1, address _priceFeed2) {
        token1 = _token1;
        token2 = _token2;
        priceFeed1 = AggregatorV3Interface(_priceFeed1);
        priceFeed2 = AggregatorV3Interface(_priceFeed2);
    }
    
    // Define the swapTokens function
    function swapTokens(uint256 _amount, bool _isToken1ToToken2) public {
        
        // Get the current price of each token from the Chainlink price oracle
        (,int256 price1,,,) = priceFeed1.latestRoundData();
        (,int256 price2,,,) = priceFeed2.latestRoundData();
        
        // Calculate the exchange rate between the tokens
        uint256 exchangeRate = uint256(price1) * 10**18 / uint256(price2);
        
        // Calculate the output amount based on the exchange rate and the input amount
        uint256 outputAmount;
        if (_isToken1ToToken2) {
            outputAmount = _amount * exchangeRate / 10**18;
        } else {
            outputAmount = _amount * 10**18 / exchangeRate;
        }
        
        uint256 finalOutputAmount = outputAmount;

        
        // Transfer the input token to the contract
        require(IERC20(token1).transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        
        // Transfer the output token to the user
        if (_isToken1ToToken2) {
            require(IERC20(token2).transfer(msg.sender, finalOutputAmount), "Transfer failed");
        } else {
            require(IERC20(token1).transfer(msg.sender, finalOutputAmount), "Transfer failed");
        }
    }
}
