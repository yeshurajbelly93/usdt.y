// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title USDTY - Stable Coin Token with USDT Parity
 * @dev ERC20 token implementation with swappable and tradeable features
 * Total Supply: 100,000,000,000 tokens (100 billion)
 * Decimals: 6 (same as USDT)
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract USDTY is IERC20 {
    // Token metadata
    string public constant name = "USDTY";
    string public constant symbol = "USDTY";
    uint8 public constant decimals = 6;
    uint256 public constant MAX_SUPPLY = 100_000_000_000 * 10 ** 6; // 100 billion tokens
    
    // State variables
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // Ownership
    address public owner;
    mapping(address => bool) public minters;
    mapping(address => bool) public burners;
    
    // Pausable
    bool public paused = false;
    
    // Events
    event Paused(address indexed by);
    event Unpaused(address indexed by);
    event Burn(address indexed from, uint256 amount);
    event Mint(address indexed to, uint256 amount);
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event BurnerAdded(address indexed account);
    event BurnerRemoved(address indexed account);
    
    // Modifier for owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    // Modifier for when token is not paused
    modifier whenNotPaused() {
        require(!paused, "Token is paused");
        _;
    }
    
    // Modifier for minter
    modifier onlyMinter() {
        require(minters[msg.sender], "Not a minter");
        _;
    }
    
    // Modifier for burner
    modifier onlyBurner() {
        require(burners[msg.sender], "Not a burner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        minters[msg.sender] = true;
        burners[msg.sender] = true;
        
        // Initial mint to owner
        _mint(msg.sender, MAX_SUPPLY);
    }
    
    // ============ ERC20 Standard Functions ============
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner_, address spender) public view override returns (uint256) {
        return _allowances[owner_][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) 
        public 
        override 
        whenNotPaused 
        returns (bool) 
    {
        _transfer(sender, recipient, amount);
        
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Insufficient allowance");
        _approve(sender, msg.sender, currentAllowance - amount);
        
        return true;
    }
    
    // ============ Internal Functions ============
    
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "Transfer from zero address");
        require(to != address(0), "Transfer to zero address");
        require(amount > 0, "Amount must be greater than 0");
        require(_balances[from] >= amount, "Insufficient balance");
        
        _balances[from] -= amount;
        _balances[to] += amount;
        
        emit Transfer(from, to, amount);
    }
    
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "Approve from zero address");
        require(spender != address(0), "Approve to zero address");
        
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }
    
    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero address");
        require(_totalSupply + amount <= MAX_SUPPLY, "Exceeds max supply");
        
        _totalSupply += amount;
        _balances[to] += amount;
        
        emit Transfer(address(0), to, amount);
        emit Mint(to, amount);
    }
    
    function _burn(address from, uint256 amount) internal {
        require(from != address(0), "Burn from zero address");
        require(_balances[from] >= amount, "Insufficient balance to burn");
        
        _balances[from] -= amount;
        _totalSupply -= amount;
        
        emit Transfer(from, address(0), amount);
        emit Burn(from, amount);
    }
    
    // ============ Minting Functions ============
    
    function mint(address to, uint256 amount) public onlyMinter {
        _mint(to, amount);
    }
    
    function addMinter(address account) public onlyOwner {
        require(account != address(0), "Invalid address");
        minters[account] = true;
        emit MinterAdded(account);
    }
    
    function removeMinter(address account) public onlyOwner {
        minters[account] = false;
        emit MinterRemoved(account);
    }
    
    // ============ Burning Functions ============
    
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    
    function burnFrom(address account, uint256 amount) public onlyBurner {
        _burn(account, amount);
    }
    
    function addBurner(address account) public onlyOwner {
        require(account != address(0), "Invalid address");
        burners[account] = true;
        emit BurnerAdded(account);
    }
    
    function removeBurner(address account) public onlyOwner {
        burners[account] = false;
        emit BurnerRemoved(account);
    }
    
    // ============ Pause Functions ============
    
    function pause() public onlyOwner {
        paused = true;
        emit Paused(msg.sender);
    }
    
    function unpause() public onlyOwner {
        paused = false;
        emit Unpaused(msg.sender);
    }
    
    // ============ Admin Functions ============
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        owner = newOwner;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
}
