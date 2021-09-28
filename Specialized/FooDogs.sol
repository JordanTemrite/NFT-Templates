// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./ERC721.sol";
import "./Ownable.sol";
import "./Address.sol";
import "./SafeMath.sol";
import "./Counters.sol";

contract FooDogs is ERC721, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Address for address;
    
    Counters.Counter private _tokenIdCounter;
    
    address public immutable buddhaContract = 0x7559190a5087c111A7937E424302F45C050C44Ee;

    mapping (uint256 => string) private _tokenURIs;
    mapping(address => uint256) public totalMinted;
    mapping(address => uint256) public _totalRedeemed;

    string private _baseURIextended;
    
    uint256 public constant maxTokenSupply = 8888;
    bool public reservedMint = false;
    bool public freeForAll = false;
    
    constructor() ERC721("FooDogs", "FOO") {
    }
  	
  	function getOwned(address _owner) public view returns(uint256) {
  	    return IERC721(buddhaContract).balanceOf(_owner);
  	}
  	
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter.current();
    }
    
    function setReservedMint(bool _trueOrFalse) external onlyOwner {
        reservedMint = _trueOrFalse;
    }
    
    function setFreeForAll(bool _trueOrFalse) external onlyOwner {
        freeForAll = _trueOrFalse;
    }
  	
  	function setBaseURI(string memory baseURI_) external onlyOwner() {
        _baseURIextended = baseURI_;
    }
    
    function reservedRedemption() public payable {
        uint256 owned = getOwned(msg.sender);
        require(owned != 0, "YOU DO NOT OWN ANY BUDDHAS");
        uint256 eligible = owned.sub(_totalRedeemed[msg.sender]);
        require(eligible != 0, "ALREADY MINTED ALLOTED AMOUNT");
        require(_tokenIdCounter.current().add(eligible) <= maxTokenSupply, "ATTEMPTED TO MINT PAST MAX SUPPLY");
        require(reservedMint == true, "RESERVED MINT INACTIVE");
        
        for(uint256 i = 0; i < eligible; i++) {
            _totalRedeemed[msg.sender] = _totalRedeemed[msg.sender].add(1);
            _safeMint(msg.sender, _tokenIdCounter.current().add(1));
            _tokenIdCounter.increment();
        }
    }
    
    function freeForAllRedemption(uint256 _numberOfMints) public payable {
        require(_tokenIdCounter.current().add(_numberOfMints) <= maxTokenSupply, "ATTEMPTED TO MINT PAST MAX SUPPLY");
        require(freeForAll == true, "FREE FOR ALL INACTIVE");

        for(uint256 i = 0; i < _numberOfMints; i++) {
            _safeMint(msg.sender, _tokenIdCounter.current().add(1));
            _tokenIdCounter.increment(); 
        }
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
            return _baseURIextended;
    }
    
}
