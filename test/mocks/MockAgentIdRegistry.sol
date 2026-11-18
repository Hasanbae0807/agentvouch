// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAgentIdRegistry} from "../../src/interfaces/IAgentIdRegistry.sol";

/// @notice Test double for the SPACE ID Agent ID registry.
/// @dev Mirrors the real registry's semantics that AgentVouch relies on:
///      one handle per address, balanceOf is 1 for holders / 0 otherwise,
///      ownerOfHandle returns address(0) for unregistered handles,
///      handles are 3..20 chars. Test-only: `setHandle` is unauthenticated
///      by design and this contract is never deployed.
contract MockAgentIdRegistry is IAgentIdRegistry {
    mapping(address => string) private _handles;
    mapping(string => address) private _owners;

    function setHandle(address user, string calldata handle) external {
        string memory old = _handles[user];
        if (bytes(old).length > 0) delete _owners[old];
        address prevOwner = _owners[handle];
        if (prevOwner != address(0)) delete _handles[prevOwner];
        _handles[user] = handle;
        _owners[handle] = user;
    }

    function balanceOf(address owner) external view returns (uint256) {
        return bytes(_handles[owner]).length > 0 ? 1 : 0;
    }

    function handleOf(address owner) external view returns (string memory) {
        return _handles[owner];
    }

    function ownerOfHandle(string calldata handle) external view returns (address) {
        return _owners[handle];
    }

    function isValidHandle(string calldata handle) external pure returns (bool) {
        bytes memory b = bytes(handle);
        if (b.length < 3 || b.length > 20) return false;
        for (uint256 i = 0; i < b.length; i++) {
            bytes1 c = b[i];
            bool ok = (c >= "a" && c <= "z") || (c >= "0" && c <= "9");
            if (!ok) return false;
        }
        return true;
    }
}
