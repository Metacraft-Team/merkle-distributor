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
        ERC721('Metacraft season pass 2022', 'MC2022')
        Ownable() 
    {
        merkleRoot = merkleRoot_;
        urlMap["SlimeGolden"] = "ar://7vpBOE3GJ4kJp63W8kWTnfGvkGGxqF0qVOlTYKm_bEw";
        urlMap["SlimeSilvery"] = "ar://rde367iRyDFJgn9-43UfuAKLbNv-EufF7VKfCb-uPUo";
        urlMap["SlimeCopper"] = "ar://gdP5kjV_fc8jC3UB7dunit_vyI0P0ZLWSWElsIs0o98";
        urlMap["BeeGolden"] = "ar://_2PeWFSVKhwrZUvR7h38JkXmvlcB9EM6x1D9aqfFjh8";
        urlMap["BeeSilvery"] = "ar://T8RAlB9mOY2CYh8LxoVP6NBPKlzl-GCkZbfpsb7lkCs";
        urlMap["BeeCopper"] = "ar://zhVYdySVzfjyQkLx0YWcXuLwxLkLJ09Q3OFVurU01eY";
        urlMap["CowGolden"] = "ar://pswhfVTmMh9SB9VXunZ9NrItB3Zqz4ICz-io2cGefbI";
        urlMap["CowSilvery"] = "ar://8qnOSFqMNm_Isi9b9gF4_A_uKuxOR_35r0NsS4LspJw";
        urlMap["CowCopper"] = "ar://EqM8vIUKF-sGiz-ShInXjzcmsToKPPqbyLdggMiAiJc";
        urlMap["CreeperGolden"] = "ar://gThiSTBd8n3NwsLZo6dgbEWHGymE1e-7WNh_O6IsINY";
        urlMap["CreeperSilvery"] = "ar://r0GvIh0Or23Qmjo3lNK9vzdm3414Ct7wGqC9u0tqjhk";
        urlMap["CreeperCopper"] = "ar://yuE5FdjAHNINqnP14ZWFlKdJ3kVQrmXFGCj_ku0nB-4";
        urlMap["DolphinGolden"] = "ar://xQtK4EsopUVdleWc8Gw-8aPGH-zJ9spuyvEuhxNtYN8";
        urlMap["DolphinSilvery"] = "ar://JLhjPuom7wzddo5-qgDlkLXZIuhuJTEJiy85e_kFKz8";
        urlMap["DolphinCopper"] = "ar://D3wwZckyOQ1NLVMzJ3CrXlww4fiS4qXn8HQGuP09qgg";
        urlMap["EnderDragonGolden"] = "ar://C0zfXnXu3jIYe6gbJzr4MCNaLi9ndqGc_DZOKLJebpE";
        urlMap["EnderDragonSilvery"] = "ar://bW_B1qid-blKGSBRvqTFFIZkV1l2obnQ5DQ8SanAacQ";
        urlMap["EnderDragonCopper"] = "ar://lrzrNtuIGa4i28hJY81uWSif-Rt_Ug4LJ3ZLCqn8G90";
        urlMap["EndermanGolden"] = "ar://RVZOfVPgegqYnvCpsI4BDa69XREiZmSlsSm7H_6gU0o";
        urlMap["EndermanSilvery"] = "ar://_KYzopNYjSYcsAFUEovjUYfD8dwnqlwUcoxsWDpQK7g";
        urlMap["EndermanCopper"] = "ar://71eGx6A_RvMcldnFB0nqU2UA3NgvicbJo22DOJJlLYs";
        urlMap["IronGolemGolden"] = "ar://GRKyE3ZvgXjilrdQ5__1NL6RTiqW5-kTwR5kyt4jf68";
        urlMap["IronGolemSilvery"] = "ar://1-_sf-2Xxi00hGxv15k7EbVChDkEp6h9bmFuQCkLsms";
        urlMap["IronGolemCopper"] = "ar://MUs64O0K72jpsq6gqShuKygzlLqOyZiZbmDIUJ0M7hg";
        urlMap["TurtleGolden"] = "ar://4g2MqEi-8b-Lh2F__jtM55dxSKUZpc5IJG2VlFJd7V4";
        urlMap["TurtleSilvery"] = "ar://g4H3kqjAfshjBEoIkX6Ks2ViRtL88aqyfag5Si0JD4I";
        urlMap["TurtleCopper"] = "ar://0PfeXImbImNFWv0J6nYMrnAKZjuQAvZn7HqZe2TNoZ8";
        urlMap["WitherGolden"] = "ar://EMLrsR5vvB6i8mgg71A_RAH-kBA44be-jTeNFIaUmpc";
        urlMap["WitherSilvery"] = "ar://PcSYjwvWQx-JoMUEIPidnwPectQjKg25lrTXI4xULrQ";
        urlMap["WitherCopper"] = "ar://_dIP9gZrnIjeQUqsF7w8dppU0qbXdQyEvIimxg4spsY";
        urlMap["AxolotlGolden"] = "ar://ZVMqJEThT2vs_cYL7CMd4ijLvUqC9Koz2D6sdI1WvGc";
        urlMap["AxolotlSilvery"] = "ar://EubG1GY0nYD3mpAWx69mX_30m3eZKCF6O77cS_beqMU";
        urlMap["AxolotlCopper"] = "ar://UpTJnmJpVtD2oAqcW2mM2UH8WtzLcLNQHw6SWy027hg";
        urlMap["PigGolden"] = "ar://7O2OuLHESc5zjwVTCrBeu7Un9TWUAVNcYNeao3tqJmg";
        urlMap["PigSilvery"] = "ar://MLfajgCbkynn2QCttTYpxrkCD0p4Ve2p0hVYPVqfeCg";
        urlMap["PigCopper"] = "ar://NJKtswIpy8tnARbpPUgai0RNehgjkFfVoVyIsiS-VwU";
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
        string memory name = string(abi.encodePacked(summary.creature, " ", level,  " #", toString(tokenId)));
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