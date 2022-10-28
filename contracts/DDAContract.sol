// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
import "hardhat/console.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
contract DDAContract is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private addressIdxs;
    address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 public uniswapRouter;
    
    address public okapiToken = 0x27441e83F4466De5d330d45b701f539064730C7E;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    bytes32 private ADMIN_ROLE;
    struct DonaterType {
        address _address;
        uint256 donations;
        string name;
    }
    struct CharityType {
        address _address;
        string name;
        string vip;
        string website;
        string email;
        string country;
        string summary;
        string detail;
        string photo;
        uint256 fund;
    }
    struct FundRaiserType {
        address _address;
        string title;
        string name;
        string email;
        string country;
        string location;
        string summary;
        string story;
        string _type;
        uint256 goal;
        uint256 fund;
        string photo;
        uint256 timestamp;
    }
    mapping(address => DonaterType) public donaters;
    mapping(address => CharityType) public charities;
    mapping(address => FundRaiserType) public fundRaisers;
    event Donate(
        address indexed _from,
        address indexed _to,
        address indexed currency,
        uint256 _amount,
        uint256 price,
        uint256 timestamp
    );
    event CreateCharity(
        address indexed _address,
        string name,
        string vip,
        string website,
        string email,
        string indexed country,
        string summary,
        string detail,
        string photo,
        uint256 timestamp
    );
    event RemoveCharity(
        address indexed _address,
        uint256 timestamp
    );
    event CreateFundRaiser(
        address indexed _address,
        string title,
        string name,
        string email,
        string country,
        string location,
        string summary,
        string story,
        string indexed _type,
        uint256 goal,
        string photo,
        uint256 timestamp
    );
    event RemoveFundRaiser(
        address indexed _address,
        uint256 timestamp
    );
    event CreateDonater(
        address indexed _address,
        string name,
        uint256 timestamp
    );
    event RemoveDonater(
        address indexed _address,
        uint256 timestamp
    );
    modifier hasAdminRole() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }
    modifier hasExistAddress() {
        require(charities[msg.sender]._address == address(0)
            && fundRaisers[msg.sender]._address == address(0)
            && donaters[msg.sender]._address == address(0)
            , 'This address is already exist');
        _;
    }
    constructor(address _admin) {
        _setupRole(ADMIN_ROLE, _admin);
    }
    /**
     * Donation function
     */
    function donate(address _to, address _currency, uint256 _amount, uint256 _price) external {
        IERC20 currency = IERC20(_currency);
        require (_amount > 0, "Deposit amount error");
        require (currency.balanceOf(msg.sender) > _amount, "Not enough tokens!");
        require (donaters[msg.sender]._address != address(0) , "Donater's address isn't registered!");
        require (fundRaisers[_to]._address != address(0) || charities[_to]._address != address(0), "FundRaiser's address isn't registered!");
        uint256 ratio = 10;
        uint256 usdAmount = _amount * price / 1 ether;
        if (usdAmount > 250000 ether) {
            ratio = 1;
        } else if (usdAmount > 100000 ether) {
            ratio = 3;
        } else if (usdAmount > 50000 ether) {
            ratio = 5;
        } else if (usdAmount > 10000 ether) {
            ratio = 7;
        } else {
            ratio = 10;
        }

        uint256 _transferAmount = _amount * (1000 - ratio) / 1000;
        uint256 _buyAmount = _amount * ratio / 1000;
        if (fundRaisers[_to]._address != address(0))
            fundRaisers[_to].fund = fundRaisers[_to].fund + _transferAmount * price / 1 ether;
        if (charities[_to]._address != address(0))
            charities[_to].fund = fundRaisers[_to].fund + _transferAmount * price / 1 ether;
        // currency.approve(address(this), _amount); // contract cannot call approve function
        currency.transferFrom(msg.sender, _to, _transferAmount);
        // swap(_currency, okapiToken, _buyAmount, 0, msg.sender);
        emit Donate(msg.sender, _to, _currency, _transferAmount, price, block.timestamp);
    }

    function createDonater(string memory name) external hasExistAddress{
        require( bytes(name).length > 0, 'There is empty string passed as parameter');

        addressIdxs.add(msg.sender);
        donaters[msg.sender] = DonaterType({
            _address: msg.sender,
            donations: 0,
            name: name
        });
        emit CreateDonater(msg.sender, name, block.timestamp);
    }
    function removeDonater() public {
        require(donaters[msg.sender]._address != address(0), 'This address is not exist');
        addressIdxs.remove(msg.sender);
        donaters[msg.sender]._address = address(0);
        emit RemoveDonater(msg.sender, block.timestamp);
    }
    function createCharity(string memory name, string memory vip, string memory website, string memory email, string memory country, string memory summary, string memory detail, string memory photo) external hasExistAddress {
        require(bytes(name).length > 0 && bytes(vip).length > 0 && bytes(website).length > 0 && bytes(email).length > 0 && bytes(country).length > 0 && bytes(summary).length > 0 && bytes(detail).length > 0 && bytes(photo).length > 0, 'There is empty string passed as parameter');

        addressIdxs.add(msg.sender);
        charities[msg.sender] = CharityType({
            _address: msg.sender,
            name: name,
            vip: vip,
            website: website,
            email: email,
            country: country,
            summary: summary,
            detail: detail,
            photo: photo,
            fund: 0
        });
        emit CreateCharity(msg.sender, name, vip, website, email, country, summary, detail, photo, block.timestamp);
    }
    function removeCharity() public {
        require(charities[msg.sender]._address != address(0), 'This address is not exist');
        addressIdxs.remove(msg.sender);        
        charities[msg.sender]._address = address(0);
        emit RemoveCharity(msg.sender, block.timestamp);
    }
    
    function createFundRaiser(string memory title, string memory name, string memory email, string memory country, string memory location, string memory summary, string memory story, string memory _type, uint256 goal, string memory photo) external hasExistAddress {
        require(goal >= 1 ether, 'Raise money could be at least $1');
        require(bytes(title).length > 0 && bytes(name).length > 0 && bytes(email).length > 0 && bytes(country).length > 0  && bytes(location).length > 0 && bytes(summary).length > 0 && bytes(story).length > 0 && bytes(_type).length > 0 && bytes(photo).length > 0, 'There is empty string passed as parameter');

        addressIdxs.add(msg.sender);
        fundRaisers[msg.sender] = FundRaiserType({
            _address: msg.sender,
            title: title,
            name: name,
            email: email,
            country: country,
            location: location,
            summary: summary,
            story: story,
            _type: _type,
            goal: goal,
            fund: 0,
            photo: photo,
            timestamp: block.timestamp
        });
        emit CreateFundRaiser(msg.sender, title, name, email, country, location, summary, story, _type, goal, photo, block.timestamp);
    }
    function removeFundRaiser() public {
        require(fundRaisers[msg.sender]._address != address(0), 'This address is not exist');
        addressIdxs.remove(msg.sender);
        fundRaisers[msg.sender]._address = address(0);
        emit RemoveFundRaiser(msg.sender, block.timestamp);
    }

    // buy okapi on uniswap
    function updateOkapi(address _okapiAddress) external hasAdminRole{
        okapiToken = _okapiAddress;
    }
    // function swap(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, address _to) public {
    //     IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        
    //     IERC20(_tokenIn).approve(UNISWAP_ROUTER_ADDRESS, _amountIn);

    //     address[] memory path;
    //     if (_tokenIn == WETH || _tokenOut == WETH) {
    //         path = new address[](2);
    //         path[0] = _tokenIn;
    //         path[1] = _tokenOut;
    //     } else {
    //         path = new address[](3);
    //         path[0] = _tokenIn;
    //         path[1] = WETH;
    //         path[2] = _tokenOut;
    //     }
    //     // for the deadline we will pass in block.timestamp
    //     IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS).swapExactTokensForTokens(_amountIn, _amountOutMin, path, _to, block.timestamp);
    // }
    

}
