#!/bin/bash

# Ensure script exits on any error
set -e

# Load environment variables
if [ -f .env ]; then
  source .env
else
  echo "❌ Missing .env file. Please create one with BASE_SEPOLIA_RPC_URL and BASE_RPC_URL"
  exit 1
fi

# Check required variables
if [[ -z "$BASE_SEPOLIA_RPC_URL" ]]; then
  echo "❌ BASE_SEPOLIA_RPC_URL is not set in .env"
  exit 1
fi

# Check if deployer keystore exists
KEYSTORE_PATH="$HOME/.foundry/keystores/deployer.json"
if [[ ! -f "$KEYSTORE_PATH" ]]; then
  echo "❌ Foundry keystore not found at $KEYSTORE_PATH"
  echo "To fix: Run 'cast wallet import deployer --interactive' and provide your private key"
  exit 1
fi

# Compile the contract
echo "🔧 Compiling smart contracts..."
forge build

# Deploy the contract
echo "🚀 Deploying Counter contract to Base Sepolia..."
DEPLOY_OUTPUT=$(forge create ./src/Counter.sol:Counter --rpc-url "$BASE_SEPOLIA_RPC_URL" --account deployer)

# Extract and save the deployed contract address
CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oE "0x[a-fA-F0-9]{40}" | head -1)
if [[ -n "$CONTRACT_ADDRESS" ]]; then
  echo "✅ Deployed at address: $CONTRACT_ADDRESS"
  # Remove old entry and append new one
  sed -i '/^COUNTER_CONTRACT_ADDRESS/d' .env
  echo "COUNTER_CONTRACT_ADDRESS=\"$CONTRACT_ADDRESS\"" >> .env
else
  echo "❌ Failed to extract deployed contract address."
  exit 1
fi

# Call the number() function to verify deployment
echo "🔍 Verifying deployment with cast call..."
cast call "$CONTRACT_ADDRESS" "number()(uint256)" --rpc-url "$BASE_SEPOLIA_RPC_URL"

echo "✅ Deployment complete and verified!"