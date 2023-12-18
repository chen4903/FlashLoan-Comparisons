// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "./interface.sol";
import "@openzeppelin/contracts/utils/math/safeMath.sol";

contract AAVE_v1 is Test{
    using SafeMath for uint256;

    // 向core借款和还款
    ILendingPoolCore public core = ILendingPoolCore(0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3);
    // 借DAI
    IDAI public constant DAI = IDAI(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    // 闪电贷需要和Lending_Pool进行交互
    IAAVE_V1_LendingPool public constant Lending_Pool = IAAVE_V1_LendingPool(0x398eC7346DcD622eDc5ae82352F02bE94C62d119);
    // 手续费手动计算需要用到的合约，为了演示需要而已
    ILendingPoolParametersProvider public parametersProvider = ILendingPoolParametersProvider(0xeAC99f8Fb1996AeB153E8cF0842908973a48C66F);

    function setUp() public {
        vm.createSelectFork("mainnet", 18_797_346);
        vm.label(address(Lending_Pool), "Lending Pool");
        vm.label(address(DAI), "DAI");

        // 我们需要借，因此先准备一些钱作为手续费。core合约中有大量的DAI，因此我们准备多一点DAI
        deal(address(DAI), address(this), 1_000 * 1e18);
        
    }

// ================================== 借DAI, 还DAI ==================================================  

    // function test_flashloan1() public {
    //     emit log_named_decimal_uint("[Before] DAI Balance", DAI.balanceOf(address(this)), 18);
    //     // 我们将core合约中的所有DAI借出来
    //     uint256 core_dai_balance = DAI.balanceOf(address(core));
        
    //     Lending_Pool.flashLoan(address(this), address(DAI), core_dai_balance, "");
    //     emit log_named_decimal_uint("[After] DAI Balance", DAI.balanceOf(address(this)), 18);
    // }

    // function executeOperation(address _reserve, uint256 _amount, uint256 _fee, bytes calldata) external{
    //     emit log_named_decimal_uint("[While] DAI Balance", DAI.balanceOf(address(this)), 18);
    //     // do anything u want

    //     // 我们借的是DAI console.log("borrow DAI:", _reserve);

    //     // 还款方式1：AAVE v1帮你计算好手续费，直接还款就行了
    //     DAI.transfer(address(core), _amount + _fee);

    //     // 还款方式2：根据计算原理自己计算fee，实际使用中没必要用这种方式，这里使用是为了理解其原理
    //     // (uint256 totalFeeBips, uint256 protocolFeeBips) = parametersProvider.getFlashLoanFeesInBips();
    //     // uint256 amountFee = _amount.mul(totalFeeBips).div(10000);

    //     // DAI.transfer(address(core), _amount + amountFee);
    // }

// ================================== 借ETH, 还ETH ==================================================   

    function test_flashloan2() public {
        deal(address(this), 1 * 1e18);
        emit log_named_decimal_uint("[Before] ETH Balance", address(this).balance, 18);
        uint256 balance = 100 ether;
        
        Lending_Pool.flashLoan(address(this), address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE), balance, "");
        emit log_named_decimal_uint("[After] ETH Balance", address(this).balance, 18);
    }

    function executeOperation(address _reserve, uint256 _amount, uint256 _fee, bytes calldata) payable external{
        emit log_named_decimal_uint("[While] ETH Balance", address(this).balance, 18);

        // do anything u want

        payable(address(core)).transfer(_amount + _fee);

    }

    receive() external payable{}
}

