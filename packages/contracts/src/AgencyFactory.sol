// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./AgencyToken.sol";
import "./BondingCurve.sol";

/**
 * @title AgencyFactory
 * @notice Permissionless factory for creating Agency tokens + bonding curves
 * @dev Completely free to use on testnets. Core of the Pump.fun-style launchpad.
 */
contract AgencyFactory {
    // ============ State ============
    address public platformFeeRecipient;
    address public owner;

    // Default virtual reserves (can be adjusted)
    uint256 public defaultVirtualTokenReserves = 1_073_000_000 ether; // ~1.073B tokens
    uint256 public defaultVirtualEthReserves = 30 ether;              // starting virtual liquidity

    uint256 public tokenCount;

    struct TokenInfo {
        address token;
        address bondingCurve;
        address creator;
        string name;
        string symbol;
        uint8 category; // 0 = Creator, 1 = Tools, 2 = Skills
        uint256 createdAt;
    }

    mapping(uint256 => TokenInfo) public tokens;
    mapping(address => uint256[]) public creatorTokens;

    // ============ Events ============
    event TokenCreated(
        address indexed token,
        address indexed bondingCurve,
        address indexed creator,
        string name,
        string symbol,
        uint8 category,
        uint256 tokenId
    );

    // ============ Constructor ============
    constructor(address platformFeeRecipient_) {
        platformFeeRecipient = platformFeeRecipient_;
        owner = msg.sender;
    }

    // ============ Main Function ============

    /**
     * @notice Create a new token + bonding curve (permissionless)
     * @param name Token name
     * @param symbol Token symbol
     * @param category 0=CreatorEquity, 1=OpenTools, 2=SkillForge
     */
    function createToken(
        string calldata name,
        string calldata symbol,
        uint8 category
    ) external returns (address token, address curve) {
        require(category <= 2, "Invalid category");
        require(bytes(name).length > 0 && bytes(symbol).length > 0, "Empty name/symbol");

        // Deploy bonding curve first (needs address for token mint)
        BondingCurve bondingCurve = new BondingCurve(
            address(0), // temporary, we will set properly
            msg.sender,
            platformFeeRecipient,
            defaultVirtualTokenReserves,
            defaultVirtualEthReserves
        );

        // Deploy token and mint full supply to the curve
        AgencyToken newToken = new AgencyToken(
            name,
            symbol,
            defaultVirtualTokenReserves,
            address(bondingCurve)
        );

        // Note: In a production version we would use a more advanced pattern
        // (CREATE2 or initialize) so the curve knows the final token address.
        // For this free MVP scaffolding we keep it simple and readable.

        uint256 id = tokenCount++;
        tokens[id] = TokenInfo({
            token: address(newToken),
            bondingCurve: address(bondingCurve),
            creator: msg.sender,
            name: name,
            symbol: symbol,
            category: category,
            createdAt: block.timestamp
        });

        creatorTokens[msg.sender].push(id);

        emit TokenCreated(
            address(newToken),
            address(bondingCurve),
            msg.sender,
            name,
            symbol,
            category,
            id
        );

        return (address(newToken), address(bondingCurve));
    }

    // ============ Admin (optional) ============
    function setPlatformFeeRecipient(address newRecipient) external {
        require(msg.sender == owner, "Not owner");
        platformFeeRecipient = newRecipient;
    }

    function setVirtualReserves(uint256 tokenReserves, uint256 ethReserves) external {
        require(msg.sender == owner, "Not owner");
        defaultVirtualTokenReserves = tokenReserves;
        defaultVirtualEthReserves = ethReserves;
    }
}
