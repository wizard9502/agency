# Agency Contracts (Free / Testnet First)

Completely free development path.

## Goal
Replicate the core of Pump.fun (excluding livestream):
- Permissionless token creation
- Bonding curve trading
- Fair launch
- Creator fee share
- Graduation-ready design

## Chains (testnets first)
- Arc Testnet (primary)
- BNB Testnet
- Later: Robinhood Chain, Solana, etc.

## Structure
```
contracts/
├── AgencyFactory.sol      # Creates new tokens + bonding curves
├── BondingCurve.sol       # Constant-product curve + trading
├── AgencyToken.sol        # Simple ERC20
└── interfaces/
```

## How to use (100% free)
1. Install Foundry or Hardhat (free)
2. Deploy to any free testnet
3. No mainnet gas needed until you are ready

## Next steps
- Deploy to Arc / BNB testnet
- Connect frontend
- Add graduation logic
