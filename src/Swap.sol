// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "./IV2Router.sol";
import "./IV2Factory.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract SwapApp {
    using SafeERC20 for IERC20;

    address public V2Router02Address;
    address private immutable WETHAddress = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    // Token Swaps
    event tokenSwap(
        address indexed user, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut
    );
    event ETHForTokensSwap(address indexed user, address indexed tokenOut, uint256 amountIn, uint256 amountOut);
    event tokensForETHSwap(address indexed user, address indexed tokenIn, uint256 amountIn, uint256 amountOut);
    event liquidityAdded(address indexed user, address tokenA, address tokenB, uint256 indexed liquidity);
    event liquidityRemoved(
        address indexed user, address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB
    );

    constructor(address routerAddress_) {
        V2Router02Address = routerAddress_;
    }

    function swapTokens(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, uint256 deadline_)
        public
        returns (uint256 tokenOut_)
    {
        IERC20(path_[0]).safeTransferFrom(msg.sender, address(this), amountIn_);
        IERC20(path_[0]).approve(V2Router02Address, amountIn_);
        uint256[] memory amountsOut = IV2Router(V2Router02Address).swapExactTokensForTokens(
            amountIn_, amountOutMin_, path_, msg.sender, deadline_
        );

        tokenOut_ = amountsOut[amountsOut.length - 1];

        emit tokenSwap(msg.sender, path_[0], path_[path_.length - 1], amountIn_, tokenOut_);
    }

    function swapETHForTokens(uint256 amountOutMin_, address[] memory path_, uint256 deadline_) external payable {
        require(msg.value > 0, "Must send ETH");

        // IERC20(path_[0]).approve(V2Router02Address, msg.value);
        uint256[] memory amountsOut = IV2Router(V2Router02Address).swapExactETHForTokens{value: msg.value}(
            amountOutMin_, path_, msg.sender, deadline_
        );

        emit ETHForTokensSwap(msg.sender, path_[path_.length - 1], msg.value, amountsOut[amountsOut.length - 1]);
    }

    function swapTokensForETH(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, uint256 deadline_)
        external
    {
        IERC20(path_[0]).safeTransferFrom(msg.sender, address(this), amountIn_);
        IERC20(path_[0]).approve(V2Router02Address, amountIn_);
        uint256[] memory amountsOut =
            IV2Router(V2Router02Address).swapExactTokensForETH(amountIn_, amountOutMin_, path_, msg.sender, deadline_);

        emit tokensForETHSwap(msg.sender, path_[0], amountIn_, amountsOut[amountsOut.length - 1]);
    }

    // Liquidity
    function addLiquidityWithTokenA(
        uint256 amountIn_,
        address[] memory path_,
        uint256 amountOutMin_,
        uint256 amountAMin_,
        uint256 amountBMin_,
        uint256 deadline_
    ) external {
        IERC20(path_[0]).safeTransferFrom(msg.sender, address(this), amountIn_);
        uint256 tokensSwapped = swapTokens(amountIn_ / 2, amountOutMin_, path_, deadline_);
        uint256 amountADesired = amountIn_ / 2;

        (,, uint256 liquidity) = IV2Router(V2Router02Address).addLiquidity(
            path_[0],
            path_[path_.length - 1],
            amountADesired,
            tokensSwapped,
            amountAMin_,
            amountBMin_,
            msg.sender,
            deadline_
        );

        emit liquidityAdded(msg.sender, path_[0], path_[path_.length - 1], liquidity);
    }

    function removeLiquidity(
        address tokenA_,
        address tokenB_,
        uint256 amountAMin_,
        uint256 amountBMin_,
        uint256 deadline_
    ) external {
        address factory = IV2Router(V2Router02Address).factory();
        address pairAddress = IUniswapV2Factory(factory).getPair(tokenA_, tokenB_);
        uint256 userLpTokens = IERC20(pairAddress).balanceOf(msg.sender);

        require(userLpTokens > 0, "No Liquidity");

        (uint256 amountA, uint256 amountB) = IV2Router(V2Router02Address).removeLiquidity(
            tokenA_, tokenB_, userLpTokens, amountAMin_, amountBMin_, msg.sender, deadline_
        );

        emit liquidityRemoved(msg.sender, tokenA_, tokenB_, amountA, amountB);
    }

    // Helpers
    function getAmountOutHelper(uint256 amountIn_, address[] calldata path_) public view returns (uint256 amountOut) {
        uint256[] memory amounts = IV2Router(V2Router02Address).getAmountsOut(amountIn_, path_);
        amountOut = amounts[amounts.length - 1];
    }
}
