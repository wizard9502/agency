// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title AgencyToken
 * @notice Simple ERC20 used by Agency launchpad
 * @dev Free, minimal implementation. No owner mint after creation.
 */
contract AgencyToken is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        address bondingCurve_
    ) ERC20(name_, symbol_) {
        // Mint entire supply to the bonding curve
        _mint(bondingCurve_, totalSupply_);
    }
}
