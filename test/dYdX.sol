// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interface.sol";
import {DSTest, console} from "forge-std/Test.sol";
import {DydxFlashloanBase} from "./utils.sol";

contract dYdX_test is DSTest, DydxFlashloanBase{

    ISoloMargin public dydx_pool = ISoloMargin(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);
    IWETH weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    uint256 amount_to_flashloan = 222 ether;

    struct MyCustomData {
        address token;
        uint repayAmount;
    }

    function setUp() public {
        cheats.createSelectFork("mainnet", 18_797_346);
        cheats.label(address(dydx_pool), "dydx_pool");
        cheats.label(address(weth), "weth");

        // fee: 2 wei
        weth.deposit{value: 2 wei}();
    }

    function test_flashloan() public {
        // Get marketId from token address
        /*
            0	WETH
            1	SAI
            2	USDC
            3	DAI
        */
        uint marketId = _getMarketIdFromTokenAddress(address(dydx_pool), address(weth));
        uint repayAmount = amount_to_flashloan + 2 wei;

        /*
            1. Withdraw: borrow
            2. Call callFunction(): We let dYdX to call our callback
            3. Deposit back: pay back
        */
        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

        operations[0] = _getWithdrawAction(marketId, amount_to_flashloan);
        operations[1] = _getCallAction(abi.encode(MyCustomData({token: address(weth), repayAmount: repayAmount})));
        operations[2] = _getDepositAction(marketId, repayAmount);

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        // Start to flashloan
        dydx_pool.operate(accountInfos, operations);
    }

    function callFunction(
        address sender,
        Account.Info memory,
        bytes memory data
    ) public {
        require(msg.sender == address(dydx_pool), "!dydx_pool");
        require(sender == address(this), "!this contract");

        MyCustomData memory mcd = abi.decode(data, (MyCustomData));
        uint256 repayAmount = mcd.repayAmount;

        // Do anything you want here...

        require(repayAmount == 2 wei + amount_to_flashloan, "Check the repayAmount");
        IERC20(address(weth)).approve(address(dydx_pool), repayAmount); // amount_to_flashloan + fee

    }    

}