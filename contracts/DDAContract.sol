// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import '@thesolidchain/pancake-swap-periphery/contracts/interfaces/IPancakeRouter02.sol';
import '@uniswap/v2-core/contracts/interfaces/IPancakeFactory.sol';
import '@uniswap/v2-core/contracts/interfaces/IPancakePair.sol';

contract DDAContract is AccessControl {
    
    enum CharityType {
        CHARITY,
        FUNDRAISER
    }

    address public immutable SWAP_ROUTER_ADDRESS;
    address public immutable SWAP_FACTOR_ADDRESS;
    address public immutable WETH_ADDRESS;
    address public immutable USDT_ADDRESS;
    address public immutable OKAPI_ADDRESS;

    bytes32 private ADMIN_ROLE;

    struct Catalog {
        string vip;
        string website;
        string name;
        string email;
        string country;
        string summary;
        string detail;
        string photo;
        string title;
        string location;
    }
    struct CharityStruct {
        address walletAddress;
        CharityType charityType;
        uint256 fund;
        Catalog catalog;
    }
    
    CharityStruct[] public charities;
    address[] public adminUsers;
    mapping(address => bool) private isAdminAddress;
    mapping(address => bool) private isCharityAddress;
    mapping(address => bool) private isBlackAddress;

    modifier hasOwnerRole() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not owner");
        _;
    }

    modifier hasAdminRole() {
        require(isAdminAddress[msg.sender] == true, "Caller is not an admin");
        _;
    }

    modifier isInBlackList() {
        require(isBlackAddress[msg.sender] == false, "Current wallet is in black list");
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
        address walletAddress,
        CharityType charityType,
        Catalog catalog,
        uint256 fund,
        uint256 timestamp
    );

    event BlackCharity(
        address indexed walletAddress,
        address indexed adminAddress,
        uint256 timestamp
    );

    event AddAdmin(
        address indexed walletAddress,
        uint256 timestamp
    );

    event RemoveAdmin(
        address indexed walletAddress,
        uint256 timestamp
    );

    constructor(address _admin, address _swapRouter, address _weth, address _usdt, address _okapi) {
        SWAP_ROUTER_ADDRESS = _swapRouter;
        WETH_ADDRESS = _weth;
        USDT_ADDRESS = _usdt;
        OKAPI_ADDRESS = _okapi;
        SWAP_FACTOR_ADDRESS = IPancakeRouter02(SWAP_ROUTER_ADDRESS).factory();
        _setupRole(ADMIN_ROLE, _admin);
        adminUsers.push(_admin);
        isCharityAddress[_admin] = true;
        isAdminAddress[_admin] = true;
    }

    function donate(uint256 _to, address _currency, uint256 _amount) external isInBlackList{
        IERC20 currency = IERC20(_currency);
        require (currency.balanceOf(msg.sender) > _amount, "Not enough tokens!");
        require (isCharityAddress[charities[_to].walletAddress], "FundRaiser's address isn't registered!");
        require (msg.sender != charities[_to].walletAddress, 'You can not send yourself');

        uint256 price = 1 ether;
        if (_currency == USDT_ADDRESS)
            price = 1 ether;
        else{            
            address pairAddress = IPancakeFactory(SWAP_FACTOR_ADDRESS).getPair(USDT_ADDRESS, _currency);
            require (pairAddress != address(0), 'There is no pool between your token and usdt');
            price = getTokenPrice(pairAddress, _currency, 1 ether);
        }
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
            ratio = 100;
        }

        uint256 transferAmount = _amount * (10000 - ratio) / 10000;
        uint256 buyAmount = _amount * ratio / 10000;
        charities[_to].fund = charities[_to].fund + transferAmount * price / 1 ether;
        currency.transferFrom(msg.sender, charities[_to].walletAddress, transferAmount);
        swap(_currency, OKAPI_ADDRESS, buyAmount, 0, msg.sender);
        emit Donate(msg.sender, charities[_to].walletAddress, _currency, transferAmount, block.timestamp);
    }
    function createCharity(CharityType _type, Catalog calldata _catalog) external isInBlackList{
        require(!isCharityAddress[msg.sender], 'This address is already exist');
        require( bytes(_catalog.email).length > 0 &&
                 bytes(_catalog.country).length > 0 &&
                 bytes(_catalog.summary).length > 0 &&
                 bytes(_catalog.detail).length > 0 &&
                 bytes(_catalog.photo).length > 0,
                 'There is empty string passed as parameter');

        charities.push(CharityStruct({
            walletAddress: msg.sender,
            charityType: _type,
            catalog: _catalog,
            fund:0
        }));
        isCharityAddress[msg.sender] = true;
        emit CreateCharity(msg.sender, _type, _catalog, 0,  block.timestamp);
    }

    function blackCharity(uint index) public hasAdminRole{
        require(charities.length > index, 'That charity is not existed!');
        address userAddress = charities[index].walletAddress;
        uint i;
        for(i = index + 1; i < charities.length; i++) {
            charities[i-1] = charities[i];
        }
        charities.pop();
        isCharityAddress[userAddress] = false;
        isBlackAddress[userAddress] = true;
        emit BlackCharity(userAddress, msg.sender, block.timestamp);
    }

    function addAdmin(address _newAddress) public hasOwnerRole{
        require(!isCharityAddress[_newAddress], 'This address is in charity list');
        require(!isBlackAddress[_newAddress], 'This address is in black list');
        adminUsers.push(_newAddress);
        isAdminAddress[_newAddress] = true;
        emit AddAdmin(_newAddress, block.timestamp);
    }

    function removeAdmin(uint index) public hasOwnerRole{
        require(index != 0, 'Cannot remove owner from admin list');
        require(adminUsers.length > index, 'That address is not existed!');
        address userAddress = adminUsers[index];
        uint i;
        for(i = index + 1; i < adminUsers.length; i++) {
            adminUsers[i-1] = adminUsers[i];
        }
        adminUsers.pop();
        isAdminAddress[userAddress] = false;
        emit RemoveAdmin(userAddress, block.timestamp);
    }
    function getCharities() public view returns (CharityStruct[] memory){
        return charities;
    }

    function getAdminUsers() public view returns (address[] memory){
        return adminUsers;
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

    function getTokenPrice(address pairAddress, address currency, uint amount) public view returns(uint)
    {
        IPancakePair pair = IPancakePair(pairAddress);
        (uint Res0, uint Res1,) = pair.getReserves();
        if(pair.token1() == currency)
            return((amount*Res0)/Res1);
        else
            return((amount*Res1)/Res0);
    }
}
