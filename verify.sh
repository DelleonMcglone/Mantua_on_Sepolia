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

# ======== COUNTER VALUE CHECK ========
# Query the current counter value
CURRENT_VALUE=$(cast call "$COUNTER_CONTRACT_ADDRESS" "number()(uint256)" --rpc-url "$BASE_SEPOLIA_RPC_URL")
echo "📊 Current counter value: $CURRENT_VALUE"

# ======== INCREMENT COUNTER ========
echo ""
echo "Do you want to:"
echo "  [1] Just view the counter value"
echo "  [2] Increment the counter"
echo "  [3] Reset counter to specific value"
read -p "Select option (1-3): " CHOICE

if [[ "$CHOICE" == "1" ]]; then
  echo "✅ Done!"
  exit 0
fi

# Check if keystore exists before running transactions
KEYSTORE_PATH="$HOME/.foundry/keystores/deployer.json"
if [[ ! -f "$KEYSTORE_PATH" ]]; then
  echo "❌ Foundry keystore not found at $KEYSTORE_PATH"
  echo "To fix: Run 'cast wallet import deployer --interactive' and provide your private key"
  exit 1
fi

if [[ "$CHOICE" == "2" ]]; then
  echo "📈 Incrementing counter..."
  cast send "$COUNTER_CONTRACT_ADDRESS" "increment()" --rpc-url "$BASE_SEPOLIA_RPC_URL" --account deployer

  # Verify the updated value
  echo "🔍 Checking updated counter value..."
  NEW_VALUE=$(cast call "$COUNTER_CONTRACT_ADDRESS" "number()(uint256)" --rpc-url "$BASE_SEPOLIA_RPC_URL")
  echo "📊 Updated counter value: $NEW_VALUE"
  
elif [[ "$CHOICE" == "3" ]]; then
  read -p "Enter new counter value: " NEW_VALUE
  
  echo "🔄 Setting counter to $NEW_VALUE..."
  cast send "$COUNTER_CONTRACT_ADDRESS" "setNumber(uint256)" "$NEW_VALUE" --rpc-url "$BASE_SEPOLIA_RPC_URL" --account deployer
  
  # Verify the updated value
  echo "🔍 Checking updated counter value..."
  RESULT=$(cast call "$COUNTER_CONTRACT_ADDRESS" "number()(uint256)" --rpc-url "$BASE_SEPOLIA_RPC_URL")
  echo "📊 Updated counter value: $RESULT"
fi

echo "✅ Verification complete!"