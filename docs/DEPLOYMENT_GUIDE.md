# USDTY Deployment Guide

Complete guide for deploying USDTY to Ethereum and BNB Smart Chain networks.

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Setup](#setup)
3. [Network Configuration](#network-configuration)
4. [Deployment Steps](#deployment-steps)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)

---

## 🔧 Prerequisites

### Required:
- **Node.js** v14+ ([Download](https://nodejs.org/))
- **npm** or **yarn** package manager
- **Private Key** with ETH/BNB for gas fees (mainnet only)

### Recommended:
- **Etherscan API Key** for contract verification ([Get here](https://etherscan.io/apis))
- **BscScan API Key** for BSC verification ([Get here](https://bscscan.com/apis))

---

## ⚙️ Setup

### Step 1: Clone Repository
```bash
git clone https://github.com/yeshurajbelly93/usdt.y.git
cd usdt.y
```

### Step 2: Install Dependencies
```bash
npm install
```

Or using yarn:
```bash
yarn install
```

### Step 3: Create Environment File
```bash
cp .env.example .env
```

### Step 4: Configure .env File
Edit `.env` with your settings:

```env
# Your private key (keep this SECRET!)
PRIVATE_KEY=your_private_key_without_0x_prefix

# RPC Endpoints
ETHEREUM_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR-API-KEY
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR-PROJECT-ID
BSC_RPC_URL=https://bsc-dataseed1.binance.org:443
BSC_TESTNET_RPC_URL=https://data-seed-prebsc-1-b.binance.org:8545

# Block Explorer API Keys
ETHERSCAN_API_KEY=your_etherscan_api_key
BSCSCAN_API_KEY=your_bscscan_api_key
```

---

## 🌐 Network Configuration

### Supported Networks:

| Network | Chain ID | RPC URL | Testnet |
|---------|----------|---------|---------|
| **Ethereum Mainnet** | 1 | https://eth-mainnet.g.alchemy.com/v2/demo | ❌ |
| **Sepolia Testnet** | 11155111 | https://sepolia.infura.io/v3/YOUR-PROJECT-ID | ✅ |
| **BSC Mainnet** | 56 | https://bsc-dataseed1.binance.org:443 | ❌ |
| **BSC Testnet** | 97 | https://data-seed-prebsc-1-b.binance.org:8545 | ✅ |

### Getting Test Tokens (Testnet):

#### Sepolia ETH:
1. Visit [Sepolia Faucet](https://sepoliafaucet.com/)
2. Connect wallet or paste address
3. Request ETH (free)

#### BSC Testnet BNB:
1. Visit [BSC Testnet Faucet](https://testnet.binance.org/faucet-smart)
2. Select "Testnet BNB"
3. Paste your address
4. Request BNB (free)

---

## 🚀 Deployment Steps

### Option 1: Interactive Deployment (Recommended)

```bash
bash deploy.sh
```

Follow the prompts to select networks.

### Option 2: Command Line Deployment

#### Deploy to Sepolia Testnet (FREE - TEST FIRST!)
```bash
npm run deploy:sepolia
```

#### Deploy to BSC Testnet (FREE - TEST FIRST!)
```bash
npm run deploy:bsc-testnet
```

#### Deploy to Ethereum Mainnet
```bash
npm run deploy:ethereum
```

#### Deploy to BSC Mainnet
```bash
npm run deploy:bsc
```

#### Deploy to Multiple Networks
```bash
npm run deploy:all
```

### Option 3: Manual Hardhat Command
```bash
npx hardhat run scripts/deploy.js --network sepolia
```

---

## 📊 What Gets Deployed

The deployment script automatically:

1. ✅ Deploys **USDTY** (ERC-20 Token)
   - Total Supply: 100 billion tokens
   - Decimals: 6 (USDT compatible)
   - Minting enabled
   - Burning enabled

2. ✅ Deploys **USDTYSwap** (DEX/AMM)
   - Create liquidity pools
   - Token swapping
   - 0.3% trading fee
   - AMM pricing

3. ✅ Deploys **USDTYTrading** (Order Book)
   - Create orders
   - Fill orders
   - 0.25% trading fee
   - Order expiration

4. ✅ Configures Roles
   - Sets USDTYSwap as minter/burner
   - Sets USDTYTrading as minter/burner
   - Ensures proper permissions

5. ✅ Saves Deployment Data
   - Creates `deployments/` folder
   - Saves addresses to JSON file
   - Records transaction details

---

## ✅ Deployment Success

After successful deployment, you'll see:

```
🚀 Starting USDTY Deployment...

📝 Deploying contracts with account: 0x...

🌐 Network: sepolia (Chain ID: 11155111)

📦 Deploying USDTY Token Contract...
✅ USDTY deployed to: 0x123...

📦 Deploying USDTYSwap Contract...
✅ USDTYSwap deployed to: 0x456...

📦 Deploying USDTYTrading Contract...
✅ USDTYTrading deployed to: 0x789...

============================================================
📊 DEPLOYMENT SUMMARY
============================================================

✅ Network: sepolia (Chain ID: 11155111)

📍 Contract Addresses:
   USDTY Token:      0x123...
   USDTYSwap (DEX):  0x456...
   USDTYTrading:     0x789...

👤 Deployer: 0x...

⏰ Timestamp: 2026-05-04T04:45:00Z

============================================================
```

---

## 🔍 Verification

After deployment, verify contracts on block explorer.

### Automatic Verification (Recommended)

```bash
npx hardhat verify --network sepolia 0x123... # USDTY
npx hardhat verify --network sepolia 0x456... 0x123... # USDTYSwap (needs USDTY address)
npx hardhat verify --network sepolia 0x789... 0x123... # USDTYTrading
```

### Manual Verification

1. Visit block explorer:
   - Ethereum: https://etherscan.io/
   - BSC: https://bscscan.com/
   - Sepolia: https://sepolia.etherscan.io/
   - BSC Testnet: https://testnet.bscscan.com/

2. Search for contract address

3. Click "Verify and Publish"

4. Select Solidity Compiler Version: **0.8.19**

5. Paste contract code and verify

---

## 💾 Deployment Data

After deployment, check `deployments/` folder:

```
deployments/
├── 1-ethereum.json          # Ethereum Mainnet
├── 11155111-sepolia.json    # Sepolia Testnet
├── 56-bsc.json              # BSC Mainnet
└── 97-bsc-testnet.json      # BSC Testnet
```

Each file contains:
```json
{
  "network": "sepolia",
  "chainId": 11155111,
  "deployer": "0x...",
  "timestamp": "2026-05-04T04:45:00Z",
  "contracts": {
    "USDTY": { "address": "0x123..." },
    "USDTYSwap": { "address": "0x456..." },
    "USDTYTrading": { "address": "0x789..." }
  }
}
```

---

## ⛽ Gas Estimation

### Testnet Deployment (FREE)
- Sepolia: Free (faucet provided)
- BSC Testnet: Free (faucet provided)

### Mainnet Deployment

| Network | Estimated Gas Cost | Current Price |
|---------|-------------------|----------------|
| **Ethereum** | ~2.5M gas | $60-200 (ETH price dependent) |
| **BSC** | ~2.5M gas | $1-5 (BNB price dependent) |

Get current gas prices:
- Ethereum: https://ethgasstation.info/
- BSC: https://bscscan.com/gastracker

---

## 🐛 Troubleshooting

### Problem: "Invalid private key"
**Solution:** 
- Ensure PRIVATE_KEY in .env doesn't have "0x" prefix
- Check for extra spaces or quotes
- Keep it SECRET - never share!

### Problem: "Insufficient funds"
**Solution:**
- Testnet: Use faucet to get free tokens
- Mainnet: Ensure wallet has ETH/BNB for gas
- Transfer funds from exchange to wallet

### Problem: "Failed to fetch RPC response"
**Solution:**
- Check internet connection
- Verify RPC URL in .env is correct
- Try alternative RPC provider
- Check if rate limit exceeded

### Problem: "Contract verification failed"
**Solution:**
- Wait 15-20 blocks before verifying
- Check correct Solidity version (0.8.19)
- Ensure constructor arguments match
- Use exact flattened source code

### Problem: "Network timeout"
**Solution:**
- Increase timeout in hardhat.config.js
- Try different RPC provider
- Deploy during low congestion times

---

## 📱 Interact After Deployment

### Using Web3.js

```javascript
const Web3 = require('web3');
const web3 = new Web3('https://sepolia.infura.io/v3/YOUR-PROJECT-ID');

// Get USDTY contract
const usdtyABI = require('./artifacts/contracts/USDTY.sol/USDTY.json').abi;
const usdtyAddress = '0x123...'; // From deployments file

const usdty = new web3.eth.Contract(usdtyABI, usdtyAddress);

// Check balance
const balance = await usdty.methods.balanceOf('0x...').call();
console.log('Balance:', web3.utils.fromWei(balance, 'mwei'));
```

### Using Ethers.js

```javascript
const ethers = require('ethers');

const provider = new ethers.providers.JsonRpcProvider(
  'https://sepolia.infura.io/v3/YOUR-PROJECT-ID'
);

const usdtyAddress = '0x123...';
const usdtyABI = require('./artifacts/contracts/USDTY.sol/USDTY.json').abi;

const usdty = new ethers.Contract(usdtyAddress, usdtyABI, provider);

// Get total supply
const totalSupply = await usdty.totalSupply();
console.log('Total Supply:', ethers.utils.formatUnits(totalSupply, 6));
```

---

## 🎊 Next Steps

1. ✅ Deploy to testnet first
2. ✅ Verify contracts on block explorer
3. ✅ Test swapping and trading
4. ✅ Create liquidity pools
5. ✅ Deploy to mainnet
6. ✅ List on DEX aggregators
7. ✅ Create marketing materials

---

**Happy Deploying! 🚀**
