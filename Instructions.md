# Wallet UI Restoration Guide

## Current Status
The codebase has multiple wallet implementations with EnhancedWalletComponent.tsx being the primary OnchainKit integration.

## Step-by-Step Restoration Plan

1. Clean Component Selection
   - Use EnhancedWalletComponent.tsx as the base
   - Remove conflicting WalletConnect.tsx usage
   - Keep MantuaWallet.tsx as reference for styling

2. Dependencies Check
   - Ensure @coinbase/onchainkit is properly installed
   - Verify wagmi configuration in WagmiContext.tsx
   - Check ThemeContext.tsx integration

3. Implementation Steps
   a. Update imports in App.tsx to use EnhancedWalletComponent
   b. Remove any duplicate wallet button implementations
   c. Verify theme integration is working
   d. Test wallet connection flow

4. Testing Checklist
   - Wallet connection works
   - Theme switching functions properly
   - Modal styling matches design
   - Transaction signing works
   - Network switching functions

5. Common Issues
   - Theme inconsistencies in modal
   - Multiple wallet instances
   - Network configuration conflicts

## Quick Implementation

1. Import and use EnhancedWalletComponent:
```tsx
import { EnhancedWalletComponent } from './components/EnhancedWalletComponent';

// In your component:
<EnhancedWalletComponent 
  hideChainIcon={false}
  onConnect={(address) => console.log('Connected:', address)}
/>
```

2. Remove any other wallet connect buttons to avoid conflicts

3. Verify ThemeContext usage:
```tsx
const { themeMode } = useTheme();
```

4. Test the complete flow:
   - Connect wallet
   - Switch networks
   - Sign messages
   - View transaction history

## Troubleshooting

If you encounter issues:
1. Check browser console for errors
2. Verify OnchainKit modal styling
3. Confirm wallet provider configuration
4. Test network switching functionality

The EnhancedWalletComponent already includes proper error handling and theme integration, making it the recommended choice for restoration.

# Base Sepolia Token Implementation Plan

## Current Status
- Basic token infrastructure is in place
- ETH (native) token working
- Need to add USDC, cbBTC, and EURC support

## Implementation Steps

### 1. Token Configuration
- Update tokenConfig.ts with Base Sepolia tokens:
  - USDC: 0xD58A2C8aC47E6c94E08eA5fBdc9f7d30Cf2b3a05
  - cbBTC: 0xA7032Aa13c41bB9a4f0DdCA27019e77F9e78e1D0
  - EURC: 0x9bBb6E924Cd0d495A270FFbFb229147b78D9a0bD

### 2. Token Icons
- Add token icons to public/icons directory
- Ensure icon paths match token symbols
- Set up fallback icons for missing assets

### 3. Balance Fetching
- Update useTokenBalances hook for Base Sepolia
- Add proper decimal handling for each token
- Implement balance caching for performance

### 4. UI Updates
- Enhance TokenHoldingsSection for new tokens
- Add token search/filter capability
- Implement token price display

### 5. Testing Steps
1. Test token balance fetching
2. Verify icon display
3. Check price updates
4. Test wallet connection
5. Verify token transfers

## Files to Modify
1. client/src/config/tokenConfig.ts
2. client/src/hooks/useTokenBalances.ts
3. client/src/components/wallet/TokenHoldingsSection.tsx
4. client/src/utils/tokenMetadataUtils.ts

## Notes
- All tokens must use Base Sepolia chain ID (84532)
- Maintain existing token display patterns
- Ensure proper error handling
- Add loading states for better UX

# Mantua Protocol: Deployment & Setup Guide

This guide provides step-by-step instructions for setting up, developing, and deploying smart contracts on the Base blockchain for Mantua Protocol using Foundry.

## Table of Contents

1. [Development Environment Setup](#development-environment-setup)
2. [Configuring Foundry with Base](#configuring-foundry-with-base)
3. [Deploying Contracts to Base](#deploying-contracts-to-base)
4. [Connecting Frontend to Smart Contracts](#connecting-frontend-to-smart-contracts)
5. [Flashblocks Integration](#flashblocks-integration)
6. [Troubleshooting](#troubleshooting)

## Development Environment Setup

1. Initialize Foundry in your project:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
forge init
```

2. After initialization, you'll have:
   - A `src/` directory with `Counter.sol` (sample contract)
   - A complete Foundry environment with tools:
     - `forge`: Build, test, and deploy contracts
     - `cast`: Interact with contracts and blockchains
     - `anvil`: Local blockchain environment for testing

## Configuring Foundry with Base

1. Create a `.env` file in the root directory with Base RPCs and Flashblocks endpoints:

```env
# RPC URLs
BASE_RPC_URL="https://mainnet.base.org"
BASE_SEPOLIA_RPC_URL="https://sepolia.base.org"

# Flashblocks preconfirmation endpoints
BASE_SEPOLIA_PRECONF_URL="https://sepolia-preconf.base.org"
BASE_PRECONF_URL="https://preconf.base.org"

# Private key for deployment (DO NOT INCLUDE 0x PREFIX)
PRIVATE_KEY=your_private_key_without_0x_prefix

# Etherscan API key for verification
ETHERSCAN_API_KEY=your_etherscan_api_key
```

2. Load the environment variables:

```bash
source .env
```

3. Import a deployer wallet securely (recommended over using private key directly):

```bash
cast wallet import deployer --interactive
```

   - You'll be prompted to enter your private key
   - Your key will be stored in `~/.foundry/keystores` (encrypted and not tracked by git)

4. Check the wallet is properly imported:

```bash
cast wallet list
```

## Deploying Contracts to Base

### Deploy to Base Sepolia Testnet

Use our deployment script which handles all the necessary steps:

```bash
./deploy.sh
```

This script will:
- Load environment variables
- Check for required RPC URLs and credentials
- Compile the contracts
- Deploy to Base Sepolia
- Save the contract address to `.env`
- Verify the deployment with a test call

### Deploy to Base Mainnet

For mainnet deployments, we've created a separate script with additional safeguards:

```bash
./deploy-to-base.sh
```

This script includes:
- A confirmation prompt before using real funds
- Support for both keystore and private key authentication
- Automatic Flashblocks integration for fast confirmations
- Contract verification instructions

## Connecting Frontend to Smart Contracts

1. The Mantua Protocol frontend is already configured with:
   - `wagmi` and `viem` for Base Sepolia and Base Mainnet
   - OnchainKit for wallet connection UI
   - Connected wallet state management

2. Key files for contract interaction:
   - `client/src/contexts/WagmiContext.tsx`: Chain configuration
   - `client/src/utils/flashblocks.ts`: Flashblocks integration

3. To connect to your deployed contract:
   - Update `COUNTER_CONTRACT_ADDRESS` in `.env`
   - Use `useContractRead` and `useContractWrite` hooks from wagmi

Example contract interaction:

```tsx
import { useContractRead, useContractWrite } from 'wagmi';
import { CONTRACT_ABI, CONTRACT_ADDRESS } from '../constants/contracts';

// Read contract state
const { data: count } = useContractRead({
  address: CONTRACT_ADDRESS,
  abi: CONTRACT_ABI,
  functionName: 'number',
});

// Write to contract
const { write: increment } = useContractWrite({
  address: CONTRACT_ADDRESS,
  abi: CONTRACT_ABI,
  functionName: 'increment',
});
```

## Flashblocks Integration

Mantua Protocol implements Base's Flashblocks for ultra-fast transaction confirmations (~200ms):

### Testing Flashblocks

```bash
# Test on Sepolia testnet
./flashblocks.sh

# Test on Mainnet
./flashblocks.sh mainnet
```

### Using Flashblocks in Frontend

The utilities in `client/src/utils/flashblocks.ts` provide:
- Automatic detection of Flashblocks-compatible chains
- Client creation with Flashblocks endpoints
- Seamless integration with existing wagmi hooks

Example:

```tsx
import { getChainClient } from '../utils/flashblocks';
import { useNetwork } from 'wagmi';

const { chain } = useNetwork();
const client = getChainClient(chain?.id);

// Now use client for transactions
const txHash = await client.sendTransaction({/* tx details */});
```

## Troubleshooting

### Keystore Access Issues

If you encounter issues with the keystore:

```bash
# Re-create the keystore
cast wallet import deployer --interactive

# Check if keystore exists
ls -la ~/.foundry/keystores
```

### Contract Verification Failures

For contract verification issues:

```bash
# Verify manually with detailed output
forge verify-contract --watch \
  --chain-id 84532 \
  --constructor-args $(cast abi-encode "constructor()") \
  $COUNTER_CONTRACT_ADDRESS \
  src/Counter.sol:Counter \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --verifier-url https://api-sepolia.basescan.org/api
```

### RPC Connection Issues

If you encounter RPC connection problems:

```bash
# Test RPC connectivity
cast chain-id --rpc-url $BASE_SEPOLIA_RPC_URL
```

---

For more details on Base development, visit the [Base documentation](https://docs.base.org/).