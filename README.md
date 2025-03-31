# Digital Asset Borrowing Protocol

A decentralized platform for lending and borrowing digital assets on the Stacks blockchain.

## Overview

The Digital Asset Borrowing Protocol enables the secure lending and borrowing of digital assets through smart contracts. Lenders can offer their digital assets for specified rates and durations, while borrowers can access these assets by paying the required loan rate.

## Features

- **Asset Creation**: Mint new digital assets that can be offered for loans
- **Lending**: Asset owners can list their digital assets with customizable loan rates and durations
- **Borrowing**: Users can borrow available assets by paying the specified loan rate
- **Automated Expiry Management**: Loan expirations are tracked on-chain using block height
- **Secure Ownership Transfers**: Asset ownership is managed through secure contract functions

## Contract Details

The protocol implements the following key functions:

- `create-asset`: Mint a new digital asset
- `offer-asset-for-loan`: List an owned asset for loan with specified parameters
- `borrow-asset`: Borrow an available asset by paying the required rate
- `get-asset-owner`: View the current owner of any asset

## Getting Started

1. Clone this repository
2. Deploy the contract to the Stacks blockchain
3. Interact with the contract through the provided functions

## Security Considerations

- Maximum loan durations and rates are enforced to prevent abuse
- Ownership verification prevents unauthorized lending
- Fund validation ensures borrowers have sufficient balance

## Development

This project uses the Clarity language for smart contract development on the Stacks blockchain.

