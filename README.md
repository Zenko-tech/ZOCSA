# Zenko Protocol
Diamond Smart Contracts using [Gemforge](https://gemforge.xyz) with [Foundry](https://github.com/foundry-rs/foundry).

![Contracts Structure](https://github.com/Zenko-tech/Contracts/blob/main/_docs/Contracts_Structure.png)

![User Flow](https://github.com/Zenko-tech/Contracts/blob/main/_docs/User_Flow.png)

![Financial Flow](https://github.com/Zenko-tech/Contracts/blob/main/_docs/Financial_Flow.png)


Actual Testnet deployment : 
- diamond : 0xc754Bb1D9070Ab27993b8b285eBF48dc9aa3CbC5
- test Token : 0xB6B01AAfd3665b1b8296C99DCC1777C51F5c1763
UI Diamond :
https://diamondscan.xyz/


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


# TESTING : 
[X] deploying OCSA facades with correct information / view functions (with URI too)
[X ~ ] testing dispatch logic with simple parameters (Simple distrib?)
[X] testing asymetric distrib
[X] testing withdraw 
[X] shouldnt be able to withdraw if no balance
[X] shouldnt be able to withdraw from facet
[X] admin shouldnt be able to mint when max supply reached
[X] user shouldnt be able to mint from facet (only admin for regulation)
[X] admin shouldnt be able to mint if receiver is contract without corresponding interface 