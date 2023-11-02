# Zenko Protocol
Diamond Smart Contracts using [Gemforge](https://gemforge.xyz) with [Foundry](https://github.com/foundry-rs/foundry).

![Contracts Structure](https://github.com/Zenko-tech/Contracts/blob/main/_docs/Contracts_Structure.png)

![User Flow](https://github.com/Zenko-tech/Contracts/blob/main/_docs/User_Flow.png)

![Financial Flow](https://github.com/Zenko-tech/Contracts/blob/main/_docs/Financial_Flow.png)


Actual Testnet deployment : 
- diamond : 
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

------------------------------------------------------
Bound ocsa / Unbounded : bound reverse a nouveau les gains sur TX d'activation 
- Transformation d'ocsa (bounded) a standard erc20 (unbounded)
- potentiel ajout de whitelist sur la function BoundOcsa - permet d'assurer le KYC des user s'inscrivant comme share older (passe de erc20 a ocsa) 
- evite la distribution des gains sur des wallets type exchange, et apporte des events sur les achats / reventes des users sur marche secondaire
=> workflow : 
 transfer() - unbound ocsa if no alrdy unbounded in user balances -> sender send unbounded ocsa to recipient
BoundOcsa() - check if user has any unbounded ocsa, ifso bound them to update totalSupply 
balanceOf() - return user's bound ocsa + unbound ocsa 
totalSupply() - return all bound ocsa + unbound ocsa
BalanceBounded() : return bal of bounded ocsa
BalanceUnBounded() : return bal of unbounded ocsa
------------------------------------------------------

### TODO/ WIP :
[] Implementation de l'interface IERC20Receiver afin de pouvoir recevoir des coins avec safetransferfrom 


[] if destination is contract, ensure mint to and transfer to can handle transfer : _checkOnERC20Received()


