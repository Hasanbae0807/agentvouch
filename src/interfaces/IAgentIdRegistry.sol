// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IAgentIdRegistry — SPACE ID Agent ID registry (BNB Chain mainnet)
/// @notice Registry address: 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F
///         ERC-721, name "SPACE ID Agent ID", symbol "AI", non-transferable
///         (a `Soulbound()` error is present in the deployed bytecode).
/// @dev Every selector below was verified on 2026-11-18 against the deployed
///      bytecode (PUSH4 dispatcher extraction + Openchain signature DB +
///      local keccak256) and by live read-only eth_call:
///        balanceOf(wallet)      -> 1
///        handleOf(wallet)       -> "begundaall"
///        ownerOfHandle(handle)  -> wallet
///        isValidHandle(handle)  -> true
///      The official Binance hackathon page documents `balanceOf` as THE way
///      to check whether an address holds an Agent ID.
interface IAgentIdRegistry {
    /// @notice ERC-721 balance. > 0 means the address holds an Agent ID.
    ///         Selector: 0x70a08231
    function balanceOf(address owner) external view returns (uint256);

    /// @notice Resolve a wallet address to its Agent ID handle (without ".ai").
    ///         Selector: 0xc50a1514
    function handleOf(address owner) external view returns (string memory);

    /// @notice Resolve an Agent ID handle to its owner wallet.
    ///         Returns address(0) when the handle is not registered.
    ///         Selector: 0x1da94fb4
    function ownerOfHandle(string calldata handle) external view returns (address);

    /// @notice Whether a handle string is a valid Agent ID handle
    ///         (registry enforces length 3..20 via minLen()/maxLen()).
    ///         Selector: 0x3ff4dbc2
    function isValidHandle(string calldata handle) external view returns (bool);
}
