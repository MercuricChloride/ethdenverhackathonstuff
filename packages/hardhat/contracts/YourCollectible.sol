pragma solidity >=0.6.0 <0.7.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import 'base64-sol/base64.sol';

import './HexStrings.sol';
import './ToColor.sol';
//learn more: https://docs.openzeppelin.com/contracts/3.x/erc721

// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

interface RegistryInterface {
    function balanceOf(address account, uint256 id) external view returns (uint256);
}

contract YourCollectible is ERC721, Ownable {

  using Strings for uint256;
  using HexStrings for uint160;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  RegistryInterface public registry;

  constructor(address _registry) public ERC721("EmblemSVG", "MBLM") {
    registry = RegistryInterface(_registry);
  }

  struct metadata {
      string badgeDefinition;
      string timestamp;
  }

  mapping(uint => metadata) public id2metadata;

  function mintItem(uint badgeDefinition)
      public
      returns (uint256)
  {
      //require(registry.balanceOf(msg.sender, badgeDefinition) == 1, 'msg.sender not a winner of this badgeDefinition');
      _tokenIds.increment();
      uint256 id = _tokenIds.current();
      id2metadata[id].badgeDefinition = uint2str(badgeDefinition);
      id2metadata[id].timestamp = uint2str(block.timestamp);
      _mint(msg.sender, id);
      return id;
  }

  function tokenURI(uint256 id) public view override returns (string memory) {
      require(_exists(id), "not exist");
      string memory name = string(abi.encodePacked('Badge #',id.toString()));
      string memory description = string(abi.encodePacked('This badge is for badge definition #',id2metadata[id].badgeDefinition,' minted at ',id2metadata[id].timestamp,'!'));
      string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

      return
          string(
              abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                          abi.encodePacked(
                              '{"name":"',
                              name,
                              '", "description":"',
                              description,
                              //TODO (CHANGE THIS LINK)
                              '", "external_url":"https://emblemdao.com/token/',
                              id.toString(),
                              '", "attributes": [{"trait_type": "badgeDefinition", "value": "#',
                              id2metadata[id].badgeDefinition,
                              '"},{"trait_type": "timestamp", "value": ',
                              id2metadata[id].timestamp,
                              '}], "owner":"',
                              (uint160(ownerOf(id))).toHexString(20),
                              '", "image": "',
                              'data:image/svg+xml;base64,',
                              image,
                              '"}'
                          )
                        )
                    )
              )
          );
  }

  function generateSVGofTokenById(uint256 id) internal view returns (string memory) {

    string memory svg = string(abi.encodePacked(
      '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">',
        renderTokenById(id),
      '</svg>'
    ));

    return svg;
  }

  // Visibility is `public` to enable it being called by other contracts for composition.
  function renderTokenById(uint256 id) public view returns (string memory) {
    string memory render = string(abi.encodePacked(
        '<text x="10" y="50">SVG Badge Metrics</text>',
        '<text x="10" y="100">Badge Definition: ',id2metadata[id].badgeDefinition,'</text>',
        '<text x="10" y="150">Awarded: ',id2metadata[id].timestamp,'</text>'
    ));

    return render;
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
      if (_i == 0) {
          return "0";
      }
      uint j = _i;
      uint len;
      while (j != 0) {
          len++;
          j /= 10;
      }
      bytes memory bstr = new bytes(len);
      uint k = len;
      while (_i != 0) {
          k = k-1;
          uint8 temp = (48 + uint8(_i - _i / 10 * 10));
          bytes1 b1 = bytes1(temp);
          bstr[k] = b1;
          _i /= 10;
      }
      return string(bstr);
  }

   function transferFrom(address from, address to, uint tokenId) public override{}
  
   function safeTransferFrom(address from, address to, uint tokenId, bytes memory _data) public override{}
  
   function safeTransferFrom(address from, address to, uint tokenId) public override{}


}
