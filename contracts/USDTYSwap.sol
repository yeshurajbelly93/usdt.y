// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title USDTYSwap - DEX-like Swap Contract for USDTY
 * @dev Enables swapping USDTY with other tokens (ETH, USDT, etc.)
 * Features: Liquidity pools, price calculation, slippage protection
 */

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract USDTYSwap {
    // Liquidity pool structure
    struct LiquidityPool {
        address token0;
        address token1;
        uint256 reserve0;
        uint256 reserve1;
        uint256 totalLiquidity;
        uint256 constant FEE_PERCENTAGE = 3; // 0.3% fee
    }
    
    // State variables
    address public owner;
    address public usdtyToken;
    
    mapping(bytes32 => LiquidityPool) public pools;
    mapping(address => mapping(address => bytes32)) public poolIds;
    
    uint256 public feeCollected;
    
    // Events
    event PoolCreated(address indexed token0, address indexed token1, uint256 initialLiquidity);
    event LiquidityAdded(address indexed provider, bytes32 poolId, uint256 amount0, uint256 amount1, uint256 liquidity);
    event LiquidityRemoved(address indexed provider, bytes32 poolId, uint256 amount0, uint256 amount1, uint256 liquidity);
    event Swap(address indexed trader, bytes32 poolId, address tokenIn, uint256 amountIn, uint256 amountOut);
    event FeeCollected(uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier validPool(bytes32 poolId) {
        require(pools[poolId].token0 != address(0), "Pool does not exist");
        _;
    }
    
    constructor(address _usdtyToken) {
        owner = msg.sender;
        usdtyToken = _usdtyToken;
    }
    
    // ============ Pool Management ============
    
    function createPool(address token0, address token1, uint256 amount0, uint256 amount1) 
        external 
        returns (bytes32 poolId) 
    {
        require(token0 != address(0) && token1 != address(0), "Invalid tokens");
        require(token0 != token1, "Tokens must be different");
        require(amount0 > 0 && amount1 > 0, "Amounts must be positive");
        
        // Ensure consistent ordering
        if (token0 > token1) {
            (token0, token1) = (token1, token0);
            (amount0, amount1) = (amount1, amount0);
        }
        
        poolId = keccak256(abi.encodePacked(token0, token1));
        require(pools[poolId].token0 == address(0), "Pool already exists");
        
        // Transfer tokens from caller
        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);
        
        // Initialize pool
        pools[poolId] = LiquidityPool({
            token0: token0,
            token1: token1,
            reserve0: amount0,
            reserve1: amount1,
            totalLiquidity: sqrt(amount0 * amount1)
        });
        
        poolIds[token0][token1] = poolId;
        poolIds[token1][token0] = poolId;
        
        emit PoolCreated(token0, token1, pools[poolId].totalLiquidity);
    }
    
    // ============ Liquidity Operations ============
    
    function addLiquidity(bytes32 poolId, uint256 amount0, uint256 amount1) 
        external 
        validPool(poolId) 
        returns (uint256 liquidity) 
    {
        LiquidityPool storage pool = pools[poolId];
        require(amount0 > 0 && amount1 > 0, "Amounts must be positive");
        
        // Calculate liquidity tokens
        liquidity = min(
            (amount0 * pool.totalLiquidity) / pool.reserve0,
            (amount1 * pool.totalLiquidity) / pool.reserve1
        );
        require(liquidity > 0, "Insufficient liquidity amount");
        
        // Transfer tokens
        IERC20(pool.token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(pool.token1).transferFrom(msg.sender, address(this), amount1);
        
        // Update reserves and liquidity
        pool.reserve0 += amount0;
        pool.reserve1 += amount1;
        pool.totalLiquidity += liquidity;
        
        emit LiquidityAdded(msg.sender, poolId, amount0, amount1, liquidity);
    }
    
    function removeLiquidity(bytes32 poolId, uint256 liquidity) 
        external 
        validPool(poolId) 
        returns (uint256 amount0, uint256 amount1) 
    {
        LiquidityPool storage pool = pools[poolId];
        require(liquidity > 0, "Liquidity must be positive");
        require(liquidity <= pool.totalLiquidity, "Insufficient liquidity");
        
        // Calculate amounts
        amount0 = (liquidity * pool.reserve0) / pool.totalLiquidity;
        amount1 = (liquidity * pool.reserve1) / pool.totalLiquidity;
        
        // Update reserves and liquidity
        pool.reserve0 -= amount0;
        pool.reserve1 -= amount1;
        pool.totalLiquidity -= liquidity;
        
        // Transfer tokens back
        IERC20(pool.token0).transfer(msg.sender, amount0);
        IERC20(pool.token1).transfer(msg.sender, amount1);
        
        emit LiquidityRemoved(msg.sender, poolId, amount0, amount1, liquidity);
    }
    
    // ============ Swap Functions ============
    
    function swap(bytes32 poolId, address tokenIn, uint256 amountIn, uint256 minAmountOut) 
        external 
        validPool(poolId) 
        returns (uint256 amountOut) 
    {
        LiquidityPool storage pool = pools[poolId];
        
        // Determine token order
        bool isToken0 = tokenIn == pool.token0;
        require(isToken0 || tokenIn == pool.token1, "Token not in pool");
        
        // Calculate output amount using Uniswap V2 formula: x*y = k
        uint256 amountWithFee = amountIn * (1000 - pool.FEE_PERCENTAGE) / 1000;
        
        if (isToken0) {
            amountOut = (pool.reserve1 * amountWithFee) / (pool.reserve0 + amountWithFee);
            require(amountOut >= minAmountOut, "Slippage too high");
            
            IERC20(pool.token0).transferFrom(msg.sender, address(this), amountIn);
            IERC20(pool.token1).transfer(msg.sender, amountOut);
            
            pool.reserve0 += amountIn;
            pool.reserve1 -= amountOut;
        } else {
            amountOut = (pool.reserve0 * amountWithFee) / (pool.reserve1 + amountWithFee);
            require(amountOut >= minAmountOut, "Slippage too high");
            
            IERC20(pool.token1).transferFrom(msg.sender, address(this), amountIn);
            IERC20(pool.token0).transfer(msg.sender, amountOut);
            
            pool.reserve1 += amountIn;
            pool.reserve0 -= amountOut;
        }
        
        // Collect fee
        uint256 fee = amountIn * pool.FEE_PERCENTAGE / 1000;
        feeCollected += fee;
        
        emit Swap(msg.sender, poolId, tokenIn, amountIn, amountOut);
    }
    
    // ============ Quote Functions ============
    
    function getAmountOut(bytes32 poolId, uint256 amountIn) 
        external 
        view 
        validPool(poolId) 
        returns (uint256 amountOut) 
    {
        LiquidityPool memory pool = pools[poolId];
        uint256 amountWithFee = amountIn * (1000 - pool.FEE_PERCENTAGE) / 1000;
        amountOut = (pool.reserve1 * amountWithFee) / (pool.reserve0 + amountWithFee);
    }
    
    function getPoolReserves(bytes32 poolId) 
        external 
        view 
        validPool(poolId) 
        returns (uint256 reserve0, uint256 reserve1, uint256 totalLiquidity) 
    {
        LiquidityPool memory pool = pools[poolId];
        return (pool.reserve0, pool.reserve1, pool.totalLiquidity);
    }
    
    // ============ Admin Functions ============
    
    function collectFees() external onlyOwner {
        require(feeCollected > 0, "No fees to collect");
        uint256 amount = feeCollected;
        feeCollected = 0;
        IERC20(usdtyToken).transfer(owner, amount);
        emit FeeCollected(amount);
    }
    
    // ============ Utility Functions ============
    
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
