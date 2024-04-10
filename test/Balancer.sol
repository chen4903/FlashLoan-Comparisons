// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "./interface.sol";

contract Balancere_test is Test{

    IBalancer_Vault balancer = IBalancer_Vault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    IERC20 public crv = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52); // CRV token
    uint256 amount_to_flashloan = 10 * 1e18;

    function setUp() public {
        vm.createSelectFork("mainnet", 19624001);
        vm.label(address(balancer), "balancer");
    }

    function test_flashloan() public {
        emit log_named_decimal_uint("[Before] CRV balance", crv.balanceOf(address(this)), 18);

        address[] memory assets = new address[](1);
        assets[0] = address(crv); // CRV

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount_to_flashloan ;

        balancer.flashLoan(
            address(this),
            assets,
            amounts,
            "Go to callback"
        );

        emit log_named_decimal_uint("[After] weth balance", crv.balanceOf(address(this)), 18);
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory
    ) external {
        emit log_named_decimal_uint("[While] weth balance", crv.balanceOf(address(this)), 18);

        feeAmounts; // no warning

        for (uint i = 0; i < tokens.length; i++) {
            // uint amountOwing = amounts[i] + (feeAmounts[i]);
            uint payback = amounts[i]; // No fee now
            IERC20(tokens[i]).transfer(msg.sender, payback);
        }
    }

}