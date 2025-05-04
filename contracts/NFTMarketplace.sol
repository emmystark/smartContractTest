// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarketplace is ERC721, ReentrancyGuard {
    uint256 private _tokenIds;
    uint256 private _itemsSold;

    address payable owner;
    uint256 listingFee = 0.025 ether;
    uint256 royaltyPercentage = 5;

    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable creator;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated (
        uint256 indexed tokenId,
        address seller,
        address creator,
        uint256 price,
        bool sold
    );

    constructor() ERC721("MyNFTMarketplace", "MNM") {
        owner = payable(msg.sender);
    }

    function mintNFT(string memory tokenURI) public returns (uint256) {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        return newTokenId;
    }

    function createMarketItem(uint256 tokenId, uint256 price) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei");
        require(msg.value == listingFee, "Must send listing fee");
        require(ownerOf(tokenId) == msg.sender, "You don't own this NFT");

        idToMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(msg.sender),
            price,
            false
        );

        _transfer(msg.sender, address(this), tokenId);

        emit MarketItemCreated(tokenId, msg.sender, msg.sender, price, false);
    }

    function buyNFT(uint256 tokenId) public payable nonReentrant {
        MarketItem storage item = idToMarketItem[tokenId];
        require(!item.sold, "Item already sold");
        require(msg.value >= item.price, "Insufficient funds");

        uint256 royalty = (item.price * royaltyPercentage) / 100;
        item.creator.transfer(royalty);
        item.seller.transfer(item.price - royalty);
        owner.transfer(listingFee);

        _transfer(address(this), msg.sender, tokenId);
        item.sold = true;
        _itemsSold++;
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds;
        uint256 unsoldCount = itemCount - _itemsSold;
        MarketItem[] memory items = new MarketItem[](unsoldCount);
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= itemCount; i++) {
            if (!idToMarketItem[i].sold) {
                items[currentIndex] = idToMarketItem[i];
                currentIndex++;
            }
        }
        return items;
    }
}