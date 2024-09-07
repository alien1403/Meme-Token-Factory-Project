# Meme Token Factory Project

Welcome to the Meme Token Factory! This project allows users to create their own meme tokens, raise funds through a bonding curve mechanism, and automatically create liquidity pools on Uniswap when certain funding goals are met. Inspired by projects like pump.fun, this platform leverages modern DeFi tools to make meme token creation accessible to everyone.

[Contract on Etherscan](https://sepolia.etherscan.io/address/0xc71Ef716FA6C7389d237e37852e135239D69BE75)

## Table of Contents

- [Meme Token Factory Project](#meme-token-factory-project)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Smart Contracts](#smart-contracts)
    - [Token.sol](#tokensol)
    - [TokenFactory.sol](#tokenfactorysol)
    - [Bonding Curve](#bonding-curve)
    - [Taylor Series Approximation](#taylor-series-approximation)
  - [Technologies Used](#technologies-used)
  - [Contributing](#contributing)
  - [License](#license)

## Overview

This project enables users to create and manage their own meme tokens with the following features:

1. **Token Creation**: Users can create their own ERC-20 tokens by specifying a name, symbol, description, and image URL.
2. **Funding via Bonding Curve**: Tokens are sold to users based on a bonding curve model, where the price increases as the supply increases.
3. **Liquidity Pool Creation**: Once a meme token reaches its funding goal, a liquidity pool is automatically created on Uniswap, and liquidity is provided to the pool.
4. **Automatic LP Token Burning**: After providing liquidity, the LP tokens are automatically burnt, locking the liquidity forever.

## Smart Contracts

### Token.sol

This contract is a simple ERC-20 token contract with an additional `mint` function. Only the owner (creator) of the token can mint additional tokens.

**The key features of this contract are**:

- Owner-Only Minting: The mint function can only be called by the owner of the token contract.
- Initial Supply: The initial supply of tokens is minted to the owner's address upon deployment.

### TokenFactory.sol
This is the main contract that handles the creation of meme tokens, manages funding via a bonding curve, and integrates with Uniswap for liquidity pool creation.

**Key functions include:**

- **createMemeToken**: Creates a new meme token with initial supply and stores relevant information about it.
- **getAllMemeTokens**: Returns all meme tokens created on the platform.
calculateCost: Calculates the cost of purchasing additional tokens based on the bonding curve.
- **buyMemeToken**: Handles the purchase of tokens, updates funding, and manages liquidity pool creation when the funding goal is met.

### Bonding Curve
A bonding curve is a mathematical concept used in token economics to determine the price of a token based on its supply. In this project, the price of a meme token increases as more tokens are sold, which incentivizes early participation and helps regulate the token supply.

The cost is calculated using the formula:
```solidity
uint cost = (INITIAL_PRICE * DECIMALS * (exp1 - exp2)) / K;
```

where **exp1** and **exp2** are calculated using the exponential function approximated via the Taylor series.

### Taylor Series Approximation
To calculate the exponential function e^x efficiently on-chain, this project uses a Taylor series approximation. This method approximates the value of e^x by summing the first few terms of its series expansion:

```solidity
// e^x = 1 + x + x^2/2! + x^3/3! +...
```

This approximation allows for efficient on-chain computation of exponential functions, which is critical for implementing the bonding curve in a gas-efficient manner.

## Technologies Used
- Solidity 0.8.24: For writing the smart contracts.
- OpenZeppelin: For ERC-20 token standard implementation.
- Uniswap V2: For creating liquidity pools and providing decentralized exchange functionality.
- Hardhat: For smart contract development, testing, and deployment.

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests.

## License
This project is licensed under the MIT License.

```css
This `README.md` provides a comprehensive overview of your project, the smart contracts involved, the technical concepts used, and instructions for getting started. You can adjust the content to better fit your project's specifics.
```
