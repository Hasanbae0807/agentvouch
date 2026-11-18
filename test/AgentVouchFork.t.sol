// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AgentVouch} from "../src/AgentVouch.sol";
import {IAgentIdRegistry} from "../src/interfaces/IAgentIdRegistry.sol";
import {TestLite} from "./AgentVouch.t.sol";

/// @notice Fork integration tests against the REAL SPACE ID Agent ID registry
///         on BNB Chain mainnet. Read-only: the fork is a local simulation,
///         nothing is broadcast and nothing is signed.
///
/// Run with:
///   forge test --fork-url https://bsc-dataseed.binance.org/ \
///     --match-contract AgentVouchForkTest -v
///
/// When run WITHOUT a fork (plain `forge test`), the registry address has no
/// code locally and every test self-skips, keeping the offline suite green.
contract AgentVouchForkTest is TestLite {
    address internal constant REGISTRY = 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;
    /// @dev Public address of the project owner's Agentic Wallet (holds "begundaall").
    address internal constant HOLDER = 0xcc64fd7BadF9e9f83ee301BdfB802f32705Cd760;
    address internal constant NON_HOLDER = address(0xdead);

    function _forked() internal view returns (bool) {
        return REGISTRY.code.length > 0;
    }

    function testForkRegistryReads() public view {
        if (!_forked()) return; // self-skip outside a fork
        IAgentIdRegistry registry = IAgentIdRegistry(REGISTRY);
        assertEq(registry.balanceOf(HOLDER), 1, "holder balanceOf is 1");
        assertEq(registry.handleOf(HOLDER), "begundaall", "handleOf resolves");
        assertEq(registry.ownerOfHandle("begundaall"), HOLDER, "ownerOfHandle resolves back");
        assertTrue(registry.isValidHandle("begundaall"), "handle is valid");
        assertEq(registry.balanceOf(NON_HOLDER), 0, "non-holder balanceOf is 0");
    }

    function testForkGateWithRealRegistry() public {
        if (!_forked()) return; // self-skip outside a fork
        AgentVouch vouch = new AgentVouch(REGISTRY);

        vm.prank(HOLDER);
        vouch.registerProfile("builder", "fork test");
        (string memory handle,,,, bool exists) = vouch.profiles(HOLDER);
        assertEq(handle, "begundaall", "profile carries the real on-chain handle");
        assertTrue(exists, "profile exists");

        vm.prank(NON_HOLDER);
        vm.expectRevert(abi.encodeWithSelector(AgentVouch.NotAgentIdHolder.selector, NON_HOLDER));
        vouch.registerProfile("builder", "should fail");
    }
}
