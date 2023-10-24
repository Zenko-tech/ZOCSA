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
[] Implementation de l'interface IERC20Receiver afin de pouvoir recevoir des coins avec safetransferfrom (update for market place)
[] Transfer / safeTransfer implemantation (update for market place)



[] ensure msg.sender / from-to on facade 
[] if destination is contract, ensure mint to and transfer to can handle transfer : _checkOnERC20Received()

/!\ potential bound ocsa / unbounded ? bound reverse a nouveau les gains sur TX d'activation ?
- Transformation d'ocsa (bounded) a standard erc20 (unbounded)
- potentiel ajout de whitelist sur la function BoundOcsa - permet d'assurer le KYC des user s'inscrivant comme share older (passe de erc20 a ocsa) 
- evite la distribution des gains sur des wallets type exchange, et apporte des events sur les achats / reventes des users sur marche secondaire
=> workflow : 
 transfer - unbound ocsa if no alrdy unbounded in user balances -> sender send unbounded ocsa to recipient
BoundOcsa : check if user has any unbounded ocsa, ifso bound them to update totalSupply 
balanceOf - return bound ocsa + unbound ocsa 
BalanceBounded : return bal of bounded ocsa
BalanceUnBounded : return bal of unbounded ocsa

## FEATURES POCSA
- pour l'instant pas de transfert implement
- Tous les versements des rewards se font bien mensuellement (et manuellement) de maniere fixe ?
- Change Mint mecanism => POCSA doit mint obligatoirement les ocsa au wallet partenaire admins, qui peut deleguer la vente sur la marketPlace Zenko, ou bien vendre lui meme les tokens - BUT - hoooow si les transfert sont desactives ? 

# TESTING : 
[X] deploying OCSA facades with correct information / view functions
[X ~ ] testing dispatch logic with simple parameters (Simple distrib?)
[X] testing asymetric distrib
[X] testing withdraw 
[X] shouldnt be able to withdraw if no balance
[X] shouldnt be able to withdraw from facet
[X] admin shouldnt be able to mint when max supply reached
[X] user shouldnt be able to mint from facet (only admin for regulation)
[X] admin shouldnt be able to mint if receiver is contract without corresponding interface 