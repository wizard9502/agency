// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title BondingCurve
 * @notice Constant-product bonding curve (Uniswap-style)
 * @dev Designed for free testnet deployment. Easy to extend later.
 *
 * Core features replicated from Pump.fun:
 * - Instant trading after creation
 * - Price rises with buys, falls with sells
 * - Platform + creator fee split
 * - Ready for graduation logic
 */
contract BondingCurve is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ============ State ============
    IERC20 public immutable token;
    address public immutable creator;
    address public immutable factory;

    uint256 public virtualTokenReserves;
    uint256 public virtualEthReserves;   // works with native token or wrapped
    uint256 public realTokenReserves;
    uint256 public realEthReserves;

    uint256 public constant FEE_BPS = 125;          // 1.25% total fee
    uint256 public constant CREATOR_FEE_BPS = 30;   // 0.30% to creator
    uint256 public constant PLATFORM_FEE_BPS = 95;  // 0.95% to platform

    address public platformFeeRecipient;
    bool public graduated;

    // ============ Events ============
    event Buy(address indexed buyer, uint256 ethIn, uint256 tokensOut, uint256 newPrice);
    event Sell(address indexed seller, uint256 tokensIn, uint256 ethOut, uint256 newPrice);
    event Graduated(address indexed token, uint256 finalEthReserves);

    // ============ Constructor ============
    constructor(
        address token_,
        address creator_,
        address platformFeeRecipient_,
        uint256 virtualTokenReserves_,
        uint256 virtualEthReserves_
    ) {
        token = IERC20(token_);
        creator = creator_;
        factory = msg.sender;
        platformFeeRecipient = platformFeeRecipient_;

        virtualTokenReserves = virtualTokenReserves_;
        virtualEthReserves = virtualEthReserves_;
        realTokenReserves = virtualTokenReserves_; // initially all tokens are in curve
        realEthReserves = 0;
    }

    // ============ Trading ============

    /**
     * @notice Buy tokens with native currency (ETH / native gas token)
     */
    function buy(uint256 minTokensOut) external payable nonReentrant returns (uint256 tokensOut) {
        require(!graduated, "Already graduated");
        require(msg.value > 0, "Zero value");

        uint256 ethIn = msg.value;

        // Calculate tokens out using constant product
        // (x + dx) * (y - dy) = x * y
        uint256 ethAfterFee = ethIn - (ethIn * FEE_BPS / 10_000);
        tokensOut = (ethAfterFee * virtualTokenReserves) / (virtualEthReserves + ethAfterFee);

        require(tokensOut >= minTokensOut, "Slippage");
        require(tokensOut <= realTokenReserves, "Insufficient tokens");

        // Update reserves
        virtualEthReserves += ethAfterFee;
        virtualTokenReserves -= tokensOut;
        realEthReserves += ethIn;
        realTokenReserves -= tokensOut;

        // Distribute fees
        uint256 creatorFee = (ethIn * CREATOR_FEE_BPS) / 10_000;
        uint256 platformFee = ethIn - ethAfterFee - creatorFee;

        if (creatorFee > 0) {
            (bool success1, ) = creator.call{value: creatorFee}("");
            require(success1, "Creator fee failed");
        }
        if (platformFee > 0) {
            (bool success2, ) = platformFeeRecipient.call{value: platformFee}("");
            require(success2, "Platform fee failed");
        }

        // Transfer tokens to buyer
        token.safeTransfer(msg.sender, tokensOut);

        emit Buy(msg.sender, ethIn, tokensOut, getCurrentPrice());
    }

    /**
     * @notice Sell tokens for native currency
     */
    function sell(uint256 tokensIn, uint256 minEthOut) external nonReentrant returns (uint256 ethOut) {
        require(!graduated, "Already graduated");
        require(tokensIn > 0, "Zero tokens");

        // Transfer tokens from seller
        token.safeTransferFrom(msg.sender, address(this), tokensIn);

        // Calculate eth out
        uint256 ethBeforeFee = (tokensIn * virtualEthReserves) / (virtualTokenReserves + tokensIn);
        ethOut = ethBeforeFee - (ethBeforeFee * FEE_BPS / 10_000);

        require(ethOut >= minEthOut, "Slippage");
        require(ethOut <= realEthReserves, "Insufficient eth");

        // Update reserves
        virtualTokenReserves += tokensIn;
        virtualEthReserves -= ethBeforeFee;
        realTokenReserves += tokensIn;
        realEthReserves -= ethBeforeFee;

        // Fees
        uint256 fee = ethBeforeFee - ethOut;
        uint256 creatorFee = (fee * CREATOR_FEE_BPS) / FEE_BPS;
        uint256 platformFee = fee - creatorFee;

        if (creatorFee > 0) {
            (bool success1, ) = creator.call{value: creatorFee}("");
            require(success1, "Creator fee failed");
        }
        if (platformFee > 0) {
            (bool success2, ) = platformFeeRecipient.call{value: platformFee}("");
            require(success2, "Platform fee failed");
        }

        // Send eth to seller
        (bool success, ) = msg.sender.call{value: ethOut}("");
        require(success, "ETH transfer failed");

        emit Sell(msg.sender, tokensIn, ethOut, getCurrentPrice());
    }

    // ============ Views ============

    function getCurrentPrice() public view returns (uint256) {
        if (virtualTokenReserves == 0) return 0;
        return (virtualEthReserves * 1e18) / virtualTokenReserves;
    }

    function getTokensOut(uint256 ethIn) public view returns (uint256) {
        uint256 ethAfterFee = ethIn - (ethIn * FEE_BPS / 10_000);
        return (ethAfterFee * virtualTokenReserves) / (virtualEthReserves + ethAfterFee);
    }

    function getEthOut(uint256 tokensIn) public view returns (uint256) {
        uint256 ethBeforeFee = (tokensIn * virtualEthReserves) / (virtualTokenReserves + tokensIn);
        return ethBeforeFee - (ethBeforeFee * FEE_BPS / 10_000);
    }

    // ============ Graduation (placeholder) ============
    // Can be extended later to migrate liquidity to a DEX
    function graduate() external {
        require(msg.sender == factory || msg.sender == creator, "Not authorized");
        require(!graduated, "Already graduated");
        // In future: migrate realEthReserves + remaining tokens to AMM and burn LP
        graduated = true;
        emit Graduated(address(token), realEthReserves);
    }

    receive() external payable {}
}
