# Brief 

对比市面上常见的闪电贷协议，横向对比他们的不同，并且做使用Demo

## comparisons

|             |      |      |
| ----------- | ---- | ---- |
| uniswapV2   |      |      |
| uniswapV3   |      |      |
| AAVE        |      |      |
| PancakeSwap |      |      |
| Compound    |      |      |
| MakerDAO    |      |      |
| dYdX        |      |      |

## Uniswap

安装依赖

```
forge install Uniswap/v2-core
```

### v2

v2中，闪电贷被写进了swap中，如果用户之前并没有向合约转入用于交易的代币，则相当于闪电贷。

```solidity
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        require(amount0Out > 0 || amount1Out > 0, 'UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'UniswapV2: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
        address _token0 = token0; // gas saving
        address _token1 = token1; // gas saving
        require(to != _token0 && to != _token1, 'UniswapV2: INVALID_TO');
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
        // 如果使用闪电贷，则需要在自定义的uniswapV2Call方法中将借出的代币归还。
        if (data.length > 0) IUniswapV2Callee(to).uniswapV2Call(msg.sender, amount0Out, amount1Out, data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'UniswapV2: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
        uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
        // 由于在swap方法最后会检查余额（扣掉手续费后）符合k恒等式约束（参考白皮书公式），因此合约可以先将用户希望获得的代币转出，
        // 新的K值必须大于等于之前的K值，理论上由于手续费，K值会不断变大
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'UniswapV2: K'); // 校验K值
        }

        _update(balance0, balance1, _reserve0, _reserve1); // 使用缓存余额更新价格预言机所需的累计价格，最后更新缓存余额为当前余额。
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }
```

看完这个方法，我们可以得出以下结论：

- 最后的`require()`只检查了K值是否大于等于之前的K值，这就意味着，无论我们怎么借、还，只要K值满足条件，都可以调用成功。这就意味着我们可以有多种借款、还款方案：
  - 借token0，还token0
  - 借token0，还token1
  - 借token0和token1，还token1
  - 借token0和token1，还token0和token1
  - 等等
- 这就让我们有很大的灵活性：我们可以选择还任意的token，只要他的`价值`足够，比如：你借出了token0和token1，你可以选择还1000`token0`，或者还10`token1`，或者120`token0`+4`token1`。

在我们写的使用教程中，写了四种不同的闪电贷，都可以通过。

总结：在UniswapV2中，闪电贷的还款逻辑是价值取向

### v3



## AAVE



## PancakeSwap



## Compound



## MakerDAO



## dYdX













