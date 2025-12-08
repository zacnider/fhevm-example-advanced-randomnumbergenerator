# RandomNumberGenerator

Random number generator using entropy oracle

## 🚀 Standard workflow
- Install (first run): `npm install --legacy-peer-deps`
- Compile: `npx hardhat compile`
- Test (local FHE + local oracle/chaos engine auto-deployed): `npx hardhat test`
- Deploy (frontend Deploy button): constructor arg is fixed to EntropyOracle `0x75b923d7940E1BD6689EbFdbBDCD74C1f6695361`
- Verify: `npx hardhat verify --network sepolia <contractAddress> 0x75b923d7940E1BD6689EbFdbBDCD74C1f6695361`

## 📋 Overview

This example demonstrates **advanced** concepts in FHEVM with **EntropyOracle integration**:
- Integrating with EntropyOracle
- Generating random numbers using encrypted entropy
- Storing encrypted random numbers
- Retrieving encrypted random numbers
- Real-world application pattern

## 🎯 What This Example Teaches

This tutorial will teach you:

1. **How to generate encrypted random numbers** using EntropyOracle
2. **How to store encrypted randomness** on-chain
3. **How to retrieve encrypted random numbers** by request ID
4. **Request management** for multiple random numbers
5. **Real-world application patterns** with encrypted randomness
6. **Privacy-preserving random number generation**

## 💡 Why This Matters

Random numbers are essential for many dApps:
- **Encrypted randomness maintains privacy** - values remain encrypted
- **EntropyOracle provides cryptographic randomness** - unpredictable and fair
- **Each request generates unique random number** - no duplicates
- **Stored encrypted** - can be used in FHE operations or decrypted off-chain
- **Real-world applications**: Lotteries, games, NFT traits, etc.

## 🔍 How It Works

### Contract Structure

The contract has three main components:

1. **Request Random Number**: Request entropy and store as random number
2. **Get Random Number**: Retrieve encrypted random number by request ID
3. **Status Checks**: Check if random number exists and get total count

### Step-by-Step Code Explanation

#### 1. Constructor

```solidity
constructor(address _entropyOracle) {
    require(_entropyOracle != address(0), "Invalid oracle address");
    entropyOracle = IEntropyOracle(_entropyOracle);
}
```

**What it does:**
- Takes EntropyOracle address as parameter
- Validates the address is not zero
- Stores the oracle interface

**Why it matters:**
- Must use the correct oracle address: `0x75b923d7940E1BD6689EbFdbBDCD74C1f6695361`

#### 2. Request Random Number

```solidity
function requestRandomNumber(bytes32 tag) external payable returns (uint256 requestId) {
    require(msg.value >= entropyOracle.getFee(), "Insufficient fee");
    
    // Request entropy from oracle
    requestId = entropyOracle.requestEntropy{value: msg.value}(tag);
    
    // Get encrypted entropy (random number)
    euint64 entropy = entropyOracle.getEncryptedEntropy(requestId);
    
    // Store encrypted random number
    randomNumbers[requestId] = entropy;
    isGenerated[requestId] = true;
    totalGenerated++;
    
    emit RandomNumberRequested(requestId, tag);
    emit RandomNumberGenerated(requestId, totalGenerated);
    
    return requestId;
}
```

**What it does:**
- Validates fee payment (0.00001 ETH)
- Requests entropy from EntropyOracle
- Gets encrypted entropy immediately (oracle fulfills synchronously in this example)
- Stores encrypted entropy as random number
- Marks request as generated
- Increments total generated count
- Emits events
- Returns request ID

**Key concepts:**
- **Encrypted entropy**: Entropy is encrypted (euint64)
- **Request ID as key**: Request ID used to retrieve random number
- **Immediate storage**: Random number stored immediately after request
- **Encrypted storage**: Random number remains encrypted on-chain

**Why encrypted:**
- Maintains privacy - random number not visible on-chain
- Can be used in FHE operations without decryption
- Can be decrypted off-chain when needed

#### 3. Get Random Number

```solidity
function getRandomNumber(uint256 requestId) external view returns (euint64 randomNumber) {
    require(isGenerated[requestId], "Random number not generated");
    return randomNumbers[requestId];
}
```

**What it does:**
- Checks if random number exists for request ID
- Returns encrypted random number (handle)

**Key concepts:**
- **View function**: Can return `euint64` because it's just reading storage
- **Handle return**: Returns handle, not decrypted value
- **Off-chain decryption**: Decrypt using FHEVM SDK

**Why view works here:**
- Just reading from storage
- Not performing FHE operations
- Returning stored handle

#### 4. Status Checks

```solidity
function hasRandomNumber(uint256 requestId) external view returns (bool generated) {
    return isGenerated[requestId];
}

function getTotalGenerated() external view returns (uint256 count) {
    return totalGenerated;
}
```

**What it does:**
- Checks if random number exists for request ID
- Returns total number of random numbers generated

**Why it's useful:**
- Check if random number is ready before retrieving
- Track total generated random numbers
- Useful for frontend status displays

## 🧪 Step-by-Step Testing

### Prerequisites

1. **Install dependencies:**
   ```bash
   npm install --legacy-peer-deps
   ```

2. **Compile contracts:**
   ```bash
   npx hardhat compile
   ```

### Running Tests

```bash
npx hardhat test
```

### What Happens in Tests

1. **Fixture Setup** (`deployContractFixture`):
   - Deploys FHEChaosEngine, EntropyOracle, and RandomNumberGenerator
   - Returns all contract instances

2. **Test: Request Random Number**
   ```typescript
   it("Should request random number", async function () {
     const tag = hre.ethers.id("test-random");
     const fee = await oracle.getFee();
     const requestId = await contract.requestRandomNumber(tag, { value: fee });
     
     expect(requestId).to.not.be.undefined;
     expect(await contract.hasRandomNumber(requestId)).to.be.true;
   });
   ```
   - Requests random number with unique tag
   - Pays required fee
   - Verifies random number is generated

3. **Test: Get Random Number**
   ```typescript
   it("Should get random number", async function () {
     // ... request random number code ...
     const randomNumber = await contract.getRandomNumber(requestId);
     expect(randomNumber).to.not.be.undefined;
   });
   ```
   - Retrieves encrypted random number
   - Verifies random number is returned (handle)

### Expected Test Output

```
  RandomNumberGenerator
    Deployment
      ✓ Should deploy successfully
      ✓ Should have EntropyOracle address set
    Random Number Generation
      ✓ Should request random number
      ✓ Should get random number by request ID
      ✓ Should track total generated

  5 passing
```

**Note:** Random numbers are encrypted (handles). Decrypt off-chain using FHEVM SDK to see actual values.

## 🚀 Step-by-Step Deployment

### Option 1: Frontend (Recommended)

1. Navigate to [Examples page](/examples)
2. Find "RandomNumberGenerator" in Tutorial Examples
3. Click **"Deploy"** button
4. Approve transaction in wallet
5. Wait for deployment confirmation
6. Copy deployed contract address

### Option 2: CLI

1. **Create deploy script** (`scripts/deploy.ts`):
   ```typescript
   import hre from "hardhat";

   async function main() {
     const ENTROPY_ORACLE_ADDRESS = "0x75b923d7940E1BD6689EbFdbBDCD74C1f6695361";
     
     const ContractFactory = await hre.ethers.getContractFactory("RandomNumberGenerator");
     const contract = await ContractFactory.deploy(ENTROPY_ORACLE_ADDRESS);
     await contract.waitForDeployment();
     
     const address = await contract.getAddress();
     console.log("RandomNumberGenerator deployed to:", address);
   }

   main().catch((error) => {
     console.error(error);
     process.exitCode = 1;
   });
   ```

2. **Deploy:**
   ```bash
   npx hardhat run scripts/deploy.ts --network sepolia
   ```

## ✅ Step-by-Step Verification

### Option 1: Frontend

1. After deployment, click **"Verify"** button on Examples page
2. Wait for verification confirmation
3. View verified contract on Etherscan

### Option 2: CLI

```bash
npx hardhat verify --network sepolia <CONTRACT_ADDRESS> 0x75b923d7940E1BD6689EbFdbBDCD74C1f6695361
```

**Important:** Constructor argument must be the EntropyOracle address: `0x75b923d7940E1BD6689EbFdbBDCD74C1f6695361`

## 📊 Expected Outputs

### After Request Random Number

- `hasRandomNumber(requestId)` returns `true`
- `getTotalGenerated()` increments
- `RandomNumberRequested` and `RandomNumberGenerated` events emitted

### After Get Random Number

- `getRandomNumber(requestId)` returns encrypted random number (handle)
- Random number is encrypted and can be used in FHE operations
- Decrypt off-chain to see actual value

## ⚠️ Common Errors & Solutions

### Error: `Random number not generated`

**Cause:** Trying to get random number for request ID that doesn't exist.

**Solution:**
```typescript
// Check if random number exists first
if (await contract.hasRandomNumber(requestId)) {
    const randomNumber = await contract.getRandomNumber(requestId);
}
```

**Prevention:** Always check `hasRandomNumber()` before getting random number.

---

### Error: `Insufficient fee`

**Cause:** Not sending enough ETH when requesting random number.

**Solution:** Always send exactly 0.00001 ETH:
```typescript
const fee = await contract.entropyOracle.getFee();
await contract.requestRandomNumber(tag, { value: fee });
```

---

### Error: Verification failed - Constructor arguments mismatch

**Cause:** Wrong constructor argument used during verification.

**Solution:** Always use the EntropyOracle address:
```bash
npx hardhat verify --network sepolia <CONTRACT_ADDRESS> 0x75b923d7940E1BD6689EbFdbBDCD74C1f6695361
```

## 🔗 Related Examples

- [SimpleLottery](../advanced-simplelottery/) - Lottery using entropy
- [EntropyNFT](../advanced-entropynft/) - NFT with entropy-based traits
- [Category: advanced](../)

## 📚 Additional Resources

- [Full Tutorial Track Documentation](../../../frontend/src/pages/Docs.tsx) - Complete educational guide
- [Zama FHEVM Documentation](https://docs.zama.org/) - Official FHEVM docs
- [GitHub Repository](https://github.com/zacnider/entrofhe/tree/main/examples/advanced-randomnumbergenerator) - Source code

## 📝 License

BSD-3-Clause-Clear
