#!/bin/bash

# Ensure script exits on any error
set -e

# Load environment variables
if [ -f .env ]; then
  source .env
else
  echo "❌ Missing .env file. Please create one with BASE_RPC_URL"
  exit 1
fi

# Check required variables
if [[ -z "$BASE_RPC_URL" ]]; then
  echo "❌ BASE_RPC_URL is not set in .env"
  exit 1
fi

# Check if deployer keystore exists
KEYSTORE_PATH="$HOME/.foundry/keystores/deployer.json"
if [[ ! -f "$KEYSTORE_PATH" ]]; then
  echo "❌ Foundry keystore not found at $KEYSTORE_PATH"
  
  # Check if PRIVATE_KEY is set as fallback
  if [[ -z "$PRIVATE_KEY" ]]; then
    echo "❌ No PRIVATE_KEY found in .env and no keystore available"
    echo "To fix: Either set PRIVATE_KEY in .env or run 'cast wallet import deployer --interactive'"
    exit 1
  else
    echo "📝 Using PRIVATE_KEY from .env instead of keystore"
    PRIVATE_KEY_ARG="--private-key $PRIVATE_KEY"
  fi
else
  echo "🔑 Using deployer keystore for transaction signing"
  PRIVATE_KEY_ARG="--account deployer"
fi

# Confirm before deploying to mainnet
echo "⚠️  You are about to deploy to BASE MAINNET!"
echo "⚠️  This will use real funds from your wallet."
read -p "Are you sure you want to continue? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Deployment canceled."
  exit 0
fi

# Compile the contract
echo "🔧 Compiling smart contracts..."
forge build

# Deploy the contract
echo "🚀 Deploying Counter contract to Base Mainnet..."
if [[ -n "$PRIVATE_KEY_ARG" ]]; then
  DEPLOY_OUTPUT=$(forge create ./src/Counter.sol:Counter --rpc-url "$BASE_RPC_URL" $PRIVATE_KEY_ARG)
else
  DEPLOY_OUTPUT=$(forge create ./src/Counter.sol:Counter --rpc-url "$BASE_RPC_URL" --account deployer)
fi

# Extract and save the deployed contract address
CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oE "0x[a-fA-F0-9]{40}" | head -1)
if [[ -n "$CONTRACT_ADDRESS" ]]; then
  echo "✅ Deployed at address: $CONTRACT_ADDRESS"
  # Remove old entry and append new one
  sed -i '/^COUNTER_CONTRACT_ADDRESS_MAINNET/d' .env
  echo "COUNTER_CONTRACT_ADDRESS_MAINNET=\"$CONTRACT_ADDRESS\"" >> .env

  # Check if we should enable Flashblocks support
  if [[ -n "$BASE_PRECONF_URL" ]]; then
    echo "🚀 Testing Flashblocks preconfirmations on deployment..."
    # Call the increment function to test Flashblocks
    cast send "$CONTRACT_ADDRESS" "increment()" $PRIVATE_KEY_ARG --rpc-url "$BASE_PRECONF_URL"
    echo "✅ Transaction sent via Flashblocks preconfirmation endpoint"
  fi
else
  echo "❌ Failed to extract deployed contract address."
  exit 1
fi

# Call the number() function to verify deployment
echo "🔍 Verifying deployment with cast call..."
cast call "$CONTRACT_ADDRESS" "number()(uint256)" --rpc-url "$BASE_RPC_URL"

echo "✅ Deployment complete and verified on Base Mainnet!"
echo "Contract Address: $CONTRACT_ADDRESS"
echo ""
echo "You can verify your contract on Basescan by running:"
echo "./verify.sh $CONTRACT_ADDRESS base"