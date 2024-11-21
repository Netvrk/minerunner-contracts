## Minerunner

### Overview

MineRunner is a blockchain-based game combining DeFi elements with gameplay, enabling players to earn, trade, and manage in-game assets securely. Smart contracts power its economy: the Axe contract mints assets earned in-game, the CashIn contract allows token purchases, and the CashOut contract enables withdrawals of $NETVR tokens for earned Metacrite, seamlessly bridging gaming and real-world value.

### Contracts

#### Axe Contract

- **Description:**

  - Represents an in-game asset in MineRunner.
  - Players can earn and mint Axe tokens by completing in-game activities.
  - Purpose: Tokenize game items for use or trade.

- **Minting:**
  - Minting available at [https://minerunner.netvrk.co](https://minerunner.netvrk.co).

#### CashIn Contract

- **Description:**
  - Enables players to purchase MineRunner in-game tokens using external tokens.
- **Usage:**
  - Tokens purchased can be used inside the game for items, upgrades, or other utilities.
  - Ensures smooth conversion from external cryptocurrency to in-game currency.

#### CashOut Contract

- **Description:**

  - Allows players to withdraw $NETVR tokens in exchange for Metacrite earned in MineRunner.

- **Functionality:**
  - Verifies cash-out requests to avoid duplicates.
  - Transfers $NETVR tokens to the player’s wallet based on their Metacrite balance.
  - Bridges in-game rewards with real-world value.

### Deployed Contracts

The following contracts are deployed on the Ethereum Mainnet and Polygon networks:

- **NTVRK:**

  - Ethereum: [0x52498F8d9791736f1D6398fE95ba3BD868114d10](https://etherscan.io/address/0x52498F8d9791736f1D6398fE95ba3BD868114d10)
  - Polygon: [0x3558887f15b5b0074dC4167761DE14A6DFcb676e](https://polygonscan.com/address/0x3558887f15b5b0074dC4167761DE14A6DFcb676e)

- **Cash In:**

  - Ethereum: [0x9725c61fe06aa00cFE0ac8689A7C99fbcd85d4Df](https://etherscan.io/address/0x9725c61fe06aa00cFE0ac8689A7C99fbcd85d4Df)
  - Polygon: [0x9725c61fe06aa00cFE0ac8689A7C99fbcd85d4Df](https://polygonscan.com/address/0x9725c61fe06aa00cFE0ac8689A7C99fbcd85d4Df)

- **Cash Out (Polygon):** [0xb1eBca91C5384A6ff126311328C64286265d849e](https://polygonscan.com/address/0xb1eBca91C5384A6ff126311328C64286265d849e)

- **Axe (Polygon):** [0x12fA9232Ff110fAD4FBB3dc25F5197419ee3bA13](https://polygonscan.com/address/0x12fA9232Ff110fAD4FBB3dc25F5197419ee3bA13)

## Getting Started

### Prerequisites

- **Node.js:** Ensure you have Node.js installed. You can download it from [here](https://nodejs.org/).
- **Hardhat:** A development environment to compile, deploy, test, and debug your Ethereum software.

### Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/Netvrk/minerunner-contracts.git
   ```
2. **Navigate to the Project Directory:**

   ```bash
    cd minerunner-contracts
   ```

3. **Install Dependencies:**
   ```bash
   npm install
   ```
4. **Compile the Contracts:**

   ```bash
   npx hardhat compile
   ```

5. **Run Tests:**

   ```bash
   npx hardhat test
   ```

6. **Deploy the Contracts:**
   ```bash
   npx hardhat run scripts/axe.ts --network sepolia
   ```
