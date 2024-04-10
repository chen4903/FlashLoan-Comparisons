// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "./interface.sol";

contract AAVE_v1 is Test{
    using SafeMath for uint256;

    // borrow from and pay back to core contract
    ILendingPoolCore public core = ILendingPoolCore(0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3);
    // flashloan for DAI
    IDAI public constant DAI = IDAI(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    // interact with pool to call flashloan
    IAAVE_V1_LendingPool public constant Lending_Pool = IAAVE_V1_LendingPool(0x398eC7346DcD622eDc5ae82352F02bE94C62d119);
    // just for demonstration
    ILendingPoolParametersProvider public parametersProvider = ILendingPoolParametersProvider(0xeAC99f8Fb1996AeB153E8cF0842908973a48C66F);

    function setUp() public {
        vm.createSelectFork("mainnet", 18_797_346);
        vm.label(address(Lending_Pool), "Lending Pool");
        vm.label(address(DAI), "DAI");

        // prepare for some fee
        deal(address(DAI), address(this), 1_000 * 1e18);
        
    }

// ================================== borrow DAI, pay back DAI ==================================================  

    // function test_flashloan1() public {
    //     emit log_named_decimal_uint("[Before] DAI Balance", DAI.balanceOf(address(this)), 18);
    //     // borrow all the DAI in core contract
    //     uint256 core_dai_balance = DAI.balanceOf(address(core));
        
    //     Lending_Pool.flashLoan(address(this), address(DAI), core_dai_balance, "");
    //     emit log_named_decimal_uint("[After] DAI Balance", DAI.balanceOf(address(this)), 18);
    // }

    // function executeOperation(address _reserve, uint256 _amount, uint256 _fee, bytes calldata) external{
    //     emit log_named_decimal_uint("[While] DAI Balance", DAI.balanceOf(address(this)), 18);
    //     // do anything u want


    //     // pay back way 1: 
    //     DAI.transfer(address(core), _amount + _fee);

    //     // pay back way 2: calculate by ourselves
    //     // (uint256 totalFeeBips, uint256 protocolFeeBips) = parametersProvider.getFlashLoanFeesInBips();
    //     // uint256 amountFee = _amount.mul(totalFeeBips).div(10000);

    //     // DAI.transfer(address(core), _amount + amountFee);
    // }

// ================================== borrow ETH, pay back ETH ==================================================   

    function test_flashloan2() public {
        deal(address(this), 1 * 1e18);
        emit log_named_decimal_uint("[Before] ETH Balance", address(this).balance, 18);
        uint256 balance = 100 ether;
        
        Lending_Pool.flashLoan(address(this), address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE), balance, "");
        emit log_named_decimal_uint("[After] ETH Balance", address(this).balance, 18);
    }

    function executeOperation(address, uint256 _amount, uint256 _fee, bytes calldata) payable external{
        emit log_named_decimal_uint("[While] ETH Balance", address(this).balance, 18);

        // do anything u want

        payable(address(core)).transfer(_amount + _fee);

    }

    receive() external payable{}
}

