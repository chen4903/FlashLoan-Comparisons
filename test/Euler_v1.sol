// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "./interface.sol";

contract Euler_v1 is Test{

    IERC20 public usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // We want to borrow USDC
    IEulerFlashloan public euler_flashloan = IEulerFlashloan(0x07df2ad9878F8797B4055230bbAE5C808b8259b3); // Flashloan

    function setUp() public {
        vm.createSelectFork("mainnet", 16818703); 
        // We can use flashloan normally in block height 16818703
        // 1. The euler_flashloan contract is deployed in block height 13774745
        // 2. The flashloan called in block height 16818926 will output `borrow revert` from Revert1(0x13d7392f5A8a6A75020eAC90F761F56Acb7175f0),
        //     Revert1 is deployed in block height 16818703
        // 3. The flashloan called in block height 16918926 will output `borrow revert` from Revert2(0xe3033E517fDA8c93957C1Bf40BB272514Bf00450),
        //     Revert2 is deployed in block height 16818926
        // 4. The flashloan called in block height 19017895 will output `stdStorage find(StdStorage): Slot(s) not found` 

        vm.label(address(euler_flashloan), "euler_flashloan");

        // We should prepare for some USDC to pay the fee
        deal(address(usdc), address(this), 1_00000 * 1e18);
        
    }

    function test_flashloan() public {
        euler_flashloan.flashLoan(address(this), address(usdc), 100 * 1e6, "Go to the CallBack"); 
    }

    function onFlashLoan(
        address receiver,
        address token,
        uint256 amount,
        uint256,
        bytes calldata
    ) external returns (bytes32) {
        assertEq(receiver, address(this));
        assertEq(token, address(usdc));
        assertEq(amount, 100 * 1e6);

        // There is no fee in Euler flashloan: receiver.onFlashLoan(msgSender, token, amount, 0, data) == CALLBACK_SUCCESS,
        usdc.approve(msg.sender, amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

}