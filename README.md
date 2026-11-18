# AgentVouch

**A reputation & endorsement graph for Agent ID holders** — built for the
Binance Wallet × BNB Chain **Agent ID Hackathon**
(submission period: 2026-11-18 08:00 UTC → 2026-12-09 08:00 UTC).

Agent ID (`name.ai`) gives every Agentic Wallet a name. AgentVouch gives that
name a **reputation**: holders register a public profile and endorse each other
for skills, forming an on-chain trust graph that any dApp or agent can query
when deciding whom to work with.

## Why Agent ID is the core, not a login button

- **Handles are the primary keys.** Profiles and endorsements are keyed by
  Agent ID handles, not raw addresses.
- **Identity is never user-supplied.** The contract resolves the caller's
  handle from the SPACE ID Agent ID registry itself (`handleOf`), so nobody
  can register or endorse under a name they do not own.
- **Both directions of resolution are used.** Endorsing `name.ai` resolves the
  target through `ownerOfHandle`; reading a profile by handle resolves the
  same way.
- **Every write is gated** by Agent ID ownership — `balanceOf > 0` on the
  registry, exactly the check the official hackathon page documents.

## How it works

| Action | Function | Who can call |
|---|---|---|
| Create/update your profile card | `registerProfile(skill, bio)` | Agent ID holders |
| Endorse a holder for a skill | `endorse(targetHandle, skill, note)` | Agent ID holders |
| Revoke your endorsement | `revokeEndorsement(targetHandle, skill)` | The original endorser |
| Read reputation | `totalEndorsementCount(handle)`, `skillEndorsementCount(handle, skill)`, `hasEndorsement(...)`, `getProfileByHandle(handle)` | Anyone (composable by other dApps/agents) |

Anti-spam is structural: **one active endorsement per (endorser, target,
skill)** — inflating a score requires many distinct Agent IDs, each of which
is a unique, non-transferable identity.

The contract also tracks `uniqueInteractors`, the number of distinct Agent ID
addresses that have written to it.

## Safety by construction

- **No value, ever.** There are no payable functions, no token handling, no
  approvals and no transfers. The contract cannot move user assets.
- **No admin.** There is no owner and no mint/pause/freeze/withdraw function —
  there are no privileged permissions to disclose.
- **No credential collection, no QR login, no brand impersonation, no return
  promises.** Interacting only ever requires the user's own wallet
  confirmation of a gas-only transaction.

## Contracts

| Contract | Address |
|---|---|
| SPACE ID Agent ID registry (BNB Chain) | `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` |
| AgentVouch (BNB Chain) | _deployed in phase 2 — see STATUS.md_ |

### Registry interface used (`src/interfaces/IAgentIdRegistry.sol`)

| Function | Selector | Verified live 2026-11-18 |
|---|---|---|
| `balanceOf(address)` | `0x70a08231` | holder → `1` |
| `handleOf(address)` | `0xc50a1514` | resolves wallet → handle |
| `ownerOfHandle(string)` | `0x1da94fb4` | resolves handle → wallet |
| `isValidHandle(string)` | `0x3ff4dbc2` | handle rules enforced (len 3–20) |

## Local development

The project is dependency-free (no forge-std) — a fresh clone builds offline.

```bash
forge build
forge test            # 16 unit tests (mock registry)
forge test --fork-url https://bsc-dataseed.binance.org/ \
  --match-contract AgentVouchForkTest -v   # integration vs the real registry
```

## Layout

```
src/AgentVouch.sol                    main contract
src/interfaces/IAgentIdRegistry.sol   verified registry interface
test/AgentVouch.t.sol                 unit tests (mock registry)
test/AgentVouchFork.t.sol             fork tests vs the real registry
test/mocks/MockAgentIdRegistry.sol    test double
script/Deploy.s.sol                   phase-2 deployment helper (not executed)
docs/RESEARCH-DESIGN.md               research notes + concept selection
```

## License

MIT — see `LICENSE`.
