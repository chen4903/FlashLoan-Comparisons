// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interface.sol";

contract Uniswap_V3 is Test{
    using SafeERC20 for IERC20;

    IUniswapV3Pool public constant pool = IUniswapV3Pool(0x11b815efB8f581194ae79006d24E0d814B7697F6); // pool(WETH-USDT)
    IERC20 public constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    function setUp() public {
        vm.createSelectFork("mainnet", 18763399);
        vm.label(address(pool), "Uniswap pool");
        vm.label(address(WETH), "WETH");
        vm.label(address(USDT), "USDT");

        // 我们需要借WETH，因此先准备一些WETH作为手续费
        deal(address(WETH), address(this), 1 * 1e18);
        deal(address(USDT), address(this), 1 * 1e6);

        // v3没有对外暴露获得reserve的方法，因此我们自己查：根据结果可知，池子中USDT更加值钱
        console.log("pool WETH reserve", WETH.balanceOf(address(pool)));
        console.log("pool USDT reserve", USDT.balanceOf(address(pool)));
    }

// ============================================ 借token0，还token0 =========================================================

    function test_flashloan1() public {
        emit log_named_decimal_uint("[Before] WETH Balance", WETH.balanceOf(address(this)), 18);
        console.log();

        bytes memory data = abi.encode(address(WETH), 100_000_000);
        pool.flash(address(this), 100_000_000, 0, data);

        emit log_named_decimal_uint("[After] WETH Balance", WETH.balanceOf(address(this)), 18);
    }

    function uniswapV3FlashCallback(uint256 _fee0, uint256 _fee1, bytes calldata _data) public {
        emit log_named_decimal_uint("[While] WETH Balance", WETH.balanceOf(address(this)), 18);
        console.log();

        (address toBorrow, uint256 Amount) = abi.decode(_data,(address, uint256));

        uint paybackAmountAndFee = Amount + _fee0; // V3中，pool合约在回调之前就将fee计算好了，然后传到回调函数的参数中

        IERC20(toBorrow).safeTransfer(msg.sender, paybackAmountAndFee);
    }

// ============================================ 借token0和token1，还token0和token1 =========================================================

    // function test_flashloan2() public {
    //     emit log_named_decimal_uint("[Before] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[Before] USDT Balance", USDT.balanceOf(address(this)), 6);
    //     console.log();

    //     bytes memory data = abi.encode(address(WETH), address(USDT), 100_000_000, 200_000_000);
    //     pool.flash(address(this), 100_000_000, 200_000_000, data);

    //     emit log_named_decimal_uint("[After] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[After] USDT Balance", USDT.balanceOf(address(this)), 6);
    // }

    // function uniswapV3FlashCallback(uint256 _fee0, uint256 _fee1, bytes calldata _data) public {
    //     emit log_named_decimal_uint("[While] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[While] USDT Balance", USDT.balanceOf(address(this)), 6);
    //     console.log();

    //     (address weth, address usdt, uint256 amount_weth, uint256 amount_usdt) = abi.decode(_data,(address, address, uint256, uint256));

    //     uint paybackAmountAndFee_weth = amount_weth + _fee0; 
    //     uint paybackAmountAndFee_usdt = amount_usdt + _fee1; 

    //     IERC20(weth).transfer(msg.sender, paybackAmountAndFee_weth);
    //     IERC20(usdt).safeTransfer(msg.sender, paybackAmountAndFee_usdt);
    // }
}