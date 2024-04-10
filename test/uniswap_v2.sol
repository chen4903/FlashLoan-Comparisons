// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "./interface.sol";

contract Uniswap_V2 is Test{
    using SafeERC20 for IERC20;

    IUniswapV2Pair public constant pair = IUniswapV2Pair(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852); // pair(WETH-USDT)
    IERC20 public constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); 

    function setUp() public {
        vm.createSelectFork("mainnet", 18_647_450);
        vm.label(address(pair), "Uniswap Pair");
        vm.label(address(WETH), "WETH");
        vm.label(address(USDT), "USDT");

        // prepare for some fee
        deal(address(WETH), address(this), 1 * 1e18);
        deal(address(USDT), address(this), 1 * 1e6);

        console.log("[the reserves]");
        (, uint256 token0_reserve, uint256 token1_reserve) = pair.getReserves();
        console.log("token0-WETH reserve", token0_reserve);
        console.log("token1-USDT reserve", token1_reserve);
        console.log();
    }

// ============================================ borrow token0，pay back token0 =========================================================

    // function test_flashloan1() public {
    //     emit log_named_decimal_uint("[Before] WETH Balance", WETH.balanceOf(address(this)), 18);

    //     bytes memory data = abi.encode(address(WETH), 100_000_000);

    //     // We want to borrow WETH, so we should know which one is WETH: token0 or token1?
    //     // 1st: In this pool, WETH is token0, so the first parameter is WETH amount. We flashloan for 1_000_000
    //     // 2nd: token1
    //     // 3rd: who will receive the amount: 1_000_000
    //     // 4th: payload, optional
    //     pair.swap(100_000_000, 0, address(this), data);

    //     emit log_named_decimal_uint("[After] WETH Balance", WETH.balanceOf(address(this)), 18);
    // }

    // function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external {
    //     emit log_named_decimal_uint("[While] WETH Balance", WETH.balanceOf(address(this)), 18);

    //     // do anything you want

    //     (address whatToBorrow, uint Amount) = abi.decode(data, (address, uint));
    //     // fee: 0.3%
    //     uint fee = ((Amount * 3) / 997) + 1;
    //     uint paybackAmountAndFee = Amount + fee;
    //     // console.log("You borrow:", whatToBorrow);

    //     WETH.safeTransfer(msg.sender, paybackAmountAndFee);

    // }

// ============================================== borrow token0，pay backtoken1 =======================================================

    // function test_flashloan2() public {
    //     emit log_named_decimal_uint("[Before] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[Before] USDT Balance", USDT.balanceOf(address(this)), 6);
    //     console.log();

    //     bytes memory data = abi.encode(address(WETH), 100_000_000_000);
    //     pair.swap(100_000_000_000, 0, address(this), data);

    //     emit log_named_decimal_uint("[After] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[After] USDT Balance", USDT.balanceOf(address(this)), 6);
    // }

    // function uniswapV2Call(address, uint256, uint256, bytes calldata data) external {
    //     emit log_named_decimal_uint("[While] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[While] USDT Balance", USDT.balanceOf(address(this)), 6);
    //     console.log();

    //     // do anything you want

    //     (, uint256 Amount_usdt) = abi.decode(data, (address, uint256));
    //     USDT.safeTransfer(msg.sender, 210); 
    // }

// ============================================== borrow token0和token1，pay back token1 =======================================================

    // function test_flashloan3() public {
    //     emit log_named_decimal_uint("[Before] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[Before] USDT Balance", USDT.balanceOf(address(this)), 6);
    //     console.log();

    //     bytes memory data = abi.encode(address(WETH), address(USDT), 100_000_000, 200_000_000);
    //     pair.swap(100_000_000, 200_000_000, address(this), data);

    //     emit log_named_decimal_uint("[After] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[After] USDT Balance", USDT.balanceOf(address(this)), 6);
    // }

    // function uniswapV2Call(address, uint256, uint256, bytes calldata data) external {
    //     emit log_named_decimal_uint("[While] WETH Balance", WETH.balanceOf(address(this)), 18);
    //     emit log_named_decimal_uint("[While] USDT Balance", USDT.balanceOf(address(this)), 6);
    //     console.log();

    //     // do anything you want

    //     (, , uint256 Amount_weth, uint256 Amount_usdt) = abi.decode(data, (address, address, uint256, uint256));
    //     // fee: 0.3%
    //     uint256 fee_weth = ((Amount_weth * 3) / 997) + 1;
    //     uint256 fee_usdt = ((Amount_usdt * 3) / 997) + 1;
    //     uint256 paybackAmountAndFee_weth = Amount_weth + fee_weth;
    //     uint256 paybackAmountAndFee_usdt = Amount_usdt + fee_usdt;

    //     // WETH.transfer(msg.sender, paybackAmountAndFee_weth);
    //     // In the example, USDT is valuable. If we decrease the amount of USDT, we should increase some WETH
    //     WETH.transfer(msg.sender, 0);
    //     USDT.safeTransfer(msg.sender, paybackAmountAndFee_usdt);
    // }

// ============================================== borrow token0+token1，pay back token0+token1 =======================================================
    function test_flashloan4() public {
        emit log_named_decimal_uint("[Before] WETH Balance", WETH.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[Before] USDT Balance", USDT.balanceOf(address(this)), 6);
        console.log();

        bytes memory data = abi.encode(address(WETH), address(USDT), 100_000_000, 200_000_000);
        pair.swap(100_000_000, 200_000_000, address(this), data);

        emit log_named_decimal_uint("[After] WETH Balance", WETH.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[After] USDT Balance", USDT.balanceOf(address(this)), 6);
    }

    function uniswapV2Call(address, uint256, uint256, bytes calldata data) external {
        emit log_named_decimal_uint("[While] WETH Balance", WETH.balanceOf(address(this)), 18);
        emit log_named_decimal_uint("[While] USDT Balance", USDT.balanceOf(address(this)), 6);
        console.log();

        // do anything you want

        (, , , uint256 Amount_usdt) = abi.decode(data, (address, address, uint256, uint256));
        // fee: 0.3%
        // uint256 fee_weth = ((Amount_weth * 3) / 997) + 1;
        uint256 fee_usdt = ((Amount_usdt * 3) / 997) + 1;
        // uint256 paybackAmountAndFee_weth = Amount_weth + fee_weth;
        uint256 paybackAmountAndFee_usdt = Amount_usdt + fee_usdt;

        WETH.transfer(msg.sender, 300_000_000);
        USDT.safeTransfer(msg.sender, paybackAmountAndFee_usdt - 1);
    }

}