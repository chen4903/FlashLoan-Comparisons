# Brief 

对比市面上常见的闪电贷协议，横向对比他们的不同，并且用Foundry做使用Demo。

## comparisons

|                   | 链                                                        | 闪电贷名字                    | 回调函数名字             | 借款数量(种) | 还款                                     | 还款指标 | 借款对象                        | 借款类型  |
| ----------------- | --------------------------------------------------------- | ----------------------------- | ------------------------ | ------------ | ---------------------------------------- | -------- | ------------------------------- | --------- |
| uniswapV2         | ETH                                                       | swap()                        | uniswapV2Call()          | 1/2          | 1或2种。transfer代币                     | 价值(K)  | 与池子交互、借款                | ERC20     |
| uniswapV3         | ETH                                                       | flash()                       | uniswapV3FlashCallback() | 1/2          | 借什么还什么。transfer代币               | 数量     | 与池子交互、借款                | ERC20     |
| AAVEV1            | ETH                                                       | flashLoan()                   | executeOperation()       | 1            | 借什么还什么。transfer代币               | 数量     | 与池子交互，向core合约借款      | ERC20/ETH |
| AAVEV2            | ETH,AVAX,Polygon                                          | flashLoan()                   | executeOperation()       | 1/n          | 借什么还什么。approve代币/开新的债务仓位 | 数量     | 与池子交互，向aToken合约借款    | ERC20     |
| AAVEV3            | ETH,AVAX,Base,Arb,Fant,Op, Polygon, Gnosis,Metis,Harmony, | flashLoan()/flashLoanSimple() | 两种executeOperation()   | 1/n          | 借什么还什么。approve代币/开新的债务仓位 | 数量     | 与池子交互，向aEthToken合约借款 | ERC20     |
| SushiSwapV2       | ETH, BSC, Base, Arb, OP, Poly.....                        | swap()                        | uniswapV2Call()          | 1/2          | 1或2种。transfer代币                     | 价值(K)  | 与池子交互、借款                | ERC20     |
| SushiSwapV3       | ETH, BSC, Base, Arb, OP, Poly.....                        | flash()                       | uniswapV3FlashCallback() | 1/2          | 借什么还什么。transfer代币               | 数量     | 与池子交互、借款                | ERC20     |
| PancakeSwapV2     | BSC                                                       | swap()                        | pancakeCall()            | 1/2          | 1或2种。transfer代币                     | 价值(K)  | 与池子交互、借款                | ERC20     |
| PancakeSwapV3     | BSC                                                       | flash()                       | pancakeV3FlashCallback() | 1/2          | 借什么还什么。transfer代币               | 数量     | 与池子交互、借款                | ERC20     |
| Euler             | ETH                                                       | flashLoan()                   | onFlashLoan()            | 1            | 借什么还什么。approve代币                | 数量     | 闪电贷合约本身                  | ERC20     |
| MakerDAO          |                                                           |                               |                          |              |                                          |          |                                 |           |
| dYdX              |                                                           |                               |                          |              |                                          |          |                                 |           |
| Nuo               |                                                           |                               |                          |              |                                          |          |                                 |           |
| Fulcrum           |                                                           |                               |                          |              |                                          |          |                                 |           |
| DeFi Money Market |                                                           |                               |                          |              |                                          |          |                                 |           |
| ETHLend           |                                                           |                               |                          |              |                                          |          |                                 |           |
| bZx               |                                                           |                               |                          |              |                                          |          |                                 |           |
| Balancer          |                                                           |                               |                          |              |                                          |          |                                 |           |

## Uniswap

> 典型的Dex

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

- 其他：
  - 收取3/1000的手续费，这个手续费指的是借款总价值的3/1000
  - Uniswap有很多个池子，不同币对组成不同的池子，每个池子都可以进行闪电贷，并且只是借款池子中的资产

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

- 其他：
  - 手续费并不像V2那样粗暴取固定值3%，它有一套很复杂的计算逻辑，但不怕，V3已经帮我们计算好了每次调用闪电贷的手续费，他会传给回调函数。
  - Uniswap有很多个池子，不同币对组成不同的池子，每个池子都可以进行闪电贷，并且只是借款池子中的资产

- 使用：在[使用教程](https://github.com/chen4903/FlashLoan-Comparisons/blob/master/test/Uniswap_V3.sol)中，写了2种不同的闪电贷借款还款方式，都可以通过。使用：注释并打开相应的方法，输入`forge test --match-path test/Uniswap_V3.sol -offline -vv`进行测试。
- 结论：在UniswapV3中，闪电贷的还款逻辑是数量取向，相比于V2，其目的性更强，借什么还什么，还帮你计算了手续费，体验更好，牺牲了一点交易的灵活性是值得的。

## AAVE

> 典型的借贷协议，支持闪电贷业务

### v1

```solidity
    function flashLoan(address _receiver, address _reserve, uint256 _amount, bytes memory _params)
        public
        nonReentrant
        onlyActiveReserve(_reserve)
        onlyAmountGreaterThanZero(_amount)
    {

        // 查看AAVE池子是否有足够的钱给你闪电贷
        // 不用getAvailableLiquidity()来查询，因为这个方法太消耗gas了
        uint256 availableLiquidityBefore = _reserve == EthAddressLib.ethAddress()
            ? address(core).balance
            : IERC20(_reserve).balanceOf(address(core));

        require(
            availableLiquidityBefore >= _amount,
            "There is not enough liquidity available to borrow"
        );

        // 闪电贷手续费
        (uint256 totalFeeBips, uint256 protocolFeeBips) = parametersProvider
            .getFlashLoanFeesInBips();
        uint256 amountFee = _amount.mul(totalFeeBips).div(10000); // 协议费：0.35%

        // 借款的金额太小，四舍五入导致手续费为0，则revert，因此闪电贷的金额不能太小
        uint256 protocolFee = amountFee.mul(protocolFeeBips).div(10000); // 协议费中的手续费：30%
        require(
            amountFee > 0 && protocolFee > 0,
            "The requested amount is too small for a flashLoan."
        );

        // 获取到调用闪电贷的合约实例
        IFlashLoanReceiver receiver = IFlashLoanReceiver(_receiver);

        address payable userPayable = address(uint160(_receiver));

        // 转钱给调用闪电贷的合约实例
        core.transferToUser(_reserve, userPayable, _amount);

        // 调用闪电贷的合约实例 调用回调函数。合约需要在回调函数中偿还金额：借款金额+手续费
        receiver.executeOperation(_reserve, _amount, amountFee, _params);

        // 闪电贷结束之后，查看合约的资产情况
        uint256 availableLiquidityAfter = _reserve == EthAddressLib.ethAddress()
            ? address(core).balance
            : IERC20(_reserve).balanceOf(address(core));

        // 闪电贷结束之后的合约资产 = 闪电贷结束之前的合约资产 + 手续费
        // V1版本非常不友好，我们必须完全精确的计算，否则交易失败
        // 这里严格等于并不会导致DoS，因为不是用合约的变量记录资产信息，
        // 这个方法是直接获取资产信息的，因此避免了这个问题
        require(
            availableLiquidityAfter == availableLiquidityBefore.add(amountFee),
            "The actual balance of the protocol is inconsistent"
        );

        // 更新闪电贷信息
        core.updateStateOnFlashLoan(
            _reserve,
            availableLiquidityBefore,
            amountFee.sub(protocolFee),
            protocolFee
        );

        //solium-disable-next-line
        emit FlashLoan(_receiver, _reserve, _amount, amountFee, protocolFee, block.timestamp);
    }
```

分析这个方法，我们可以发现：

- 一次只能借一种资产，并且只能还这种资产
- aave只有一个池子，因此大家都在这个Lending pool进行存取款、闪电贷等。但是，借的不是池子的钱，而是core合约中的钱，并且还钱也是还给core
- 可以借款token，也可以借款ETH原生代币（当`_reserve`是`0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`）

```solidity
    function transferToUser(address _reserve, address payable _user, uint256 _amount)
        external
        onlyLendingPool
    {
        if (_reserve != EthAddressLib.ethAddress()) {
            ERC20(_reserve).safeTransfer(_user, _amount);
        } else {
            //solium-disable-next-line
            (bool result, ) = _user.call.value(_amount).gas(50000)("");
            require(result, "Transfer of ETH failed");
        }
    }
```

总结：

- 信息：闪电贷叫`flashLoan()`, 回调函数叫`executeOperation()`。

- 其他：固定0.35%的手续费，协议费占手续费的30%
- 使用：在使用教程中，写了借DAI的例子。使用：输入`forge test --match-path test/AAVE_v1.sol -offline -vv`进行测试。
- 结论：在aave v1中，闪电贷的还款逻辑是数量取向

### v2

```solidity
  function flashLoan(
    address receiverAddress, // 接收借款地址，需要实现回调函数
    address[] calldata assets, // 借什么
    uint256[] calldata amounts, // 借多少
    uint256[] calldata modes, // 不还款时设置的债务类型
    						// 0 => 不设置任何债务，交易回退
    						// 1 => 以稳定利率设置债务，债务数量为闪电贷的代币数量，债务地址为onBehalfof
    						// 2 => 以可变利率设置债务，债务数量为闪电贷的代币数量，债务地址为onBehalfof
    address onBehalfOf, // 债务接收地址，当modes = 1 or 2时有效
    bytes calldata params, // 
    uint16 referralCode // 用于注册发起操作的集成商的代码，以获得潜在奖励。如果动作由用户直接执行，没有任何中间人，则设置为0
  ) external override whenNotPaused {
    FlashLoanLocalVars memory vars; // 单笔闪电贷的局部变量结构

    ValidationLogic.validateFlashloan(assets, amounts); // 校验长度匹配

    address[] memory aTokenAddresses = new address[](assets.length); // 生息代币地址(aToken)
    uint256[] memory premiums = new uint256[](assets.length); // 手续费

    vars.receiver = IFlashLoanReceiver(receiverAddress); // 闪电贷代币接收地址

    for (vars.i = 0; vars.i < assets.length; vars.i++) {
      aTokenAddresses[vars.i] = _reserves[assets[vars.i]].aTokenAddress; // 标的代币assets[vars.i]对应的生息代币

      premiums[vars.i] = amounts[vars.i].mul(_flashLoanPremiumTotal).div(10000); // 固定手续费 9 / 10000 = 0.09% = 0.0009

	  // 闪电贷乐观转账：将标的代币从生息代币地址转账给接收地址 receiverAddress，转账数量为amounts[vars.i]
      IAToken(aTokenAddresses[vars.i]).transferUnderlyingTo(receiverAddress, amounts[vars.i]);
    }

    require( // 执行自定义业务函数，并检查返回值是否为true
      vars.receiver.executeOperation(assets, amounts, premiums, msg.sender, params),
      Errors.LP_INVALID_FLASH_LOAN_EXECUTOR_RETURN
    );

    for (vars.i = 0; vars.i < assets.length; vars.i++) { // 循环遍历每一个闪电贷财产
      vars.currentAsset = assets[vars.i]; // 闪电贷代币地址
      vars.currentAmount = amounts[vars.i]; // 闪电贷代币数量
      vars.currentPremium = premiums[vars.i]; // 手续费
      vars.currentATokenAddress = aTokenAddresses[vars.i]; // 生息代币（矿池）地址
      vars.currentAmountPlusPremium = vars.currentAmount.add(vars.currentPremium); // 闪电贷代币数量+手续费

      if (DataTypes.InterestRateMode(modes[vars.i]) == DataTypes.InterestRateMode.NONE) { // modes==0
        _reserves[vars.currentAsset].updateState(); // 更新流动性累计指数和可变的借款指数
        _reserves[vars.currentAsset].cumulateToLiquidityIndex( // 将闪电贷手续费累积到储备金中，并在所有人之间分摊
          IERC20(vars.currentATokenAddress).totalSupply(),
          vars.currentPremium
        );
        _reserves[vars.currentAsset].updateInterestRates( // 更新利率
          vars.currentAsset, // 待更新的储备金地址（标的代币地址）
          vars.currentATokenAddress, // 与标的代币对应的生息代币地址（流动性）
          vars.currentAmountPlusPremium, // 添加到协议的流动性数量（存款或偿还）
          0 // 从协议中获取的流动性数量（赎回或借入）
        ); // 更新储备金当前稳定借款利率，当前可变借款利率和当前流动性利率

        IERC20(vars.currentAsset).safeTransferFrom( // 闪电贷还款，需要receiverAddress对aToken的授权批准
          receiverAddress, // from：闪电贷接收地址
          vars.currentATokenAddress, // to：生息代币地址，闪电贷的贷款来源地址
          vars.currentAmountPlusPremium // 代币数量
        );
      } else {
        // If the user chose to not return the funds, the system checks if there is enough collateral and
        // eventually opens a debt position
        _executeBorrow( // 若不还款，检查质押物，然后开一个债务仓位
          ExecuteBorrowParams(
            vars.currentAsset,
            msg.sender,
            onBehalfOf, // 债务接收地址
            vars.currentAmount,
            modes[vars.i],
            vars.currentATokenAddress,
            referralCode,
            false
          )
        );
      }
      emit FlashLoan( // 出发FlashLoan事件
        receiverAddress, // 闪电贷代币接收地址，自定义业务函数执行合约地址
        msg.sender, // 闪电贷发起账户地址
        vars.currentAsset, // 闪电贷代币地址
        vars.currentAmount, // 闪电贷代币数量
        vars.currentPremium, // 手续费
        referralCode // 用于注册发起操作的集成商的代码，以获得潜在的奖励。如果动作由用户直接执行，没有任何中间人，则设置为0
      );
    }
  }
```

分析这个方法，我们可以发现：

- 一次借多种资产，并且借什么还什么
- aave只有一个池子，因此大家都在这个Lending pool进行存取款、闪电贷等。
- 每次都是在对应的aToken进行实际的借款：我们调用Lending_Pool进行闪电贷，然后去到aToken合约(拥有大量的Token)，然后aToken合约将Token借给你。
- 实际的闪电贷逻辑：`Lending_Pool`使用`transferFrom()`将aToken合约的Token给你，你在回调函数中完成一系列操作：
  - 如果mode=0：需要在闪电贷之前或者闪电贷的回调函数中`approve()`给Lending_Pool相应数量代币，然后在回调函数结束之后，Lending_Pool会`transferFrom()`你的代币进行还款
  - 如果mode!=0：你在使用闪电贷之前，在AAVE中质押了相应的资产，并且它们是可被抵押的、价值足够，然后在回调函数结束之后，Lending_Pool会开启一个新的债务仓位
- 不支持闪电贷ETH

总结：

- 信息：闪电贷叫`flashLoan()`, 回调函数叫`executeOperation()`。

- 其他：固定手续费0.09%
- 使用：在使用教程中，写了`借USDT,WBTC，还USDT,WBTC`和`借USDT,WBTC，不还款，而是开一个新的债务仓位, modes=2`的例子。使用：输入`forge test --match-path test/AAVE_v2.sol -offline -vv`进行测试。
- 结论：在aave v2中，闪电贷的还款逻辑是数量取向

### v3

V3版本的闪电贷写了两个，一个是批量闪电贷，一个是只闪电贷一种资产：

```solidity
  function flashLoan(
    address receiverAddress, // 接收代币、执行回调函数的地址
    address[] calldata assets, // 借什么（标的资产）
    uint256[] calldata amounts, // 借多少
    uint256[] calldata interestRateModes, // 利率模式，和v2版本中的modes相同
    address onBehalfOf, // 债务接收地址，和v2版本中的相同
    bytes calldata params,
    uint16 referralCode // 用于注册发起操作的集成商的代码，以获得潜在的奖励。如果动作由用户直接执行，没有中间人，则设置为0
  ) public virtual override {
    DataTypes.FlashloanParams memory flashParams = DataTypes.FlashloanParams({
      receiverAddress: receiverAddress,
      assets: assets,
      amounts: amounts,
      interestRateModes: interestRateModes,
      onBehalfOf: onBehalfOf,
      params: params,
      referralCode: referralCode,
      flashLoanPremiumToProtocol: _flashLoanPremiumToProtocol, // 协议费0
      flashLoanPremiumTotal: _flashLoanPremiumTotal, // 交易手续费0.09%
      maxStableRateBorrowSizePercent: _maxStableRateBorrowSizePercent,
      reservesCount: _reservesCount,
      addressesProvider: address(ADDRESSES_PROVIDER),
      userEModeCategory: _usersEModeCategory[onBehalfOf],
      isAuthorizedFlashBorrower: IACLManager(ADDRESSES_PROVIDER.getACLManager()).isFlashBorrower(
        msg.sender
      ) // 角色判断：msg.sender是否是FlashBorrower
    });

    FlashLoanLogic.executeFlashLoan(
      _reserves,
      _reservesList,
      _eModeCategories,
      _usersConfig[onBehalfOf],
      flashParams
    );
  }
  
  function flashLoanSimple(
    address receiverAddress, // 闪电贷接收代币以及执行自定义业务函数的合约地址
    address asset, // 闪电贷的代币地址
    uint256 amount, // 闪电贷的代币数量
    bytes calldata params, // 闪电贷执行自定义业务函数的参数数据
    uint16 referralCode
  ) public virtual override {
    DataTypes.FlashloanSimpleParams memory flashParams = DataTypes.FlashloanSimpleParams({
      receiverAddress: receiverAddress,
      asset: asset,
      amount: amount,
      params: params,
      referralCode: referralCode,
      flashLoanPremiumToProtocol: _flashLoanPremiumToProtocol, // 闪电贷协议费
      flashLoanPremiumTotal: _flashLoanPremiumTotal // 闪电贷交易费
    });
    FlashLoanLogic.executeFlashLoanSimple(_reserves[asset], flashParams);
  }
```

执行闪电贷

```solidity
  function executeFlashLoan(
    mapping(address => DataTypes.ReserveData) storage reservesData,
    mapping(uint256 => address) storage reservesList,
    mapping(uint8 => DataTypes.EModeCategory) storage eModeCategories,
    DataTypes.UserConfigurationMap storage userConfig,
    DataTypes.FlashloanParams memory params
  ) external {
    // The usual action flow (cache -> updateState -> validation -> changeState -> updateRates)
    // is altered to (validation -> user payload -> cache -> updateState -> changeState -> updateRates) for flashloans.
    // This is done to protect against reentrance and rate manipulation within the user specified payload.

    // 闪电贷基本检查
    ValidationLogic.validateFlashloan(reservesData, params.assets, params.amounts); 

    FlashLoanLocalVars memory vars;

    vars.totalPremiums = new uint256[](params.assets.length);

    vars.receiver = IFlashLoanReceiver(params.receiverAddress); 
    (vars.flashloanPremiumTotal, vars.flashloanPremiumToProtocol) = params.isAuthorizedFlashBorrower
      ? (0, 0)
      : (params.flashLoanPremiumTotal, params.flashLoanPremiumToProtocol); // 协议费和手续费

    for (vars.i = 0; vars.i < params.assets.length; vars.i++) {
      vars.currentAmount = params.amounts[vars.i]; // 闪电贷标的代币数量
      vars.totalPremiums[vars.i] = DataTypes.InterestRateMode(params.interestRateModes[vars.i]) ==
        DataTypes.InterestRateMode.NONE
        ? vars.currentAmount.percentMul(vars.flashloanPremiumTotal)
        : 0;
      IAToken(reservesData[params.assets[vars.i]].aTokenAddress).transferUnderlyingTo( // 乐观转账
        params.receiverAddress,
        vars.currentAmount
      );
    }

    require(
      vars.receiver.executeOperation( // 回调函数
        params.assets,
        params.amounts,
        vars.totalPremiums,
        msg.sender,
        params.params
      ),
      Errors.INVALID_FLASHLOAN_EXECUTOR_RETURN
    );

    for (vars.i = 0; vars.i < params.assets.length; vars.i++) {
      vars.currentAsset = params.assets[vars.i];
      vars.currentAmount = params.amounts[vars.i];

      if (
        DataTypes.InterestRateMode(params.interestRateModes[vars.i]) ==
        DataTypes.InterestRateMode.NONE
      ) {
        _handleFlashLoanRepayment( // 执行还款
          reservesData[vars.currentAsset],
          DataTypes.FlashLoanRepaymentParams({
            asset: vars.currentAsset,
            receiverAddress: params.receiverAddress,
            amount: vars.currentAmount,
            totalPremium: vars.totalPremiums[vars.i], // 交易费
            flashLoanPremiumToProtocol: vars.flashloanPremiumToProtocol, // 协议费
            referralCode: params.referralCode 
          })
        );
      } else { // 不还款，检查抵押物，然后设置新的债务仓位
        // If the user chose to not return the funds, the system checks if there is enough collateral and
        // eventually opens a debt position
        BorrowLogic.executeBorrow(
          reservesData,
          reservesList,
          eModeCategories,
          userConfig,
          DataTypes.ExecuteBorrowParams({
            asset: vars.currentAsset,
            user: msg.sender,
            onBehalfOf: params.onBehalfOf,
            amount: vars.currentAmount,
            interestRateMode: DataTypes.InterestRateMode(params.interestRateModes[vars.i]),
            referralCode: params.referralCode,
            releaseUnderlying: false,
            maxStableRateBorrowSizePercent: params.maxStableRateBorrowSizePercent,
            reservesCount: params.reservesCount,
            oracle: IPoolAddressesProvider(params.addressesProvider).getPriceOracle(),
            userEModeCategory: params.userEModeCategory,
            priceOracleSentinel: IPoolAddressesProvider(params.addressesProvider)
              .getPriceOracleSentinel()
          })
        );
        // no premium is paid when taking on the flashloan as debt
        emit FlashLoan(
          params.receiverAddress,
          msg.sender,
          vars.currentAsset,
          vars.currentAmount,
          DataTypes.InterestRateMode(params.interestRateModes[vars.i]),
          0,
          params.referralCode
        );
      }
    }
  }
  
  function executeFlashLoanSimple(
    DataTypes.ReserveData storage reserve,
    DataTypes.FlashloanSimpleParams memory params
  ) external {
    // The usual action flow (cache -> updateState -> validation -> changeState -> updateRates)
    // is altered to (validation -> user payload -> cache -> updateState -> changeState -> updateRates) for flashloans.
    // This is done to protect against reentrance and rate manipulation within the user specified payload.

    ValidationLogic.validateFlashloanSimple(reserve); // 检查储备池reserve的配置

    IFlashLoanSimpleReceiver receiver = IFlashLoanSimpleReceiver(params.receiverAddress); // 闪电贷接收代币的合约地址
    uint256 totalPremium = params.amount.percentMul(params.flashLoanPremiumTotal); // 手续费
    IAToken(reserve.aTokenAddress).transferUnderlyingTo(params.receiverAddress, params.amount); // 乐观转账

    require(
      receiver.executeOperation( // 不需要还款，但需要对aToken授权
        params.asset,
        params.amount,
        totalPremium,
        msg.sender,
        params.params
      ),
      Errors.INVALID_FLASHLOAN_EXECUTOR_RETURN
    );

    _handleFlashLoanRepayment(
      reserve,
      DataTypes.FlashLoanRepaymentParams({
        asset: params.asset, // 代币地址
        receiverAddress: params.receiverAddress, // 接受代币的合约地址
        amount: params.amount,// 代币数量
        totalPremium: totalPremium, // 手续费
        flashLoanPremiumToProtocol: params.flashLoanPremiumToProtocol, // 协议费
        referralCode: params.referralCode
      })
    );
  }

  function _handleFlashLoanRepayment(
    DataTypes.ReserveData storage reserve,
    DataTypes.FlashLoanRepaymentParams memory params
  ) internal {
    uint256 premiumToProtocol = params.totalPremium.percentMul(params.flashLoanPremiumToProtocol);
    uint256 premiumToLP = params.totalPremium - premiumToProtocol;
    uint256 amountPlusPremium = params.amount + params.totalPremium; // 协议费 + 手续费

    DataTypes.ReserveCache memory reserveCache = reserve.cache(); // 状态更新以及转移手续费
    reserve.updateState(reserveCache);
    reserveCache.nextLiquidityIndex = reserve.cumulateToLiquidityIndex(
      IERC20(reserveCache.aTokenAddress).totalSupply() +
        uint256(reserve.accruedToTreasury).rayMul(reserveCache.nextLiquidityIndex),
      premiumToLP
    );

    reserve.accruedToTreasury += premiumToProtocol
      .rayDiv(reserveCache.nextLiquidityIndex)
      .toUint128();

    // 更新利率
    reserve.updateInterestRates(reserveCache, params.asset, amountPlusPremium, 0);

    IERC20(params.asset).safeTransferFrom(
      params.receiverAddress,
      reserveCache.aTokenAddress,
      amountPlusPremium
    );

    // 闪电贷还款，需要receiverAddress对aToken授权批准
    IAToken(reserveCache.aTokenAddress).handleRepayment(
      params.receiverAddress,
      params.receiverAddress,
      amountPlusPremium
    );

    emit FlashLoan(
      params.receiverAddress,
      msg.sender,
      params.asset,
      params.amount,
      DataTypes.InterestRateMode(0),
      params.totalPremium,
      params.referralCode
    );
  }
```

分析这个方法，我们可以发现：

- 一次借多种资产，并且借什么还什么
- aave只有一个池子，因此大家都在这个pool进行存取款、闪电贷等。
- 每次都是在对应的aEthToken进行实际的借款：我们调用Pool进行闪电贷，然后去到aEthToken合约(拥有大量的Token)，然后aEthToken合约将Token借给你。
- 实际的闪电贷逻辑：`Pool`使用`transferFrom()`将aEthToken合约的Token给你，你在回调函数中完成一系列操作：
  - 如果mode=0：需要在闪电贷之前或者闪电贷的回调函数中`approve()`给Pool相应数量代币，然后在回调函数结束之后，Pool会`transferFrom()`你的代币进行还款
  - 如果mode!=0：你在使用闪电贷之前，在AAVE中质押了相应的资产，并且它们是可被抵押的、价值足够，然后在回调函数结束之后，Pool会开启一个新的债务仓位
- 不支持闪电贷ETH
- 和V2的区别不大，主要是增加了`flashLoanSimple()`

总结：

- 信息：闪电贷叫`flashLoan()`和`flashLoanSimple()`, 回调函数叫`executeOperation()`。

- 其他：固定手续费0.09%
- 使用：在使用教程中，写了3个例子。使用：输入`forge test --match-path test/AAVE_v3.sol -offline -vv`进行测试。
- 结论：在aave v3中，闪电贷的还款逻辑是数量取向

## SushiSwap

> 典型的Dex

### v2

照抄uniswap V2

可以在[这里](https://dev.sushi.com/docs/Products/Classic%20AMM/Deployment%20Addresses)找到SushiSwap在各个链部署的地址

### v3

照抄uniswap V3

可以在[这里](https://dev.sushi.com/docs/Products/V3%20AMM/Periphery/Deployment%20Addresses)找到SushiSwap在各个链部署的地址

## PancakeSwap

> 典型的Dex

### v2

照抄uniswap V2

### v3

照抄uniswap V3

## Euler

> Euler是一个模块化借贷平台，使用户能够无限制地借贷和建造

### v1

```solidity
    // 0x07df2ad9878F8797B4055230bbAE5C808b8259b3
    function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data) override external returns (bool) {
        require(markets.underlyingToEToken(token) != address(0), "e/flash-loan/unsupported-token");

        if(!_isDeferredLiquidityCheck) {
            exec.deferLiquidityCheck(address(this), abi.encode(receiver, token, amount, data, msg.sender));
            _isDeferredLiquidityCheck = false;
        } else {
            _loan(receiver, token, amount, data, msg.sender);
        }
        
        return true;
    }

    function onDeferredLiquidityCheck(bytes memory encodedData) override external {
        require(msg.sender == eulerAddress, "e/flash-loan/on-deferred-caller");
        (IERC3156FlashBorrower receiver, address token, uint amount, bytes memory data, address msgSender) =
            abi.decode(encodedData, (IERC3156FlashBorrower, address, uint, bytes, address));

        _isDeferredLiquidityCheck = true;
        _loan(receiver, token, amount, data, msgSender);

        _exitAllMarkets();
    }

    function _loan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes memory data, address msgSender) internal {
        DToken dToken = DToken(markets.underlyingToDToken(token));

        dToken.borrow(0, amount);
        Utils.safeTransfer(token, address(receiver), amount);

        require(
            receiver.onFlashLoan(msgSender, token, amount, 0, data) == CALLBACK_SUCCESS,
            "e/flash-loan/callback"
        );

        Utils.safeTransferFrom(token, address(receiver), address(this), amount);
        require(IERC20(token).balanceOf(address(this)) >= amount, 'e/flash-loan/pull-amount');

        uint allowance = IERC20(token).allowance(address(this), eulerAddress);
        if(allowance < amount) {
            (bool success,) = token.call(abi.encodeWithSelector(IERC20(token).approve.selector, eulerAddress, type(uint).max));
            require(success, "e/flash-loan/approve");
        }

        dToken.repay(0, amount);
    }
```

目前Euler已经禁止使用闪电贷了。具体哪个区块开始不可以用，可以看测试文件。目前无法使用Euler的闪电贷，但对复现以前的PoC作为学习还是很有用的。既然已经用不了了，就不做过多的分析。

使用指令进行测试：`forge test --match-path test/Euler_v1.sol -vvvv`

- Euler无需支付手续费：`receiver.onFlashLoan(msgSender, token, amount, 0, data) == CALLBACK_SUCCESS`，可惜他已经不能用了

## MakerDAO

> MakerDAO能够生成 Dai，这是世界上第一个公正的货币和领先的去中心化稳定币。

我们只讨论借DAI，借款Vat的场景太少见了

```solidity
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external override lock returns (bool) {
        require(token == address(dai), "DssFlash/token-unsupported");
        require(amount <= max, "DssFlash/ceiling-exceeded");
        require(vat.live() == 1, "DssFlash/vat-not-live");

        uint256 amt = _mul(amount, RAY);

        vat.suck(address(this), address(this), amt);
        daiJoin.exit(address(receiver), amount);

        emit FlashLoan(address(receiver), token, amount, 0);

        require(
            receiver.onFlashLoan(msg.sender, token, amount, 0, data) == CALLBACK_SUCCESS,
            "DssFlash/callback-failed"
        );

        dai.transferFrom(address(receiver), address(this), amount); // 因此我们要approve还款
        daiJoin.join(address(this), amount);
        vat.heal(amt);

        return true;
    }
```

- 只能借款DAI就很无语
- 使用approve的方式还款
- 测试：`forge test --match-path test/MakerDAO.sol -vvv`

## dYdX

> 针对专业交易者的去中心化交易所，与Uniswap属于不同的类型，闪电贷是其隐藏的功能
>



## Nuo



## Fulcrum



## DeFi Money Market



## ETHLend



## bZx



## Balancer



# Summary

- 在一种情况下，闪电贷使用者可以灵活偿还债务：token0或者token1的`banlanceOf()`是价值取向的，他会随着某些变量而变化，因此闪电贷使用者可以操纵这些变量，使得token0或者token1的价值变化来偿还债务。比如使用闪电贷之前池子中有10个token0，`balanceOf()`得出的结果是10，闪电贷过程中进行操纵，`balanceOf()`得出的结果是100（但仍然只有10个token0，只是价值变为100）
- 







