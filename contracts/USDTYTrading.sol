// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title USDTYTrading - Order Book Trading Contract for USDTY
 * @dev Enables peer-to-peer trading with order books and matching
 * Features: Create orders, fill orders, cancel orders, order expiration
 */

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract USDTYTrading {
    // Order structure
    struct Order {
        uint256 orderId;
        address maker;
        address tokenIn;
        uint256 amountIn;
        address tokenOut;
        uint256 amountOut;
        uint256 amountFilled;
        uint256 expirationTime;
        bool cancelled;
        uint256 createdAt;
    }
    
    // State variables
    address public owner;
    address public usdtyToken;
    
    uint256 public nextOrderId = 1;
    mapping(uint256 => Order) public orders;
    mapping(address => uint256[]) public userOrders;
    
    uint256 public feeCollected;
    uint256 public constant FEE_PERCENTAGE = 25; // 0.25% (25 basis points)
    uint256 public constant FEE_DIVISOR = 10000;
    
    // Events
    event OrderCreated(
        uint256 indexed orderId,
        address indexed maker,
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint256 amountOut,
        uint256 expirationTime
    );
    
    event OrderFilled(
        uint256 indexed orderId,
        address indexed filler,
        uint256 amountFilled,
        uint256 amountOutReceived,
        uint256 fee
    );
    
    event OrderCancelled(
        uint256 indexed orderId,
        address indexed maker,
        uint256 refundAmount
    );
    
    event FeeCollected(address indexed tokenIn, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier orderExists(uint256 orderId) {
        require(orderId > 0 && orderId < nextOrderId, "Order does not exist");
        _;
    }
    
    modifier orderNotCancelled(uint256 orderId) {
        require(!orders[orderId].cancelled, "Order is cancelled");
        _;
    }
    
    modifier orderNotExpired(uint256 orderId) {
        require(block.timestamp <= orders[orderId].expirationTime, "Order expired");
        _;
    }
    
    modifier onlyOrderMaker(uint256 orderId) {
        require(msg.sender == orders[orderId].maker, "Only order maker");
        _;
    }
    
    constructor(address _usdtyToken) {
        owner = msg.sender;
        usdtyToken = _usdtyToken;
    }
    
    // ============ Order Creation ============
    
    function createOrder(
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint256 amountOut,
        uint256 expirationTime
    ) external returns (uint256 orderId) {
        require(tokenIn != address(0) && tokenOut != address(0), "Invalid tokens");
        require(tokenIn != tokenOut, "Tokens must be different");
        require(amountIn > 0 && amountOut > 0, "Amounts must be positive");
        require(expirationTime > block.timestamp, "Invalid expiration time");
        
        // Transfer tokenIn to contract (escrow)
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        
        orderId = nextOrderId++;
        
        orders[orderId] = Order({
            orderId: orderId,
            maker: msg.sender,
            tokenIn: tokenIn,
            amountIn: amountIn,
            tokenOut: tokenOut,
            amountOut: amountOut,
            amountFilled: 0,
            expirationTime: expirationTime,
            cancelled: false,
            createdAt: block.timestamp
        });
        
        userOrders[msg.sender].push(orderId);
        
        emit OrderCreated(
            orderId,
            msg.sender,
            tokenIn,
            amountIn,
            tokenOut,
            amountOut,
            expirationTime
        );
    }
    
    // ============ Order Filling ============
    
    function fillOrder(uint256 orderId, uint256 fillAmount) 
        external 
        orderExists(orderId)
        orderNotCancelled(orderId)
        orderNotExpired(orderId)
        returns (uint256 amountOut, uint256 fee)
    {
        Order storage order = orders[orderId];
        
        require(fillAmount > 0, "Fill amount must be positive");
        require(order.amountFilled + fillAmount <= order.amountIn, "Fill amount exceeds remaining");
        
        // Calculate output amount proportionally
        amountOut = (fillAmount * order.amountOut) / order.amountIn;
        
        // Calculate fee (0.25%)
        fee = (amountOut * FEE_PERCENTAGE) / FEE_DIVISOR;
        uint256 amountToMaker = amountOut - fee;
        
        // Transfer tokenIn from filler
        IERC20(order.tokenIn).transferFrom(msg.sender, address(this), fillAmount);
        
        // Transfer tokenOut to filler (net of fee)
        IERC20(order.tokenOut).transfer(msg.sender, amountToMaker);
        
        // Collect fee
        feeCollected += fee;
        
        // Update order state
        order.amountFilled += fillAmount;
        
        emit OrderFilled(orderId, msg.sender, fillAmount, amountToMaker, fee);
    }
    
    // ============ Order Cancellation ============
    
    function cancelOrder(uint256 orderId) 
        external 
        orderExists(orderId)
        onlyOrderMaker(orderId)
        orderNotCancelled(orderId)
        returns (uint256 refundAmount)
    {
        Order storage order = orders[orderId];
        order.cancelled = true;
        
        // Calculate refund (remaining unfilled amount)
        refundAmount = order.amountIn - order.amountFilled;
        
        if (refundAmount > 0) {
            IERC20(order.tokenIn).transfer(msg.sender, refundAmount);
        }
        
        emit OrderCancelled(orderId, msg.sender, refundAmount);
    }
    
    // ============ Query Functions ============
    
    function getOrder(uint256 orderId) 
        external 
        view 
        orderExists(orderId) 
        returns (Order memory) 
    {
        return orders[orderId];
    }
    
    function getOrderStatus(uint256 orderId) 
        external 
        view 
        orderExists(orderId) 
        returns (string memory) 
    {
        Order memory order = orders[orderId];
        
        if (order.cancelled) return "CANCELLED";
        if (block.timestamp > order.expirationTime) return "EXPIRED";
        if (order.amountFilled == order.amountIn) return "FILLED";
        if (order.amountFilled > 0) return "PARTIALLY_FILLED";
        return "OPEN";
    }
    
    function getOrderQuote(uint256 orderId, uint256 fillAmount) 
        external 
        view 
        orderExists(orderId) 
        returns (uint256 amountOut, uint256 fee) 
    {
        Order memory order = orders[orderId];
        
        require(fillAmount > 0, "Fill amount must be positive");
        require(order.amountFilled + fillAmount <= order.amountIn, "Fill amount exceeds remaining");
        
        amountOut = (fillAmount * order.amountOut) / order.amountIn;
        fee = (amountOut * FEE_PERCENTAGE) / FEE_DIVISOR;
    }
    
    function getRemainingAmount(uint256 orderId) 
        external 
        view 
        orderExists(orderId) 
        returns (uint256) 
    {
        Order memory order = orders[orderId];
        return order.amountIn - order.amountFilled;
    }
    
    function getUserOrders(address user) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return userOrders[user];
    }
    
    function getUserOrderCount(address user) 
        external 
        view 
        returns (uint256) 
    {
        return userOrders[user].length;
    }
    
    function getActiveOrders(address user) 
        external 
        view 
        returns (uint256[] memory activeOrders) 
    {
        uint256[] memory allOrders = userOrders[user];
        uint256 activeCount = 0;
        
        // Count active orders
        for (uint256 i = 0; i < allOrders.length; i++) {
            Order memory order = orders[allOrders[i]];
            if (!order.cancelled && 
                block.timestamp <= order.expirationTime && 
                order.amountFilled < order.amountIn) {
                activeCount++;
            }
        }
        
        // Create active orders array
        activeOrders = new uint256[](activeCount);
        uint256 index = 0;
        
        for (uint256 i = 0; i < allOrders.length; i++) {
            Order memory order = orders[allOrders[i]];
            if (!order.cancelled && 
                block.timestamp <= order.expirationTime && 
                order.amountFilled < order.amountIn) {
                activeOrders[index++] = allOrders[i];
            }
        }
    }
    
    // ============ Admin Functions ============
    
    function collectFees(address token, address recipient) 
        external 
        onlyOwner 
        returns (uint256 collected) 
    {
        require(feeCollected > 0, "No fees to collect");
        
        collected = feeCollected;
        feeCollected = 0;
        
        IERC20(token).transfer(recipient, collected);
        
        emit FeeCollected(token, collected);
    }
    
    function emergencyWithdraw(address token, uint256 amount) 
        external 
        onlyOwner 
    {
        IERC20(token).transfer(owner, amount);
    }
    
    // ============ Utility Functions ============
    
    function isOrderExpired(uint256 orderId) 
        external 
        view 
        orderExists(orderId) 
        returns (bool) 
    {
        return block.timestamp > orders[orderId].expirationTime;
    }
    
    function isOrderFilled(uint256 orderId) 
        external 
        view 
        orderExists(orderId) 
        returns (bool) 
    {
        Order memory order = orders[orderId];
        return order.amountFilled >= order.amountIn;
    }
    
    function calculateOutputAmount(uint256 orderId, uint256 fillAmount) 
        external 
        view 
        orderExists(orderId) 
        returns (uint256 amountOut) 
    {
        Order memory order = orders[orderId];
        amountOut = (fillAmount * order.amountOut) / order.amountIn;
    }
    
    function calculateFee(uint256 amountOut) 
        external 
        pure 
        returns (uint256) 
    {
        return (amountOut * FEE_PERCENTAGE) / FEE_DIVISOR;
    }
}
