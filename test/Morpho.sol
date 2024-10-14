// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "./interface.sol";

contract Morpho is Test{
    IMorpho public morpho = IMorpho(0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb);
    IUSDT public constant USDT = IUSDT(0xdAC17F958D2ee523a2206206994597C13D831ec7); 

    function setUp() public {
        vm.createSelectFork("mainnet", 20_003_121);
        vm.label(address(morpho), "Morpho");
        vm.label(address(USDT), "USDT");
    }

    // ================================== borrow USDT, pay back USDT ==================================================   
    function test_flashloan1() public {
        emit log_named_decimal_uint("[Before] USDT Balance", USDT.balanceOf(address(this)), 6);

        uint256 amount = 1_000_000 * 1e6;
        USDT.approve(address(morpho), type(uint256).max - 1);
        morpho.flashLoan(address(USDT), amount, "");

        emit log_named_decimal_uint("[After] USDT Balance", USDT.balanceOf(address(this)), 6);
    }

    function onMorphoFlashLoan(uint256 assets, bytes memory data) external {
        // do anything you want

        emit log_named_decimal_uint("[While] USDT Balance", USDT.balanceOf(address(this)), 6);
    }

    receive() external payable{}
}