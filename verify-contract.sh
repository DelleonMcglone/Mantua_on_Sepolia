#!/bin/bash

# Ensure script exits on any error
set -e

# Load environment variables
if [ -f .env ]; then
  source .env
else
  echo "❌ Missing .env file."
  exit 1
fi

# Check for contract address
if [[ -z "$COUNTER_CONTRACT_ADDRESS" ]]; then
  echo "❌ COUNTER_CONTRACT_ADDRESS is not set in .env"
  echo "💡 Deploy your contract first with ./deploy.sh"
  exit 1
fi

# Check for RPC URL
if [[ -z "$BASE_SEPOLIA_RPC_URL" ]]; then
  echo "❌ BASE_SEPOLIA_RPC_URL is not set in .env"
  exit 1
fi

# Verify the current counter value
echo "🔍 Checking current counter value..."
CURRENT_VALUE=$(cast call "$COUNTER_CONTRACT_ADDRESS" "number()(uint256)" --rpc-url "$BASE_SEPOLIA_RPC_URL")
echo "📊 Current counter value: $CURRENT_VALUE"

# Ask if user wants to increment the counter
read -p "Do you want to increment the counter? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Determine sending method
  SEND_CMD=""
  if [[ -n "$DEPLOYER_ACCOUNT" ]]; then
    echo "🔑 Using Foundry keystore account: $DEPLOYER_ACCOUNT"
    SEND_CMD="--account $DEPLOYER_ACCOUNT"
  elif [[ -n "$PRIVATE_KEY" ]]; then
    echo "🔑 Using private key from .env file"
    SEND_CMD="--private-key $PRIVATE_KEY"
  else
    echo "❌ No credentials found for sending transaction"
    exit 1
  fi

  # Increment the counter
  echo "📈 Incrementing counter..."
  cast send "$COUNTER_CONTRACT_ADDRESS" "increment()" --rpc-url "$BASE_SEPOLIA_RPC_URL" $SEND_CMD
  
  # Verify the updated value
  echo "🔍 Checking updated counter value..."
  NEW_VALUE=$(cast call "$COUNTER_CONTRACT_ADDRESS" "number()(uint256)" --rpc-url "$BASE_SEPOLIA_RPC_URL")
  echo "📊 Updated counter value: $NEW_VALUE"
fi

echo "✅ Verification complete!"