#!/bin/bash

# Ensure script exits on any error
set -e

# Load environment variables
if [ -f .env ]; then
  source .env
else
  echo "❌ Missing .env file. Please create one with BASE_SEPOLIA_PRECONF_URL and BASE_PRECONF_URL"
  exit 1
fi

# Select network
if [ "$1" == "mainnet" ]; then
  NETWORK="mainnet"
  RPC_URL="$BASE_PRECONF_URL"
  CONTRACT_ADDRESS="$COUNTER_CONTRACT_ADDRESS_MAINNET"
  echo "Using Base Mainnet Flashblocks endpoint: $RPC_URL"
else
  NETWORK="sepolia"
  RPC_URL="$BASE_SEPOLIA_PRECONF_URL"
  CONTRACT_ADDRESS="$COUNTER_CONTRACT_ADDRESS"
  echo "Using Base Sepolia Flashblocks endpoint: $RPC_URL"
fi

# Check required variables
if [[ -z "$RPC_URL" ]]; then
  echo "❌ Flashblocks RPC URL for $NETWORK is not set in .env"
  exit 1
fi

# Check if contract address is available
if [[ -z "$CONTRACT_ADDRESS" ]]; then
  echo "❌ No contract address found for $NETWORK in .env"
  echo "Please deploy a contract first using ./deploy.sh or ./deploy-to-base.sh"
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

# Get current counter value
echo "🔍 Current counter value before transaction:"
cast call "$CONTRACT_ADDRESS" "number()(uint256)" --rpc-url "$RPC_URL"

# Execute a transaction using Flashblocks preconfirmation
echo -e "\n⚡ Sending transaction via Flashblocks..."
START_TIME=$(date +%s.%N)

if [[ -n "$PRIVATE_KEY_ARG" ]]; then
  cast send "$CONTRACT_ADDRESS" "increment()" $PRIVATE_KEY_ARG --rpc-url "$RPC_URL"
else
  cast send "$CONTRACT_ADDRESS" "increment()" --account deployer --rpc-url "$RPC_URL"
fi

END_TIME=$(date +%s.%N)
ELAPSED_TIME=$(echo "$END_TIME - $START_TIME" | bc)
echo "⏱️  Transaction processed in approximately ${ELAPSED_TIME} seconds"

# Get updated counter value
echo -e "\n🔍 Updated counter value after transaction:"
cast call "$CONTRACT_ADDRESS" "number()(uint256)" --rpc-url "$RPC_URL"

echo -e "\n✅ Flashblocks transaction test complete!"
echo "For more information about Flashblocks, visit: https://docs.base.org/using-base/flashblocks"