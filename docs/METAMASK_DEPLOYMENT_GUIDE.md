# 🦊 USDTY MetaMask Deployment Guide

Complete step-by-step guide to deploy USDTY using MetaMask with gas fee management.

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Getting MetaMask Private Key](#getting-metamask-private-key)
3. [Setup Project](#setup-project)
4. [Get Free Testnet Tokens](#get-free-testnet-tokens)
5. [Deploy via MetaMask](#deploy-via-metamask)
6. [View Contract Addresses](#view-contract-addresses)
7. [Verify Contracts](#verify-contracts)

---

## 🔧 Prerequisites

### Required Software:
- ✅ **Node.js v14+** - [Download](https://nodejs.org/)
- ✅ **npm** - Comes with Node.js
- ✅ **MetaMask Browser Extension** - [Install](https://metamask.io/)

### Required Accounts:
- ✅ **MetaMask Wallet** - Create account
- ✅ **GitHub Account** - To clone repo
- ✅ **Testnet Tokens** - Free from faucets

### System Requirements:
- ✅ 500MB disk space
- ✅ Internet connection
- ✅ 5-10 minutes

---

## 🦊 Getting MetaMask Private Key

### Step 1: Open MetaMask
```
Click the MetaMask icon in your browser
```

### Step 2: Access Account Details
```
1. Click the account avatar (top right)
2. Click "Account details"
3. Click "Show private key"
4. Enter your MetaMask password
```

### Step 3: Copy Private Key
```
⚠️ IMPORTANT:
- Copy the ENTIRE private key
- DO NOT include "0x" prefix
- Keep it SECRET - never share!
- Store in a safe place
```

### Example:
```
❌ WRONG:  0x1234567890abcdef...
✅ RIGHT:  1234567890abcdef...
```

---

## ⚙️ Setup Project

### Step 1: Clone Repository
```bash
git clone https://github.com/yeshurajbelly93/usdt.y.git
cd usdt.y
```

### Step 2: Install Dependencies
```bash
npm install
```

This will install:
- Hardhat (Ethereum development framework)
- Ethers.js (Web3 library)
- dotenv (Environment configuration)

### Step 3: Create Environment File
```bash
cp .env.example .env
```

### Step 4: Edit .env with Private Key
```bash
# Open .env file in your text editor
# Find this line:
PRIVATE_KEY=your_private_key_without_0x_prefix

# Replace with your actual private key:
PRIVATE_KEY=abc123def456...
```

### Step 5: Verify Setup
```bash
npm run compile
```

If successful, you'll see:
```
✓ Compiled successfully
```

---

## 💰 Get Free Testnet Tokens

### For Sepolia (Ethereum Testnet)

#### Method 1: Sepolia Faucet (Recommended)
```
1. Visit: https://sepoliafaucet.com/
2. Select "Sepolia ETH"
3. Paste your wallet address (from MetaMask)
4. Click "Send me ETH"
5. Wait 1-2 minutes
6. You'll receive 0.5 ETH free!
```

#### Method 2: Alchemy Faucet
```
1. Visit: https://www.alchemy.com/faucets/ethereum-sepolia
2. Connect MetaMask
3. Click "Send Me ETH"
4. You'll receive 0.5 ETH free!
```

#### Check Balance
```
1. Open MetaMask
2. Make sure you're on "Sepolia" network
3. Check your balance (should show ~0.5 ETH)
```

### For BSC Testnet (Binance Smart Chain)

#### Method 1: BSC Testnet Faucet
```
1. Visit: https://testnet.binance.org/faucet-smart
2. Copy your wallet address
3. Paste address in faucet
4. Click "Give me BNB"
5. Wait 1-2 minutes
6. You'll receive 0.5 BNB free!
```

#### Method 2: BscScan Faucet
```
1. Visit: https://testnet.bscscan.com/
2. Look for faucet link
3. Paste your address
4. Claim free BNB
```

#### Check Balance
```
1. Open MetaMask
2. Make sure you're on "BSC Testnet" (Chain ID: 97)
3. Check your balance (should show ~0.5 BNB)
```

---

## 🚀 Deploy via MetaMask

### Option 1: Interactive Deployment (Recommended)

```bash
# Make script executable (Mac/Linux)
chmod +x deploy-metamask.sh

# Run interactive script
./deploy-metamask.sh
```

This will:
1. ✅ Prompt you to select a network
2. ✅ Show gas cost estimates
3. ✅ Ask for confirmation
4. ✅ Connect to your MetaMask wallet
5. ✅ Deploy contracts

### Option 2: Direct Command

**Deploy to Sepolia Testnet (FREE)**
```bash
npm run deploy:sepolia
```

**Deploy to BSC Testnet (FREE)**
```bash
npm run deploy:bsc-testnet
```

**Deploy to Ethereum Mainnet (PAID)**
```bash
npm run deploy:ethereum
```

**Deploy to BSC Mainnet (PAID)**
```bash
npm run deploy:bsc
```

### What Happens During Deployment

#### 1. Hardhat Connects to Your Wallet
```
🔗 Connecting to hardhat network...
🦊 Using MetaMask account: 0x123...
```

#### 2. Compilation
```
📦 Compiling contracts...
✅ Compilation successful
```

#### 3. Deployment Begins
```
📤 Deploying USDTY Token...
⏳ Waiting for confirmation...
```

#### 4. MetaMask Popup (IMPORTANT!)
```
MetaMask Notification:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Contract Creation
From: 0x123...
To: Smart Contract
Data: (contract bytecode)
Gas Limit: 2,500,000
Gas Price: 2 gwei
Estimated Total: 0.005 ETH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Click ✅ CONFIRM to proceed
```

#### 5. Deployment Completes
```
✅ USDTY deployed to: 0x123...
✅ USDTYSwap deployed to: 0x456...
✅ USDTYTrading deployed to: 0x789...
```

---

## 📍 View Contract Addresses

### After Successful Deployment

You'll see output like:

```
========================================
📊 DEPLOYMENT SUMMARY
========================================

✅ Network: sepolia (Chain ID: 11155111)

📍 Contract Addresses:
   USDTY Token:      0x123456789abcdef...
   USDTYSwap (DEX):  0x987654321fedcba...
   USDTYTrading:     0xabcdef123456789...

👤 Deployer: 0x...
⏰ Timestamp: 2026-05-19T02:10:00Z

========================================
```

### Save These Addresses!
```
Create a file to save your contract addresses:
- USDTY: 0x123...
- USDTYSwap: 0x456...
- USDTYTrading: 0x789...
```

### View on Block Explorer

**Sepolia**
```
USDTY: https://sepolia.etherscan.io/address/0x123...
USDTYSwap: https://sepolia.etherscan.io/address/0x456...
USDTYTrading: https://sepolia.etherscan.io/address/0x789...
```

**BSC Testnet**
```
USDTY: https://testnet.bscscan.com/address/0x123...
USDTYSwap: https://testnet.bscscan.com/address/0x456...
USDTYTrading: https://testnet.bscscan.com/address/0x789...
```

---

## ✅ Verify Contracts

### Why Verify?
Verifying makes your contract code visible on the block explorer, so users can:
- ✅ See the actual code
- ✅ Verify it's legitimate
- ✅ Call functions directly from explorer

### Automatic Verification

After deployment, run:

```bash
# Verify on Sepolia
npx hardhat verify --network sepolia 0x123... # USDTY
npx hardhat verify --network sepolia 0x456... "0x123..." # USDTYSwap
npx hardhat verify --network sepolia 0x789... "0x123..." # USDTYTrading
```

### Manual Verification

1. Visit block explorer:
   - Sepolia: https://sepolia.etherscan.io/
   - BSC: https://bscscan.com/

2. Search for your contract address

3. Click "Verify and Publish"

4. Select:
   - Compiler: Solidity
   - Version: 0.8.19
   - License: MIT

5. Paste your contract code

6. Click "Verify"

---

## 💰 Gas Cost Reference

### Testnet (FREE)
```
Sepolia: 0 ETH (FREE faucet)
BSC Testnet: 0 BNB (FREE faucet)
```

### Mainnet (PAID)

**Ethereum Mainnet**
```
Gas Price: 20-100 gwei (typical)
Gas Used: ~2.5M
Estimated Cost: $50-500 USD
```

**BSC Mainnet**
```
Gas Price: 5-20 gwei (typical)
Gas Used: ~2.5M
Estimated Cost: $1-10 USD
```

Check current prices:
- ETH: https://ethgasstation.info/
- BNB: https://bscscan.com/gastracker

---

## 🚨 Troubleshooting

### Problem: "Insufficient funds"
**Solution:**
1. Check your balance in MetaMask
2. For testnet: Get free tokens from faucet
3. For mainnet: Send funds from exchange

### Problem: "Invalid private key"
**Solution:**
1. Check .env file has correct private key
2. Ensure no "0x" prefix
3. No extra spaces or quotes
4. Copy from MetaMask Account Details

### Problem: "Network timeout"
**Solution:**
1. Check internet connection
2. Try different RPC endpoint
3. Wait and try again
4. Check network status

### Problem: "Contract already exists"
**Solution:**
1. You've already deployed to this network
2. Check deployments/ folder for address
3. To redeploy: Delete old deployment file

### Problem: "MetaMask stuck on pending"
**Solution:**
1. Open MetaMask
2. Settings → Advanced → Reset Account
3. Try deployment again
4. Or increase gas price manually

---

## 🔐 Security Best Practices

✅ **DO:**
- Keep private key SECRET
- Use testnet first
- Verify contracts before mainnet
- Use hardware wallet (Ledger/Trezor) for mainnet
- Store addresses safely

❌ **DON'T:**
- Share private key with anyone
- Post private key on GitHub
- Use same key on multiple networks
- Deploy without testing
- Skip verification step

---

## 🎊 Next Steps After Deployment

1. ✅ View contracts on block explorer
2. ✅ Verify contracts
3. ✅ Test token transfers
4. ✅ Create liquidity pools
5. ✅ Test swapping functionality
6. ✅ Test order book trading
7. ✅ Deploy to mainnet (after testing)

---

## 📚 Additional Resources

- **Hardhat Docs**: https://hardhat.org/
- **Ethers.js**: https://docs.ethers.org/
- **MetaMask Help**: https://support.metamask.io/
- **Sepolia Faucets**: https://sepoliafaucet.com/
- **BSC Testnet**: https://testnet.binance.org/

---

## 🆘 Need Help?

1. Check deployment logs for errors
2. Review troubleshooting section
3. Check contract addresses in `deployments/` folder
4. Visit block explorer to verify
5. Check MetaMask for transaction history

---

**Happy Deploying! 🚀**
