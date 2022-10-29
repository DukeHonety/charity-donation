// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
import "hardhat/console.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@thesolidchain/pancake-swap-periphery/contracts/interfaces/IPancakeRouter02.sol';
contract DDAContract is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private addressIdxs;
    enum CharityType{ CHARITY, FUNDRAISER }
    address public SWAP_ROUTER_ADDRESS = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    address public WETH = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address public okapiToken = 0xBE301038121CbbA399843d5B88799CAdAb027Fe6;

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
        address _address;
        CharityType _type;
        uint256 fund; // fundRaiser
        Catalog catalog;
    }
    
    CharityStruct[] public charities;
    uint public totalCharity;
    mapping(address => bool) private addressAry;
    modifier hasAdminRole() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }
    event Donate(address indexed _from, address indexed _to, address indexed _currency, uint256 amount, uint256 timestamp);
    event CreateCharity(
        address _address,
        CharityType _type,
        Catalog _catalog,
        uint256 _fund,
        uint256 timestamp
    );
    event RemoveCharity(
        address indexed _address,
        uint256 timestamp
    );
    constructor(address _admin) {
        _setupRole(ADMIN_ROLE, _admin);
        totalCharity = 0;
    }
    function donate(uint256 _to, address _currency, uint256 _amount) external {
        IERC20 currency = IERC20(_currency);
        require (_amount > 1 ether, "Deposit amount error");
        require (currency.balanceOf(msg.sender) > _amount, "Not enough tokens!");
        require (addressAry[charities[_to]._address], "FundRaiser's address isn't registered!");
        require (msg.sender != charities[_to]._address, 'You can not send yourself');
        uint256 ratio = 10;
        if (_amount >= 250000 ether) {
            ratio = 1;
        } else if (_amount >= 100000 ether) {
            ratio = 3;
        } else if (_amount >= 50000 ether) {
            ratio = 5;
        } else if (_amount >= 10000 ether) {
            ratio = 7;
        } else {
            ratio = 10;
        }

        uint256 _transferAmount = _amount * (100 - ratio) / 100;
        uint256 _buyAmount = _amount * ratio / 100;
        charities[_to].fund = charities[_to].fund + _transferAmount;
        currency.transferFrom(msg.sender, charities[_to]._address, _transferAmount);
        swap(_currency, okapiToken, _buyAmount, 0, msg.sender);
        emit Donate(msg.sender, charities[_to]._address, _currency, _transferAmount, block.timestamp);
    }
    function createCharity(CharityType _type, Catalog calldata _catalog) external {
        require(!addressAry[msg.sender], 'This address is already exist');
        require( bytes(_catalog.email).length > 0 &&
                 bytes(_catalog.country).length > 0 &&
                 bytes(_catalog.summary).length > 0 &&
                 bytes(_catalog.detail).length > 0 &&
                 bytes(_catalog.photo).length > 0,
                 'There is empty string passed as parameter');

        addressIdxs.add(msg.sender);
        addressAry[msg.sender] = true;
        charities.push(CharityStruct({
            _address: msg.sender,
            _type: _type,
            catalog: _catalog,
            fund:0
        }));
        totalCharity += 1;
        emit CreateCharity(msg.sender, _type, _catalog, 0,  block.timestamp);
    }
    function removeCharity(uint index) public hasAdminRole{
        address userAddress = charities[index]._address;
        addressIdxs.remove(userAddress);
        addressAry[userAddress] = false;
        delete charities[index];
        totalCharity -= 1;
        emit RemoveCharity(userAddress, block.timestamp);
    }

    // buy okapi on uniswap
    function updateOkapi(address _okapiAddress) external hasAdminRole{
        okapiToken = _okapiAddress;
    }
    function updateRouter(address _swapRouter) external hasAdminRole{
        SWAP_ROUTER_ADDRESS = _swapRouter;
    }
    function updateWETH(address _wethAddress) external hasAdminRole{
        WETH = _wethAddress;
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
}
