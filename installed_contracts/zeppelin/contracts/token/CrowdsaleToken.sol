pragma solidity ^0.4.8;


import "./StandardToken.sol";

/*
 * CrowdsaleToken
 *
 * Simple ERC20 Token example, with crowdsale token creation
 */
contract CrowdsaleToken is StandardToken {

    uint public startTime = 1492435800; // 2017/04/17 09:30 UTC-5
    uint public closeTime = startTime + 31 days;

    // 1 ETH = 50 tokens (^E18). 
    uint public price = 50 ether;       // Each token has 18 decimal places, just like ether. 

    function () payable {
        createTokens(msg.sender);
    }
  
    function createTokens(address recipient) payable {
        uint currentPrice;

        if ((now < startTime) || (now > closeTime) || (msg.value == 0)) throw;

        if (now < (startTime + 1 days)) {
            currentPrice = safeDiv(safeMul(price, 8), 10);  // 20 % discount (x * 8 / 10)
        } 
        else if (now < (startTime + 2 days)) {
            currentPrice = safeDiv(safeMul(price, 9), 10);  // 10 % discount (x * 9 / 10)
        }
        else if (now < (startTime + 12 days)) {
            // 1 % reduction in the discounted rate from day 2 until day 12 (sliding scale per second)
            // 8640000 is 60 x 60 x 24 x 100 (100 for 1%) (60 x 60 x 24 for seconds per day)
            currentPrice = price - safeDiv(safeMul(startTime + 12 days - now, price), 8640000);
        }
        else {
            currentPrice = price;
        }

        uint tokens = safeMul(msg.value, currentPrice);

        totalSupply = safeAdd(totalSupply, tokens);
        balances[recipient] = safeAdd(balances[recipient], tokens);
    }
  
}