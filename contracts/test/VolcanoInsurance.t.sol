// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import {VolcanoInsurance, IVolcanoInsurance} from "../src/VolcanoInsurance.sol";

contract VolcanoInsuranceTest is Test, IVolcanoInsurance { 

    VolcanoInsurance public volcanoInsurance;

    //Functions fallback and receive used when the test contract is sent msg.value to prevent the test from reverting.
    fallback() external payable {}     // Fallback function is called when msg.data is not empty
    receive() external payable {}      // Function to receive Ether. msg.data must be empty

    function setUp() public {
        volcanoInsurance = new VolcanoInsurance();
        // assertEq(weigold.MAX_BPS(),10000);
        // assertEq(weigold.SCALE_FEE(),30);
        assertEq(volcanoInsurance.owner(),address(this));
    }

    function test_ownerAddCollateralRevertOnlyOwner() public {
        vm.prank(address(0));
        uint256 collateralAmount = 1 ether;
         // Solmate Owned revert.
        vm.expectRevert("UNAUTHORIZED");
        volcanoInsurance.ownerAddCollateral{value: collateralAmount}(collateralAmount);
    }

    function test_ownerAddCollateralRevertMsgValueDoesNotMatchInputCollateral() public {
        uint256 collateralAmount = 1 ether;
        vm.expectRevert(MsgValueDoesNotMatchInputCollateral.selector);    //Revert if not the owner. Custom error from SimpleStorage.
        volcanoInsurance.ownerAddCollateral{value: 0}(collateralAmount);
    }

    function test_ownerAddCollateralSuccess() public {
        assertEq(0,volcanoInsurance.openWeiToInsure());
        uint256 collateralAmount = 1 ether;
        volcanoInsurance.ownerAddCollateral{value: collateralAmount}(collateralAmount);
        assertEq(1 ether,volcanoInsurance.openWeiToInsure());
    }

    function test_ownerLiquidClaimLiquidRevertOnlyOwner() public {
        vm.prank(address(0));
        uint256 collateralAmount = 1 ether;
         // Solmate Owned revert.
        vm.expectRevert("UNAUTHORIZED");
        volcanoInsurance.ownerLiquidClaimLiquid(collateralAmount);
    }

    function test_ownerLiquidClaimSuccess() public {
        uint256 collateralAmount = 1 ether;
        assertEq(0,volcanoInsurance.openWeiToInsure());
        test_ownerAddCollateralSuccess();
        assertEq(1 ether,volcanoInsurance.openWeiToInsure());
        volcanoInsurance.ownerLiquidClaimLiquid(collateralAmount);
        assertEq(0,volcanoInsurance.openWeiToInsure());
    }

    function test_ownerLiquidClaimRevertNotEnoughCollateralInContract() public {
        uint256 collateralAmount = 1 ether;
        assertEq(0,volcanoInsurance.openWeiToInsure());
        vm.expectRevert(NotEnoughCollateralInContract.selector);    //Revert if not the owner. Custom error from SimpleStorage.
        volcanoInsurance.ownerLiquidClaimLiquid(collateralAmount);
        assertEq(0,volcanoInsurance.openWeiToInsure());
    }

    function test_buyerCreatePolicyRevertOwnerIsMsgSender() public {
        vm.expectRevert(OwnerIsMsgSender.selector);    
        volcanoInsurance.buyerCreatePolicy(1,-1);
    }

    function test_buyerCreatePolicyRevertNotEnoughCollateralInContract() public {
        vm.startPrank(address(0));
        vm.expectRevert(NotEnoughCollateralInContract.selector);    
        volcanoInsurance.buyerCreatePolicy(1,-1);
    }

    function test_buyerCreatePolicyRevertMsgValueTooSmallForPolicyBuy() public {
        test_ownerAddCollateralSuccess();
        uint256 fee = volcanoInsurance.INSURANCE_POLICY_FEE(); 
        vm.startPrank(address(0));
        vm.expectRevert(MsgValueTooSmallForPolicyBuy.selector);   
        volcanoInsurance.buyerCreatePolicy{value: (fee-1)}(1,-1);
    }
    
    function test_buyerCreatePolicySuccess() public {
        test_ownerAddCollateralSuccess();
        uint256 fee = volcanoInsurance.INSURANCE_POLICY_FEE(); 
        vm.startPrank(address(0));
        volcanoInsurance.buyerCreatePolicy{value: fee}(1,-1);
        vm.stopPrank();
    }

    function test_buyerCreatePolicyRevertPolicyAlreadyBoughtUser() public {
        test_buyerCreatePolicySuccess();
        test_ownerAddCollateralSuccess();
        uint256 fee = volcanoInsurance.INSURANCE_POLICY_FEE(); 
        vm.startPrank(address(0));
        vm.expectRevert(PolicyAlreadyBoughtUser.selector);   
        volcanoInsurance.buyerCreatePolicy{value: fee}(1,-1);
    }

    function test_ownerClaimExpiredPolicyRevertPolicyDoesNotExist() public {
        vm.expectRevert(PolicyDoesNotExist.selector);   
        volcanoInsurance.ownerClaimExpiredPolicy(address(0));
    }

    function test_ownerClaimExpiredPolicyRevertPolicyDidNotExpireYet() public {
        test_buyerCreatePolicySuccess();
        vm.expectRevert(PolicyDidNotExpireYet.selector);   
        volcanoInsurance.ownerClaimExpiredPolicy(address(0));
    }

    function test_ownerClaimExpiredPolicySuccess() public {
        test_buyerCreatePolicySuccess();
        // Warp to: 
        // the current time + 1 year from now
        vm.warp(block.timestamp + 31536000);
        volcanoInsurance.ownerClaimExpiredPolicy(address(0));
    }

    function test_buyerClaimRewardRevertVolcanoTimeOracleDataNotSetYet() public {
        vm.expectRevert(VolcanoTimeOracleDataNotSetYet.selector);   
        volcanoInsurance.buyerClaimReward();
    }

    function test_buyerClaimRewardRevertCoordinatesCannotBeTheOrigin() public {
        volcanoInsurance.ownerOracleTestVariables(block.timestamp,0,0);
        vm.expectRevert(CoordinatesCannotBeTheOrigin.selector);   
        volcanoInsurance.buyerClaimReward();
    }

    function test_buyerClaimRewardRevertPolicyDoesNotExist() public {
        volcanoInsurance.ownerOracleTestVariables(block.timestamp,1,-1);
        vm.expectRevert(PolicyDoesNotExist.selector);   
        volcanoInsurance.buyerClaimReward();
    }

    function test_buyerClaimRewardRevertPolicySignedAfterEruption() public {
        test_buyerCreatePolicySuccess();
        volcanoInsurance.ownerOracleTestVariables((block.timestamp-31536000),1,-1);
        vm.prank(address(0));
        vm.expectRevert(PolicySignedAfterEruption.selector);   
        volcanoInsurance.buyerClaimReward();
    }


    // ownerOracleTestVariables




    // function testOracleEthGoldPrice() public {
    //     uint256 priceEthGold = weigold.getLatestWeiGoldPrice();
    //     assertGt(priceEthGold,0);
    // }

    // function testOwnerUpdateSlotsValid() public {
    //     assertEq(weigold.vendingSlotCount(0),0);
    //     weigold.ownerUpdateSlots(0,1);
    //     assertEq(weigold.vendingSlotCount(0),1);
    // }

    // function testOwnerUpdateSlotsNotOwner() public {
    //     vm.startPrank(address(0)); //Change the address to not be the owner. The owner is address(this) in this context.
    //     // vm.expectRevert(NotOwner.selector);    //Revert if not the owner. Custom error from SimpleStorage.
    //     vm.expectRevert("UNAUTHORIZED");    //Revert if not the owner. Custom error from SimpleStorage.
    //     weigold.ownerUpdateSlots(0,1);
    // }

    // function testBuyGoldSlotEmpty() public {
    //     vm.startPrank(address(0)); //Change the address to not be the owner. The owner is address(this) in this context.
    //     assertEq(weigold.vendingSlotCount(0),0);
    //     vm.expectRevert(SlotEmpty.selector);    //Revert if not the owner. Custom error from SimpleStorage.
    //     weigold.buyGold(0);
    // }

    // function testBuyGoldMsgValueTooSmall() public {
    //     testOwnerUpdateSlotsValid();
    //     vm.startPrank(address(0)); //Change the address to not be the owner. The owner is address(this) in this context.
    //     assertEq(weigold.vendingSlotCount(0),1);
    //     vm.expectRevert(MsgValueTooSmall.selector);    //Revert if not the owner. Custom error from SimpleStorage.
    //     weigold.buyGold(0);
    // }

    // function testBuyGoldValidWithPriceRefund() public {
    //     testOwnerUpdateSlotsValid();
    //     uint256 priceEthGold = weigold.getLatestWeiGoldPrice();
    //     deal(address(0),2*priceEthGold);
    //     vm.startPrank(address(0)); //Change the address to not be the owner. The owner is address(this) in this context.
    //     uint256 prankBalanceBeforeRefund = address(0).balance;
    //     assertEq(weigold.vendingSlotCount(0),1);
    //     weigold.buyGold{value: priceEthGold + 1}(0);
    //     assertEq(address(0).balance,prankBalanceBeforeRefund-priceEthGold);
    // }

    // function testBuyGoldValidWithNoPriceRefund() public {
    //     testOwnerUpdateSlotsValid();
    //     vm.startPrank(address(0)); //Change the address to not be the owner. The owner is address(this) in this context.
    //     uint256 prankBalance = address(0).balance;
    //     uint256 priceEthGold = weigold.getLatestWeiGoldPrice();
    //     assertGt(prankBalance,priceEthGold);
    //     assertEq(weigold.vendingSlotCount(0),1);
    //     weigold.buyGold{value:priceEthGold}(0);
    // }

}