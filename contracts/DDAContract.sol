// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;
import "hardhat/console.sol";


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

contract DDAContract is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private addressIdxs;

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
        string _type;
    }
    struct FundRaiserType {
        address _address;
        uint256 goal;
        uint256 fund;
        string name;
        string country;
        string location;
        string story;
        string _type;
    }
    mapping(address => DonaterType) public donaters;
    mapping(address => CharityType) public charities;
    mapping(address => FundRaiserType) public fundRaisers;
    event Donate(
        address indexed _from,
        address indexed _to,
        uint256 _amount,
        uint256 timestamp
    );
    event CreateCharity(
        address indexed _address,
        string title,
        string country,
        string location,
        string indexed _type,
        uint256 timestamp
    );
    event RemoveCharity(
        address indexed _address,
        uint256 timestamp
    );
    event CreateFundRaiser(
        address indexed _address,
        uint256 goal,
        uint256 fund,
        string name,
        string country,
        string location,
        string story,
        string indexed _type,
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
    constructor(address _admin) public {
        _setupRole(ADMIN_ROLE, _admin);
    }
    /**
     * Donation function
     */
    function donate(address _to, address _currency, uint256 _amount) external {
        IERC20 currency = IERC20(_currency);
        require ( _amount > 0, "Deposit amount error");
        require (currency.balanceOf(msg.sender) < _amount, "Not enough tokens!");
        require (donaters[msg.sender]._address != address(0) , "Donater's address isn't registered!");
        require (fundRaisers[_to]._address != address(0) , "FundRaiser's address isn't registered!");
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

        // fundRaisers[_to].fund += _transferAmount;
        currency.approve(address(this), _amount);
        currency.transferFrom(msg.sender, _to, _transferAmount);
        emit Donate(msg.sender, _to, _transferAmount, block.timestamp);

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
    function createCharity(string memory title, string memory country, string memory location, string memory _type) external hasExistAddress {
        require(bytes(title).length > 0 && bytes(country).length > 0 && bytes(location).length > 0 && bytes(_type).length > 0, 'There is empty string passed as parameter');

        addressIdxs.add(msg.sender);
        charities[msg.sender] = CharityType({
            _address: msg.sender,
            title: title,
            country: country,
            location: location,
            _type: _type
        });
        emit CreateCharity(msg.sender, title, country, location, _type, block.timestamp);
    }
    function removeCharity() public {
        require(charities[msg.sender]._address != address(0), 'This address is not exist');
        addressIdxs.remove(msg.sender);        
        charities[msg.sender]._address = address(0);
        emit RemoveCharity(msg.sender, block.timestamp);
    }
    function createFundRaiser(uint256 goal, string memory name, string memory country, string memory location, string memory story, string memory _type) external hasExistAddress {
        require(goal >= 1 ether, 'Raise money could be at least $1');
        require(bytes(name).length > 0 && bytes(country).length > 0  && bytes(location).length > 0 && bytes(story).length > 0 && bytes(_type).length > 0, 'There is empty string passed as parameter');

        addressIdxs.add(msg.sender);
        fundRaisers[msg.sender] = FundRaiserType({
            _address: msg.sender,
            goal: goal,
            fund: 0,
            name: name,
            country: country,
            location: location,
            story: story,
            _type: _type
        });
        emit CreateFundRaiser(msg.sender, goal, 0, name, country, location, story, _type, block.timestamp);
    }
    function removeFundRaiser() public {
        require(fundRaisers[msg.sender]._address != address(0), 'This address is not exist');
        addressIdxs.remove(msg.sender);
        fundRaisers[msg.sender]._address = address(0);
        emit RemoveFundRaiser(msg.sender, block.timestamp);
    }

    // function getDonater(address _address) external view returns(DonaterType memory) {
    //     return donaters[_address];
    // }
    // function getCharity(address _address) external view returns (CharityType memory) {
    //     return charities[_address];
    // }
    // function getFundRaiser(address _address) external view returns (FundRaiserType memory) {
    //     return fundRaisers[_address];
    // }
}
