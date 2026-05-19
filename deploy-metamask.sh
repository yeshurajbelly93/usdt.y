#!/bin/bash

# USDTY MetaMask Deployment Script
# This script guides you through deploying USDTY using MetaMask

echo ""
echo "=========================================="
echo "🦊 USDTY MetaMask Deployment Guide"
echo "=========================================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo ""
    echo "📝 Creating .env file..."
    cp .env.example .env
    echo "✅ Created .env"
    echo ""
    echo "⚙️  Please edit .env and add your MetaMask private key:"
    echo "   PRIVATE_KEY=your_private_key_without_0x_prefix"
    echo ""
    exit 1
fi

# Check if PRIVATE_KEY is set
if ! grep -q "PRIVATE_KEY=" .env || grep "PRIVATE_KEY=" .env | grep -q "your_"; then
    echo "❌ Error: PRIVATE_KEY not configured in .env!"
    echo ""
    echo "📝 Please edit .env and add your MetaMask private key:"
    echo "   1. Open MetaMask"
    echo "   2. Click account menu → Account Details → Show Private Key"
    echo "   3. Copy private key (WITHOUT 0x prefix)"
    echo "   4. Edit .env file and paste it"
    echo ""
    exit 1
fi

# Check npm and hardhat
if ! command -v npm &> /dev/null; then
    echo "❌ Error: npm not installed!"
    echo "   Download Node.js: https://nodejs.org/"
    exit 1
fi

if ! command -v npx &> /dev/null; then
    echo "❌ Error: npx not installed!"
    echo "   Run: npm install -g hardhat"
    exit 1
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    echo "✅ Dependencies installed"
    echo ""
fi

# Menu
echo "🌐 Select Network for Deployment:"
echo ""
echo "TESTNET (FREE):"
echo "  1) Sepolia (Ethereum Testnet) - FREE"
echo "  2) BSC Testnet (Binance Testnet) - FREE"
echo ""
echo "MAINNET (PAID):"
echo "  3) Ethereum Mainnet - ~$60-200"
echo "  4) BSC Mainnet - ~$1-5"
echo "  5) Deploy to ALL networks"
echo ""
echo "  0) Exit"
echo ""
read -p "Enter your choice (0-5): " choice

case $choice in
    1)
        echo ""
        echo "⚠️  Before deploying to Sepolia:"
        echo "   ✅ Have testnet ETH? (Get free from faucet)"
        echo "   ✅ MetaMask connected to Sepolia?"
        echo "   ✅ Checked gas prices?"
        echo ""
        read -p "Ready to deploy? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            echo ""
            echo "🚀 Deploying to Sepolia..."
            npx hardhat run scripts/deploy.js --network sepolia
        fi
        ;;
    2)
        echo ""
        echo "⚠️  Before deploying to BSC Testnet:"
        echo "   ✅ Have testnet BNB? (Get free from faucet)"
        echo "   ✅ MetaMask connected to BSC Testnet?"
        echo "   ✅ Checked gas prices?"
        echo ""
        read -p "Ready to deploy? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            echo ""
            echo "🚀 Deploying to BSC Testnet..."
            npx hardhat run scripts/deploy.js --network bscTestnet
        fi
        ;;
    3)
        echo ""
        echo "⚠️  MAINNET DEPLOYMENT WARNING!"
        echo "   💰 This will cost real ETH (~$60-200)"
        echo "   ✅ Have sufficient ETH?"
        echo "   ✅ Verified contract on testnet?"
        echo "   ✅ Checked current ETH price and gas?"
        echo ""
        read -p "I understand the cost. Deploy? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            echo ""
            echo "🚀 Deploying to Ethereum Mainnet..."
            npx hardhat run scripts/deploy.js --network ethereum
        fi
        ;;
    4)
        echo ""
        echo "⚠️  MAINNET DEPLOYMENT WARNING!"
        echo "   💰 This will cost real BNB (~$1-5)"
        echo "   ✅ Have sufficient BNB?"
        echo "   ✅ Verified contract on testnet?"
        echo "   ✅ Checked current BNB price and gas?"
        echo ""
        read -p "I understand the cost. Deploy? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            echo ""
            echo "🚀 Deploying to BSC Mainnet..."
            npx hardhat run scripts/deploy.js --network bsc
        fi
        ;;
    5)
        echo ""
        echo "⚠️  MAINNET DEPLOYMENT WARNING!"
        echo "   💰 This will deploy to ALL networks"
        echo "   💰 Mainnet deployments will cost real funds"
        echo "   ✅ Have sufficient ETH and BNB?"
        echo "   ✅ Really want to deploy to all networks?"
        echo ""
        read -p "I understand. Deploy to all? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            echo ""
            echo "🚀 Deploying to Sepolia..."
            npx hardhat run scripts/deploy.js --network sepolia
            echo ""
            echo "🚀 Deploying to BSC Testnet..."
            npx hardhat run scripts/deploy.js --network bscTestnet
            echo ""
            read -p "Continue with mainnet? (yes/no): " mainnet_confirm
            if [ "$mainnet_confirm" = "yes" ]; then
                echo ""
                echo "🚀 Deploying to Ethereum Mainnet..."
                npx hardhat run scripts/deploy.js --network ethereum
                echo ""
                echo "🚀 Deploying to BSC Mainnet..."
                npx hardhat run scripts/deploy.js --network bsc
            fi
        fi
        ;;
    0)
        echo ""
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo ""
        echo "❌ Invalid choice!"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "✨ DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "📁 Check deployment data:"
echo "   ls deployments/"
echo ""
echo "🔗 View on block explorer:"
echo "   Sepolia: https://sepolia.etherscan.io/"
echo "   BSC: https://bscscan.com/"
echo ""
echo "🔍 Verify contracts:"
echo "   npm run verify:ethereum"
echo "   npm run verify:bsc"
echo ""
echo "📖 For more help, see docs/METAMASK_DEPLOYMENT_GUIDE.md"
echo ""
