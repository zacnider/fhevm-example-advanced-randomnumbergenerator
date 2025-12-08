// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.27;

import {euint64} from "@fhevm/solidity/lib/FHE.sol";

/**
 * @title IEntropyOracle
 * @notice Interface for Entropy Oracle - Developer-friendly entropy source
 * @dev Developers integrate this interface to request encrypted entropy
 */
interface IEntropyOracle {
    function requestEntropy(bytes32 tag) external payable returns (uint256 requestId);
    function getEncryptedEntropy(uint256 requestId) external view returns (euint64);
    function isRequestFulfilled(uint256 requestId) external view returns (bool);
    function getRequest(uint256 requestId) external view returns (
        address consumer,
        bytes32 tag,
        uint256 timestamp,
        bool fulfilled
    );
    function getFee() external pure returns (uint256);
}


