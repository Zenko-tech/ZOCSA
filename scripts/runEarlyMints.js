// #!/usr/bin/env node
// (async () => {
//   require('dotenv').config()
//   const { $ } = (await import('execa'))

//   const addresses = require('../gemforge.deployments.json')


// })()
const { ethers } = require("foundry");
const { id } = ethers.utils;

// Replace with your contract's ABI
const ERC721_ABI = [
    // ... your contract's ABI ...
    "function mint(address to, uint256 tokenId) public",  // This is a simple mint function for demonstration, adjust according to your contract
    // ... other functions ...
];

// Setup
async function setup() {
    await ethers.provider.send("hardhat_reset", []);
    const accounts = await ethers.provider.listAccounts();
    return accounts;
}

// Main function to mint an ERC721 token
async function mintToken() {
    const accounts = await setup();
    const owner = accounts[0];  // Assuming the 0th account is the owner or has minting rights

    // Connect to the contract
    const contractAddress = "YOUR_CONTRACT_ADDRESS_HERE";  // Replace with your deployed contract's address
    const contract = new ethers.Contract(contractAddress, ERC721_ABI, owner);

    // Mint a new token
    const tokenId = 1;  // Replace with desired tokenId or generate dynamically
    const tx = await contract.mint(owner, tokenId);
    await tx.wait();

    console.log(`Minted token with ID: ${tokenId} to address: ${owner}`);
}

mintToken().catch(console.error);