//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Membership is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    bool public active = true;
    uint public max_supply;
    uint public price;
    uint public constant max_per_mint = 5;
    uint public membershipStartTime;
    uint public membershipEndTime;


    constructor (string memory _name, string memory _symbol, uint _max_supply, uint _price) ERC721(_name, _symbol) {
        max_supply = _max_supply;
        // a price of 5 is equal to 0.05
        price = _price * (10 ** 16);
        // set NFT to expire after one year
        membershipStartTime = block.timestamp;
        membershipEndTime = block.timestamp + 365 days;
    }

    function mintNFTs(uint _count) public payable {
        uint totalMinted = _tokenIds.current();

        require(totalMinted.add(_count) <= max_supply, "Not enough NFTs left!");
        require(_count > 0 && _count <= max_per_mint, "Cannot mint specified number of NFTs.");
        require(msg.value >= price.mul(_count), "Not enough ether to purchase NFTs.");

        for (uint i = 0; i < _count; i++) {
            _mintSingleNFT();
        }
    }

    function _mintSingleNFT() private {
        uint newTokenID = _tokenIds.current();
        _safeMint(msg.sender, newTokenID);
        _tokenIds.increment();
    }

    function tokensOfOwner(address _owner) external view returns (uint[] memory) {
        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint256[](tokenCount);

        for (uint i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    function checkExpiration() public payable {
        if (block.timestamp >= membershipEndTime) {
            active = false;
        }
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");

        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
}
