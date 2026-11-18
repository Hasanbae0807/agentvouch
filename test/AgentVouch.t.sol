// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AgentVouch} from "../src/AgentVouch.sol";
import {MockAgentIdRegistry} from "./mocks/MockAgentIdRegistry.sol";

/// @dev Minimal cheatcode interface — keeps the project dependency-free
///      (no forge-std needed to run the suite).
interface Vm {
    function prank(address msgSender) external;
    function expectRevert() external;
    function expectRevert(bytes4 revertData) external;
    function expectRevert(bytes calldata revertData) external;
}

/// @dev Tiny assertion helpers (revert with a message on failure).
abstract contract TestLite {
    Vm internal constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function assertTrue(bool cond, string memory msg_) internal pure {
        if (!cond) revert(msg_);
    }

    function assertFalse(bool cond, string memory msg_) internal pure {
        if (cond) revert(msg_);
    }

    function assertEq(uint256 a, uint256 b, string memory msg_) internal pure {
        if (a != b) revert(msg_);
    }

    function assertEq(address a, address b, string memory msg_) internal pure {
        if (a != b) revert(msg_);
    }

    function assertEq(string memory a, string memory b, string memory msg_) internal pure {
        if (keccak256(bytes(a)) != keccak256(bytes(b))) revert(msg_);
    }
}

contract AgentVouchTest is TestLite {
    MockAgentIdRegistry internal registry;
    AgentVouch internal vouch;

    address internal alice = address(0xA11CE);
    address internal bob = address(0xB0B);
    address internal carol = address(0xCA401);
    address internal stranger = address(0x57A9);

    function setUp() public {
        registry = new MockAgentIdRegistry();
        registry.setHandle(alice, "alice");
        registry.setHandle(bob, "bob");
        registry.setHandle(carol, "carol");
        // `stranger` intentionally holds no Agent ID.
        vouch = new AgentVouch(address(registry));
    }

    // ------------------------------------------------------- gate (Agent ID)

    function testNonHolderCannotRegister() public {
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(AgentVouch.NotAgentIdHolder.selector, stranger));
        vouch.registerProfile("builder", "hello");
    }

    function testNonHolderCannotEndorse() public {
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(AgentVouch.NotAgentIdHolder.selector, stranger));
        vouch.endorse("alice", "builder", "great");
    }

    function testIsAgentPassthrough() public view {
        assertTrue(vouch.isAgent(alice), "alice is an agent");
        assertFalse(vouch.isAgent(stranger), "stranger is not an agent");
        assertEq(vouch.handleOf(bob), "bob", "handle passthrough");
    }

    // ------------------------------------------------------------ profiles

    function testHolderRegistersProfile() public {
        vm.prank(alice);
        vouch.registerProfile("builder", "I build agents");

        (string memory handle, string memory skill, string memory bio,, bool exists) =
            vouch.profiles(alice);
        assertEq(handle, "alice", "handle resolved from registry, not user input");
        assertEq(skill, "builder", "skill stored");
        assertEq(bio, "I build agents", "bio stored");
        assertTrue(exists, "profile exists");
        assertTrue(vouch.hasInteracted(alice), "interaction marked");
        assertEq(vouch.uniqueInteractors(), 1, "one unique interactor");
    }

    function testProfileUpdateOverwritesAndCountsOnce() public {
        vm.prank(alice);
        vouch.registerProfile("builder", "v1");
        vm.prank(alice);
        vouch.registerProfile("trader", "v2");

        (, string memory skill, string memory bio,,) = vouch.profiles(alice);
        assertEq(skill, "trader", "skill updated");
        assertEq(bio, "v2", "bio updated");
        assertEq(vouch.uniqueInteractors(), 1, "update does not double-count interactors");
    }

    function testRegisterEmptySkillReverts() public {
        vm.prank(alice);
        vm.expectRevert(AgentVouch.EmptySkill.selector);
        vouch.registerProfile("", "bio");
    }

    function testGetProfileByHandle() public {
        vm.prank(bob);
        vouch.registerProfile("artist", "pixels");

        AgentVouch.Profile memory p = vouch.getProfileByHandle("bob");
        assertEq(p.handle, "bob", "profile found by handle");
        assertEq(p.skill, "artist", "skill by handle");
        assertTrue(p.exists, "exists by handle");
    }

    // --------------------------------------------------------- endorsements

    function testEndorseFlow() public {
        vm.prank(alice);
        vouch.endorse("bob", "builder", "solid work");

        assertEq(vouch.skillEndorsementCount("bob", "builder"), 1, "skill count");
        assertEq(vouch.totalEndorsementCount("bob"), 1, "total count");
        assertEq(vouch.totalEndorsementsMade(), 1, "lifetime count");
        assertTrue(vouch.hasEndorsement(alice, "bob", "builder"), "hasEndorsement");
        assertTrue(vouch.hasInteracted(alice), "endorser counted as interactor");
        assertEq(vouch.uniqueInteractors(), 1, "only the endorser interacted");

        bytes32 key = vouch.endorsementKey(alice, "bob", "builder");
        (address endorser, string memory endorserHandle,,,, bool active) = vouch.endorsements(key);
        assertEq(endorser, alice, "endorser stored");
        assertEq(endorserHandle, "alice", "endorser handle resolved from registry");
        assertTrue(active, "endorsement active");
    }

    function testEndorseNonexistentHandleReverts() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(AgentVouch.TargetNotFound.selector, "ghost"));
        vouch.endorse("ghost", "builder", "boo");
    }

    function testSelfEndorseReverts() public {
        vm.prank(alice);
        vm.expectRevert(AgentVouch.SelfEndorsement.selector);
        vouch.endorse("alice", "builder", "me");
    }

    function testDuplicateEndorseReverts() public {
        vm.prank(alice);
        vouch.endorse("bob", "builder", "first");
        vm.prank(alice);
        vm.expectRevert(AgentVouch.AlreadyEndorsed.selector);
        vouch.endorse("bob", "builder", "again");
    }

    function testSamePairDifferentSkillAllowed() public {
        vm.prank(alice);
        vouch.endorse("bob", "builder", "builds");
        vm.prank(alice);
        vouch.endorse("bob", "trader", "trades");

        assertEq(vouch.totalEndorsementCount("bob"), 2, "two skills counted");
        assertEq(vouch.skillEndorsementCount("bob", "builder"), 1, "builder count");
        assertEq(vouch.skillEndorsementCount("bob", "trader"), 1, "trader count");
    }

    function testRevokeAndReEndorse() public {
        vm.prank(alice);
        vouch.endorse("bob", "builder", "first");
        vm.prank(alice);
        vouch.revokeEndorsement("bob", "builder");

        assertEq(vouch.skillEndorsementCount("bob", "builder"), 0, "count decremented");
        assertEq(vouch.totalEndorsementCount("bob"), 0, "total decremented");
        assertFalse(vouch.hasEndorsement(alice, "bob", "builder"), "no longer endorsed");
        assertEq(vouch.totalEndorsementsMade(), 1, "lifetime count keeps history");

        vm.prank(alice);
        vouch.endorse("bob", "builder", "second chance");
        assertTrue(vouch.hasEndorsement(alice, "bob", "builder"), "re-endorse works");
        assertEq(vouch.totalEndorsementsMade(), 2, "lifetime count grows");
    }

    function testRevokeWithoutEndorsementReverts() public {
        vm.prank(alice);
        vm.expectRevert(AgentVouch.NotEndorsed.selector);
        vouch.revokeEndorsement("bob", "builder");
    }

    function testCannotRevokeOthersEndorsement() public {
        vm.prank(alice);
        vouch.endorse("bob", "builder", "mine");
        vm.prank(carol);
        vm.expectRevert(AgentVouch.NotEndorsed.selector);
        vouch.revokeEndorsement("bob", "builder");
        assertTrue(vouch.hasEndorsement(alice, "bob", "builder"), "endorsement untouched");
    }

    // ------------------------------------------------------------- metrics

    function testUniqueInteractorsAcrossUsers() public {
        vm.prank(alice);
        vouch.registerProfile("builder", "a");
        vm.prank(bob);
        vouch.endorse("alice", "builder", "nice");
        vm.prank(carol);
        vouch.endorse("alice", "builder", "agree");

        assertEq(vouch.uniqueInteractors(), 3, "three unique Agent ID interactors");
        assertEq(vouch.totalEndorsementCount("alice"), 2, "alice endorsed twice");
    }
}
