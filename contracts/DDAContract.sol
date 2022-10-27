// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

// interface IERC20 {
//     function totalSupply() external view returns (uint);
//     function balanceOf(address account) external view returns (uint);
//     function transfer(address recipient, uint amount) external returns (bool);
//     function allowance(address owner, address spender) external view returns (uint);
//     function approve(address spender, uint amount) external returns (bool);
//     function transferFrom(
//         address sender,
//         address recipient,
//         uint amount
//     ) external returns (bool);
//     event Transfer(address indexed from, address indexed to, uint value);
//     event Approval(address indexed owner, address indexed spender, uint value);
// }

contract DDAContract is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private charityAddressIdx;

    bytes32 private ADMIN_ROLE;
    struct DonaterType {
        address _address;
        uint256 donations;
        string name;
    }
    struct CharityType {
        address _address;
        string title;
        string country;
        string location;
    }
    struct FundRaiserType {
        address walletAddress;
        uint256 goal;
        uint256 fund;
        string name;
        string country;
        string location;
        string story;
    }
    IERC20 usdt = IERC20(address(0x528726caB4AaB84607Ff2A21a79e31d17D188693));
    mapping(address => DonaterType) private donaters;
    mapping(address => CharityType) private charities;
    mapping(address => FundRaiserType) private fundRaisers;
    
    event Donate(
        address indexed _from,
        address indexed _to,
        uint256 _amount
    );

    event CreateCharity(
        string title,
        string indexed country,
        string indexed location
    );
    modifier hasAdminRole() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }
    constructor(address _admin) public {
        _setupRole(ADMIN_ROLE, _admin);
    }
    function donate(address _to, uint256 _amount) external {
        require ( _amount > 0, "Deposit amount error");
        require (usdt.balanceOf(msg.sender) < _amount, "Not enough tokens!");
        require (!charityAddresses[msg.sender] , "Charity address is invalid");
        uint256 ratio = 10;
        if (_amount > 250000 ether) {
            ratio = 1;
        } else if (_amount > 100000 ether) {
            ratio = 3;
        } else if (_amount > 50000 ether) {
            ratio = 5;
        } else if (_amount > 10000 ether) {
            ratio = 7;
        } else {
            ratio = 10;
        }

        uint256 _transferAmount = _amount * (1000 - ratio) / 1000;
        uint256 _buyAmount = _amount * ratio / 1000;
        emit Donate(msg.sender, _to, _amount);
    }

    function createCharity(string title, string country, string location) external {
        require(!charities[msg.sender], 'This address is already exist');
        require(title != '', 'Charity title is required');
        require(country != '', 'Country is required');
        require(location != '', 'Location is required');
        charities
        emit CreateCharity(title, country, location);
    }
    // function convertToOkapi(uint daiAmount, uint deadline) public payable {
    //     address[] memory path = new address[](2);
    //     path[0] = uniswapRouter.WETH();
    //     path[1] = daiToken;

    //     uniswapRouter.swapETHForExactTokens.value(msg.value)(daiAmount, path, address(this), deadline);
        
    //     // refund leftover ETH to user
    //     msg.sender.call.value(address(this).balance)("");
    // }
    
    function addCharity(bool type) public{
        require(!charities[msg.sender], 'The charity address is existed!');
        charityAddressIdx.add(msg.sender);
        charities[msg.sender] = CharityType ({
            walletAddress: msg.sender,
            type: type,
            funds: 0
        });
    }

    function removeCharity() public{
        require(!charities[msg.sender], 'The charity address is existed!');
    }
}
