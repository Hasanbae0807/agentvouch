"use strict";
/*
 * AgentVouch front-end.
 * - Reads go through a public BSC RPC (no wallet needed).
 * - Writes are prepared here but signed and sent ONLY by the user's own
 *   wallet (window.ethereum). This page never handles keys or seed phrases.
 * - The AgentVouch contract is asset-free: no payable functions, no token
 *   approvals. Every write is a gas-only endorsement/profile transaction.
 */

const AGENTVOUCH_ADDRESS = "0x50c3ec6393e62090a349b717247890ac94e8f639";
const REGISTRY_ADDRESS = "0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F";
const BSC_CHAIN_ID = 56n;
const BSC_RPC = "https://bsc-dataseed.binance.org/";

// ABI copied verbatim from the build artifact out/AgentVouch.sol/AgentVouch.json
const AGENTVOUCH_ABI = [{"type": "constructor", "inputs": [{"name": "registry_", "type": "address", "internalType": "address"}], "stateMutability": "nonpayable"}, {"type": "function", "name": "endorse", "inputs": [{"name": "targetHandle", "type": "string", "internalType": "string"}, {"name": "skill", "type": "string", "internalType": "string"}, {"name": "note", "type": "string", "internalType": "string"}], "outputs": [], "stateMutability": "nonpayable"}, {"type": "function", "name": "endorsementKey", "inputs": [{"name": "endorser", "type": "address", "internalType": "address"}, {"name": "targetHandle", "type": "string", "internalType": "string"}, {"name": "skill", "type": "string", "internalType": "string"}], "outputs": [{"name": "", "type": "bytes32", "internalType": "bytes32"}], "stateMutability": "pure"}, {"type": "function", "name": "endorsements", "inputs": [{"name": "", "type": "bytes32", "internalType": "bytes32"}], "outputs": [{"name": "endorser", "type": "address", "internalType": "address"}, {"name": "endorserHandle", "type": "string", "internalType": "string"}, {"name": "skill", "type": "string", "internalType": "string"}, {"name": "note", "type": "string", "internalType": "string"}, {"name": "createdAt", "type": "uint64", "internalType": "uint64"}, {"name": "active", "type": "bool", "internalType": "bool"}], "stateMutability": "view"}, {"type": "function", "name": "getProfileByHandle", "inputs": [{"name": "handle", "type": "string", "internalType": "string"}], "outputs": [{"name": "", "type": "tuple", "internalType": "struct AgentVouch.Profile", "components": [{"name": "handle", "type": "string", "internalType": "string"}, {"name": "skill", "type": "string", "internalType": "string"}, {"name": "bio", "type": "string", "internalType": "string"}, {"name": "updatedAt", "type": "uint64", "internalType": "uint64"}, {"name": "exists", "type": "bool", "internalType": "bool"}]}], "stateMutability": "view"}, {"type": "function", "name": "handleOf", "inputs": [{"name": "user", "type": "address", "internalType": "address"}], "outputs": [{"name": "", "type": "string", "internalType": "string"}], "stateMutability": "view"}, {"type": "function", "name": "hasEndorsement", "inputs": [{"name": "endorser", "type": "address", "internalType": "address"}, {"name": "targetHandle", "type": "string", "internalType": "string"}, {"name": "skill", "type": "string", "internalType": "string"}], "outputs": [{"name": "", "type": "bool", "internalType": "bool"}], "stateMutability": "view"}, {"type": "function", "name": "hasInteracted", "inputs": [{"name": "", "type": "address", "internalType": "address"}], "outputs": [{"name": "", "type": "bool", "internalType": "bool"}], "stateMutability": "view"}, {"type": "function", "name": "isAgent", "inputs": [{"name": "user", "type": "address", "internalType": "address"}], "outputs": [{"name": "", "type": "bool", "internalType": "bool"}], "stateMutability": "view"}, {"type": "function", "name": "profiles", "inputs": [{"name": "", "type": "address", "internalType": "address"}], "outputs": [{"name": "handle", "type": "string", "internalType": "string"}, {"name": "skill", "type": "string", "internalType": "string"}, {"name": "bio", "type": "string", "internalType": "string"}, {"name": "updatedAt", "type": "uint64", "internalType": "uint64"}, {"name": "exists", "type": "bool", "internalType": "bool"}], "stateMutability": "view"}, {"type": "function", "name": "registerProfile", "inputs": [{"name": "skill", "type": "string", "internalType": "string"}, {"name": "bio", "type": "string", "internalType": "string"}], "outputs": [], "stateMutability": "nonpayable"}, {"type": "function", "name": "registry", "inputs": [], "outputs": [{"name": "", "type": "address", "internalType": "contract IAgentIdRegistry"}], "stateMutability": "view"}, {"type": "function", "name": "revokeEndorsement", "inputs": [{"name": "targetHandle", "type": "string", "internalType": "string"}, {"name": "skill", "type": "string", "internalType": "string"}], "outputs": [], "stateMutability": "nonpayable"}, {"type": "function", "name": "skillEndorsementCount", "inputs": [{"name": "", "type": "string", "internalType": "string"}, {"name": "", "type": "string", "internalType": "string"}], "outputs": [{"name": "", "type": "uint256", "internalType": "uint256"}], "stateMutability": "view"}, {"type": "function", "name": "totalEndorsementCount", "inputs": [{"name": "", "type": "string", "internalType": "string"}], "outputs": [{"name": "", "type": "uint256", "internalType": "uint256"}], "stateMutability": "view"}, {"type": "function", "name": "totalEndorsementsMade", "inputs": [], "outputs": [{"name": "", "type": "uint256", "internalType": "uint256"}], "stateMutability": "view"}, {"type": "function", "name": "uniqueInteractors", "inputs": [], "outputs": [{"name": "", "type": "uint256", "internalType": "uint256"}], "stateMutability": "view"}, {"type": "event", "name": "Endorsed", "inputs": [{"name": "endorser", "type": "address", "indexed": true, "internalType": "address"}, {"name": "endorserHandle", "type": "string", "indexed": false, "internalType": "string"}, {"name": "target", "type": "address", "indexed": true, "internalType": "address"}, {"name": "targetHandle", "type": "string", "indexed": false, "internalType": "string"}, {"name": "skill", "type": "string", "indexed": false, "internalType": "string"}], "anonymous": false}, {"type": "event", "name": "EndorsementRevoked", "inputs": [{"name": "endorser", "type": "address", "indexed": true, "internalType": "address"}, {"name": "targetHandle", "type": "string", "indexed": false, "internalType": "string"}, {"name": "skill", "type": "string", "indexed": false, "internalType": "string"}], "anonymous": false}, {"type": "event", "name": "ProfileRegistered", "inputs": [{"name": "wallet", "type": "address", "indexed": true, "internalType": "address"}, {"name": "handle", "type": "string", "indexed": false, "internalType": "string"}, {"name": "skill", "type": "string", "indexed": false, "internalType": "string"}], "anonymous": false}, {"type": "error", "name": "AlreadyEndorsed", "inputs": []}, {"type": "error", "name": "EmptySkill", "inputs": []}, {"type": "error", "name": "NotAgentIdHolder", "inputs": [{"name": "caller", "type": "address", "internalType": "address"}]}, {"type": "error", "name": "NotEndorsed", "inputs": []}, {"type": "error", "name": "SelfEndorsement", "inputs": []}, {"type": "error", "name": "TargetNotFound", "inputs": [{"name": "handle", "type": "string", "internalType": "string"}]}];

// Minimal registry ABI (only the read functions this page uses, selectors
// verified in src/interfaces/IAgentIdRegistry.sol).
const REGISTRY_ABI = [
  "function balanceOf(address owner) view returns (uint256)",
  "function handleOf(address owner) view returns (string)",
  "function ownerOfHandle(string handle) view returns (address)",
  "function isValidHandle(string handle) view returns (bool)",
];

const $ = (id) => document.getElementById(id);

const readProvider = new ethers.JsonRpcProvider(BSC_RPC);
const vouchRead = new ethers.Contract(AGENTVOUCH_ADDRESS, AGENTVOUCH_ABI, readProvider);
const registryRead = new ethers.Contract(REGISTRY_ADDRESS, REGISTRY_ABI, readProvider);

let signer = null;
let myAddress = null;
let vouchWrite = null;

function shortAddr(a) {
  return a ? a.slice(0, 6) + "…" + a.slice(-4) : "";
}

function setTxStatus(msg) {
  $("txStatus").textContent = msg;
}

/* ------------------------------------------------------------- stats */

async function loadStats() {
  try {
    const [interactors, made] = await Promise.all([
      vouchRead.uniqueInteractors(),
      vouchRead.totalEndorsementsMade(),
    ]);
    $("statInteractors").textContent = interactors.toString();
    $("statEndorsements").textContent = made.toString();
  } catch (e) {
    $("statInteractors").textContent = "?";
    $("statEndorsements").textContent = "?";
  }
}

/* ------------------------------------------------- recent endorsements */

async function loadRecent() {
  const list = $("recentList");
  try {
    const latest = await readProvider.getBlockNumber();
    const from = Math.max(0, latest - 200000); // ~1.7 days of BSC blocks
    const logs = await vouchRead.queryFilter(vouchRead.filters.Endorsed(), from, latest);
    if (logs.length === 0) {
      list.innerHTML = '<li class="muted">No endorsements yet — be the first.</li>';
      return;
    }
    const items = logs.slice(-10).reverse();
    list.innerHTML = "";
    for (const log of items) {
      const a = log.args;
      const li = document.createElement("li");
      li.textContent =
        `${a.endorserHandle}.ai endorsed ${a.targetHandle}.ai for "${a.skill}"`;
      list.appendChild(li);
    }
  } catch (e) {
    list.innerHTML = '<li class="muted">Could not load recent endorsements.</li>';
  }
}

/* ------------------------------------------------------------ wallet */

async function connectWallet() {
  if (!window.ethereum) {
    $("walletInfo").textContent =
      "No wallet found. Open this page in a wallet browser (e.g. Binance Web3 Wallet or MetaMask) or install a wallet extension.";
    return;
  }
  try {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const network = await provider.getNetwork();
    if (network.chainId !== BSC_CHAIN_ID) {
      await window.ethereum.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: "0x38" }],
      });
    }
    signer = await provider.getSigner();
    myAddress = await signer.getAddress();
    vouchWrite = new ethers.Contract(AGENTVOUCH_ADDRESS, AGENTVOUCH_ABI, signer);
    $("connectBtn").textContent = "Connected";
    $("walletInfo").textContent = "Wallet: " + shortAddr(myAddress);
    await loadMyStatus();
  } catch (e) {
    $("walletInfo").textContent = "Connection failed or was rejected in the wallet.";
  }
}

async function loadMyStatus() {
  const status = $("myStatus");
  try {
    const isAgent = await vouchRead.isAgent(myAddress);
    if (!isAgent) {
      status.textContent =
        "This wallet does not hold an Agent ID, so it cannot register a profile or endorse. You can still browse profiles below.";
      $("myProfile").hidden = true;
      return;
    }
    const handle = await vouchRead.handleOf(myAddress);
    const total = await vouchRead.totalEndorsementCount(handle);
    status.textContent = "Agent ID detected for this wallet.";
    $("myHandle").textContent = handle + ".ai";
    $("myEndorseTotal").textContent = total.toString();
    $("myProfile").hidden = false;
  } catch (e) {
    status.textContent = "Could not read Agent ID status for this wallet.";
  }
}

$("connectBtn").addEventListener("click", connectWallet);

/* ----------------------------------------------------------- profile */

$("profileForm").addEventListener("submit", async (ev) => {
  ev.preventDefault();
  if (!vouchWrite) { setTxStatus("Connect your wallet first."); return; }
  const skill = $("profileSkill").value.trim();
  const bio = $("profileBio").value.trim();
  if (!skill) { setTxStatus("Skill must not be empty."); return; }
  try {
    setTxStatus("Waiting for you to confirm the transaction in your wallet…");
    const tx = await vouchWrite.registerProfile(skill, bio);
    setTxStatus("Transaction sent: " + tx.hash + " — waiting for confirmation…");
    await tx.wait();
    setTxStatus("Profile saved. Transaction: " + tx.hash);
    await loadStats();
    await loadMyStatus();
  } catch (e) {
    setTxStatus("Transaction failed or was rejected: " + (e.shortMessage || e.message));
  }
});

/* ------------------------------------------------------------ lookup */

$("lookupForm").addEventListener("submit", async (ev) => {
  ev.preventDefault();
  const out = $("lookupResult");
  const handle = $("lookupHandle").value.trim().replace(/\.ai$/i, "");
  out.textContent = "Loading…";
  try {
    const owner = await registryRead.ownerOfHandle(handle);
    if (owner === ethers.ZeroAddress) {
      out.textContent = `Handle "${handle}" is not registered as an Agent ID.`;
      return;
    }
    const [profile, total] = await Promise.all([
      vouchRead.getProfileByHandle(handle),
      vouchRead.totalEndorsementCount(handle),
    ]);
    const lines = [
      `Handle: ${handle}.ai`,
      `Owner wallet: ${owner}`,
      `Endorsements received (all skills): ${total.toString()}`,
    ];
    if (profile.exists) {
      lines.push(`Primary skill: ${profile.skill}`);
      lines.push(`Bio: ${profile.bio || "—"}`);
      lines.push(`Profile last updated: ${new Date(Number(profile.updatedAt) * 1000).toLocaleString()}`);
    } else {
      lines.push("This holder has not registered an AgentVouch profile yet.");
    }
    out.textContent = lines.join("\n");
  } catch (e) {
    out.textContent = "Lookup failed: " + (e.shortMessage || e.message);
  }
});

/* ----------------------------------------------------------- endorse */

$("endorseForm").addEventListener("submit", async (ev) => {
  ev.preventDefault();
  if (!vouchWrite) { setTxStatus("Connect your wallet first."); return; }
  const target = $("endorseTarget").value.trim().replace(/\.ai$/i, "");
  const skill = $("endorseSkill").value.trim();
  const note = $("endorseNote").value.trim();
  if (!target || !skill) { setTxStatus("Target handle and skill are required."); return; }
  try {
    setTxStatus("Waiting for you to confirm the endorsement in your wallet…");
    const tx = await vouchWrite.endorse(target, skill, note);
    setTxStatus("Transaction sent: " + tx.hash + " — waiting for confirmation…");
    await tx.wait();
    setTxStatus(`Endorsed ${target}.ai for "${skill}". Transaction: ` + tx.hash);
    await loadStats();
    await loadRecent();
  } catch (e) {
    setTxStatus("Endorsement failed or was rejected: " + (e.shortMessage || e.message));
  }
});

$("revokeBtn").addEventListener("click", async () => {
  if (!vouchWrite) { setTxStatus("Connect your wallet first."); return; }
  const target = $("endorseTarget").value.trim().replace(/\.ai$/i, "");
  const skill = $("endorseSkill").value.trim();
  if (!target || !skill) { setTxStatus("Fill in the target handle and skill to revoke."); return; }
  try {
    setTxStatus("Waiting for you to confirm the revocation in your wallet…");
    const tx = await vouchWrite.revokeEndorsement(target, skill);
    setTxStatus("Transaction sent: " + tx.hash + " — waiting for confirmation…");
    await tx.wait();
    setTxStatus(`Revoked your endorsement of ${target}.ai for "${skill}". Transaction: ` + tx.hash);
    await loadStats();
    await loadRecent();
  } catch (e) {
    setTxStatus("Revocation failed or was rejected: " + (e.shortMessage || e.message));
  }
});

/* -------------------------------------------------------------- init */

loadStats();
loadRecent();
