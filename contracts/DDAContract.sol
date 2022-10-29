// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import '@thesolidchain/pancake-swap-periphery/contracts/interfaces/IPancakeRouter02.sol';
contract DDAContract is AccessControl {
    
    enum CharityType {
        CHARITY,
        FUNDRAISER
    }

    address public SWAP_ROUTER_ADDRESS;
    address public WETH_ADDRESS;
    address public USDT_ADDRESS;
    address public OKAPI_ADDRESS;

    bytes32 private ADMIN_ROLE;
    struct Catalog {
        string vip; // charity
        string website; // charity
        string name;
        string email;
        string country;
        string summary;
        string detail;
        string photo;
        string title; // fundRaiser
        string location; // fundRaiser
    }
    struct CharityStruct {
        address wallet_address;
        CharityType charityType;
        uint256 fund; // fundRaiser
        Catalog catalog;
    }
    
    CharityStruct[] public charities;
    mapping(address => bool) private isExistAddress;

    modifier hasAdminRole() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    event Donate(
        address indexed _from,
        address indexed _to,
        address indexed _currency,
        uint256 amount,
        uint256 timestamp
    );

    event CreateCharity(
        address wallet_address,
        CharityType charityType,
        Catalog catalog,
        uint256 fund,
        uint256 timestamp
    );

    event RemoveCharity(
        address indexed wallet_address,
        uint256 timestamp
    );
    constructor(address _admin, address _swapRouter, address _weth, address _usdt, address _okapi) {
        _setupRole(ADMIN_ROLE, _admin);
        SWAP_ROUTER_ADDRESS = _swapRouter;
        WETH_ADDRESS = _weth;
        USDT_ADDRESS = _usdt;
        OKAPI_ADDRESS = _okapi;
    }
    function donate(uint256 _to, address _currency, uint256 _amount) external {
        IERC20 currency = IERC20(_currency);
        
        require (_amount > 1 ether, "Deposit amount error");
        require (currency.balanceOf(msg.sender) > _amount, "Not enough tokens!");
        require (isExistAddress[charities[_to].wallet_address], "FundRaiser's address isn't registered!");
        require (msg.sender != charities[_to].wallet_address, 'You can not send yourself');

        uint256 price = 1 ether;
        if (_currency == USDT_ADDRESS)
            price = 2 ether;
        uint256 usdtAmount = _amount * price / 1 ether;
        uint256 ratio = 10;

        if (usdtAmount >= 250000 ether) {
            ratio = 1;
        } else if (usdtAmount >= 100000 ether) {
            ratio = 3;
        } else if (usdtAmount >= 50000 ether) {
            ratio = 5;
        } else if (usdtAmount >= 10000 ether) {
            ratio = 7;
        } else {
            ratio = 10;
        }

        uint256 transferAmount = _amount * (100 - ratio) / 100;
        uint256 buyAmount = _amount * ratio / 100;
        charities[_to].fund = charities[_to].fund + transferAmount * price / 1 ether;
        currency.transferFrom(msg.sender, charities[_to].wallet_address, transferAmount);
        // swap(_currency, OKAPI_ADDRESS, buyAmount, 0, msg.sender);
        emit Donate(msg.sender, charities[_to].wallet_address, _currency, transferAmount, block.timestamp);
    }
    function createCharity(CharityType _type, Catalog calldata _catalog) external {
        require(!isExistAddress[msg.sender], 'This address is already exist');
        require( bytes(_catalog.email).length > 0 &&
                 bytes(_catalog.country).length > 0 &&
                 bytes(_catalog.summary).length > 0 &&
                 bytes(_catalog.detail).length > 0 &&
                 bytes(_catalog.photo).length > 0,
                 'There is empty string passed as parameter');

        charities.push(CharityStruct({
            wallet_address: msg.sender,
            charityType: _type,
            catalog: _catalog,
            fund:0
        }));
        isExistAddress[msg.sender] = true;
        emit CreateCharity(msg.sender, _type, _catalog, 0,  block.timestamp);
    }
    function removeCharity(uint index) public hasAdminRole{
        address userAddress = charities[index].wallet_address;
        isExistAddress[userAddress] = false;
        delete charities[index];
        emit RemoveCharity(userAddress, block.timestamp);
    }
    
    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) public {
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        
        IERC20(_tokenIn).approve(SWAP_ROUTER_ADDRESS, _amountIn);

        address[] memory path;
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        IPancakeRouter02(SWAP_ROUTER_ADDRESS).swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp + 60);
    }

    // function getTokenPrice(address pairAddress, uint amount) public view returns(uint)
    // {
    //     IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
    //     IERC20 token1 = IERC20(pair.token1);
    //     (uint Res0, uint Res1,) = pair.getReserves();

    //     // decimals
    //     uint res0 = Res0*(10**token1.decimals());
    //     return((amount*res0)/Res1); // return amount of token0 needed to buy token1
    // }
}
