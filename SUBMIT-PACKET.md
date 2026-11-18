# SUBMIT PACKET — Agent ID Hackathon (DRAF, belum disubmit)

Isian siap tempel untuk formulir submit Binance. Deadline: **9 Des 2026
15:00 WIB**. Yang bertanda ⚠️ menunggu konfirmasi final tuan sebelum submit.

## Isian formulir

| Field | Isi |
|---|---|
| Project name | AgentVouch |
| Category | Innovation Award (Category B) |
| Contract address (BNB Chain mainnet) | `0x50c3ec6393e62090a349b717247890ac94e8f639` |
| Website | ⚠️ Lihat catatan hosting di bawah — sementara: https://github.com/Hasanbae0807/agentvouch |
| Prize recipient address | ⚠️ `0xcc64fd7BadF9e9f83ee301BdfB802f32705Cd760` (wallet agentic tuan — MENUNGGU KONFIRMASI FINAL TUAN) |
| Open-source repo | https://github.com/Hasanbae0807/agentvouch |
| Verified source | Sourcify EXACT MATCH — https://sourcify.dev/#/lookup/0x50c3ec6393e62090a349b717247890ac94e8f639 |
| Agent ID registry used | `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` (SPACE ID Agent ID, BNB Chain) |

## Agent ID usage description (English, ±150 words — tempel ke field deskripsi)

> AgentVouch is an on-chain reputation and endorsement graph built entirely
> around SPACE ID Agent ID. Agent ID gives every Agentic Wallet a name;
> AgentVouch gives that name a reputation. The contract resolves identity from
> the Agent ID registry itself — profiles and endorsements are keyed by handles
> that the contract reads via `handleOf` and `ownerOfHandle`, never by
> user-supplied names — so nobody can register or vouch under an identity they
> do not own. Every write is gated by Agent ID ownership (registry
> `balanceOf > 0`), exactly the check the hackathon documents. Holders register
> a public profile and endorse each other per skill, with one active
> endorsement per (endorser, target, skill) to keep scores spam-resistant. All
> reputation data is exposed through composable read functions, so other dApps
> and agents can query trust before choosing whom to work with. The contract is
> asset-free by construction: no payable functions, no token approvals, no
> admin keys.

## Catatan website / hosting front-end

Front-end statis sudah jadi di `web/` (index.html + app.js + style.css, tanpa
build step). Formulir submit butuh URL website yang hidup. Opsi yang disiapkan:

**GitHub Pages dari repo agentvouch (disarankan, gratis):**

1. Buka https://github.com/Hasanbae0807/agentvouch → Settings → Pages.
2. Source: "Deploy from a branch" → branch `main`, folder `/web` — bila folder
   `/web` tidak muncul sebagai pilihan, pakai branch `gh-pages` berisi isi
   folder `web/`, atau pindahkan isi `web/` ke folder `docs/`.
3. Save → URL situs menjadi `https://hasanbae0807.github.io/agentvouch/`.
4. Pakai URL itu sebagai field Website saat submit.

⚠️ Pages BELUM diaktifkan (menunggu konfirmasi tuan + nama final). Alternatif:
hosting statis apa pun (Netlify/Vercel/IPFS) dengan mengunggah folder `web/`.

## Syarat Innovation Award yang harus dijaga

- Produk LIVE + **≥30 alamat Agent ID berinteraksi** dengan kontrak selama
  periode submit (pantau `uniqueInteractors()` on-chain; saat paket ini dibuat
  masih 0 — strategi interaksi terpisah, lihat STATUS.md).
- Source terverifikasi + open-source: ✅ Sourcify exact match, repo publik.
- Tanpa deposit/lock/KYC khusus event.

## Checklist sebelum submit (diisi saat hari-H)

- [ ] Tuan konfirmasi nama final "AgentVouch".
- [ ] Tuan konfirmasi alamat penerima hadiah.
- [ ] GitHub Pages aktif, URL website final terisi.
- [ ] `uniqueInteractors()` ≥ 30 (atau submit tetap jalan dengan skor data
      apa adanya — keputusan tuan).
