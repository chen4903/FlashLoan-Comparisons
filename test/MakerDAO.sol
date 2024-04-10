// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import "./interface.sol";

contract MakerDAO is Test{

    IDAI public dai = IDAI(0x6B175474E89094C44Da98b954EedeAC495271d0F); // We want to borrow DAI
    IDssFlash_MakerDAO public dss_flash_makerdao = IDssFlash_MakerDAO(0x60744434d6339a6B27d73d9Eda62b6F66a0a04FA); // Flashloan

    function setUp() public {
        vm.createSelectFork("mainnet", 19619170); 
        vm.label(address(dss_flash_makerdao), "dss_flash_makerdao");

        // We should prepare for some DAI to pay the fee
        deal(address(dai), address(this), 1 * 1e18);
    }

    function test_flashloan() public {
        // We can only borrow DAI...
        dss_flash_makerdao.flashLoan(address(this), address(dai), 10 * 1e18, "Go to the callback");
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount, 
        uint256 fee,
        bytes calldata
    ) external returns (bytes32) {
        assertEq(msg.sender, address(dss_flash_makerdao));
        assertEq(initiator, address(this));

        // Do anything you want

        IDAI(token).approve(msg.sender, amount + fee); // Pay back flashloan fee

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

}