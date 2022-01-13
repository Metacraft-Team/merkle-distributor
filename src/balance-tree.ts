import MerkleTree from './merkle-tree'
import { BigNumber, utils } from 'ethers'

export default class BalanceTree {
  private readonly tree: MerkleTree
  constructor(balances: { account: string; score: number; creature: string}[]) {
    this.tree = new MerkleTree(
      balances.map(({ account, score, creature}, index) => {
        return BalanceTree.toNode(index, account, score, creature)
      })
    )
  }

  public static verifyProof(
    index: number | BigNumber,
    account: string,
    score: number,
    creature: string,
    proof: Buffer[],
    root: Buffer
  ): boolean {
    let pair = BalanceTree.toNode(index, account, score, creature)
    for (const item of proof) {
      pair = MerkleTree.combinedHash(pair, item)
    }

    return pair.equals(root)
  }

  // keccak256(abi.encode(index, account, amount))
  public static toNode(index: number | BigNumber, account: string, score: number, creature: string): Buffer {
    var buffer = Buffer.from(creature)
    return Buffer.from(
      utils.solidityKeccak256(['uint256', 'address', 'uint256', 'bytes'], [index, account, score, buffer]).substr(2),
      'hex'
    )
  }

  public getHexRoot(): string {
    return this.tree.getHexRoot()
  }

  // returns the hex bytes32 values of the proof
  public getProof(index: number | BigNumber, account: string, score: number, creature: string): string[] {
    return this.tree.getHexProof(BalanceTree.toNode(index, account, score, creature))
  }
}
