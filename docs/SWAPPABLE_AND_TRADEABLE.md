# USDTY Swappable & Tradeable Features Guide

Complete documentation for swapping and trading capabilities.

## 📚 Table of Contents
1. [Swapping (DEX)](#swapping-dex)
2. [Trading (Order Book)](#trading-order-book)
3. [Advanced Usage](#advanced-usage)
4. [Fee Structure](#fee-structure)
5. [Security Considerations](#security-considerations)

---

## 🔄 Swapping (DEX)

### Overview
The USDTYSwap contract implements an **Automated Market Maker (AMM)** similar to Uniswap V2, allowing users to swap tokens through liquidity pools with constant product formula: **x*y=k**

### Creating a Liquidity Pool

```javascript
// Setup
const usdty = await ethers.getContractAt("USDTY", usdtyAddress);
const usdc = await ethers.getContractAt("IERC20", usdcAddress);
const swap = await ethers.getContractAt("USDTYSwap", swapAddress);

// Approve tokens
const amount0 = ethers.utils.parseUnits("1000", 6);  // 1000 USDTY
const amount1 = ethers.utils.parseUnits("1000", 6);  // 1000 USDC

await usdty.approve(swap.address, amount0);
await usdc.approve(swap.address, amount1);

// Create pool
const tx = await swap.createPool(
  usdty.address,
  usdc.address,
  amount0,
  amount1
);

const receipt = await tx.wait();
console.log("✅ Pool created!");
// Pool ID will be 1
```

### Key Parameters:
- **token0** & **token1**: Pool token addresses (will be sorted)
- **amount0** & **amount1**: Initial liquidity amounts
- **Returns**: Pool ID (1-indexed)

### Adding Liquidity

```javascript
const poolId = 1;
const addAmount0 = ethers.utils.parseUnits("500", 6);
const addAmount1 = ethers.utils.parseUnits("500", 6);

await usdty.approve(swap.address, addAmount0);
await usdc.approve(swap.address, addAmount1);

const tx = await swap.addLiquidity(poolId, addAmount0, addAmount1);
const receipt = await tx.wait();

console.log("✅ Liquidity added!");
console.log("Shares received:", receipt.events[2].args.shares.toString());
```

### Swapping Tokens

#### Swap Token0 → Token1 (USDTY → USDC)

```javascript
const poolId = 1;
const amountIn = ethers.utils.parseUnits("100", 6);  // 100 USDTY
const minAmountOut = ethers.utils.parseUnits("95", 6); // At least 95 USDC (5% slippage)

// First, get the exact amount out
const quote = await swap.getAmountOut(poolId, amountIn, true); // true = token0
console.log("Expected USDC:", ethers.utils.formatUnits(quote, 6));

// Approve tokens
await usdty.approve(swap.address, amountIn);

// Execute swap
const tx = await swap.swapToken0ToToken1(poolId, amountIn, minAmountOut);
const receipt = await tx.wait();

console.log("✅ Swap successful!");
console.log("USDC received:", ethers.utils.formatUnits(receipt.events[1].args.amountOut, 6));
```

#### Swap Token1 → Token0 (USDC → USDTY)

```javascript
const poolId = 1;
const amountIn = ethers.utils.parseUnits("100", 6);  // 100 USDC
const minAmountOut = ethers.utils.parseUnits("95", 6); // At least 95 USDTY

// Get quote
const quote = await swap.getAmountOut(poolId, amountIn, false); // false = token1
console.log("Expected USDTY:", ethers.utils.formatUnits(quote, 6));

// Approve tokens
await usdc.approve(swap.address, amountIn);

// Execute swap
const tx = await swap.swapToken1ToToken0(poolId, amountIn, minAmountOut);
const receipt = await tx.wait();

console.log("✅ Swap successful!");
```

### Removing Liquidity

```javascript
const poolId = 1;
const sharesToRemove = ethers.utils.parseUnits("1000", 6); // Remove 1000 shares

const tx = await swap.removeLiquidity(poolId, sharesToRemove);
const receipt = await tx.wait();

console.log("✅ Liquidity removed!");
console.log("Amount0:", ethers.utils.formatUnits(receipt.events[0].args.amount0, 6));
console.log("Amount1:", ethers.utils.formatUnits(receipt.events[0].args.amount1, 6));
```

### Querying Pool Information

```javascript
// Get pool details
const [token0, token1, reserve0, reserve1, totalShares] = await swap.getPoolInfo(1);

console.log(`Pool 1:
  Token0: ${token0}
  Token1: ${token1}
  Reserve0: ${ethers.utils.formatUnits(reserve0, 6)} units
  Reserve1: ${ethers.utils.formatUnits(reserve1, 6)} units
  Total Shares: ${ethers.utils.formatUnits(totalShares, 6)}`);

// Get LP shares for user
const myShares = await swap.getLPShares(1, userAddress);
console.log(`My LP shares: ${ethers.utils.formatUnits(myShares, 6)}`);

// Get price impact
const amountIn = ethers.utils.parseUnits("100", 6);
const amountOut = await swap.getAmountOut(1, amountIn, true);
const priceImpact = ((amountIn - amountOut) / amountIn) * 100;
console.log(`Price impact: ${priceImpact.toFixed(2)}%`);
```

---

## 📊 Trading (Order Book)

### Overview
The USDTYTrading contract implements a **decentralized order book** with support for:
- Create buy/sell orders
- Partial order fills
- Order expiration
- Fee-based model

### Creating an Order

```javascript
// User1 creates an order: Sell 1000 USDTY for 1000 USDC
const usdty = await ethers.getContractAt("USDTY", usdtyAddress);
const usdc = await ethers.getContractAt("IERC20", usdcAddress);
const trading = await ethers.getContractAt("USDTYTrading", tradingAddress);

// Set expiration to 24 hours from now
const expirationTime = Math.floor(Date.now() / 1000) + (24 * 60 * 60);

const amountIn = ethers.utils.parseUnits("1000", 6);   // 1000 USDTY
const amountOut = ethers.utils.parseUnits("1000", 6);  // 1000 USDC

// Approve tokens for escrow
await usdty.approve(trading.address, amountIn);

// Create order
const tx = await trading.createOrder(
  usdty.address,
  amountIn,
  usdc.address,
  amountOut,
  expirationTime
);

const receipt = await tx.wait();
console.log("✅ Order created!");
console.log("Order ID:", receipt.events[0].args.orderId.toString());
```

### Key Parameters:
- **tokenIn**: Token to sell
- **amountIn**: Amount to sell
- **tokenOut**: Token to receive
- **amountOut**: Target amount to receive
- **expirationTime**: Unix timestamp when order expires
- **Returns**: Order ID

### Filling an Order

#### Get Order Quote First

```javascript
const orderId = 1;
const amountToFill = ethers.utils.parseUnits("500", 6); // Fill half the order

const [amountOut, fee] = await trading.getOrderQuote(orderId, amountToFill);

console.log(`Order Quote:
  Amount In (you pay): ${ethers.utils.formatUnits(amountToFill, 6)} USDC
  Amount Out (you get): ${ethers.utils.formatUnits(amountOut, 6)} USDTY
  Trading Fee: ${ethers.utils.formatUnits(fee, 6)} USDTY (0.25%)`);
```

#### Fill the Order

```javascript
// User2 fills the order
const orderId = 1;
const amountToFill = ethers.utils.parseUnits("500", 6);

// Approve USDC
await usdc.approve(trading.address, ethers.utils.parseUnits("500", 6));

// Fill order
const tx = await trading.fillOrder(orderId, amountToFill);
const receipt = await tx.wait();

console.log("✅ Order filled!");
console.log("Tokens received:", ethers.utils.formatUnits(receipt.events[0].args.amountOut, 6));
```

### Canceling an Order

```javascript
const orderId = 1;

// Only order maker can cancel
const tx = await trading.connect(orderMaker).cancelOrder(orderId);
const receipt = await tx.wait();

console.log("✅ Order cancelled!");
console.log("Refunded amount:", ethers.utils.formatUnits(receipt.events[0].args.refundAmount, 6));
```

### Querying Order Information

#### Get Full Order Details

```javascript
const orderId = 1;
const order = await trading.getOrder(orderId);

console.log(`Order #${orderId}:
  Maker: ${order.maker}
  Token In: ${order.tokenIn}
  Amount In: ${ethers.utils.formatUnits(order.amountIn, 6)} units
  Token Out: ${order.tokenOut}
  Amount Out (target): ${ethers.utils.formatUnits(order.amountOut, 6)} units
  Amount Filled: ${ethers.utils.formatUnits(order.amountFilled, 6)} units
  Remaining: ${ethers.utils.formatUnits(order.remainingAmount, 6)} units
  Expires: ${new Date(order.expirationTime * 1000).toISOString()}
  Cancelled: ${order.cancelled}`);
```

#### Get Order Status

```javascript
const orderId = 1;
const status = await trading.getOrderStatus(orderId);

console.log(`Order Status: ${status}`);
// Possible values: OPEN, PARTIALLY_FILLED, FILLED, CANCELLED, EXPIRED
```

#### Get User's Orders

```javascript
const userAddress = "0x...";
const orderIds = await trading.getUserOrders(userAddress);

console.log(`User's Orders: ${orderIds.map(id => id.toString()).join(", ")}`);
```

---

## 🔧 Advanced Usage

### Multi-Hop Swaps (Swap Chain)

```javascript
// Swap A → B → C in multiple hops
const amountIn = ethers.utils.parseUnits("100", 6);

// Swap A to B
const amountAB = await swap.getAmountOut(poolAB, amountIn, true);
await tokenA.approve(swap.address, amountIn);
await swap.swapToken0ToToken1(poolAB, amountIn, amountAB.mul(95).div(100)); // 5% slippage

// Swap B to C
const amountBC = await swap.getAmountOut(poolBC, amountAB, true);
await tokenB.approve(swap.address, amountAB);
await swap.swapToken0ToToken1(poolBC, amountAB, amountBC.mul(95).div(100));

console.log("✅ Multi-hop swap complete!");
```

### Batch Fill Orders

```javascript
// Fill multiple orders from one account
const orderIds = [1, 2, 3];
const amounts = [
  ethers.utils.parseUnits("100", 6),
  ethers.utils.parseUnits("200", 6),
  ethers.utils.parseUnits("150", 6),
];

const totalApproval = amounts.reduce((a, b) => a.add(b));
await usdc.approve(trading.address, totalApproval);

for (let i = 0; i < orderIds.length; i++) {
  await trading.fillOrder(orderIds[i], amounts[i]);
  console.log(`✅ Order ${orderIds[i]} filled!`);
}
```

### Dynamic Price Discovery

```javascript
// Monitor price changes in pool
async function getPriceHistory(poolId, times) {
  const amountIn = ethers.utils.parseUnits("1", 6);
  
  for (const time of times) {
    const amountOut = await swap.getAmountOut(poolId, amountIn, true);
    const price = amountOut / amountIn;
    console.log(`${new Date(time).toISOString()}: Price = ${price.toFixed(6)}`);
  }
}
```

---

## 💰 Fee Structure

### DEX (Swap) Fees
- **Fee Rate:** 0.3% per swap
- **Collected in:** Native token pairs
- **Example:** 100 USDTY swap → 0.3 USDTY fee → 99.7 USDTY fee-adjusted input

```
amountInAfterFee = 100 * (1 - 0.003) = 99.7
amountOut = (99.7 * reserve1) / (reserve0 + 99.7)
```

### Order Book Trading Fees
- **Fee Rate:** 0.25% per order fill
- **Applied on:** Output token
- **Example:** Fill order for 1000 USDC → 2.5 USDC fee → 997.5 USDC to maker

```
fee = 1000 * 0.0025 = 2.5
amountToMaker = 1000 - 2.5 = 997.5
```

### Collecting Fees

```javascript
// For DEX
const collectedFees = await swap.collectedFees();
await swap.collectFees(treasuryAddress);

// For Trading
const tradingFees = await trading.collectedFees();
await trading.collectFees(usdcAddress, treasuryAddress);
```

---

## 🔐 Security Considerations

### 1. **Slippage Protection**
Always set realistic slippage on swaps:
```javascript
// Get current price
const amountOut = await swap.getAmountOut(poolId, amountIn, true);

// Set minimum with 5% tolerance
const minAmountOut = amountOut.mul(95).div(100);

// Execute swap
await swap.swapToken0ToToken1(poolId, amountIn, minAmountOut);
```

### 2. **Order Expiration**
Always check order expiration before filling:
```javascript
const order = await trading.getOrder(orderId);
require(block.timestamp <= order.expirationTime, "Order expired");
```

### 3. **Price Impact**
Monitor price impact in large swaps:
```javascript
const priceImpact = ((amountIn - amountOut) / amountIn) * 100;
if (priceImpact > 5) {
  console.warn("⚠️ High price impact:", priceImpact.toFixed(2), "%");
}
```

### 4. **Approvals**
Always verify contract allowances:
```javascript
const allowance = await token.allowance(userAddress, spenderAddress);
console.log(`Current allowance: ${ethers.utils.formatUnits(allowance, 6)}`);
```

---

## 📝 Summary

### Quick Reference

| Operation | Contract | Function |
|-----------|----------|----------|
| Create Pool | USDTYSwap | `createPool()` |
| Add Liquidity | USDTYSwap | `addLiquidity()` |
| Remove Liquidity | USDTYSwap | `removeLiquidity()` |
| Swap | USDTYSwap | `swapToken0ToToken1()` / `swapToken1ToToken0()` |
| Get Quote | USDTYSwap | `getAmountOut()` |
| Create Order | USDTYTrading | `createOrder()` |
| Fill Order | USDTYTrading | `fillOrder()` |
| Cancel Order | USDTYTrading | `cancelOrder()` |
| Get Order | USDTYTrading | `getOrder()` |

---

**Happy Trading! 🚀**
