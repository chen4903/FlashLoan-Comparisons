// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "./interface.sol";

contract AAVE_v3 is Test{
    using SafeERC20 for IERC20;

    // 交互的池子
    IAAVE_V3_Pool public constant pool = IAAVE_V3_Pool(0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2);
    IERC20 public constant usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7); 
    IERC20 public constant wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    address public constant aEthUSDT = 0x23878914EFE38d27C4D67Ab83ed1b93A74D4086a;
    address public constant aEthWbtc = 0x5Ee5bf7ae06D1Be5997A1A72006FE6C607eC6DE8;

    function setUp() public {
        vm.createSelectFork("mainnet", 18_811_540);
        vm.label(address(pool), "pool");
        vm.label(address(usdt), "usdt");

        // 我们需要借，因此先准备一些钱作为手续费。
        deal(address(usdt), address(this), 1_000_000 * 1e6);
        deal(address(wbtc), address(this), 100 * 1e8);
        emit log_named_decimal_uint("[Before] usdt Balance", usdt.balanceOf(address(this)), 6);
        emit log_named_decimal_uint("[Before] wbtc Balance", wbtc.balanceOf(address(this)), 8);
        console.log();
    }

// ==================================== 借USDT,wBtc，还USDT,wBtc ==============================================      

    // function test_flashloan1() public {
        
    //     // Define the parameters for the flash loan
    //     address[] memory assets = new address[](2);
    //     assets[0] = address(usdt);
    //     assets[1] = address(wbtc);
    //     uint256[] memory amounts = new uint256[](2);
    //     amounts[0] = usdt.balanceOf(aEthUSDT); // 将aEthUSDT中的USDT全部借走
    //     amounts[1] = wbtc.balanceOf(aEthWbtc); // 将aEthUSDT中的USDT全部借走
    //     uint256[] memory modes = new uint256[](2);
    //     modes[0] = 0; // 0 corresponds to no debt swap
    //     modes[1] = 0; // 0 corresponds to no debt swap

    //     address onBehalfOf = address(this);
    //     bytes memory params = "";
    
    //     pool.flashLoan(
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
    //     address[] calldata assets,
    //     uint256[] calldata amounts,
    //     uint256[] calldata premiums,
    //     address initiator,
    //     bytes calldata params
    // ) external returns (bool){
    //     emit log_named_decimal_uint("[While] usdt Balance", usdt.balanceOf(address(this)), 6);
    //     emit log_named_decimal_uint("[While] wbtc Balance", wbtc.balanceOf(address(this)), 8);
    //     console.log();

    //     // do anything u want

    //     for(uint256 i = 0; i < assets.length; i++) { // 还款的方式是approve给Lendingl_Pool，因为他会transferFrom你的token进行还款   
    //         IERC20(assets[i]).safeIncreaseAllowance(msg.sender, amounts[i] + premiums[i]); 
    //     }

    //     return true;
    // }

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

    //     IERC20(usdt).safeIncreaseAllowance(address(pool), 100_000 * 1e6); 
    //     pool.deposit(address(usdt), 100_000 * 1e6 , address(this), 0);
    //     IERC20(wbtc).safeIncreaseAllowance(address(pool), 100 * 1e8); 
    //     pool.deposit(address(wbtc), 100 * 1e8 , address(this), 0);
    //     // AAVE默认情况下，deposit的资产都是作为抵押品的，如果不想作为抵押品，设置为false。如果这么做，就以为着本次闪电贷会失败
    //     // pool.setUserUseReserveAsCollateral(address(usdt), false);
    //     // pool.setUserUseReserveAsCollateral(address(wbtc), false);

    //     emit log_named_decimal_uint("[complete deposit] usdt Balance", usdt.balanceOf(address(this)), 6);
    //     emit log_named_decimal_uint("[complete deposit] wbtc Balance", wbtc.balanceOf(address(this)), 8);
    //     console.log();

    //     pool.flashLoan(
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

// ================================== 只借usdt, 还usdt ==================================================  

    function test_flashloan3() public {
        
        // Define the parameters for the flash loan
    
        pool.flashLoanSimple(
            address(this), 
            address(usdt), 
            usdt.balanceOf(aEthUSDT), 
            "", 
            0 
        );

        emit log_named_decimal_uint("[After] usdt Balance", usdt.balanceOf(address(this)), 6);
    }

    function executeOperation(
        address assets,
        uint256 amounts,
        uint256 premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool){
        emit log_named_decimal_uint("[While] usdt Balance", usdt.balanceOf(address(this)), 6);
        console.log();

        // do anything u want

        // 还款的方式是approve给Lendingl_Pool，因为他会transferFrom你的token进行还款   
        IERC20(assets).safeIncreaseAllowance(msg.sender, amounts + premiums); 

        return true;
    }
}