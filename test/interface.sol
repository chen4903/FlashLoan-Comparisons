pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IDAI {
    event Approval(address indexed src, address indexed guy, uint256 wad);
    event LogNote(
        bytes4 indexed sig,
        address indexed usr,
        bytes32 indexed arg1,
        bytes32 indexed arg2,
        bytes data
    ) anonymous;
    event Transfer(address indexed src, address indexed dst, uint256 wad);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function allowance(address, address) external view returns (uint256);

    function approve(address usr, uint256 wad) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function burn(address usr, uint256 wad) external;

    function decimals() external view returns (uint8);

    function deny(address guy) external;

    function mint(address usr, uint256 wad) external;

    function move(
        address src,
        address dst,
        uint256 wad
    ) external;

    function name() external view returns (string memory);

    function nonces(address) external view returns (uint256);

    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function pull(address usr, uint256 wad) external;

    function push(address usr, uint256 wad) external;

    function rely(address guy) external;

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function version() external view returns (string memory);

    function wards(address) external view returns (uint256);
}

interface IDssFlash_MakerDAO {
    event Deny(address indexed usr);
    event File(bytes32 indexed what, uint256 data);
    event FlashLoan(
        address indexed receiver,
        address token,
        uint256 amount,
        uint256 fee
    );
    event Rely(address indexed usr);
    event VatDaiFlashLoan(
        address indexed receiver,
        uint256 amount,
        uint256 fee
    );

    function CALLBACK_SUCCESS() external view returns (bytes32);

    function CALLBACK_SUCCESS_VAT_DAI() external view returns (bytes32);

    function dai() external view returns (address);

    function daiJoin() external view returns (address);

    function deny(address usr) external;

    function file(bytes32 what, uint256 data) external;

    function flashFee(address token, uint256 amount)
        external
        view
        returns (uint256);

    function flashLoan(
        address receiver,
        address token,
        uint256 amount,
        bytes memory data
    ) external returns (bool);

    function max() external view returns (uint256);

    function maxFlashLoan(address token) external view returns (uint256);

    function rely(address usr) external;

    function vat() external view returns (address);

    function vatDaiFlashLoan(
        address receiver,
        uint256 amount,
        bytes memory data
    ) external returns (bool);

    function wards(address) external view returns (uint256);
}

interface IEulerFlashloan {
    function CALLBACK_SUCCESS() external view returns (bytes32);

    function flashFee(address token, uint256) external view returns (uint256);

    function flashLoan(
        address receiver,
        address token,
        uint256 amount,
        bytes memory data
    ) external returns (bool);

    function maxFlashLoan(address token) external view returns (uint256);

    function onDeferredLiquidityCheck(bytes memory encodedData) external;
}

interface DataTypes {
    struct EModeCategory {
        uint16 ltv;
        uint16 liquidationThreshold;
        uint16 liquidationBonus;
        address priceSource;
        string label;
    }

    struct ReserveConfigurationMap {
        uint256 data;
    }

    struct ReserveData {
        ReserveConfigurationMap configuration;
        uint128 liquidityIndex;
        uint128 currentLiquidityRate;
        uint128 variableBorrowIndex;
        uint128 currentVariableBorrowRate;
        uint128 currentStableBorrowRate;
        uint40 lastUpdateTimestamp;
        uint16 id;
        address aTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
        address interestRateStrategyAddress;
        uint128 accruedToTreasury;
        uint128 unbacked;
        uint128 isolationModeTotalDebt;
    }

    struct UserConfigurationMap {
        uint256 data;
    }
}

interface IAAVE_V3_Pool {
    event BackUnbacked(
        address indexed reserve,
        address indexed backer,
        uint256 amount,
        uint256 fee
    );
    event Borrow(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint8 interestRateMode,
        uint256 borrowRate,
        uint16 indexed referralCode
    );
    event FlashLoan(
        address indexed target,
        address initiator,
        address indexed asset,
        uint256 amount,
        uint8 interestRateMode,
        uint256 premium,
        uint16 indexed referralCode
    );
    event IsolationModeTotalDebtUpdated(
        address indexed asset,
        uint256 totalDebt
    );
    event LiquidationCall(
        address indexed collateralAsset,
        address indexed debtAsset,
        address indexed user,
        uint256 debtToCover,
        uint256 liquidatedCollateralAmount,
        address liquidator,
        bool receiveAToken
    );
    event MintUnbacked(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint16 indexed referralCode
    );
    event MintedToTreasury(address indexed reserve, uint256 amountMinted);
    event RebalanceStableBorrowRate(
        address indexed reserve,
        address indexed user
    );
    event Repay(
        address indexed reserve,
        address indexed user,
        address indexed repayer,
        uint256 amount,
        bool useATokens
    );
    event ReserveDataUpdated(
        address indexed reserve,
        uint256 liquidityRate,
        uint256 stableBorrowRate,
        uint256 variableBorrowRate,
        uint256 liquidityIndex,
        uint256 variableBorrowIndex
    );
    event ReserveUsedAsCollateralDisabled(
        address indexed reserve,
        address indexed user
    );
    event ReserveUsedAsCollateralEnabled(
        address indexed reserve,
        address indexed user
    );
    event Supply(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint16 indexed referralCode
    );
    event SwapBorrowRateMode(
        address indexed reserve,
        address indexed user,
        uint8 interestRateMode
    );
    event UserEModeSet(address indexed user, uint8 categoryId);
    event Withdraw(
        address indexed reserve,
        address indexed user,
        address indexed to,
        uint256 amount
    );

    function ADDRESSES_PROVIDER() external view returns (address);

    function BRIDGE_PROTOCOL_FEE() external view returns (uint256);

    function FLASHLOAN_PREMIUM_TOTAL() external view returns (uint128);

    function FLASHLOAN_PREMIUM_TO_PROTOCOL() external view returns (uint128);

    function MAX_NUMBER_RESERVES() external view returns (uint16);

    function MAX_STABLE_RATE_BORROW_SIZE_PERCENT()
        external
        view
        returns (uint256);

    function POOL_REVISION() external view returns (uint256);

    function backUnbacked(
        address asset,
        uint256 amount,
        uint256 fee
    ) external returns (uint256);

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function configureEModeCategory(
        uint8 id,
        DataTypes.EModeCategory memory category
    ) external;

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function dropReserve(address asset) external;

    function finalizeTransfer(
        address asset,
        address from,
        address to,
        uint256 amount,
        uint256 balanceFromBefore,
        uint256 balanceToBefore
    ) external;

    function flashLoan(
        address receiverAddress,
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory interestRateModes,
        address onBehalfOf,
        bytes memory params,
        uint16 referralCode
    ) external;

    function flashLoanSimple(
        address receiverAddress,
        address asset,
        uint256 amount,
        bytes memory params,
        uint16 referralCode
    ) external;

    function getConfiguration(address asset)
        external
        view
        returns (DataTypes.ReserveConfigurationMap memory);

    function getEModeCategoryData(uint8 id)
        external
        view
        returns (DataTypes.EModeCategory memory);

    function getReserveAddressById(uint16 id) external view returns (address);

    function getReserveData(address asset)
        external
        view
        returns (DataTypes.ReserveData memory);

    function getReserveNormalizedIncome(address asset)
        external
        view
        returns (uint256);

    function getReserveNormalizedVariableDebt(address asset)
        external
        view
        returns (uint256);

    function getReservesList() external view returns (address[] memory);

    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );

    function getUserConfiguration(address user)
        external
        view
        returns (DataTypes.UserConfigurationMap memory);

    function getUserEMode(address user) external view returns (uint256);

    function initReserve(
        address asset,
        address aTokenAddress,
        address stableDebtAddress,
        address variableDebtAddress,
        address interestRateStrategyAddress
    ) external;

    function initialize(address provider) external;

    function liquidationCall(
        address collateralAsset,
        address debtAsset,
        address user,
        uint256 debtToCover,
        bool receiveAToken
    ) external;

    function mintToTreasury(address[] memory assets) external;

    function mintUnbacked(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function rebalanceStableBorrowRate(address asset, address user) external;

    function repay(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        address onBehalfOf
    ) external returns (uint256);

    function repayWithATokens(
        address asset,
        uint256 amount,
        uint256 interestRateMode
    ) external returns (uint256);

    function repayWithPermit(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        address onBehalfOf,
        uint256 deadline,
        uint8 permitV,
        bytes32 permitR,
        bytes32 permitS
    ) external returns (uint256);

    function rescueTokens(
        address token,
        address to,
        uint256 amount
    ) external;

    function resetIsolationModeTotalDebt(address asset) external;

    function setConfiguration(
        address asset,
        DataTypes.ReserveConfigurationMap memory configuration
    ) external;

    function setReserveInterestRateStrategyAddress(
        address asset,
        address rateStrategyAddress
    ) external;

    function setUserEMode(uint8 categoryId) external;

    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral)
        external;

    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function supplyWithPermit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode,
        uint256 deadline,
        uint8 permitV,
        bytes32 permitR,
        bytes32 permitS
    ) external;

    function swapBorrowRateMode(address asset, uint256 interestRateMode)
        external;

    function updateBridgeProtocolFee(uint256 protocolFee) external;

    function updateFlashloanPremiums(
        uint128 flashLoanPremiumTotal,
        uint128 flashLoanPremiumToProtocol
    ) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

interface IAAVE_V2_LendingPool {
    event Borrow(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint256 borrowRateMode,
        uint256 borrowRate,
        uint16 indexed referral
    );
    event Deposit(
        address indexed reserve,
        address user,
        address indexed onBehalfOf,
        uint256 amount,
        uint16 indexed referral
    );
    event FlashLoan(
        address indexed target,
        address indexed initiator,
        address indexed asset,
        uint256 amount,
        uint256 premium,
        uint16 referralCode
    );
    event LiquidationCall(
        address indexed collateralAsset,
        address indexed debtAsset,
        address indexed user,
        uint256 debtToCover,
        uint256 liquidatedCollateralAmount,
        address liquidator,
        bool receiveAToken
    );
    event Paused();
    event RebalanceStableBorrowRate(
        address indexed reserve,
        address indexed user
    );
    event Repay(
        address indexed reserve,
        address indexed user,
        address indexed repayer,
        uint256 amount
    );
    event ReserveDataUpdated(
        address indexed reserve,
        uint256 liquidityRate,
        uint256 stableBorrowRate,
        uint256 variableBorrowRate,
        uint256 liquidityIndex,
        uint256 variableBorrowIndex
    );
    event ReserveUsedAsCollateralDisabled(
        address indexed reserve,
        address indexed user
    );
    event ReserveUsedAsCollateralEnabled(
        address indexed reserve,
        address indexed user
    );
    event Swap(address indexed reserve, address indexed user, uint256 rateMode);
    event TokensRescued(
        address indexed tokenRescued,
        address indexed receiver,
        uint256 amountRescued
    );
    event Unpaused();
    event Withdraw(
        address indexed reserve,
        address indexed user,
        address indexed to,
        uint256 amount
    );

    function FLASHLOAN_PREMIUM_TOTAL() external view returns (uint256);

    function LENDINGPOOL_REVISION() external view returns (uint256);

    function MAX_NUMBER_RESERVES() external view returns (uint256);

    function MAX_STABLE_RATE_BORROW_SIZE_PERCENT()
        external
        view
        returns (uint256);

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function finalizeTransfer(
        address asset,
        address from,
        address to,
        uint256 amount,
        uint256 balanceFromBefore,
        uint256 balanceToBefore
    ) external;

    function flashLoan(
        address receiverAddress,
        address[] memory assets,
        uint256[] memory amounts,
        uint256[] memory modes,
        address onBehalfOf,
        bytes memory params,
        uint16 referralCode
    ) external;

    function getAddressesProvider() external view returns (address);

    function getConfiguration(address asset)
        external
        view
        returns (DataTypes.ReserveConfigurationMap memory);

    function getReserveData(address asset)
        external
        view
        returns (DataTypes.ReserveData memory);

    function getReserveNormalizedIncome(address asset)
        external
        view
        returns (uint256);

    function getReserveNormalizedVariableDebt(address asset)
        external
        view
        returns (uint256);

    function getReservesList() external view returns (address[] memory);

    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );

    function getUserConfiguration(address user)
        external
        view
        returns (DataTypes.UserConfigurationMap memory);

    function initReserve(
        address asset,
        address aTokenAddress,
        address stableDebtAddress,
        address variableDebtAddress,
        address interestRateStrategyAddress
    ) external;

    function initialize(address provider) external;

    function liquidationCall(
        address collateralAsset,
        address debtAsset,
        address user,
        uint256 debtToCover,
        bool receiveAToken
    ) external;

    function paused() external view returns (bool);

    function rebalanceStableBorrowRate(address asset, address user) external;

    function repay(
        address asset,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external returns (uint256);

    function rescueTokens(
        address token,
        address to,
        uint256 amount
    ) external;

    function setConfiguration(address asset, uint256 configuration) external;

    function setPause(bool val) external;

    function setReserveInterestRateStrategyAddress(
        address asset,
        address rateStrategyAddress
    ) external;

    function setUserUseReserveAsCollateral(address asset, bool useAsCollateral)
        external;

    function swapBorrowRateMode(address asset, uint256 rateMode) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

interface ILendingPoolCore{}

interface ILendingPoolParametersProvider {
    function getFlashLoanFeesInBips() external pure returns (uint256, uint256);

    function getMaxStableRateBorrowSizePercent()
        external
        pure
        returns (uint256);

    function getRebalanceDownRateDelta() external pure returns (uint256);

    function initialize(address _addressesProvider) external;
}

interface IAAVE_V1_LendingPool {
    event Borrow(
        address indexed _reserve,
        address indexed _user,
        uint256 _amount,
        uint256 _borrowRateMode,
        uint256 _borrowRate,
        uint256 _originationFee,
        uint256 _borrowBalanceIncrease,
        uint16 indexed _referral,
        uint256 _timestamp
    );
    event Deposit(
        address indexed _reserve,
        address indexed _user,
        uint256 _amount,
        uint16 indexed _referral,
        uint256 _timestamp
    );
    event FlashLoan(
        address indexed _target,
        address indexed _reserve,
        uint256 _amount,
        uint256 _totalFee,
        uint256 _protocolFee,
        uint256 _timestamp
    );
    event LiquidationCall(
        address indexed _collateral,
        address indexed _reserve,
        address indexed _user,
        uint256 _purchaseAmount,
        uint256 _liquidatedCollateralAmount,
        uint256 _accruedBorrowInterest,
        address _liquidator,
        bool _receiveAToken,
        uint256 _timestamp
    );
    event OriginationFeeLiquidated(
        address indexed _collateral,
        address indexed _reserve,
        address indexed _user,
        uint256 _feeLiquidated,
        uint256 _liquidatedCollateralForFee,
        uint256 _timestamp
    );
    event RebalanceStableBorrowRate(
        address indexed _reserve,
        address indexed _user,
        uint256 _newStableRate,
        uint256 _borrowBalanceIncrease,
        uint256 _timestamp
    );
    event RedeemUnderlying(
        address indexed _reserve,
        address indexed _user,
        uint256 _amount,
        uint256 _timestamp
    );
    event Repay(
        address indexed _reserve,
        address indexed _user,
        address indexed _repayer,
        uint256 _amountMinusFees,
        uint256 _fees,
        uint256 _borrowBalanceIncrease,
        uint256 _timestamp
    );
    event ReserveUsedAsCollateralDisabled(
        address indexed _reserve,
        address indexed _user
    );
    event ReserveUsedAsCollateralEnabled(
        address indexed _reserve,
        address indexed _user
    );
    event Swap(
        address indexed _reserve,
        address indexed _user,
        uint256 _newRateMode,
        uint256 _newRate,
        uint256 _borrowBalanceIncrease,
        uint256 _timestamp
    );
    event TokensRescued(
        address indexed tokenRescued,
        address indexed receiver,
        uint256 amountRescued
    );

    function LENDINGPOOL_REVISION() external view returns (uint256);

    function UINT_MAX_VALUE() external view returns (uint256);

    function addressesProvider() external view returns (address);

    function borrow(
        address _reserve,
        uint256 _amount,
        uint256 _interestRateMode,
        uint16 _referralCode
    ) external;

    function core() external view returns (address);

    function dataProvider() external view returns (address);

    function deposit(
        address _reserve,
        uint256 _amount,
        uint16 _referralCode
    ) external payable;

    function flashLoan(
        address _receiver,
        address _reserve,
        uint256 _amount,
        bytes memory _params
    ) external;

    function getReserveConfigurationData(address _reserve)
        external
        view
        returns (
            uint256 ltv,
            uint256 liquidationThreshold,
            uint256 liquidationBonus,
            address interestRateStrategyAddress,
            bool usageAsCollateralEnabled,
            bool borrowingEnabled,
            bool stableBorrowRateEnabled,
            bool isActive
        );

    function getReserveData(address _reserve)
        external
        view
        returns (
            uint256 totalLiquidity,
            uint256 availableLiquidity,
            uint256 totalBorrowsStable,
            uint256 totalBorrowsVariable,
            uint256 liquidityRate,
            uint256 variableBorrowRate,
            uint256 stableBorrowRate,
            uint256 averageStableBorrowRate,
            uint256 utilizationRate,
            uint256 liquidityIndex,
            uint256 variableBorrowIndex,
            address aTokenAddress,
            uint40 lastUpdateTimestamp
        );

    function getReserves() external view returns (address[] memory);

    function getUserAccountData(address _user)
        external
        view
        returns (
            uint256 totalLiquidityETH,
            uint256 totalCollateralETH,
            uint256 totalBorrowsETH,
            uint256 totalFeesETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );

    function getUserReserveData(address _reserve, address _user)
        external
        view
        returns (
            uint256 currentATokenBalance,
            uint256 currentBorrowBalance,
            uint256 principalBorrowBalance,
            uint256 borrowRateMode,
            uint256 borrowRate,
            uint256 liquidityRate,
            uint256 originationFee,
            uint256 variableBorrowIndex,
            uint256 lastUpdateTimestamp,
            bool usageAsCollateralEnabled
        );

    function initialize(address _addressesProvider) external;

    function liquidationCall(
        address _collateral,
        address _reserve,
        address _user,
        uint256 _purchaseAmount,
        bool _receiveAToken
    ) external payable;

    function parametersProvider() external view returns (address);

    function rebalanceStableBorrowRate(address _reserve, address _user)
        external;

    function redeemUnderlying(
        address _reserve,
        address _user,
        uint256 _amount,
        uint256 _aTokenBalanceAfterRedeem
    ) external;

    function repay(
        address _reserve,
        uint256 _amount,
        address _onBehalfOf
    ) external payable;

    function rescueTokens(
        address token,
        address to,
        uint256 amount
    ) external;

    function setUserUseReserveAsCollateral(
        address _reserve,
        bool _useAsCollateral
    ) external;

    function swapBorrowRateMode(address _reserve) external;
}

library Actions {
  enum ActionType {
    Deposit, // supply tokens
    Withdraw, // borrow tokens
    Transfer, // transfer balance between accounts
    Buy, // buy an amount of some token (publicly)
    Sell, // sell an amount of some token (publicly)
    Trade, // trade tokens against another account
    Liquidate, // liquidate an undercollateralized or expiring account
    Vaporize, // use excess tokens to zero-out a completely negative account
    Call // send arbitrary data to an address
  }

  enum AccountLayout {
    OnePrimary,
    TwoPrimary,
    PrimaryAndSecondary
  }

  enum MarketLayout {
    ZeroMarkets,
    OneMarket,
    TwoMarkets
  }

  struct ActionArgs {
    ActionType actionType;
    uint accountId;
    Types.AssetAmount amount;
    uint primaryMarketId;
    uint secondaryMarketId;
    address otherAddress;
    uint otherAccountId;
    bytes data;
  }

  struct DepositArgs {
    Types.AssetAmount amount;
    Account.Info account;
    uint market;
    address from;
  }

  struct WithdrawArgs {
    Types.AssetAmount amount;
    Account.Info account;
    uint market;
    address to;
  }

  struct TransferArgs {
    Types.AssetAmount amount;
    Account.Info accountOne;
    Account.Info accountTwo;
    uint market;
  }

  struct BuyArgs {
    Types.AssetAmount amount;
    Account.Info account;
    uint makerMarket;
    uint takerMarket;
    address exchangeWrapper;
    bytes orderData;
  }

  struct SellArgs {
    Types.AssetAmount amount;
    Account.Info account;
    uint takerMarket;
    uint makerMarket;
    address exchangeWrapper;
    bytes orderData;
  }

  struct TradeArgs {
    Types.AssetAmount amount;
    Account.Info takerAccount;
    Account.Info makerAccount;
    uint inputMarket;
    uint outputMarket;
    address autoTrader;
    bytes tradeData;
  }

  struct LiquidateArgs {
    Types.AssetAmount amount;
    Account.Info solidAccount;
    Account.Info liquidAccount;
    uint owedMarket;
    uint heldMarket;
  }

  struct VaporizeArgs {
    Types.AssetAmount amount;
    Account.Info solidAccount;
    Account.Info vaporAccount;
    uint owedMarket;
    uint heldMarket;
  }

  struct CallArgs {
    Account.Info account;
    address callee;
    bytes data;
  }
}

library Decimal {
  struct D256 {
    uint value;
  }
}

library Interest {
  struct Rate {
    uint value;
  }

  struct Index {
    uint96 borrow;
    uint96 supply;
    uint32 lastUpdate;
  }
}

library Monetary {
  struct Price {
    uint value;
  }
  struct Value {
    uint value;
  }
}

library Storage {
  // All information necessary for tracking a market
  struct Market {
    // Contract address of the associated ERC20 token
    address token;
    // Total aggregated supply and borrow amount of the entire market
    Types.TotalPar totalPar;
    // Interest index of the market
    Interest.Index index;
    // Contract address of the price oracle for this market
    address priceOracle;
    // Contract address of the interest setter for this market
    address interestSetter;
    // Multiplier on the marginRatio for this market
    Decimal.D256 marginPremium;
    // Multiplier on the liquidationSpread for this market
    Decimal.D256 spreadPremium;
    // Whether additional borrows are allowed for this market
    bool isClosing;
  }

  // The global risk parameters that govern the health and security of the system
  struct RiskParams {
    // Required ratio of over-collateralization
    Decimal.D256 marginRatio;
    // Percentage penalty incurred by liquidated accounts
    Decimal.D256 liquidationSpread;
    // Percentage of the borrower's interest fee that gets passed to the suppliers
    Decimal.D256 earningsRate;
    // The minimum absolute borrow value of an account
    // There must be sufficient incentivize to liquidate undercollateralized accounts
    Monetary.Value minBorrowedValue;
  }

  // The maximum RiskParam values that can be set
  struct RiskLimits {
    uint64 marginRatioMax;
    uint64 liquidationSpreadMax;
    uint64 earningsRateMax;
    uint64 marginPremiumMax;
    uint64 spreadPremiumMax;
    uint128 minBorrowedValueMax;
  }

  // The entire storage state of Solo
  struct State {
    // number of markets
    uint numMarkets;
    // marketId => Market
    mapping(uint => Market) markets;
    // owner => account number => Account
    mapping(address => mapping(uint => Account.accStorage)) accounts;
    // Addresses that can control other users accounts
    mapping(address => mapping(address => bool)) operators;
    // Addresses that can control all users accounts
    mapping(address => bool) globalOperators;
    // mutable risk parameters of the system
    RiskParams riskParams;
    // immutable risk limits of the system
    RiskLimits riskLimits;
  }
}

library Types {
  enum AssetDenomination {
    Wei, // the amount is denominated in wei
    Par // the amount is denominated in par
  }

  enum AssetReference {
    Delta, // the amount is given as a delta from the current value
    Target // the amount is given as an exact number to end up at
  }

  struct AssetAmount {
    bool sign; // true if positive
    AssetDenomination denomination;
    AssetReference ref;
    uint value;
  }

  struct TotalPar {
    uint128 borrow;
    uint128 supply;
  }

  struct Par {
    bool sign; // true if positive
    uint128 value;
  }

  struct Wei {
    bool sign; // true if positive
    uint value;
  }
}

interface ISoloMargin {
  struct OperatorArg {
    address operator;
    bool trusted;
  }

  function ownerSetSpreadPremium(uint marketId, Decimal.D256 calldata spreadPremium)
    external;

  function getIsGlobalOperator(address operator) external view returns (bool);

  function getMarketTokenAddress(uint marketId) external view returns (address);

  function ownerSetInterestSetter(uint marketId, address interestSetter) external;

  function getAccountValues(Account.Info calldata account)
    external
    view
    returns (Monetary.Value memory, Monetary.Value memory);

  function getMarketPriceOracle(uint marketId) external view returns (address);

  function getMarketInterestSetter(uint marketId) external view returns (address);

  function getMarketSpreadPremium(uint marketId)
    external
    view
    returns (Decimal.D256 memory);

  function getNumMarkets() external view returns (uint);

  function ownerWithdrawUnsupportedTokens(address token, address recipient)
    external
    returns (uint);

  function ownerSetMinBorrowedValue(Monetary.Value calldata minBorrowedValue) external;

  function ownerSetLiquidationSpread(Decimal.D256 calldata spread) external;

  function ownerSetEarningsRate(Decimal.D256 calldata earningsRate) external;

  function getIsLocalOperator(address _owner, address operator)
    external
    view
    returns (bool);

  function getAccountPar(Account.Info calldata account, uint marketId)
    external
    view
    returns (Types.Par memory);

  function ownerSetMarginPremium(uint marketId, Decimal.D256 calldata marginPremium)
    external;

  function getMarginRatio() external view returns (Decimal.D256 memory);

  function getMarketCurrentIndex(uint marketId)
    external
    view
    returns (Interest.Index memory);

  function getMarketIsClosing(uint marketId) external view returns (bool);

  function getRiskParams() external view returns (Storage.RiskParams memory);

  function getAccountBalances(Account.Info calldata account)
    external
    view
    returns (
      address[] memory,
      Types.Par[] memory,
      Types.Wei[] memory
    );

  function renounceOwnership() external;

  function getMinBorrowedValue() external view returns (Monetary.Value memory);

  function setOperators(OperatorArg[] calldata args) external;

  function getMarketPrice(uint marketId) external view returns (address);

  function owner() external view returns (address);

  function isOwner() external view returns (bool);

  function ownerWithdrawExcessTokens(uint marketId, address recipient)
    external
    returns (uint);

  function ownerAddMarket(
    address token,
    address priceOracle,
    address interestSetter,
    Decimal.D256 calldata marginPremium,
    Decimal.D256 calldata spreadPremium
  ) external;

  function operate(
    Account.Info[] calldata accounts,
    Actions.ActionArgs[] calldata actions
  ) external;

  function getMarketWithInfo(uint marketId)
    external
    view
    returns (
      Storage.Market memory,
      Interest.Index memory,
      Monetary.Price memory,
      Interest.Rate memory
    );

  function ownerSetMarginRatio(Decimal.D256 calldata ratio) external;

  function getLiquidationSpread() external view returns (Decimal.D256 memory);

  function getAccountWei(Account.Info calldata account, uint marketId)
    external
    view
    returns (Types.Wei memory);

  function getMarketTotalPar(uint marketId)
    external
    view
    returns (Types.TotalPar memory);

  function getLiquidationSpreadForPair(uint heldMarketId, uint owedMarketId)
    external
    view
    returns (Decimal.D256 memory);

  function getNumExcessTokens(uint marketId) external view returns (Types.Wei memory);

  function getMarketCachedIndex(uint marketId)
    external
    view
    returns (Interest.Index memory);

  function getAccountStatus(Account.Info calldata account)
    external
    view
    returns (uint8);

  function getEarningsRate() external view returns (Decimal.D256 memory);

  function ownerSetPriceOracle(uint marketId, address priceOracle) external;

  function getRiskLimits() external view returns (Storage.RiskLimits memory);

  function getMarket(uint marketId) external view returns (Storage.Market memory);

  function ownerSetIsClosing(uint marketId, bool isClosing) external;

  function ownerSetGlobalOperator(address operator, bool approved) external;

  function transferOwnership(address newOwner) external;

  function getAdjustedAccountValues(Account.Info calldata account)
    external
    view
    returns (Monetary.Value memory, Monetary.Value memory);

  function getMarketMarginPremium(uint marketId)
    external
    view
    returns (Decimal.D256 memory);

  function getMarketInterestRate(uint marketId)
    external
    view
    returns (Interest.Rate memory);
}

library Account {
  enum Status {
    Normal,
    Liquid,
    Vapor
  }
  struct Info {
    address owner; // The address that owns the account
    uint number; // A nonce that allows a single address to control many accounts
  }
  struct accStorage {
    mapping(uint => Types.Par) balances; // Mapping from marketId to principal
    Status status;
  }
}

interface CheatCodes {
    // This allows us to getRecordedLogs()
    struct Log {
        bytes32[] topics;
        bytes data;
    }
    // Set block.timestamp (newTimestamp)

    function warp(uint256) external;
    // Set block.height (newHeight)
    function roll(uint256) external;
    // Set block.basefee (newBasefee)
    function fee(uint256) external;
    // Set block.coinbase (who)
    function coinbase(address) external;
    // Loads a storage slot from an address (who, slot)
    function load(address, bytes32) external returns (bytes32);
    // Stores a value to an address' storage slot, (who, slot, value)
    function store(address, bytes32, bytes32) external;
    // Signs data, (privateKey, digest) => (v, r, s)
    function sign(uint256, bytes32) external returns (uint8, bytes32, bytes32);
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
    // Derive a private key from a provided mnenomic string (or mnenomic file path) at the derivation path m/44'/60'/0'/0/{index}
    function deriveKey(string calldata, uint32) external returns (uint256);
    // Derive a private key from a provided mnenomic string (or mnenomic file path) at the derivation path {path}{index}
    function deriveKey(string calldata, string calldata, uint32) external returns (uint256);
    // Performs a foreign function call via terminal, (stringInputs) => (result)
    function ffi(string[] calldata) external returns (bytes memory);
    // Set environment variables, (name, value)
    function setEnv(string calldata, string calldata) external;
    // Read environment variables, (name) => (value)
    function envBool(string calldata) external returns (bool);
    function envUint(string calldata) external returns (uint256);
    function envInt(string calldata) external returns (int256);
    function envAddress(string calldata) external returns (address);
    function envBytes32(string calldata) external returns (bytes32);
    function envString(string calldata) external returns (string memory);
    function envBytes(string calldata) external returns (bytes memory);
    // Read environment variables as arrays, (name, delim) => (value[])
    function envBool(string calldata, string calldata) external returns (bool[] memory);
    function envUint(string calldata, string calldata) external returns (uint256[] memory);
    function envInt(string calldata, string calldata) external returns (int256[] memory);
    function envAddress(string calldata, string calldata) external returns (address[] memory);
    function envBytes32(string calldata, string calldata) external returns (bytes32[] memory);
    function envString(string calldata, string calldata) external returns (string[] memory);
    function envBytes(string calldata, string calldata) external returns (bytes[] memory);
    // Sets the *next* call's msg.sender to be the input address
    function prank(address) external;
    // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
    function startPrank(address) external;
    // Sets the *next* call's msg.sender to be the input address, and the tx.origin to be the second input
    function prank(address, address) external;
    // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called, and the tx.origin to be the second input
    function startPrank(address, address) external;
    // Resets subsequent calls' msg.sender to be `address(this)`
    function stopPrank() external;
    // Sets an address' balance, (who, newBalance)
    function deal(address, uint256) external;
    // Sets an address' code, (who, newCode)
    function etch(address, bytes calldata) external;
    // Expects an error on next call
    function expectRevert() external;
    function expectRevert(bytes calldata) external;
    function expectRevert(bytes4) external;
    // Record all storage reads and writes
    function record() external;
    // Gets all accessed reads and write slot from a recording session, for a given address
    function accesses(address) external returns (bytes32[] memory reads, bytes32[] memory writes);
    // Record all the transaction logs
    function recordLogs() external;
    // Gets all the recorded logs
    function getRecordedLogs() external returns (Log[] memory);
    // Prepare an expected log with (bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData).
    // Call this function, then emit an event, then call a function. Internally after the call, we check if
    // logs were emitted in the expected order with the expected topics and data (as specified by the booleans).
    // Second form also checks supplied address against emitting contract.
    function expectEmit(bool, bool, bool, bool) external;
    function expectEmit(bool, bool, bool, bool, address) external;
    // Mocks a call to an address, returning specified data.
    // Calldata can either be strict or a partial match, e.g. if you only
    // pass a Solidity selector to the expected calldata, then the entire Solidity
    // function will be mocked.
    function mockCall(address, bytes calldata, bytes calldata) external;
    // Mocks a call to an address with a specific msg.value, returning specified data.
    // Calldata match takes precedence over msg.value in case of ambiguity.
    function mockCall(address, uint256, bytes calldata, bytes calldata) external;
    // Clears all mocked calls
    function clearMockedCalls() external;
    // Expect a call to an address with the specified calldata.
    // Calldata can either be strict or a partial match
    function expectCall(address, bytes calldata) external;
    // Expect a call to an address with the specified msg.value and calldata
    function expectCall(address, uint256, bytes calldata) external;
    // Gets the code from an artifact file. Takes in the relative path to the json file
    function getCode(string calldata) external returns (bytes memory);
    // Labels an address in call traces
    function label(address, string calldata) external;
    // If the condition is false, discard this run's fuzz inputs and generate new ones
    function assume(bool) external;
    // Set nonce for an account
    function setNonce(address, uint64) external;
    // Get nonce for an account
    function getNonce(address) external returns (uint64);
    // Set block.chainid (newChainId)
    function chainId(uint256) external;
    // Using the address that calls the test contract, has the next call (at this call depth only) create a transaction that can later be signed and sent onchain
    function broadcast() external;
    // Has the next call (at this call depth only) create a transaction with the address provided as the sender that can later be signed and sent onchain
    function broadcast(address) external;
    // Using the address that calls the test contract, has the all subsequent calls (at this call depth only) create transactions that can later be signed and sent onchain
    function startBroadcast() external;
    // Has the all subsequent calls (at this call depth only) create transactions that can later be signed and sent onchain
    function startBroadcast(address) external;
    // Stops collecting onchain transactions
    function stopBroadcast() external;
    // Reads the entire content of file to string. Path is relative to the project root. (path) => (data)
    function readFile(string calldata) external returns (string memory);
    // Reads next line of file to string, (path) => (line)
    function readLine(string calldata) external returns (string memory);
    // Writes data to file, creating a file if it does not exist, and entirely replacing its contents if it does.
    // Path is relative to the project root. (path, data) => ()
    function writeFile(string calldata, string calldata) external;
    // Writes line to file, creating a file if it does not exist.
    // Path is relative to the project root. (path, data) => ()
    function writeLine(string calldata, string calldata) external;
    // Closes file for reading, resetting the offset and allowing to read it from beginning with readLine.
    // Path is relative to the project root. (path) => ()
    function closeFile(string calldata) external;
    // Removes file. This cheatcode will revert in the following situations, but is not limited to just these cases:
    // - Path points to a directory.
    // - The file doesn't exist.
    // - The user lacks permissions to remove the file.
    // Path is relative to the project root. (path) => ()
    function removeFile(string calldata) external;

    function toString(address) external returns (string memory);
    function toString(bytes calldata) external returns (string memory);
    function toString(bytes32) external returns (string memory);
    function toString(bool) external returns (string memory);
    function toString(uint256) external returns (string memory);
    function toString(int256) external returns (string memory);
    // Snapshot the current state of the evm.
    // Returns the id of the snapshot that was created.
    // To revert a snapshot use `revertTo`
    function snapshot() external returns (uint256);
    // Revert the state of the evm to a previous snapshot
    // Takes the snapshot id to revert to.
    // This deletes the snapshot and all snapshots taken after the given snapshot id.
    function revertTo(uint256) external returns (bool);
    // Creates a new fork with the given endpoint and block and returns the identifier of the fork
    function createFork(string calldata, uint256) external returns (uint256);
    // Creates a new fork with the given endpoint and the _latest_ block and returns the identifier of the fork
    function createFork(string calldata) external returns (uint256);
    // Creates _and_ also selects a new fork with the given endpoint and block and returns the identifier of the fork
    function createSelectFork(string calldata, uint256) external returns (uint256);
    // Creates _and_ also selects a new fork with the given endpoint and the latest block and returns the identifier of the fork
    function createSelectFork(string calldata) external returns (uint256);
    // Takes a fork identifier created by `createFork` and sets the corresponding forked state as active.
    function selectFork(uint256) external;
    /// Returns the currently active fork
    /// Reverts if no fork is currently active
    function activeFork() external returns (uint256);
    // Updates the currently active fork to given block number
    // This is similar to `roll` but for the currently active fork
    function rollFork(uint256) external;
    // Updates the given fork to given block number
    function rollFork(uint256 forkId, uint256 blockNumber) external;
    /// Returns the RPC url for the given alias
    function rpcUrl(string calldata) external returns (string memory);
    /// Returns all rpc urls and their aliases `[alias, url][]`
    function rpcUrls() external returns (string[2][] memory);
    function makePersistent(address account) external;
}

interface IWETH {
    function name() external view returns (string memory);

    function approve(address guy, uint256 wad) external returns (bool);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function withdraw(uint256 wad) external;

    function decimals() external view returns (uint8);

    function balanceOf(address) external view returns (uint256);

    function symbol() external view returns (string memory);

    function transfer(address dst, uint256 wad) external returns (bool);

    function deposit() external payable;

    function allowance(address, address) external view returns (uint256);

    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}