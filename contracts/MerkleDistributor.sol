// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./interfaces/IMerkleDistributor.sol";
import "./Library.sol";

contract MerkleDistributor is IMerkleDistributor, ERC721, Ownable{
    struct Summary {
        uint256 score;
        string creature;
        uint256 index;
    }
    
    uint256 public count = 0;  // counter of token number

    bytes32 public immutable override merkleRoot;
    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;
    mapping(string => string) private urlMap;
    mapping(uint256 => Summary) private tokenSummary;

    constructor(bytes32 merkleRoot_) public 
        ERC721('metacraft1', 'metacraft1')
        Ownable() 
    {
        merkleRoot = merkleRoot_;
        urlMap["SlimeGolden"] = "https://storage.googleapis.com/opensea-prod.appspot.com/creature/50.png";
        urlMap["SlimeCopper"] = "https://storage.googleapis.com/opensea-prod.appspot.com/creature/50.png";
    }

    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 index, address account, uint256 score, string memory creature, bytes32[] calldata merkleProof) external override {
        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, score, creature));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

        // Mark it claimed and send the token.
        _setClaimed(index);
        _safeMint(account, count);
        tokenSummary[count] = Summary({score: score, creature: creature, index: index});
        count += 1;
        emit Claimed(index, account, score, creature);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        Summary memory summary = tokenSummary[tokenId];
        string memory level = scoreLevel(summary.score);
        string memory name = string(abi.encodePacked(summary.creature, " ", level,  "#", toString(tokenId)));
        string memory url = urlMap[string(abi.encodePacked(summary.creature, level))];
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',name, '",',
                        '"description": "Metacraft Summary",',
                        '"image":"', url, '",',
                        '"attributes": [',
                        abi.encodePacked(
                            '{"trait_type": "Score", "value": "',
                            toString(summary.score),
                            '"},',
                            '{"trait_type": "Creature", "value": "',
                            summary.creature,
                            '"},',
                            '{"trait_type": "Texture", "value": "',
                            level,
                            '"}'
                        ),
                        ']}'
                    )
                )));
        return string(abi.encodePacked('data:application/json;base64,', json));
    }

    function scoreLevel(uint256 score) internal pure returns (string memory) {
        if (score >= 2000) {
            return "Golden";
        }
        if (score >= 1000) {
            return "Silvery";
        }
        return "Copper";
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return '0';
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}