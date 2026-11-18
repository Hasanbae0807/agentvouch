// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AgentVouch} from "../src/AgentVouch.sol";

/// @notice Phase-2 deployment helper — NOT executed in phase 1.
/// @dev Kept dependency-free (no forge-std Script base) so the project builds
///      from a fresh clone. In phase 2 the deploy is a single create:
///        AgentVouch(REGISTRY_BSC_MAINNET)
///      Registry on BNB Chain mainnet (verified on-chain 2026-11-18):
///        0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F  (SPACE ID Agent ID)
contract Deploy {
    address public constant REGISTRY_BSC_MAINNET = 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;

    function deploy() external returns (AgentVouch vouch) {
        return new AgentVouch(REGISTRY_BSC_MAINNET);
    }
}
