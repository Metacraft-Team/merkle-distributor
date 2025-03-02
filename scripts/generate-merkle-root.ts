import { program } from 'commander'
import fs from 'fs'
import { parseBalanceMap } from '../src/parse-balance-map'

program
  .version('0.0.0')
  .requiredOption(
    '-i, --input <path>',
    'input JSON file location containing a map of account addresses to string balances'
  )

program.parse(process.argv)

const json = JSON.parse(fs.readFileSync(program.input, { encoding: 'utf8' }))

if (typeof json !== 'object') throw new Error('Invalid JSON')

var res = parseBalanceMap(json)
for (const item in res.claims) {
  console.log(item, JSON.stringify(res.claims[item]))
}
console.log(res.merkleRoot)
// console.log(JSON.stringify(parseBalanceMap(json)))
