# Mantua Protocol

A cutting-edge cryptocurrency platform simplifying blockchain interactions through intuitive design and advanced wallet management, with a focus on user engagement and educational experiences.

## Features

- React with Vite frontend
- TypeScript support
- OnchainKit and Thirdweb wallet integration
- Base network support (Mainnet and Sepolia testnet)
- Dynamic theme management
- Enhanced wallet connection experience
- Advanced wallet UI components
- Comprehensive wallet interaction toolkit
- Base Sepolia deployment tools
- Flashblocks integration for ultra-fast transaction confirmations

## Flashblocks Integration

This project includes integration with Base's Flashblocks preconfirmation service, which provides ultra-fast transaction confirmations (~200ms) for an improved user experience.

### Backend Integration

- RPC endpoints configured in `foundry.toml` for both Base Mainnet and Sepolia testnet
- Environment variables in `.env.example` for Flashblocks RPC URLs:
  - `BASE_SEPOLIA_PRECONF_URL`: Sepolia testnet Flashblocks endpoint
  - `BASE_PRECONF_URL`: Mainnet Flashblocks endpoint
- Deployment scripts use Flashblocks when available
- `flashblocks.sh` utility script to test Flashblocks functionality

### Frontend Integration

The frontend uses the utilities in `client/src/utils/flashblocks.ts` to:
- Create Viem clients configured for Flashblocks
- Check if a chain supports Flashblocks
- Automatically use Flashblocks RPC endpoints when available

## Deployment

The project includes deployment scripts for both Base Sepolia testnet and Base Mainnet:

### Base Sepolia Testnet

1. Set up your `.env` file with the required values from `.env.example`
2. Make sure your wallet has testnet funds
3. Run the deployment script:

```bash
./deploy.sh
```

### Base Mainnet

1. Make sure your `.env` has the required mainnet values
2. Ensure your wallet has funds for gas
3. Run the mainnet deployment script:

```bash
./deploy-to-base.sh
```

### Verifying Contracts

After deployment, verify your contracts on Basescan:

```bash
./verify.sh YOUR_CONTRACT_ADDRESS base_sepolia
# OR
./verify.sh YOUR_CONTRACT_ADDRESS base
```

## Testing Flashblocks

To test Flashblocks functionality:

```bash
# Test on Sepolia testnet
./flashblocks.sh

# Test on Mainnet
./flashblocks.sh mainnet
```

## Development

Start the development server:

```bash
npm run dev
```

The app will be available at [http://localhost:5000](http://localhost:5000)

## Environment Setup

Copy `.env.example` to `.env` and fill in the required values:

```bash
cp .env.example .env
```

Required environment variables:
- `BASE_RPC_URL`: Base Mainnet RPC URL
- `BASE_SEPOLIA_RPC_URL`: Base Sepolia testnet RPC URL
- `BASE_PRECONF_URL`: Flashblocks preconfirmation endpoint for Mainnet
- `BASE_SEPOLIA_PRECONF_URL`: Flashblocks preconfirmation endpoint for Sepolia
- `PRIVATE_KEY`: Your wallet's private key for deployments