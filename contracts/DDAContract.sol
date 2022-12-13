// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract DDAContract is AccessControl, Ownable {
    
    enum CharityType {
        CHARITY,
        FUNDRAISER
    }

    struct Catalog {
        CharityType charityType;
        uint256 fund;
        uint256 goal;
        string donateType;
        string photo;
    }
    struct CharityStruct {
        address walletAddress;
        Catalog catalog;
    }

    address public immutable SWAP_ROUTER_ADDRESS;
    address public immutable USDT_ADDRESS;
    address public immutable OKAPI_ADDRESS;
    address public immutable WETH_ADDRESS;
    address private immutable ETH_COMPARE_ADDRESS;
    AggregatorV3Interface  public immutable ETHUSD_PRICE_FEED;

    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 private constant CHARITY_ROLE = keccak256("CHARITY_ROLE");
    bytes32 private constant BLACK_ROLE = keccak256("BLACK_ROLE");

    CharityStruct[] public charities;
    address[] public adminUsers;

    modifier notBlackRole() {
        require (!hasRole(BLACK_ROLE, msg.sender), "Current wallet is in black list");
        _;
    }

    event Donate(
        address indexed _from,
        address indexed _to,
        address indexed _currency,
        uint256 amount,
        string _comment,
        uint256 timestamp
    );

    event CreateCharity(
        address indexed walletAddress,
        Catalog catalog,
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

    constructor(address _admin, address _swapRouter, address _usdt, address _okapi, address _ethUsdPriceAddress) {
        require (_admin != address(0), 'Admin address can not be zero.');
        require (_swapRouter != address(0), 'Admin address can not be zero.');
        require (_usdt != address(0), 'USDT address can not be zero.');

        SWAP_ROUTER_ADDRESS = _swapRouter;
        USDT_ADDRESS = _usdt; 
        OKAPI_ADDRESS = _okapi;
        ETHUSD_PRICE_FEED = AggregatorV3Interface(_ethUsdPriceAddress);
        WETH_ADDRESS = IUniswapV2Router02(SWAP_ROUTER_ADDRESS).WETH();
        ETH_COMPARE_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    }

    /**
     * @notice This function will send donation to (_to)th index of charities and buy Okapi token 
     * @param _to : the index of charity on charities list
     * @param _currency : the cryptocurrency address of donation
     * @param _amount : the amount of cryptocurrency : wei
    */
    function donate(uint256 _to, address _currency, uint256 _amount, string calldata _comment) external notBlackRole payable {
        IERC20 currency = IERC20(_currency);
        require (hasRole(CHARITY_ROLE, charities[_to].walletAddress), "FundRaiser's address isn't registered!");
        require (_amount > 100 wei, "The amount must be bigger than 100 wei!");
        require (charities[_to].walletAddress != msg.sender, "You can not donate to yourself");
        if (_currency == ETH_COMPARE_ADDRESS) {
            require (payable(msg.sender).balance > _amount, "Not have enough tokens!");
        }
        else {
            require (currency.balanceOf(msg.sender) > _amount, "Not have enough tokens!");
        }

        uint256 price = 1 ether;
        if (_currency != USDT_ADDRESS){
            if (_currency == ETH_COMPARE_ADDRESS) {
                (,int ethPrice,,,) = ETHUSD_PRICE_FEED.latestRoundData();
                price = uint256(ethPrice) * 1e8;
            }
            else {
                address pairAddress = IUniswapV2Factory(IUniswapV2Router02(SWAP_ROUTER_ADDRESS).factory()).getPair(USDT_ADDRESS, _currency);
                require (pairAddress != address(0), 'There is no pool between your token and usdt');
                price = getTokenPrice(pairAddress, _currency, 1 ether);
            }
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
        }
        uint256 transferAmount = _amount * (1000 - ratio) / 1000;
        uint256 buyAmount = _amount - transferAmount;
        charities[_to].catalog.fund = charities[_to].catalog.fund + transferAmount * price / 1 ether;

        if (_currency == ETH_COMPARE_ADDRESS) {
            payable(charities[_to].walletAddress).transfer(transferAmount);
            swap(_currency, OKAPI_ADDRESS, buyAmount, 0, msg.sender);
        }
        else {
            currency.transferFrom(msg.sender, charities[_to].walletAddress, transferAmount);
            currency.transferFrom(msg.sender, address(this), buyAmount);
            swap(_currency, OKAPI_ADDRESS, buyAmount, 0, msg.sender);
        }
        emit Donate(msg.sender, charities[_to].walletAddress, _currency, transferAmount, _comment, block.timestamp);
    }

    /**
     * @notice This function will create charity and store it to charities list 
     * @param _catalog : information of charity [vip, website, name, email, country, summary, detail, photo, title, location]
    */
    function createCharity(Catalog calldata _catalog) external notBlackRole {
        require (!hasRole(CHARITY_ROLE, msg.sender), "Current wallet is in charity list");
        require (_catalog.goal > 0, 'Your goal of your fundraising can not be zero');

        charities.push(CharityStruct({
            walletAddress: msg.sender,
            catalog: _catalog
        }));
        _setupRole(CHARITY_ROLE, msg.sender);
        emit CreateCharity(msg.sender, _catalog,  block.timestamp);
    }

    /**
     * @notice This function will remove charity and set it as black charity to block on this contract 
     * @param index: index of charity on charities list
     */
    function blackCharity(uint index) external onlyRole(ADMIN_ROLE) {
        require (charities.length > index, 'That charity is not existed!');
        address userAddress = charities[index].walletAddress;
        uint i;
        for(i = index + 1; i < charities.length; i++) {
            charities[i-1] = charities[i];
        }
        charities.pop();
        _revokeRole(CHARITY_ROLE, userAddress);
        _setupRole(BLACK_ROLE, userAddress);
        emit BlackCharity(userAddress, msg.sender, block.timestamp);
    }

    /**
     * @notice This function will create admin and store it to adminUser list 
     * @param _newAddress : new adminUser's addresss
    */
    function addAdmin(address _newAddress) external onlyOwner {
        require (!hasRole(ADMIN_ROLE, _newAddress), 'This address already has admin role');

        adminUsers.push(_newAddress);
        _setupRole(ADMIN_ROLE, _newAddress);
        emit AddAdmin(_newAddress, block.timestamp);
    }

    /**
     * @notice This function will remove ADMIN_ROLE of adminUser's selected index
     * @param _index: index of adminUser on adminUsers list
     */
    function removeAdmin(uint _index) external onlyOwner {
        require (adminUsers.length > _index, 'That address is not existed!');

        address userAddress = adminUsers[_index];
        uint i;
        for(i = _index + 1; i < adminUsers.length; i++) {
            adminUsers[i-1] = adminUsers[i];
        }
        adminUsers.pop();
        _revokeRole(ADMIN_ROLE, userAddress);
        emit RemoveAdmin(userAddress, block.timestamp);
    }

    function getCharities() public view returns (CharityStruct[] memory) {
        return charities;
    }

    function getAdminUsers() public view returns (address[] memory) {
        return adminUsers;
    }

    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) public payable {
        if (_tokenIn == ETH_COMPARE_ADDRESS) {
            address[] memory path = new address[](2);
            path[0] = WETH_ADDRESS;
            path[1] = _tokenOut;
            IUniswapV2Router02(SWAP_ROUTER_ADDRESS).swapExactETHForTokens{value: _amountIn}(_amountOutMin, path, _to, block.timestamp);
        }
        else {
            address[] memory path = new address[](3);
            IERC20(_tokenIn).approve(SWAP_ROUTER_ADDRESS, _amountIn);
            path[0] = _tokenIn;
            path[1] = WETH_ADDRESS;
            path[2] = _tokenOut;
            IUniswapV2Router02(SWAP_ROUTER_ADDRESS).swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
        
        }
    }

    function getTokenPrice(address pairAddress, address currency, uint amount) internal view returns(uint)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint Res0, uint Res1,) = pair.getReserves();
        if(pair.token1() == currency)
            return((amount*Res0)/Res1);
        else
            return((amount*Res1)/Res0);
    }

    function renounceRole(bytes32 role, address account) public override{
        revert("disabled");
    }

    function renounceOwnership() public override{
        revert("disabled");
    }
}
