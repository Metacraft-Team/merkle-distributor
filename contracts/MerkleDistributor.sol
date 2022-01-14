// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./interfaces/IMerkleDistributor.sol";

contract MerkleDistributor is IMerkleDistributor, ERC721, Ownable{
    bytes32 public immutable override merkleRoot;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;
    mapping(string => string) private urlMap;

    constructor(bytes32 merkleRoot_) public 
        ERC721('metacraft', 'metacraft')
        Ownable() 
    {
        merkleRoot = merkleRoot_;
        urlMap["Slime1"] = "https://storage.googleapis.com/opensea-prod.appspot.com/creature/50.png";
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
        _safeMint(account, index);
        emit Claimed(index, account, score, creature);
    }

    function tokenURI(uint256 tokenId) public pure override returns (string memory) {
        return "data:application/json;base64,ewogICJuYW1lIjogIkhlcmJpZSBTdGFyYmVsbHkiLAogICJkZXNjcmlwdGlvbiI6ICJGcmllbmRseSBPcGVuU2VhIENyZWF0dXJlIHRoYXQgZW5qb3lzIGxvbmcgc3dpbXMgaW4gdGhlIG9jZWFuLiIsCiAgImltYWdlIjogImh0dHBzOi8vc3RvcmFnZS5nb29nbGVhcGlzLmNvbS9vcGVuc2VhLXByb2QuYXBwc3BvdC5jb20vY3JlYXR1cmUvNTAucG5nIiwKICAiYXR0cmlidXRlcyI6IFtdCn0=";
    }

    function scoreLevel(uint256 score) internal pure returns (string memory) {
        if (score >= 2000) {
            return "3";
        }
        if (score >= 1000) {
            return "2";
        }
        return "1";
    }
}
