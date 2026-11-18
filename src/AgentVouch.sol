// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAgentIdRegistry} from "./interfaces/IAgentIdRegistry.sol";

/// @title AgentVouch — reputation & endorsement graph for Agent ID holders
/// @notice Agent ID holders register a public profile keyed by their handle and
///         endorse each other for skills. Identity is never user-supplied: the
///         contract resolves handles from the SPACE ID Agent ID registry itself,
///         so a profile or endorsement cannot be forged under someone else's name.
///
/// @dev Safety / hackathon red-line compliance BY CONSTRUCTION:
///      - No payable functions, no token handling, no approvals, no transfers.
///        This contract can never move user assets.
///      - No admin/owner at all: no mint, pause, freeze or withdraw powers exist,
///        so there are no privileged permissions to disclose.
///      - Every write is gated by Agent ID ownership (registry.balanceOf > 0),
///        exactly the check the official hackathon page documents.
///      - Endorsements are one-active-per (endorser, target, skill), which makes
///        spam structurally expensive and keeps counts meaningful.
contract AgentVouch {
    /// @notice SPACE ID Agent ID registry this deployment reads identity from.
    IAgentIdRegistry public immutable registry;

    struct Profile {
        string handle; // resolved from the registry at write time, never user input
        string skill; // primary skill, free text (e.g. "builder")
        string bio; // short free text
        uint64 updatedAt;
        bool exists;
    }

    struct Endorsement {
        address endorser;
        string endorserHandle; // resolved from the registry at write time
        string skill;
        string note;
        uint64 createdAt;
        bool active;
    }

    /// @notice Profiles by wallet address.
    mapping(address => Profile) public profiles;
    /// @notice Active endorsement count: targetHandle => skill => count.
    mapping(string => mapping(string => uint256)) public skillEndorsementCount;
    /// @notice Active endorsement count: targetHandle => total.
    mapping(string => uint256) public totalEndorsementCount;
    /// @notice Endorsements by key = keccak256(endorser, targetHandle, skill).
    mapping(bytes32 => Endorsement) public endorsements;
    /// @notice Whether an address has ever written to this contract.
    mapping(address => bool) public hasInteracted;
    /// @notice Unique Agent ID addresses that have interacted (hackathon metric).
    uint256 public uniqueInteractors;
    /// @notice Lifetime count of endorsements created (incl. later revoked).
    uint256 public totalEndorsementsMade;

    event ProfileRegistered(address indexed wallet, string handle, string skill);
    event Endorsed(
        address indexed endorser,
        string endorserHandle,
        address indexed target,
        string targetHandle,
        string skill
    );
    event EndorsementRevoked(address indexed endorser, string targetHandle, string skill);

    error NotAgentIdHolder(address caller);
    error TargetNotFound(string handle);
    error SelfEndorsement();
    error EmptySkill();
    error AlreadyEndorsed();
    error NotEndorsed();

    modifier onlyAgent() {
        if (registry.balanceOf(msg.sender) == 0) revert NotAgentIdHolder(msg.sender);
        _;
    }

    constructor(address registry_) {
        registry = IAgentIdRegistry(registry_);
    }

    // ------------------------------------------------------------- writes

    /// @notice Create or update your public profile. Your handle is read from
    ///         the Agent ID registry — you cannot choose or fake it.
    function registerProfile(string calldata skill, string calldata bio) external onlyAgent {
        if (bytes(skill).length == 0) revert EmptySkill();
        string memory handle = registry.handleOf(msg.sender);
        profiles[msg.sender] = Profile({
            handle: handle,
            skill: skill,
            bio: bio,
            updatedAt: uint64(block.timestamp),
            exists: true
        });
        _markInteracted(msg.sender);
        emit ProfileRegistered(msg.sender, handle, skill);
    }

    /// @notice Endorse another Agent ID holder for a skill.
    /// @param targetHandle Handle of the holder being endorsed (without ".ai").
    /// @param skill Skill tag, e.g. "builder", "trader", "auditor".
    /// @param note Short free-text note.
    function endorse(string calldata targetHandle, string calldata skill, string calldata note)
        external
        onlyAgent
    {
        if (bytes(skill).length == 0) revert EmptySkill();
        address target = registry.ownerOfHandle(targetHandle);
        if (target == address(0)) revert TargetNotFound(targetHandle);
        if (target == msg.sender) revert SelfEndorsement();

        bytes32 key = endorsementKey(msg.sender, targetHandle, skill);
        Endorsement storage e = endorsements[key];
        if (e.active) revert AlreadyEndorsed();

        string memory myHandle = registry.handleOf(msg.sender);
        e.endorser = msg.sender;
        e.endorserHandle = myHandle;
        e.skill = skill;
        e.note = note;
        e.createdAt = uint64(block.timestamp);
        e.active = true;

        skillEndorsementCount[targetHandle][skill] += 1;
        totalEndorsementCount[targetHandle] += 1;
        totalEndorsementsMade += 1;
        _markInteracted(msg.sender);
        emit Endorsed(msg.sender, myHandle, target, targetHandle, skill);
    }

    /// @notice Revoke one of your active endorsements.
    function revokeEndorsement(string calldata targetHandle, string calldata skill) external {
        bytes32 key = endorsementKey(msg.sender, targetHandle, skill);
        Endorsement storage e = endorsements[key];
        if (!e.active || e.endorser != msg.sender) revert NotEndorsed();
        e.active = false;
        skillEndorsementCount[targetHandle][skill] -= 1;
        totalEndorsementCount[targetHandle] -= 1;
        emit EndorsementRevoked(msg.sender, targetHandle, skill);
    }

    // -------------------------------------------------------------- views

    /// @notice Deterministic key for an (endorser, target, skill) endorsement.
    function endorsementKey(address endorser, string memory targetHandle, string memory skill)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(endorser, targetHandle, skill));
    }

    /// @notice Whether `endorser` currently endorses `targetHandle` for `skill`.
    function hasEndorsement(address endorser, string calldata targetHandle, string calldata skill)
        external
        view
        returns (bool)
    {
        return endorsements[endorsementKey(endorser, targetHandle, skill)].active;
    }

    /// @notice Profile lookup by handle (resolved through the registry).
    function getProfileByHandle(string calldata handle) external view returns (Profile memory) {
        address wallet = registry.ownerOfHandle(handle);
        return profiles[wallet];
    }

    /// @notice Convenience passthrough: does this address hold an Agent ID?
    function isAgent(address user) external view returns (bool) {
        return registry.balanceOf(user) > 0;
    }

    /// @notice Convenience passthrough: the Agent ID handle of an address.
    function handleOf(address user) external view returns (string memory) {
        return registry.handleOf(user);
    }

    // ----------------------------------------------------------- internal

    function _markInteracted(address user) internal {
        if (!hasInteracted[user]) {
            hasInteracted[user] = true;
            uniqueInteractors += 1;
        }
    }
}
