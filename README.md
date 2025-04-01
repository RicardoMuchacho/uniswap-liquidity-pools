# 🔄 SwapApp - Uniswap V2 Router Integration on Arbitrum One

## 📌 Overview
SwapApp is a Solidity smart contract that integrates Uniswap's V2 Router to enable seamless token swaps on the Arbitrum One mainnet. The contract supports swaps between ERC-20 tokens and ETH, ensuring efficient and decentralized trading.

## ✨ Key Features
- **Uniswap V2 Integration**: Uses Uniswap V2 Router for decentralized swaps.
- **100% Test Coverage**: Ensures reliability and security.
- **Token-to-Token Swaps**: Swap one ERC-20 token for another.
- **ETH to Token Swaps**: Convert ETH to ERC-20 tokens.
- **Token to ETH Swaps**: Convert ERC-20 tokens to ETH.

## 📜 Contracts Overview

| Contract  | Description |
|-----------|------------|
| `IV2Router` | Interface for interacting with Uniswap V2 Router functions. |
| `Swap` | Implements token swaps and ETH conversions using Uniswap V2 Router. |

### ⚙️ `Swap.sol` Contract Functions

| Function | Description |
|----------|------------|
| `swapTokens(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, uint256 deadline_)` | Swaps ERC-20 tokens for another ERC-20 token. |
| `swapETHForTokens(uint256 amountOutMin_, address[] memory path_, uint256 deadline_)` | Swaps ETH for ERC-20 tokens. |
| `swapTokensForETH(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, uint256 deadline_)` | Swaps ERC-20 tokens for ETH. |
| `getAmountOutHelper(uint256 amountIn_, address[] calldata path_)` | Helper function to fetch estimated output amount for a given input amount. |

## 🚀 Getting Started
1. Deploy `SwapApp` with the Uniswap V2 Router address on Arbitrum One.
2. Ensure that users approve token transfers before swapping.
3. Call the relevant swap function depending on the desired trade type.

