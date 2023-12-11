// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-core/contracts/interfaces/IERC20.sol';
import "./interface.sol";

contract Uniswap_V2 is Test{
    IUniswapV2Pair public constant pair = IUniswapV2Pair(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852); // pair(WETH-USDT)
    IERC20 public constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IUSDT public constant USDT = IUSDT(0xdAC17F958D2ee523a2206206994597C13D831ec7); // USDT并不是标准的ERC20

    function setUp() public {
        vm.createSelectFork("mainnet", 18_647_450);
        vm.label(address(pair), "Uniswap Pair");
        vm.label(address(WETH), "WETH");
        vm.label(address(USDT), "USDT");

        // 我们需要借，因此先准备一些钱作为手续费
        deal(address(WETH), address(this), 1 * 1e18);
        deal(address(USDT), address(this), 1 * 1e18);

        console.log("[the reserves]");
        (, uint256 token0_reserve, uint256 token1_reserve) = pair.getReserves();
        console.log("token0-WETH reserve", token0_reserve);
        console.log("token1-USDT reserve", token1_reserve);
        console.log();
    }

// ============================================ 借token0，还token0 =========================================================

    // function test_flashloan1() public {
    //     emit log_named_decimal_uint("[Before] WETH Balance", WETH.balanceOf(address(this)), WETH.decimals());

    //     bytes memory data = abi.encode(address(WETH), 100_000_000);
    //     // 我们需要借WETH，因此需要提前知道在这个池子中，token0和token1哪个是WETH，
    //     // 第一个参数：本例中token0是WETH，因此第一个参数是要借出的WETH数量，我们借1_000_000；
    //     // 第二个参数：要借的另外一个token
    //     // 第三个参数：是借给谁；
    //     // 第四个参数：是附带的data，可要可不要，如果写了，可以方便在回调函数中做相关处理，
    //     // 我们编码了附带的data，为了在回调函数中解析出借了哪个代币，借了多少
    //     pair.swap(100_000_000, 0, address(this), data);

    //     emit log_named_decimal_uint("[After] WETH Balance", WETH.balanceOf(address(this)), WETH.decimals());
    // }

    // function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external {
    //     emit log_named_decimal_uint("[While] WETH Balance", WETH.balanceOf(address(this)), WETH.decimals());

    //     // do anything you want

    //     (address whatToBorrow, uint Amount) = abi.decode(data, (address, uint));
    //     // 加上利息 0.3%
    //     uint fee = ((Amount * 3) / 997) + 1;
    //     uint paybackAmountAndFee = Amount + fee;
    //     // console.log("You borrow:", whatToBorrow);

    //     WETH.transfer(msg.sender, paybackAmountAndFee);

    // }

// ============================================== 借token0，还token1 =======================================================

    // function test_flashloan2() public {
    //     emit log_named_decimal_uint("[Before] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[Before] USDT Balance", USDT.balanceOf(address(this)), 18);
    //     console.log();

    //     bytes memory data = abi.encode(address(WETH), 100_000_000_000);
    //     pair.swap(100_000_000_000, 0, address(this), data);

    //     emit log_named_decimal_uint("[After] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[After] USDT Balance", USDT.balanceOf(address(this)), 18);
    // }

    // function uniswapV2Call(address, uint256, uint256, bytes calldata data) external {
    //     emit log_named_decimal_uint("[While] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[While] USDT Balance", USDT.balanceOf(address(this)), 18);
    //     console.log();

    //     // do anything you want

    //     (, uint256 Amount_usdt) = abi.decode(data, (address, uint256));
    //     // 我们借了100_000_000_000的WETH，而只需要还210的USDT作为手续费，
    //     // 说明了这个池子当中，USDT比较值钱（因为如果换 3/1000 的WETH，那么手续费远不止210）
    //     USDT.transfer(msg.sender, 210); 
    // }

// ============================================== 借token0和token1，还token1 =======================================================

    // function test_flashloan3() public {
    //     emit log_named_decimal_uint("[Before] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[Before] USDT Balance", USDT.balanceOf(address(this)), 18);
    //     console.log();

    //     bytes memory data = abi.encode(address(WETH), address(USDT), 100_000_000, 200_000_000);
    //     pair.swap(100_000_000, 200_000_000, address(this), data);

    //     emit log_named_decimal_uint("[After] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[After] USDT Balance", USDT.balanceOf(address(this)), 18);
    // }

    // function uniswapV2Call(address, uint256, uint256, bytes calldata data) external {
    //     emit log_named_decimal_uint("[While] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[While] USDT Balance", USDT.balanceOf(address(this)), 18);
    //     console.log();

    //     // do anything you want

    //     (, , uint256 Amount_weth, uint256 Amount_usdt) = abi.decode(data, (address, address, uint256, uint256));
    //     // 加上利息 0.3%
    //     uint256 fee_weth = ((Amount_weth * 3) / 997) + 1;
    //     uint256 fee_usdt = ((Amount_usdt * 3) / 997) + 1;
    //     uint256 paybackAmountAndFee_weth = Amount_weth + fee_weth;
    //     uint256 paybackAmountAndFee_usdt = Amount_usdt + fee_usdt;

    //     // WETH.transfer(msg.sender, paybackAmountAndFee_weth);
    //     // 我们并不需要两种代币都还手续费，只要我们交易前后的K值大于等于之前的K值，就可以通过，
    //     // 我们这里设置为还WETH 0元，还USDT手续费加上借款金额。刚刚好足够手续费
    //     // （也许是碰巧吧，USDT在本例中比较值钱，一般情况下要大于USDT手续费+借款金额）
    //     WETH.transfer(msg.sender, 0);
    //     USDT.transfer(msg.sender, paybackAmountAndFee_usdt);
    // }

// ============================================== 借token0和token1，还token0和token1 =======================================================
    // function test_flashloan4() public {
    //     emit log_named_decimal_uint("[Before] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[Before] USDT Balance", USDT.balanceOf(address(this)), 18);
    //     console.log();

    //     bytes memory data = abi.encode(address(WETH), address(USDT), 100_000_000, 200_000_000);
    //     pair.swap(100_000_000, 200_000_000, address(this), data);

    //     emit log_named_decimal_uint("[After] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[After] USDT Balance", USDT.balanceOf(address(this)), 18);
    // }

    // function uniswapV2Call(address, uint256, uint256, bytes calldata data) external {
    //     emit log_named_decimal_uint("[While] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[While] USDT Balance", USDT.balanceOf(address(this)), 18);
    //     console.log();

    //     // do anything you want

    //     (, , uint256 Amount_weth, uint256 Amount_usdt) = abi.decode(data, (address, address, uint256, uint256));
    //     // 加上利息 0.3%
    //     uint256 fee_weth = ((Amount_weth * 3) / 997) + 1;
    //     uint256 fee_usdt = ((Amount_usdt * 3) / 997) + 1;
    //     uint256 paybackAmountAndFee_weth = Amount_weth + fee_weth;
    //     uint256 paybackAmountAndFee_usdt = Amount_usdt + fee_usdt;

    //     WETH.transfer(msg.sender, 300_000_000);
    //     USDT.transfer(msg.sender, paybackAmountAndFee_usdt - 1);
    // }
}