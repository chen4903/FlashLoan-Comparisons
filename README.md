# Brief 

Compare the common FlashLoan protocols, horizontally compare their differences, and make a demo of their usage by Foundry.

## comparisons

|                   | Chain                                                     | FlashLoan Name                | Callback Name                   | Asset kinds per FlashLoan | Pay back                                                     | Repayment indicators | Pay back obj                                           | Pay back type     |
| ----------------- | --------------------------------------------------------- | ----------------------------- | ------------------------------- | ------------------------- | ------------------------------------------------------------ | -------------------- | ------------------------------------------------------ | ----------------- |
| uniswapV2         | ETH                                                       | swap()                        | uniswapV2Call()                 | 1/2                       | 1/2 . transfer token                                         | Value(K)             | Interact with pool                                     | ERC20             |
| uniswapV3         | ETH                                                       | flash()                       | uniswapV3FlashCallback()        | 1/2                       | Pay back what you flashloan. transfer token                  | Amount               | Interact with pool                                     | ERC20             |
| AAVEV1            | ETH                                                       | flashLoan()                   | executeOperation()              | 1                         | Pay back what you flashloan. transfer token                  | Amount               | Interact with pool, but borrow from core contract      | ERC20/ETH         |
| AAVEV2            | ETH,AVAX,Polygon                                          | flashLoan()                   | executeOperation()              | 1/n                       | Pay back what you flashloan. approve token/Create a new debt positions | Amount               | Interact with pool, but borrow from aToken contract    | ERC20             |
| AAVEV3            | ETH,AVAX,Base,Arb,Fant,Op, Polygon, Gnosis,Metis,Harmony, | flashLoan()/flashLoanSimple() | two kinds of executeOperation() | 1/n                       | Pay back what you flashloan. approve token/Create a new debt positions | Amount               | Interact with pool, but borrow from aEthToken contract | ERC20             |
| SushiSwapV2       | ETH, BSC, Base, Arb, OP, Poly.....                        | swap()                        | uniswapV2Call()                 | 1/2                       | 1/2. transfer token                                          | Value(K)             | Interact with pool                                     | ERC20             |
| SushiSwapV3       | ETH, BSC, Base, Arb, OP, Poly.....                        | flash()                       | uniswapV3FlashCallback()        | 1/2                       | Pay back what you flashloan.  transfer token                 | Amount               | Interact with pool                                     | ERC20             |
| PancakeSwapV2     | BSC                                                       | swap()                        | pancakeCall()                   | 1/2                       | 1/2. transfer token                                          | Value(K)             | Interact with pool                                     | ERC20             |
| PancakeSwapV3     | BSC                                                       | flash()                       | pancakeV3FlashCallback()        | 1/2                       | Pay back what you flashloan. transfer token                  | Amount               | Interact with pool                                     | ERC20             |
| Euler             | ETH                                                       | flashLoan()                   | onFlashLoan()                   | 1                         | Pay back what you flashloan. approve token                   | Amount               | The contract itself                                    | ERC20             |
| MakerDAO          | ETH                                                       | flashLoan()                   | onFlashLoan()                   | DAI                       | Only DAI。approve DAI                                        | Amount               | The contract itself                                    | DAI               |
| dYdX              | ETH                                                       | operate()                     | callFunction()                  | 1                         | WETH/SAI/USDC/DAI                                            | Amount               | The contract itself                                    | WETH/SAI/USDC/DAI |
| bZx               | ETH, polygon                                              | flashBorrow()                 | any name defined by yourself    | 1                         | Pay back what you flashloan. transfer token                  | Amount               | iToken                                                 | ERC20             |
| Balancer          | ETH, polygon, Base, OP...                                 | flashLoan()                   | receiveFlashLoan()              | n                         | Pay back what you flashloan. transfer token                  | Amount               | The contract itself                                    | ERC20             |
| Nuo               |                                                           |                               |                                 |                           |                                                              |                      |                                                        |                   |
| Fulcrum           |                                                           |                               |                                 |                           |                                                              |                      |                                                        |                   |
| DeFi Money Market |                                                           |                               |                                 |                           |                                                              |                      |                                                        |                   |
| ETHLend           |                                                           |                               |                                 |                           |                                                              |                      |                                                        |                   |

## Uniswap

> Dex

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
        // If you want to call as flashloan, you should pay back in uniswapV2Call
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
		
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'UniswapV2: K'); // check K
        }

        _update(balance0, balance1, _reserve0, _reserve1); 
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }
```

- The `require()` only check the `K` equal or larger than before, so we have 6 strategies as long as we guarantee the `K`:
  - borrow token0, pay back token0
  - borrow token0, pay back token1
  - borrow token1, pay back token0
  - borrow token0, pay back token1
  - borrow token0, pay back token0 and token 1
  - borrow token1, pay back token0 and token 1

- fee: 0.3%

- test: `forge test --match-path test/Uniswap_V2.sol -offline -vv`

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

- fee: We don't need to calculate it by ourselves, because it will be flow to the parameters to the callback.

- test: `forge test --match-path test/Uniswap_V3.sol -offline -vv`

## AAVE

> Lending protocol

### v1

```solidity
    function flashLoan(address _receiver, address _reserve, uint256 _amount, bytes memory _params)
        public
        nonReentrant
        onlyActiveReserve(_reserve)
        onlyAmountGreaterThanZero(_amount)
    {

        // Check if AAVE Pool has enough money
        uint256 availableLiquidityBefore = _reserve == EthAddressLib.ethAddress()
            ? address(core).balance
            : IERC20(_reserve).balanceOf(address(core));

        require(
            availableLiquidityBefore >= _amount,
            "There is not enough liquidity available to borrow"
        );

        // fee
        (uint256 totalFeeBips, uint256 protocolFeeBips) = parametersProvider
            .getFlashLoanFeesInBips();
        uint256 amountFee = _amount.mul(totalFeeBips).div(10000); // 协议费：0.35%

        // If the loan amount is too small and rounding results in a handling fee of 0, 
        // it will be revert. Therefore, the amount of FlashLoan cannot be too small
        uint256 protocolFee = amountFee.mul(protocolFeeBips).div(10000); // fee of protocol：30%
        require(
            amountFee > 0 && protocolFee > 0,
            "The requested amount is too small for a flashLoan."
        );

        IFlashLoanReceiver receiver = IFlashLoanReceiver(_receiver);

        address payable userPayable = address(uint160(_receiver));

        core.transferToUser(_reserve, userPayable, _amount);

        // go to the callback
        receiver.executeOperation(_reserve, _amount, amountFee, _params);

        // check the balance
        uint256 availableLiquidityAfter = _reserve == EthAddressLib.ethAddress()
            ? address(core).balance
            : IERC20(_reserve).balanceOf(address(core));

        // The V1 version is very unfriendly。 We must calculate completely accurately, otherwise the transaction will fail
        require(
            availableLiquidityAfter == availableLiquidityBefore.add(amountFee),
            "The actual balance of the protocol is inconsistent"
        );

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

- Only one pool in AAVE v1,everyone interacts with it. But we flashloan money from core contract but not pool contract.
- When the `_reserve` is `0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE`, we will flashloan for ETH.

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

- fee: 0.35% total,30% of it is protocol fee.

- test: `forge test --match-path test/AAVE_v1.sol -offline -vv`

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

- Only one pool in AAVE v2,everyone interacts with it. And than we will flashloan from aToken contract.
- The flashloan logic: `Pool` use `transferFrom()` to send you the token from aToken contract.
  - mode = 0: you should approve to the `pool`, so `pool` can call `transferFrom()` to catch your payback.
  - mode = 0: Create a new debt positions

- Not support flashloan for ETH anymore.
- fee: 0.09%
- test: `forge test --match-path test/AAVE_v2.sol -offline -vv`

### v3

There are two flashloan in V3: one is for batchFlashloan, one is for singleFlashloan

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

execute the flashloan

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

- Only one pool in AAVE v2,everyone interacts with it. And than we will flashloan from aEthToken contract.
- The flashloan logic: `Pool` use `transferFrom()` to send you the token from aEthToken contract.
  - mode = 0: you should approve to the `pool`, so `pool` can call `transferFrom()` to catch your payback.
  - mode = 0: Create a new debt positions
- Not support flashloan for ETH anymore

- fee: 0.09%
- test: `forge test --match-path test/AAVE_v3.sol -offline -vv`

## SushiSwap

> Dex

### v2

The same as uniswap V2

[Here](https://dev.sushi.com/docs/Products/Classic%20AMM/Deployment%20Addresses) to find the all deployment contracts

### v3

The same as uniswap V3

[Here](https://dev.sushi.com/docs/Products/V3%20AMM/Periphery/Deployment%20Addresses) to find the all deployment contracts

## PancakeSwap

> Dex

### v2

The same as uniswap V2

### v3

The same as uniswap V3

## Euler

> lending protocol

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

- Currently, Euler has banned the use of flashloan. The specific block that cannot be used can be found in the test file. At present, Euler's Flash Loan cannot be used, but it is still useful for PoC as a learning tool. Since it's no longer usable, don't do too much analysis.


- test: `forge test --match-path test/Euler_v1.sol -vvvv`

- No fee: `receiver.onFlashLoan(msgSender, token, amount, 0, data) == CALLBACK_SUCCESS`

## MakerDAO

> DAI is a stablecoin token on the Ethereum blockchain whose value is kept as close to one United States dollar as possible by decentralized parties incentivized by smart contracts to perform actions that affect the token's supply and therefore its price.

WE only discuss how to flashloan for DAI here while flashloan for Vat is unnormal

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

        dai.transferFrom(address(receiver), address(this), amount); // So we need to use `approve()` to pay back
        daiJoin.join(address(this), amount);
        vat.heal(amt);

        return true;
    }
```

- We can only flashloan for DAI
- test：`forge test --match-path test/MakerDAO.sol -vvv`

## dYdX

> dYdX is the leading DeFi protocol developer for advanced trading. Flashloan is its hidden feature.

```solidity
    function operate(
        Storage.State storage state,
        Account.Info[] memory accounts,
        Actions.ActionArgs[] memory actions
    ) public {
        Events.logOperation();

        _verifyInputs(accounts, actions); 

        (
            bool[] memory primaryAccounts,
            Cache.MarketCache memory cache
        ) = _runPreprocessing(
            state,
            accounts,
            actions
        );

        _runActions( // 1. withdraw   2. go to the callback   3. deposit
            state,
            accounts,
            actions,
            cache
        );

        _verifyFinalState( // check the contract's state: it is balance in flashloan
            state,
            accounts,
            primaryAccounts,
            cache
        );
    }
```

- code

  - Go to the callback：https://etherscan.io/address/0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e#code#L5453

  - withdraw：https://etherscan.io/address/0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e#code#L4844

  - call：https://etherscan.io/address/0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e#code#L4866

  - deposit：https://etherscan.io/address/0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e#code#L4841

- We can only flashloan for: WETH, DAI, USDC, SAI 

- fee: 2 wei

- test: `forge test --match-path test/dYdX.sol -vvv`

## bZx

> lending protocol

- Flashloan entrance: https://etherscan.io/address/0xf8165b7b2b37705e4fd3e33cd9895999c3c5b529#code#L968

```solidity
    function flashBorrow(
        uint256 borrowAmount,
        address borrower,
        address target,
        string calldata signature,
        bytes calldata data)
        external
        payable
        nonReentrant
        pausable(msg.sig)
        settlesInterest
        returns (bytes memory)
    {
        require(borrowAmount != 0, "38");

        // save before balances
        uint256 beforeEtherBalance = address(this).balance.sub(msg.value);
        uint256 beforeAssetsBalance = _underlyingBalance()
            .add(totalAssetBorrow());

        // lock totalAssetSupply for duration of flash loan
        _flTotalAssetSupply = beforeAssetsBalance;

        // transfer assets to calling contract
        _safeTransfer(loanTokenAddress, borrower, borrowAmount, "39");

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        // arbitrary call: go to the ArbitraryCaller contract
        (bool success, bytes memory returnData) = arbitraryCaller.call.value(msg.value)(
            abi.encodeWithSelector(
                0xde064e0d, // sendCall(address,bytes)
                target,
                callData
            )
        );
        require(success, "call failed");

        // unlock totalAssetSupply
        _flTotalAssetSupply = 0;

        // verifies return of flash loan
        require( // No fee
            address(this).balance >= beforeEtherBalance &&
            _underlyingBalance()
                .add(totalAssetBorrow()) >= beforeAssetsBalance,
            "40"
        );

        return returnData;
    }
```

- https://etherscan.io/address/0x000F400e6818158D541C3EBE45FE3AA0d47372FF#code#L20

```solidity
contract ArbitraryCaller {
    function sendCall(
        address target,
        bytes calldata callData)
        external
        payable
    {
        (bool success,) = target.call.value(msg.value)(callData); // Execute flashloan
        assembly {
            let size := returndatasize()
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            if eq(success, 0) { revert(ptr, size) }
            return(ptr, size)
        }
    }
}
```

- fee: no fee
- The callback name can be defined by yourself.
- test: `forge test --match-path test/bZx.sol -vvv`

## Balancer

> Dex

```solidity
    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external override nonReentrant whenNotPaused {
        InputHelpers.ensureInputLengthMatch(tokens.length, amounts.length);

        uint256[] memory feeAmounts = new uint256[](tokens.length);
        uint256[] memory preLoanBalances = new uint256[](tokens.length);

        // Used to ensure `tokens` is sorted in ascending order, which ensures token uniqueness.
        IERC20 previousToken = IERC20(0);

        for (uint256 i = 0; i < tokens.length; ++i) {
            IERC20 token = tokens[i];
            uint256 amount = amounts[i];

            _require(token > previousToken, token == IERC20(0) ? Errors.ZERO_TOKEN : Errors.UNSORTED_TOKENS);
            previousToken = token;

            preLoanBalances[i] = token.balanceOf(address(this));
            feeAmounts[i] = _calculateFlashLoanFeeAmount(amount);

            _require(preLoanBalances[i] >= amount, Errors.INSUFFICIENT_FLASH_LOAN_BALANCE);
            token.safeTransfer(address(recipient), amount); // get the amount
        }

        recipient.receiveFlashLoan(tokens, amounts, feeAmounts, userData); // callback
		
		// check the state
        for (uint256 i = 0; i < tokens.length; ++i) {
            IERC20 token = tokens[i];
            uint256 preLoanBalance = preLoanBalances[i];

            // Checking for loan repayment first (without accounting for fees) makes for simpler debugging, and results
            // in more accurate revert reasons if the flash loan protocol fee percentage is zero.
            uint256 postLoanBalance = token.balanceOf(address(this));
            _require(postLoanBalance >= preLoanBalance, Errors.INVALID_POST_LOAN_BALANCE);

            // No need for checked arithmetic since we know the loan was fully repaid.
            uint256 receivedFeeAmount = postLoanBalance - preLoanBalance;
            _require(receivedFeeAmount >= feeAmounts[i], Errors.INSUFFICIENT_FLASH_LOAN_FEE_AMOUNT);

            _payFeeAmount(token, receivedFeeAmount);
            emit FlashLoan(recipient, token, amounts[i], receivedFeeAmount);
        }
    }
}
```

- fee: no fee now. (2024/04/10)

- test: `forge test --match-path test/Balancer.sol -vvv`

- [here](https://docs.balancer.fi/reference/contracts/deployment-addresses/mainnet.html#gauges-and-governance) to get the all deployment contract addresses

## Nuo



## Fulcrum



## DeFi Money Market



## ETHLend









