// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.27;

import {FHE, euint64} from "@fhevm/solidity/lib/FHE.sol";
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
contract RandomNumberGenerator {
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
