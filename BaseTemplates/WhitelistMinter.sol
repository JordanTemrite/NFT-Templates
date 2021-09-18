// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./ERC721.sol";
import "./Ownable.sol";
import "./Address.sol";
import "./SafeMath.sol";
import "./Counters.sol";
import "./PaymentSplitter.sol";

contract "WhitelistMinter" is ERC721, Ownable, PaymentSplitter {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Address for address;
    
    Counters.Counter private _tokenIdCounter;    

    mapping (uint256 => string) private _tokenURIs;
    mapping(address => uint256) public totalAvailableForUser;    

    string private _baseURIextended;
    
    uint256 public constant maxTokenSupply = 10000;
    bool public whiteListSale = false;
    bool public regularSale = false;
    uint256 public salePrice;
    
    address payable thisContract;
    
    
    address[] private _team = [
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        ];
    
    uint256[] private _teamShares = [
        100
        ];
    
    constructor() ERC721("WHITELISTSALE", "WLS") PaymentSplitter(_team, _teamShares) {
    }
    
    fallback() external payable {

  	}
  	
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter.current();
    }
    
    function setWhitelistSale(bool _trueOrFalse) external onlyOwner {
        whiteListSale = _trueOrFalse;
    }
    
    function setRegularSale(bool _trueOrFalse) external onlyOwner {
        regularSale = _trueOrFalse;
    }
    
    function setSalePrice(uint256 _priceInWei) external onlyOwner {
        salePrice = _priceInWei;
    }
    
    function viewWhitelistForUser(address _user) external view returns(uint256) {
        return totalAvailableForUser[_user];
    }
    
    function populateWhitelist(address[] memory _whitelisted) external onlyOwner {
        for(uint256 i = 0; i < _whitelisted.length; i++) {
            totalAvailableForUser[_whitelisted[i]] = totalAvailableForUser[_whitelisted[i]].add(2);
        }
    }
    
    function withdrawAll() external onlyOwner {
        for (uint256 i = 0; i < _team.length; i++) {
            address payable wallet = payable(_team[i]);
            release(wallet);
        }
    }
  	
  	function setBaseURI(string memory baseURI_) external onlyOwner() {
            _baseURIextended = baseURI_;
    }
    
    function setThisContract(address payable _thisContract) external onlyOwner {
        thisContract = _thisContract;
    }
    
    function whitelistBuy(uint256 _numberOfPasses) public payable {
        require(msg.value == calculateTotalPrice(_numberOfPasses), "INCORRECT AMOUNT SENT. SEND EXACT AMOUNTS");
        require(thisContract.send(msg.value), "RECIEVER MUST BE THIS CONTRACT");
        require(_tokenIdCounter.current().add(_numberOfPasses) <= maxTokenSupply, "ATTEMPTED TO MINT PAST MAX SUPPLY");
        require(totalAvailableForUser[msg.sender] >= 1, "OUT OF MINT ALLOTMENTS");
        require(whiteListSale == true, "SALE IS INACTIVE");
        
        for(uint256 i = 0; i < _numberOfPasses; i++) {
            totalAvailableForUser[msg.sender] = totalAvailableForUser[msg.sender].sub(1);
            _safeMint(msg.sender, _tokenIdCounter.current() + 1);
            _tokenIdCounter.increment();
        }
    }
    
    function regularSaleMint(uint256 _numberOfMints) public payable {
        require(thisContract.send(msg.value), "RECIEVER MUST BE THIS CONTRACT");
        require(msg.value == calculateTotalPrice(_numberOfMints), "INCORRECT AMOUNT SENT. SEND EXACT AMOUNTS");
        require(_tokenIdCounter.current().add(_numberOfMints) <= maxTokenSupply, "ATTEMPTED TO MINT PAST MAX SUPPLY");
        require(regularSale == true, "SALE IS INACTIVE");

        for(uint256 i = 0; i < _numberOfMints; i++) {
            _safeMint(msg.sender, _tokenIdCounter.current().add(1));
            _tokenIdCounter.increment(); 
        }
    }
    
    function calculateTotalPrice(uint256 _numberOfPasses) public view returns(uint256) {
        return salePrice.mul(_numberOfPasses);
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
            return _baseURIextended;
    }
    
}
