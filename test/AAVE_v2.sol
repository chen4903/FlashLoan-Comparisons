// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "./interface.sol";

contract AAVE_v2 is Test{
    using SafeERC20 for IERC20;

    // 交互的池子
    IAAVE_V2_LendingPool public constant Lending_pool = IAAVE_V2_LendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    IERC20 public constant usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); 
    IERC20 public constant wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    address public constant aUSDT = 0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811;
    address public constant awbtc = 0x9ff58f4fFB29fA2266Ab25e75e2A8b3503311656;

    function setUp() public {
        vm.createSelectFork("mainnet", 18_811_540);
        vm.label(address(Lending_pool), "Lending Pool");
        vm.label(address(usdt), "usdt");

        // 我们需要借，因此先准备一些钱作为手续费。
        deal(address(usdt), address(this), 100_000 * 1e6);
        deal(address(wbtc), address(this), 100 * 1e8);
        emit log_named_decimal_uint("[Before] usdt Balance", usdt.balanceOf(address(this)), 6);
        emit log_named_decimal_uint("[Before] wbtc Balance", wbtc.balanceOf(address(this)), 8);
        console.log();
    }

// ============================================== 借USDT,WBTC，还USDT,WBTC =======================================================      

    function test_flashloan1() public {
        // Define the parameters for the flash loan
        address[] memory assets = new address[](2);
        assets[0] = address(usdt);
        assets[1] = address(wbtc);
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = usdt.balanceOf(aUSDT); // 将aUSDT中的USDT全部借走
        amounts[1] = wbtc.balanceOf(awbtc); // 将aUSDT中的USDT全部借走
        uint256[] memory modes = new uint256[](2);
        modes[0] = 0; // 0 corresponds to no debt swap
        modes[1] = 0; // 0 corresponds to no debt swap

        address onBehalfOf = address(this);
        bytes memory params = "";
    
        Lending_pool.flashLoan(
            address(this), // address receiverAddress, 
            assets, // address[] memory assets,
            amounts, // uint256[] memory amounts,
            modes, // uint256[] memory modes,
            onBehalfOf, // address onBehalfOf,
            params, // bytes memory params,
            0 // uint16 referralCode
        );

        emit log_named_decimal_uint("[After] usdt Balance", usdt.balanceOf(address(this)), 6);
        emit log_named_decimal_uint("[After] wbtc Balance", wbtc.balanceOf(address(this)), 8);
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool){
        emit log_named_decimal_uint("[While] usdt Balance", usdt.balanceOf(address(this)), 6);
        emit log_named_decimal_uint("[While] wbtc Balance", wbtc.balanceOf(address(this)), 8);
        console.log();

        // do anything u want

        for(uint256 i = 0; i < assets.length; i++) { // 还款的方式是approve给Lendingl_Pool，因为他会transferFrom你的token进行还款   
            IERC20(assets[i]).safeIncreaseAllowance(msg.sender, amounts[i] + premiums[i]); 
        }

        return true;
    }

// ================================== 借USDT,WBTC，不还款，而是开一个新的债务仓位, modes=2 ==================================================   

    // function test_flashloan2() public {
    //     // Define the parameters for the flash loan
    //     address[] memory assets = new address[](2);
    //     assets[0] = address(usdt);
    //     assets[1] = address(wbtc);
    //     uint256[] memory amounts = new uint256[](2);
    //     amounts[0] = 1 * 1e6;
    //     amounts[1] = 1 * 1e8; 
    //     uint256[] memory modes = new uint256[](2);
    //     modes[0] = 2; // 以稳定利率设置债务
    //     modes[1] = 2; // 以可变利率设置债务

    //     address onBehalfOf = address(this);

    //     bytes memory params = "";

    //     IERC20(usdt).safeIncreaseAllowance(address(Lending_pool), 100_000 * 1e6); 
    //     Lending_pool.deposit(address(usdt), 100_000 * 1e6 , address(this), 0);
    //     IERC20(wbtc).safeIncreaseAllowance(address(Lending_pool), 100 * 1e8); 
    //     Lending_pool.deposit(address(wbtc), 100 * 1e8 , address(this), 0);
    //     // AAVE默认情况下，deposit的资产都是作为抵押品的，如果不想作为抵押品，设置为false。如果这么做，就以为着本次闪电贷会失败
    //     // Lending_pool.setUserUseReserveAsCollateral(address(usdt), false);
    //     // Lending_pool.setUserUseReserveAsCollateral(address(wbtc), false);

    //     emit log_named_decimal_uint("[complete deposit] usdt Balance", usdt.balanceOf(address(this)), 6);
    //     emit log_named_decimal_uint("[complete deposit] wbtc Balance", wbtc.balanceOf(address(this)), 8);
    //     console.log();

    //     Lending_pool.flashLoan(
    //         address(this), // address receiverAddress, 
    //         assets, // address[] memory assets,
    //         amounts, // uint256[] memory amounts,
    //         modes, // uint256[] memory modes,
    //         onBehalfOf, // address onBehalfOf,
    //         params, // bytes memory params,
    //         0 // uint16 referralCode
    //     );

    //     emit log_named_decimal_uint("[After] usdt Balance", usdt.balanceOf(address(this)), 6);
    //     emit log_named_decimal_uint("[After] wbtc Balance", wbtc.balanceOf(address(this)), 8);
    // }

    // function executeOperation(
    //     address[] calldata,
    //     uint256[] calldata,
    //     uint256[] calldata,
    //     address,
    //     bytes calldata
    // ) external returns (bool){
    //     emit log_named_decimal_uint("[While] usdt Balance", usdt.balanceOf(address(this)), 6);
    //     emit log_named_decimal_uint("[While] wbtc Balance", wbtc.balanceOf(address(this)), 8);
    //     console.log();

    //     // do anything u want

    //     return true;
    // }

}