// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "./interface.sol";

contract bZx_test is Test{
    IbZxPool public bZx_pool = IbZxPool(0x398eC7346DcD622eDc5ae82352F02bE94C62d119);
    IWETH weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IToken public iweth = IToken(0xB983E01458529665007fF7E0CDdeCDB74B967Eb6);
    uint256 amount_to_flashloan = 1 * 1e18;  // 1 WETH

    function setUp() public {
        vm.createSelectFork("mainnet", 19624001);
        vm.label(address(bZx_pool), "bZx_pool");
        vm.label(address(weth), "weth");
        vm.label(address(iweth), "iweth");
    }

    function test_flashloan() public {
        emit log_named_decimal_uint("[Before] weth balance", weth.balanceOf(address(this)), 18);

        iweth.flashBorrow(
            amount_to_flashloan, // borrowAmount
            address(this), // borrower
            address(this), // target
            "", // signature
            // data
            abi.encodeWithSignature( 
                "ACallbackCreateBy_LEVI_104(address,address,uint256)", // callback
                weth, 
                iweth, 
                amount_to_flashloan 
            )
        );

        emit log_named_decimal_uint("[After] weth balance", weth.balanceOf(address(this)), 18);
    }

    function ACallbackCreateBy_LEVI_104(
        address token_to_flashloan,
        address iToken,
        uint256 tamount_of_flashloan
    ) external {
        emit log_named_decimal_uint("[While] weth balance", weth.balanceOf(address(this)), 18);

        // Do anything you want...

        IERC20(token_to_flashloan).transfer(iToken, tamount_of_flashloan);
    }

}