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
    
    IERC20 usdt = IERC20(address(0x528726caB4AaB84607Ff2A21a79e31d17D188693));

    bytes32 private adminRole;
    IERC20 private okapiToken;

    EnumerableSet.AddressSet private charityAddressIdx;
    mapping(address => bool) private charityAddresses;
    uint256 private limit10k = 10000 ether;
    uint256 private limit50k = 50000 ether;
    uint256 private limit100k = 100000 ether;
    uint256 private limit250k = 250000 ether;
    
    constructor(address _admin) public {
        _setupRole(adminRole, _admin);
    }
    function doDonation(address _to, uint256 _amount) public {
        require ( _amount >= 0, "Deposit amount error");
        require (usdt.balanceOf(msg.sender) >= _amount, "Not enough tokens!");
        require (!charityAddresses[msg.sender] , "Charity address is invalid");
        uint256 ratio = 10;
        if (_amount > limit250k) {
            ratio = 1;
        } else if (_amount > limit100k) {
            ratio = 3;
        } else if (_amount > limit50k) {
            ratio = 5;
        } else if (_amount > limit10k) {
            ratio = 7;
        } else {
            ratio = 10;
        }

        uint256 _transferAmount = _amount * (1000 - ratio) / 1000;
        usdt.transfer(_to, _transferAmount);
    }

    // function convertToOkapi(uint daiAmount, uint deadline) public payable {
    //     address[] memory path = new address[](2);
    //     path[0] = uniswapRouter.WETH();
    //     path[1] = daiToken;

    //     uniswapRouter.swapETHForExactTokens.value(msg.value)(daiAmount, path, address(this), deadline);
        
    //     // refund leftover ETH to user
    //     msg.sender.call.value(address(this).balance)("");
    // }
    function addCharity() public{
        require(!charityAddresses[msg.sender], 'The charity addres is existed!');
        charityAddressIdx.add(msg.sender);
        charityAddresses[msg.sender] = true;
    }
}
