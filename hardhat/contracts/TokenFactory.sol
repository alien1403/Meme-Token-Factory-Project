//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Token} from "./Token.sol";
import "hardhat/console.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

contract TokenFactory {
    struct memeToken {
        string name;
        string symbol;
        string description;
        string tokenImageURL;
        uint fundingRaised;
        address tokenAddress;
        address creatorAddress;
    }

    address[] public memeTokenAddresses;

    address constant UNISWAP_V2_FACTORY_ADDRESS =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant UNISWAP_V2_ROUTER_ADDRESS =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    uint constant DECIMALS = 10 ** 18;
    uint constant MAX_SUPPLY = 1000000 * DECIMALS;
    uint constant INIT_SUPPLY = (20 * MAX_SUPPLY) / 100;
    uint public constant INITIAL_PRICE = 3 * 10 ** 13;
    uint public constant K = 8 * 10 ** 15;

    mapping(address => memeToken) addressToMemeTokenMapping;
    uint constant MEMETOKEN_CREATION_FEE = 0.0001 ether;

    uint constant MEMECOIN_FUNDING_GOAL = 24 ether;

    function createMemeToken(
        string memory name,
        string memory symbol,
        string memory description,
        string memory imageUrl
    ) public payable returns (address) {
        require(
            msg.value >= MEMETOKEN_CREATION_FEE,
            "Not enough Ethereum to deploy"
        );

        Token memeTokenContract = new Token(name, symbol, INIT_SUPPLY);
        address memeTokenAddress = address(memeTokenContract);
        memeTokenAddresses.push(memeTokenAddress);
        memeToken memory newlyCreatedToken = memeToken(
            name,
            symbol,
            description,
            imageUrl,
            0,
            memeTokenAddress,
            msg.sender
        );
        addressToMemeTokenMapping[memeTokenAddress] = newlyCreatedToken;
        console.log("memetoken successfully deployed to: ", memeTokenAddress);
        return memeTokenAddress;
    }

    function getAllMemeTokens() public view returns (memeToken[] memory) {
        memeToken[] memory allTokens = new memeToken[](
            memeTokenAddresses.length
        );
        for (uint i = 0; i < memeTokenAddresses.length; i++) {
            allTokens[i] = addressToMemeTokenMapping[memeTokenAddresses[i]];
        }
        return allTokens;
    }

    // Using a Taylor series approximation to calculate e^x
    // e^x = 1 + x + x^2/2! + x^3/3! +...

    function exp(uint x) internal pure returns (uint) {
        uint sum = 10 ** 18;
        uint term = 10 ** 18;
        uint powerOfX = x;

        for (uint i = 1; i <= 20; i++) {
            term = (term * powerOfX) / (i * 10 ** 18);
            sum += term;
            if (term < 1) break;
        }
        return sum;
    }

    function calculateCost(
        uint currentSupply,
        uint amount
    ) public pure returns (uint) {
        uint exp1 = (K * (currentSupply + amount)) / DECIMALS;
        uint exp2 = (K * currentSupply) / DECIMALS;

        exp1 = exp(exp1);
        exp2 = exp(exp2);

        // Bonding curve
        // c = (P0 / k) * (e^(k * (currentSupply + amount)) - e^(k*currentSupply))
        uint cost = (INITIAL_PRICE * DECIMALS * (exp1 - exp2)) / K;
        return cost;
    }

    function buyMemeToken(
        address memeTokenAddress,
        uint purchaseQty
    ) public payable returns (uint) {
        require(
            addressToMemeTokenMapping[memeTokenAddress].tokenAddress !=
                address(0),
            "Token is not listed in the platform"
        );

        memeToken storage listedToken = addressToMemeTokenMapping[
            memeTokenAddress
        ];
        require(
            addressToMemeTokenMapping[memeTokenAddress].fundingRaised <=
                MEMECOIN_FUNDING_GOAL,
            "Funding has already been raised"
        );

        Token tokenContract = Token(memeTokenAddress);
        uint currentSupply = tokenContract.totalSupply();
        uint availableSupply = MAX_SUPPLY - currentSupply;

        uint availableSupplyScaled = availableSupply / DECIMALS;
        uint purchaseQuantityScaled = purchaseQty * DECIMALS;

        require(purchaseQty <= availableSupplyScaled, "NOT ENOUGH SUPPLY");

        // calculate the cost for purchase
        uint currentSupplyScalled = (currentSupply - INIT_SUPPLY) / DECIMALS;
        uint requiredETH = calculateCost(currentSupplyScalled, purchaseQty);

        console.log("Required ETH to buy is: ", requiredETH);

        require(msg.value >= requiredETH, "Incorrect value of ETH sent");

        listedToken.fundingRaised += msg.value;
        tokenContract.mint(purchaseQuantityScaled, msg.sender);

        console.log(
            "The user token balance is: ",
            tokenContract.balanceOf(msg.sender)
        );

        if (listedToken.fundingRaised >= MEMECOIN_FUNDING_GOAL) {
            // create the liquidity pool on Uniswap
            address pool = createLiquidityPool(memeTokenAddress);

            console.log("pool created address is: ", pool);
            // provide liquidity to the pool
            uint ethAmount = listedToken.fundingRaised;
            uint liquidity = provideLiquidity(
                memeTokenAddress,
                INIT_SUPPLY,
                ethAmount
            );
            console.log("Liquidity added to pool ", liquidity);
            // burn the lp token that represents the liquidity position
            burnLpTokens(pool, liquidity);
        }

        return requiredETH;
    }

    function createLiquidityPool(
        address memeTokenAddress
    ) internal returns (address) {
        IUniswapV2Factory factory = IUniswapV2Factory(
            UNISWAP_V2_FACTORY_ADDRESS
        );
        IUniswapV2Router01 router = IUniswapV2Router01(
            UNISWAP_V2_ROUTER_ADDRESS
        );
        address pair = factory.createPair(memeTokenAddress, router.WETH());

        return pair;
    }

    function provideLiquidity(
        address memeTokenAddress,
        uint tokenAmount,
        uint ethAmount
    ) internal returns (uint) {
        Token memeTokenContract = Token(memeTokenAddress);
        memeTokenContract.approve(UNISWAP_V2_ROUTER_ADDRESS, tokenAmount);
        IUniswapV2Router01 router = IUniswapV2Router01(
            UNISWAP_V2_ROUTER_ADDRESS
        );
        (uint amountToken, uint amountETH, uint liquidity) = router
            .addLiquidityETH{value: ethAmount}(
            memeTokenAddress,
            tokenAmount,
            tokenAmount,
            ethAmount,
            address(this),
            block.timestamp
        );
        return liquidity;
    }

    function burnLpTokens(
        address pool,
        uint liquidity
    ) internal returns (uint) {
        IUniswapV2Pair uniswapV2Contract = IUniswapV2Pair(pool);
        uniswapV2Contract.transfer(address(0), liquidity);
        console.log("LP Tokens burnt: ", liquidity);
        return 1;
    }
}
