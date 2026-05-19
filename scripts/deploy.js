const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("\n========================================");
  console.log("🚀 USDTY TOKEN DEPLOYMENT SCRIPT");
  console.log("========================================\n");

  // Get network information
  const network = hre.network.name;
  const { chainId } = await hre.ethers.provider.getNetwork();
  const [deployer] = await hre.ethers.getSigners();

  console.log(`📍 Network: ${network} (Chain ID: ${chainId})`);
  console.log(`👤 Deployer: ${deployer.address}`);
  console.log(`💰 Deployer Balance: ${hre.ethers.utils.formatEther(await deployer.getBalance())} ETH/BNB\n`);

  // Check sufficient balance
  const balance = await deployer.getBalance();
  if (balance.lt(hre.ethers.utils.parseEther("0.5"))) {
    console.warn("⚠️  Warning: Balance may be insufficient for deployment!");
    console.log("   Please ensure you have enough gas fees.\n");
  }

  // Create deployments directory
  const deploymentsDir = path.join(__dirname, "../deployments");
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir, { recursive: true });
  }

  try {
    // ============ Deploy USDTY Token ============
    console.log("📦 Deploying USDTY Token Contract...");
    const USDTY = await hre.ethers.getContractFactory("USDTY");
    const usdty = await USDTY.deploy();
    await usdty.deployed();
    console.log("✅ USDTY deployed to:", usdty.address);

    // ============ Deploy USDTYSwap ============
    console.log("\n📦 Deploying USDTYSwap Contract...");
    const USDTYSwap = await hre.ethers.getContractFactory("USDTYSwap");
    const swap = await USDTYSwap.deploy(usdty.address);
    await swap.deployed();
    console.log("✅ USDTYSwap deployed to:", swap.address);

    // ============ Deploy USDTYTrading ============
    console.log("\n📦 Deploying USDTYTrading Contract...");
    const USDTYTrading = await hre.ethers.getContractFactory("USDTYTrading");
    const trading = await USDTYTrading.deploy(usdty.address);
    await trading.deployed();
    console.log("✅ USDTYTrading deployed to:", trading.address);

    // ============ Configure Roles ============
    console.log("\n⚙️  Configuring contract roles...");
    
    // Add USDTYSwap as minter and burner
    await usdty.addMinter(swap.address);
    console.log("✅ Added USDTYSwap as minter");
    
    await usdty.addBurner(swap.address);
    console.log("✅ Added USDTYSwap as burner");

    // Add USDTYTrading as minter and burner
    await usdty.addMinter(trading.address);
    console.log("✅ Added USDTYTrading as minter");
    
    await usdty.addBurner(trading.address);
    console.log("✅ Added USDTYTrading as burner");

    // ============ Save Deployment Data ============
    const deploymentData = {
      network: network,
      chainId: chainId,
      deployer: deployer.address,
      timestamp: new Date().toISOString(),
      contracts: {
        USDTY: {
          address: usdty.address,
          txHash: usdty.deployTransaction?.hash,
        },
        USDTYSwap: {
          address: swap.address,
          txHash: swap.deployTransaction?.hash,
        },
        USDTYTrading: {
          address: trading.address,
          txHash: trading.deployTransaction?.hash,
        },
      },
    };

    // Save to file
    const filename = path.join(deploymentsDir, `${chainId}-${network}.json`);
    fs.writeFileSync(filename, JSON.stringify(deploymentData, null, 2));
    console.log(`\n💾 Deployment data saved to: ${filename}`);

    // ============ Display Summary ============
    console.log("\n========================================");
    console.log("📊 DEPLOYMENT SUMMARY");
    console.log("========================================");
    console.log(`\n✅ Network: ${network} (Chain ID: ${chainId})`);
    console.log(`\n📍 Contract Addresses:`);
    console.log(`   USDTY Token:      ${usdty.address}`);
    console.log(`   USDTYSwap (DEX):  ${swap.address}`);
    console.log(`   USDTYTrading:     ${trading.address}`);
    console.log(`\n👤 Deployer: ${deployer.address}`);
    console.log(`\n⏰ Timestamp: ${new Date().toISOString()}`);

    // ============ Verification Info ============
    console.log("\n========================================");
    console.log("🔍 VERIFICATION (Next Steps)");
    console.log("========================================");
    console.log(`\nTo verify contracts on block explorer, run:\n`);
    console.log(`npx hardhat verify --network ${network} ${usdty.address}`);
    console.log(`npx hardhat verify --network ${network} ${swap.address} "${usdty.address}"`);
    console.log(`npx hardhat verify --network ${network} ${trading.address} "${usdty.address}"`);

    // Block Explorer Links
    console.log("\n========================================");
    console.log("🔗 BLOCK EXPLORER LINKS");
    console.log("========================================");

    let explorerUrl = "";
    if (chainId === 1) {
      explorerUrl = "https://etherscan.io/address/";
    } else if (chainId === 11155111) {
      explorerUrl = "https://sepolia.etherscan.io/address/";
    } else if (chainId === 56) {
      explorerUrl = "https://bscscan.com/address/";
    } else if (chainId === 97) {
      explorerUrl = "https://testnet.bscscan.com/address/";
    }

    if (explorerUrl) {
      console.log(`\nUSDTY: ${explorerUrl}${usdty.address}`);
      console.log(`USDTYSwap: ${explorerUrl}${swap.address}`);
      console.log(`USDTYTrading: ${explorerUrl}${trading.address}`);
    }

    console.log("\n========================================");
    console.log("✨ DEPLOYMENT COMPLETE! ✨");
    console.log("========================================\n");

  } catch (error) {
    console.error("\n❌ Deployment failed:");
    console.error(error);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
