// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract DDAContract {
    IERC20 usdt = IERC20(address(0xdAC17F958D2ee523a2206206994597C13D831ec7));
    bytes32 private ADMIN_ROLE;
    IERC20 private OkapiToken;
    EnumerableSet.AddressSet private CharityAddresseIdx;
    address private CharityAddresses;
    uint256 private limit10k = IWETH(100000);
    uint256 private limit50k = IWETH(500000);
    uint256 private limit100k = IWETH(1000000);
    uint256 private limit250k = IWETH(2500000);
    
    function doDonation(address _to, uint256 _amount) public {
        require( _amount >= IWETH(1), 'Deposit amount error');
        require (usdt.balanceOf(msg.sender) >= _amount, 'Not enough tokens!');
        require (!CharityAddresses[msg.sender], 'Charity address is invalid!');
        
        if (donation)
        uint256 _transferAmount = _amount * ratio;
        usdt.transfer(_to, _transferAmount);
    }

    function convertToOkapi(uint daiAmount, uint deadline) public payable {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = daiToken;

        uniswapRouter.swapETHForExactTokens.value(msg.value)(daiAmount, path, address(this), deadline);
        
        // refund leftover ETH to user
        msg.sender.call.value(address(this).balance)("");
    }
    function addCharity() public whenNotPaused{
        require(!CharityAddresses[msg.sender], 'The charity addres is existed!');
        CharityAddresseIdx.add(msg.sender);
        CharityAddresses[msg.sender] = msg.sender;
    }
}
