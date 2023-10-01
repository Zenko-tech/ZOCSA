# Zenko Protocol
Diamond Smart Contracts using [Gemforge](https://gemforge.xyz) with [Foundry](https://github.com/foundry-rs/foundry).

Actual Testnet deployment : 
0xc754Bb1D9070Ab27993b8b285eBF48dc9aa3CbC5

## Requirements

* [Node.js 20+](https://nodejs.org)
* [PNPM](https://pnpm.io/) _(NOTE: `yarn` and `npm` can also be used)_
* [Foundry](https://github.com/foundry-rs/foundry/blob/master/README.md)

## Installation

Create `.env` and set the following within:

```
LOCAL_RPC_URL=http://localhost:8545
SEPOLIA_RPC_URL=<your infura/alchemy endpoint for spolia>
ETHERSCAN_API_KEY=<your etherscan api key>
MNEMONIC=<your deployment wallet mnemonic>
```

## Usage
Run Tests :

```
pnpm build
forge test
```

Run a local dev node in a separate terminal:

```
pnpm devnet
```

To build the code:

```
$ pnpm build
```

To deploy to the local node:

```
$ pnpm dep
```

To deploy to Sepolia testnet:

```
$ pnpm dep sepolia
```

For verbose output simply add `-v`:

```
$ pnpm build -v
$ pnpm dep -v
```

## License

MIT - see [LICSENSE.md](LICENSE.md)

Prettier :
npx prettier --write --plugin=prettier-plugin-solidity 'src/**/*.sol'


### TODO/ WIP :
    -- for later updates --
[] Implementation de l'interface IERC721Receiver afin de pouvoir recevoir des nft avec safetransferfrom (update for market place)
[] Transfer / safeTransfer implemantation (update for market place)

[] Determine base URI/mint URI in LibERC721.sol
[] Check for ERC721 Metadata interface et implementation (ERC20.sol vs ERC721.sol)
[] check for supportInterface() and double safeTransferFrom() implementation in ERC721 with eip2535
[X] restrict erc721WithdrawUserEarnings() to allowed facades for security reason
[] ensure msg.sender / from-to on facade 
[X] if destination is contract, ensure mint to and transfer to can handle transfer : _checkOnERC721Received()