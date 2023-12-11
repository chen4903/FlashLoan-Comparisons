# Brief 

对比市面上常见的闪电贷协议，横向对比他们的不同，并且用Foundry做使用Demo

## comparisons

|             | 闪电贷名字 | 回调函数名字             | 借款   | 还款         | 还款指标 |
| ----------- | ---------- | ------------------------ | ------ | ------------ | -------- |
| uniswapV2   | swap()     | uniswapV2Call()          | 1或2种 | 1或2种       | 价值     |
| uniswapV3   | flash()    | uniswapV3FlashCallback() | 1或2种 | 借什么还什么 | 数量     |
| AAVE        |            |                          |        |              |          |
| PancakeSwap |            |                          |        |              |          |
| Compound    |            |                          |        |              |          |
| MakerDAO    |            |                          |        |              |          |
| dYdX        |            |                          |        |              |          |

## Uniswap

安装依赖

```
forge install Uniswap/v2-core
forge install Uniswap/v3-core
```

### v2

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

分析这个方法，我们可以发现：

- 最后的`require()`只检查了K值是否大于等于之前的K值，这就意味着，无论我们怎么借、还，只要K值满足条件，都可以调用成功。这就意味着我们可以有多种借款、还款方案：
  - 借token0，还token0
  - 借token0，还token1
  - 借token0和token1，还token1
  - 借token0和token1，还token0和token1
  - 等等...
- 这就让我们有很大的灵活性：我们可以选择还任意的token，只要他的`价值`足够，比如：你借出了token0和token1，你可以选择还1000`token0`，或者还10`token1`，或者120`token0`+4`token1`。

总结：

- 信息：闪电贷叫`swap()`, 回调函数叫`uniswapV2Call()`。v2中，闪电贷被写进了swap中，如果用户之前并没有向合约转入用于交易的代币，则相当于闪电贷。

- 其他：收取3/1000的手续费，这个手续费指的是借款总价值的3/1000
- 使用：在[使用教程](https://github.com/chen4903/FlashLoan-Comparisons/blob/master/test/uniswap_v2.sol)中，写了四种不同的闪电贷借款还款方式，都可以通过。使用：注释并打开相应的方法，输入`forge test --match-path test/Uniswap_V2.sol -offline -vv`进行测试。
- 结论：在UniswapV2中，闪电贷的还款逻辑是价值取向。

### v3

```solidity
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external override lock noDelegateCall {
        uint128 _liquidity = liquidity;
        require(_liquidity > 0, 'L');

        uint256 fee0 = FullMath.mulDivRoundingUp(amount0, fee, 1e6);
        uint256 fee1 = FullMath.mulDivRoundingUp(amount1, fee, 1e6);
        uint256 balance0Before = balance0();
        uint256 balance1Before = balance1();

        if (amount0 > 0) TransferHelper.safeTransfer(token0, recipient, amount0);
        if (amount1 > 0) TransferHelper.safeTransfer(token1, recipient, amount1);

        IUniswapV3FlashCallback(msg.sender).uniswapV3FlashCallback(fee0, fee1, data);

        uint256 balance0After = balance0();
        uint256 balance1After = balance1();

        require(balance0Before.add(fee0) <= balance0After, 'F0');
        require(balance1Before.add(fee1) <= balance1After, 'F1');

        // sub is safe because we know balanceAfter is gt balanceBefore by at least fee
        uint256 paid0 = balance0After - balance0Before;
        uint256 paid1 = balance1After - balance1Before;

        if (paid0 > 0) {
            uint8 feeProtocol0 = slot0.feeProtocol % 16;
            uint256 fees0 = feeProtocol0 == 0 ? 0 : paid0 / feeProtocol0;
            if (uint128(fees0) > 0) protocolFees.token0 += uint128(fees0);
            feeGrowthGlobal0X128 += FullMath.mulDiv(paid0 - fees0, FixedPoint128.Q128, _liquidity);
        }
        if (paid1 > 0) {
            uint8 feeProtocol1 = slot0.feeProtocol >> 4;
            uint256 fees1 = feeProtocol1 == 0 ? 0 : paid1 / feeProtocol1;
            if (uint128(fees1) > 0) protocolFees.token1 += uint128(fees1);
            feeGrowthGlobal1X128 += FullMath.mulDiv(paid1 - fees1, FixedPoint128.Q128, _liquidity);
        }

        emit Flash(msg.sender, recipient, amount0, amount1, paid0, paid1);
    }
```

分析这个方法，我们可以发现：

- 第2、3个`require()`限制了池子交易前后的每个token的数量不得减少，这就意味着我们借什么，就得还什么，因此只有三种方案：
  - 借token0，还token0
  - 借token1，还token1
  - 借token0和token1，还token0和token1

总结：

- 信息：闪电贷叫`flash()`, 回调函数叫`uniswapV3FlashCallback()`。

- 其他：手续费并不像V2那样粗暴取固定值3%，它有一套很复杂的计算逻辑，但不怕，V3已经帮我们计算好了每次调用闪电贷的手续费，他会传给回调函数。
- 使用：在[使用教程](https://github.com/chen4903/FlashLoan-Comparisons/blob/master/test/uniswap_v3.sol)中，写了2种不同的闪电贷借款还款方式，都可以通过。使用：注释并打开相应的方法，输入`forge test --match-path test/Uniswap_V3.sol -offline -vv`进行测试。
- 结论：在UniswapV3中，闪电贷的还款逻辑是数量取向，相比于V2，其目的性更强，借什么还什么，还帮你计算了手续费，体验更好，牺牲了一点交易的灵活性是值得的。

## AAVE



## PancakeSwap



## Compound



## MakerDAO



## dYdX













