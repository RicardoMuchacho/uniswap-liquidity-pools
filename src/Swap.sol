// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "./IV2Router.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract SwapApp {
    using SafeERC20 for IERC20;

    address public V2Router02Address;
    address private immutable WETHAddress = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    event tokenSwap(
        address indexed user, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut
    );
    event ETHForTokensSwap(address indexed user, address indexed tokenOut, uint256 amountIn, uint256 amountOut);
    event tokensForETHSwap(address indexed user, address indexed tokenIn, uint256 amountIn, uint256 amountOut);

    constructor(address routerAddress_) {
        V2Router02Address = routerAddress_;
    }

    function swapTokens(uint256 amountIn_, uint256 amountOutMin_, address[] memory path_, uint256 deadline_) external {
        IERC20(path_[0]).safeTransferFrom(msg.sender, address(this), amountIn_);
        IERC20(path_[0]).approve(V2Router02Address, amountIn_);
        uint256[] memory amountsOut = IV2Router(V2Router02Address).swapExactTokensForTokens(
            amountIn_, amountOutMin_, path_, msg.sender, deadline_
        );

        emit tokenSwap(msg.sender, path_[0], path_[path_.length - 1], amountIn_, amountsOut[amountsOut.length - 1]);
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

    function getAmountOutHelper(uint256 amountIn_, address[] calldata path_) public view returns (uint256 amountOut) {
        uint256[] memory amounts = IV2Router(V2Router02Address).getAmountsOut(amountIn_, path_);
        amountOut = amounts[amounts.length - 1];
    }
}
