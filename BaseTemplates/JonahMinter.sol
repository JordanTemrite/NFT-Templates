// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "./ERC721.sol";
import "./Ownable.sol";
import "./Address.sol";
import "./SafeMath.sol";
import "./Counters.sol";

contract Minter is ERC721, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Address for address;
    
    mapping (uint256 => string) private _tokenURIs;

    string private _baseURIextended;
    
    Counters.Counter private _tokenIdCounter;
    
    uint256 public constant maxMintPassSupply = 10000;
    
    constructor() ERC721("MintPass", "MINTPASS") {
    }
  	
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter.current();
    }
    
  	function setBaseURI(string memory baseURI_) external onlyOwner() {
            _baseURIextended = baseURI_;
    }
    
    function mintNfts(uint256 _numberOfPasses) public payable {
        require(_tokenIdCounter.current().add(_numberOfPasses) <= maxMintPassSupply, "Purchase would exceed max supply");
        
        for(uint256 i = 0; i < _numberOfPasses; i++) {
            _safeMint(msg.sender, _tokenIdCounter.current() + 1);
            _tokenIdCounter.increment();
        }
    }    
    
    function _baseURI() internal view virtual override returns (string memory) {
            return _baseURIextended;
    }
    
}
