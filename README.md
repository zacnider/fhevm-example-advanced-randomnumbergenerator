# RandomNumberGenerator

Learn how to generate encrypted random numbers

## 🎓 What You'll Learn

This example teaches you how to use FHEVM to build privacy-preserving smart contracts. You'll learn step-by-step how to implement encrypted operations, manage permissions, and work with encrypted data.

## 🚀 Quick Start

1. **Clone this repository:**
   ```bash
   git clone https://github.com/zacnider/fhevm-example-advanced-randomnumbergenerator.git
   cd fhevm-example-advanced-randomnumbergenerator
   ```

2. **Install dependencies:**
   ```bash
   npm install --legacy-peer-deps
   ```

3. **Setup environment:**
   ```bash
   npm run setup
   ```
   Then edit `.env` file with your credentials:
   - `SEPOLIA_RPC_URL` - Your Sepolia RPC endpoint
   - `PRIVATE_KEY` - Your wallet private key (for deployment)
   - `ETHERSCAN_API_KEY` - Your Etherscan API key (for verification)

4. **Compile contracts:**
   ```bash
   npm run compile
   ```

5. **Run tests:**
   ```bash
   npm test
   ```

6. **Deploy to Sepolia:**
   ```bash
   npm run deploy:sepolia
   ```

7. **Verify contract (after deployment):**
   ```bash
   npm run verify <CONTRACT_ADDRESS>
   ```

**Alternative:** Use the [Examples page](https://entrofhe.vercel.app/examples) for browser-based deployment and verification.

---

## 📚 Overview

@title RandomNumberGenerator
@notice Random number generator using entropy
@dev Example demonstrating how to request entropy and use it for random number generation
In this example, you will learn:
- Requesting entropy from oracle
- Storing encrypted random numbers
- Retrieving encrypted values

@notice Request a random number
@param tag Unique tag for this request
@return requestId The request ID from encrypted randomness
@dev Requires 0.00001 ETH fee for entropy request

@notice Get encrypted random number for a request
@param requestId The request ID
@return randomNumber Encrypted random number (euint64)

@notice Check if random number is generated for a request
@param requestId The request ID
@return generated True if generated

@notice Get total number of random numbers generated
@return count Total count



## 🔐 Learn Zama FHEVM Through This Example

This example teaches you how to use the following **Zama FHEVM** features:

### What You'll Learn About

- **ZamaEthereumConfig**: Inherits from Zama's network configuration
  ```solidity
  contract MyContract is ZamaEthereumConfig {
      // Inherits network-specific FHEVM configuration
  }
  ```

- **FHE Operations**: Uses Zama's FHE library for encrypted operations
  - `FHE.add()` - Zama FHEVM operation
  - `FHE.sub()` - Zama FHEVM operation
  - `FHE.mul()` - Zama FHEVM operation
  - `FHE.eq()` - Zama FHEVM operation
  - `FHE.xor()` - Zama FHEVM operation
  - `FHE.allowThis()` - Zama FHEVM operation

- **Encrypted Types**: Uses Zama's encrypted integer types
  - `euint64` - 64-bit encrypted unsigned integer
  - `externalEuint64` - External encrypted value from user

- **Access Control**: Uses Zama's permission system
  - `FHE.allowThis()` - Allow contract to use encrypted values
  - `FHE.allow()` - Allow specific user to decrypt
  - `FHE.allowTransient()` - Temporary permission for single operation
  - `FHE.fromExternal()` - Convert external encrypted values to internal

### Zama FHEVM Imports

```solidity
// Zama FHEVM Core Library - FHE operations and encrypted types
import {FHE, euint64, externalEuint64} from "@fhevm/solidity/lib/FHE.sol";

// Zama Network Configuration - Provides network-specific settings
import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";
```

### Zama FHEVM Code Example

```solidity
// Advanced Zama FHEVM usage patterns
euint64 result = FHE.add(value1, value2);
FHE.allowThis(result);

// Combining multiple Zama FHEVM operations
euint64 entropy = entropyOracle.getEncryptedEntropy(requestId);
FHE.allowThis(entropy);
euint64 finalResult = FHE.xor(result, entropy);
FHE.allowThis(finalResult);
```

### FHEVM Concepts You'll Learn

1. **Complex FHE Operations**: Learn how to use Zama FHEVM for complex fhe operations
2. **Real-World Applications**: Learn how to use Zama FHEVM for real-world applications
3. **Entropy Integration**: Learn how to use Zama FHEVM for entropy integration

### Learn More About Zama FHEVM

- 📚 [Zama FHEVM Documentation](https://docs.zama.org/protocol)
- 🎓 [Zama Developer Hub](https://www.zama.org/developer-hub)
- 💻 [Zama FHEVM GitHub](https://github.com/zama-ai/fhevm)



## 🔍 Contract Code

```solidity
// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.27;

import {FHE, euint64} from "@fhevm/solidity/lib/FHE.sol";
import {ZamaEthereumConfig} from "@fhevm/solidity/config/ZamaConfig.sol";
import "./IEntropyOracle.sol";

/**
 * @title RandomNumberGenerator
 * @notice Random number generator using entropy
 * @dev Example demonstrating how to request entropy and use it for random number generation
 * 
 * This example shows:
 * - Requesting entropy from oracle
 * - Storing encrypted random numbers
 * - Retrieving encrypted values
 */
contract RandomNumberGenerator is ZamaEthereumConfig {
    IEntropyOracle public entropyOracle;
    
    // Store generated random numbers
    mapping(uint256 => euint64) public randomNumbers;
    mapping(uint256 => bool) public isGenerated;
    
    uint256 public totalGenerated;
    
    event RandomNumberRequested(uint256 indexed requestId, bytes32 tag);
    event RandomNumberGenerated(uint256 indexed requestId, uint256 requestNumber);
    
    constructor(address _entropyOracle) {
        require(_entropyOracle != address(0), "Invalid oracle address");
        entropyOracle = IEntropyOracle(_entropyOracle);
    }
    
    /**
     * @notice Request a random number
     * @param tag Unique tag for this request
     * @return requestId The request ID from entropy oracle
     * @dev Requires 0.00001 ETH fee for entropy request
     */
    function requestRandomNumber(bytes32 tag) external payable returns (uint256 requestId) {
        require(msg.value >= entropyOracle.getFee(), "Insufficient fee");
        
        // Request entropy from oracle
        requestId = entropyOracle.requestEntropy{value: msg.value}(tag);
        
        // Get encrypted entropy
        euint64 entropy = entropyOracle.getEncryptedEntropy(requestId);
        
        // Store encrypted random number
        randomNumbers[requestId] = entropy;
        isGenerated[requestId] = true;
        totalGenerated++;
        
        emit RandomNumberRequested(requestId, tag);
        emit RandomNumberGenerated(requestId, totalGenerated);
        
        return requestId;
    }
    
    /**
     * @notice Get encrypted random number for a request
     * @param requestId The request ID
     * @return randomNumber Encrypted random number (euint64)
     */
    function getRandomNumber(uint256 requestId) external view returns (euint64 randomNumber) {
        require(isGenerated[requestId], "Random number not generated");
        return randomNumbers[requestId];
    }
    
    /**
     * @notice Check if random number is generated for a request
     * @param requestId The request ID
     * @return generated True if generated
     */
    function hasRandomNumber(uint256 requestId) external view returns (bool generated) {
        return isGenerated[requestId];
    }
    
    /**
     * @notice Get total number of random numbers generated
     * @return count Total count
     */
    function getTotalGenerated() external view returns (uint256 count) {
        return totalGenerated;
    }
}

```

## 🧪 Tests

See [test file](./test/RandomNumberGenerator.test.ts) for comprehensive test coverage.

```bash
npm test
```


## 📚 Category

**advanced**



## 🔗 Related Examples

- [All advanced examples](https://github.com/zacnider/entrofhe/tree/main/examples)

## 📝 License

BSD-3-Clause-Clear
