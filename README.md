# Zenko : OCSA Diamond
Diamond Smart Contracts using [Gemforge](https://gemforge.xyz) with [Foundry](https://github.com/foundry-rs/foundry).

## Overview

The Zenko OCSA diamond is designed for the creation and management of ERC20 dividend sharing tokens. The protocol is tailored for Zenko's internal use, and can be leveraged by partners through the deployment of a second diamond to issue digital shares in their companies without the complexities of traditional share governance. 
The core functionality enables revenue sharing from various solutions and departments, reflecting a decentralized financial (DeFi) approach to corporate revenue distribution.

![Contracts Structure](https://github.com/Zenko-tech/Contracts/blob/main/_docs/Contracts_Structure.png)

![User Flow](https://github.com/Zenko-tech/Contracts/blob/main/_docs/User_Flow.png)

![Financial Flow](https://github.com/Zenko-tech/Contracts/blob/main/_docs/Financial_Flow.png)

## System Components

### Facets
The protocol uses a diamond pattern to manage its smart contracts, allowing for modular upgrades and interaction.

- AdminFacet: Handles administrative tasks, such as token configuration and access control.
- WhitelistFacet: Manages a list of approved users, allowing them to participate in revenue sharing.
- ZOCSAFacet: Central to the protocol, this facet deals with the core logic of ZOCSA tokens including creation, distribution, and dividend sharing.

### Shared Contracts
- AccessControl: Manages permissions across different facets of the system.
- MetaContext: Provides contextual information for transactions.
- ReentrancyGuard: Protects against re-entrancy attacks, ensuring contract interactions are secure.
- Structs: Defines various data structures used throughout the system.

### Libraries
- LibAppStorage: Central storage library, managing the state across the protocol.
- LibMath, LibString: Provide utility functions for mathematical operations and string handling.
- LibWhitelist: Contains logic for managing the whitelist functionality.
- LibZOCSA: Encapsulates business logic specific to ZOCSA tokens.

### Interfaces
- IAdminFacet, IZOCSAFacet: Define the external functions provided by their respective facets.

### Facades
ZOCSA: A simplified interface for interacting with the protocol's core features, presenting a user-friendly access point.

## Actors and Roles
- Admin: Has the ability to configure tokens, update contract logic, and manage access control.
- Partner: Can utilize an other diamond with same logic implemantation to create dividend-sharing tokens for their own company.
- User: Holds ZOCSA tokens and receives dividends based on company revenues.

## Security Considerations
The protocol employs ReentrancyGuard to prevent re-entrancy attacks, and AccessControl to ensure only authorized users can perform sensitive operations. The use of the diamond pattern allows for transparent upgrades and maintenance, ensuring long-term stability and security.

## Explanation of the Reward Distribution Logic
In this system, OCSA tokens can exist in two states: bound (bounded) and unbound (unbounded). Here's the logic behind each function and how it relates to the reward distribution:

1. Binding/Unbinding Tokens:
- Bound Tokens are tied to the system and eligible for dividend distributions. When a user activates (or binds) their OCSA tokens, they become eligible to receive dividends from the system's revenue.
- Unbound Tokens are regular ERC20 tokens not yet activated for dividend distribution. They can be transferred like any standard token without triggering dividend distribution.

2. Whitelisting:
- To ensure compliance with KYC regulations, a whitelist can be implemented on the BoundOcsa function. This means only verified users (who have passed KYC) can bind their tokens to become shareholders, which transitions their tokens from the standard ERC20 state to the OCSA state.

3. Preventing Exchange Wallets from Receiving Dividends:
- The system avoids distributing dividends to exchange or non-eligible wallets by only allowing whitelisted users to bind their tokens.

4. Workflow Functions:
- transfer(): This function is responsible for transferring tokens. If the tokens being transferred are not already unbounded in the user's balance, they are unbound during the transfer.
- BoundOcsa(): This function checks if the user has any unbounded OCSA. If they do, it binds them, which updates the totalSupply to reflect the new bound tokens.
- balanceOf(): This function returns the sum of a user's bound and unbound OCSA.
- totalSupply(): This returns the aggregate of all bound and unbound OCSA in the system.
- BalanceBounded(): This function returns the balance of only the bound OCSA.
- BalanceUnBounded(): This returns the balance of only the unbound OCSA.

The logic behind this system allows for the differentiation of tokens based on their eligibility for dividend distribution and ensures that only verified shareholders can receive dividends. This mechanism also adds a layer of security and regulatory compliance by incorporating KYC checks into the token binding process.


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

Create `.env` and copy .env_exemple content

## Usage
Run Tests :

```
pnpm build
forge test -vvv
```

To deploy to Sepolia testnet:

```
$ pnpm dep sepolia
```


## License

MIT - see [LICSENSE.md](LICENSE.md)

Prettier :
npx prettier --write --plugin=prettier-plugin-solidity 'src/**/*.sol'


### TODO/ WIP :
[] Implementation de l'interface IERC20Receiver afin de pouvoir recevoir des coins avec safetransferfrom 


[] if destination is contract, ensure mint to and transfer to can handle transfer : _checkOnERC20Received()


