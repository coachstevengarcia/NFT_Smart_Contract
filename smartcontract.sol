// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CBAI is ERC721, Ownable, ReentrancyGuard {

  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  uint256 totalSupply;
  uint256 currentSupply;
  uint256 NFTCost;
  mapping (address => uint256) whitelist;
  mapping (address => uint256) blacklist;
  bool isSaleActive = true;
  bool isWhitelistEnabled = false;

  constructor(string memory uri) ERC721("CBAI", "CBAI") {
    totalSupply = 50;
    currentSupply = 0;
    NFTCost = 0.001 ether;
    isSaleActive = false;
    setBaseURI(uri);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function mint(uint256 amount) public payable {
    require(msg.sender != address(0), "ERC721Mint: INVALID_ADDRESS.");
    require(totalSupply >= currentSupply + amount, "NOT ENOUGH NFTS AVAILABLE TO MINT.");
    require(amount <= 10, "CAN'T MINT MORE THAN 10 NFTS PER TRANSACTION");
    require(blacklist[msg.sender] < 1, "YOU ARE BLACKLISTED, UNABLE TO MINT");
    require(isSaleActive, "SALE IS NOT ACTIVE");

    if(msg.sender != owner()) {
      require(msg.value >= NFTCost * amount, "PLEASE SEND THE REQUIRED ETHER AMOUNT.");
    }

    for(uint256 i = 0; i < amount; i++) {
      _safeMint(msg.sender, currentSupply + 1);
      currentSupply++;
    }
  }

  function whitelistMint(uint256 amount) public payable {
    require(msg.sender != address(0), "ERC721Mint: INVALID_ADDRESS.");
    require(whitelist[msg.sender] > 0, "YOU ARE NOT IN THE WHITELIST OR ALREADY MINT THE MAXIMUM SLOTS");
    require(totalSupply >= currentSupply + amount, "NOT ENOUGH NFTS AVAILABLE TO MINT.");
    require(amount <= 10, "CAN'T MINT MORE THAN 10 NFTS PER TRANSACTION");
    require(blacklist[msg.sender] < 1, "YOU ARE BLACKLISTED, UNABLE TO MINT");
    require(isWhitelistEnabled, "WHITELIST IS NOT ACTIVE");

    if(msg.sender != owner()) {
      require(msg.value >= NFTCost * amount, "PLEASE SEND THE REQUIRED ETHER AMOUNT.");
    }

    for(uint256 i = 0; i < amount; i++) {
      _safeMint(msg.sender, currentSupply + 1);
      currentSupply++;
    }
  }


  function getTotalSupply() public view returns (uint256 supply) {
    return totalSupply;
  }

  function getCurrentSupply() public view returns (uint256 supply) {
    return currentSupply;
  }

  function tokenURI(uint256 tokenId)
  public
  view
  virtual
  override
  returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
    ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
    : "";
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setNFTCost(uint256 newNFTCost) public onlyOwner {
    NFTCost = newNFTCost;
  }

  function getBaseURI() view public returns (string memory) {
    return baseURI;
  }

  function getNFTCost() view public returns (uint256) {
    return NFTCost;
  }

  function getPublicSaleIsActive() view public returns (bool) {
    return isSaleActive;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function batchAddToWhitelist(address[] memory addresses) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      whitelist[addresses[i]] = 1;
    }
  }

  function singleAddToWhitelist(address newAddress) external onlyOwner {
    whitelist[newAddress] = 1;
  }

  function batchRemoveFromWhitelist(address [] memory addresses) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      whitelist[addresses[i]]--;
    }
  }

  function singleRemoveFromWhitelist(address addressToRemove) external onlyOwner {
    whitelist[addressToRemove]--;
  }

  function batchAddToBlacklist(address[] memory addresses) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      blacklist[addresses[i]] = 1;
    }
  }

  function singleAddToBlacklist(address newAddress) external onlyOwner {
    blacklist[newAddress] = 1;
  }

  function batchRemoveFromBlacklist(address [] memory addresses) external onlyOwner {
    for (uint256 i = 0; i < addresses.length; i++) {
      blacklist[addresses[i]]--;
    }
  }

  function singleRemoveFromBlacklist(address addressToRemove) external onlyOwner {
    blacklist[addressToRemove]--;
  }

  function adminIncreaseMaxSupply(uint16 newMaxSupply) external onlyOwner {
    totalSupply = newMaxSupply;
  }

  function adminManageSaleState(bool saleState) external onlyOwner {
    isSaleActive = saleState;
  }

  function adminManageWhitelistState(bool whitelistState) external onlyOwner {
    isWhitelistEnabled = whitelistState;
  }

  function withdraw() public payable onlyOwner nonReentrant{
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }
}