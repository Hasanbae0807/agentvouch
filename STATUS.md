# STATUS — Agent ID Hackathon, Fase 1 (SELESAI 2026-11-18)

Event: Binance Wallet × BNB Chain "Agent ID Hackathon", pool 60.000 USDC.
Deadline submit: **9 Des 2026 15:00 WIB**. Fase 1 = riset + desain + bangun + test
lokal. **Tidak ada deploy, tidak ada broadcast, tidak ada tanda tangan di fase ini.**

## Konsep pemenang: AgentVouch

Graf endorsement & profil reputasi antar-holder Agent ID. Profil dikunci handle
yang di-resolve kontrak sendiri dari registry; endorsement per keahlian antar
handle (satu aktif per pemberi/target/skill = anti-spam); read API komposabel
untuk dApp/agen lain. Kontrak NOL aset: tanpa payable, tanpa approval, tanpa
admin — patuh red-line event by construction.

Self-judge 3 kandidat (rubrik resmi: Depth 30% · Practicality 25% · Completion 25% · Innovation 20%):

| Kandidat | Depth | Practicality | Completion | Innovation | Total |
|---|---|---|---|---|---|
| A — Wall of Agents (guestbook) | 55 | 40 | 90 | 35 | 56,0 |
| B — HandlePay (bayar ke handle) | 85 | 80 | 55 | 70 | 73,3 — ditolak: interaksi wajib kirim nilai (friksi ≥30 alamat) + risiko red-line aset |
| **C — AgentVouch** ✅ | **90** | **75** | **85** | **80** | **83,0** |

Detail riset & alasan lengkap: `docs/RESEARCH-DESIGN.md`.

## Registry yang dipakai (terverifikasi on-chain 2026-11-18, read-only)

- SPACE ID Agent ID: `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` (BSC, ERC-721 "AI",
  non-transferable, bukan proxy, tanpa ERC721Enumerable).
- Interface terverifikasi (bytecode dispatcher + Openchain DB + keccak lokal +
  live eth_call): `balanceOf` 0x70a08231 · `handleOf` 0xc50a1514 ·
  `ownerOfHandle` 0x1da94fb4 · `isValidHandle` 0x3ff4dbc2.
- Bukti live: balanceOf(wallet tuan)=1, handleOf="begundaall",
  ownerOfHandle("begundaall")=wallet tuan, isValidHandle=true, minLen 3/maxLen 20.

## Arsitektur

- `src/AgentVouch.sol` — kontrak utama (gate `onlyAgent`, registerProfile,
  endorse, revokeEndorsement, view komposabel, metrik uniqueInteractors).
- `src/interfaces/IAgentIdRegistry.sol` — interface registry + bukti selector.
- `test/mocks/MockAgentIdRegistry.sol` — test double (tidak pernah di-deploy).
- `test/AgentVouch.t.sol` — 16 unit test; `test/AgentVouchFork.t.sol` — 2 fork
  test vs registry asli (self-skip bila tanpa fork). Tanpa dependensi eksternal.
- `script/Deploy.s.sol` — helper fase 2 (belum dijalankan).

## Hasil test (persis)

- `forge build` — sukses (solc 0.8.30, forge 1.9.0; hanya lint note typecast uint64).
- Unit (mock registry): **16 passed, 0 failed, 0 skipped**.
- Fork (registry BSC asli, read-only): **2 passed, 0 failed** —
  gate lolos untuk wallet holder asli ("begundaall"), non-holder tertolak.
- Suite offline penuh: **18 passed, 0 failed, 0 skipped**.

## Rencana fase 2 (setelah konfirmasi tuan soal gas)

1. Deploy AgentVouch ke BSC mainnet dari wallet agentic (estimasi kasar deploy
   ±1–2 jt gas; kutip ulang harga gas + cek saldo BNB saat eksekusi).
2. Verifikasi source di BscScan + publikasikan repo GitHub (open-source).
3. Front-end statis (halaman profil + endorse; koneksi wallet standar, TANPA
   login QR; semua tx dikonfirmasi user di wallet-nya sendiri).
4. Submit proyek ke Binance (nama, website, alamat kontrak, deskripsi Agent ID).
5. Strategi ≥30 interaksi: pengumuman X + hashtag resmi, ajakan endorse timbal
   balik di komunitas Agent ID/SPACE ID, profil tuan sebagai seed; pantau
   `uniqueInteractors` on-chain sampai ≥30 sebelum 9 Des.
6. Jalur sampingan Community Promotion (2.000 USDC/20 orang): posting X soal
   AgentVouch + #BinanceWalletHackathon #AgenticWallet + submit survey resmi.

## Yang butuh tuan (fase 2)

- [x] Konfirmasi "gas" + gas BNB untuk deploy — "Gass" dari tuan 2026-11-18
      20:03 WIB; deploy SELESAI (lihat Fase 2 di bawah).
- [x] Repo GitHub publik baru — https://github.com/Hasanbae0807/agentvouch
      (dibuat tuan; token muse-push ditambah aksesnya; push SELESAI, lihat
      Fase 2).
- [ ] Konfirmasi nama proyek final ("AgentVouch") + alamat penerima hadiah
      (default: wallet agentic) untuk formulir submit.
- [ ] Posting X dari akun tuan untuk dorongan interaksi + jalur komunitas
      (Muse siapkan teksnya).

## Fase 2 — DEPLOY SELESAI (2026-11-18 ~20:05–20:10 WIB)

- **Kontrak AgentVouch (BSC mainnet): `0x50c3ec6393e62090a349b717247890ac94e8f639`**
- Jalur deploy: `baw contract-call` tidak mendukung creation polos (`--to`
  wajib untuk EVM; preview tanpa `--to` ditolak CLI: "to is required for EVM
  contract-call"). Dipakai jalur yang didukung baw: panggilan biasa ke
  **Deterministic Deployment Proxy (Arachnid CREATE2 factory)
  `0x4e59b44847b379578588920cA78FbF26c0B4956C`** — bytecode on-chain diverifikasi
  byte-for-byte sama dengan proxy kanonis (69 byte). Calldata = salt 32 byte
  (nol) + init code AgentVouch (bytecode + argumen konstruktor registry).
  Alamat hasil CREATE2 deterministik dan sudah diprediksi + disimulasikan
  sebelum broadcast.
- Pipeline validasi: eth_call simulasi creation OK · eth_estimateGas creation
  1.756.537 · simulasi factory-call mengembalikan persis alamat prediksi ·
  preview baw fresh (requestId `b82ce4c595004dda9882a5a9fa5be087`):
  simulationCode sukses, `balanceChanges`/`allowanceChanges`/
  `authorityChanges` SEMUA KOSONG, value 0, tanpa approval — lalu execute.
- **txHash deploy: `0xab617f0b8a60c19203b5c454cfe880d9c99e98403cb40ca5ff7eb71e506e4721`**
  (orderId baw `26111800002063553118`, status BROADCASTED; receipt status
  `0x1`, block 134316236).
- Gas aktual: 1.748.969 gas × 0,107 gwei efektif = **0,00018718 BNB**.
  Saldo BNB wallet agentic sesudah deploy ≈ 0,0015268 BNB.
- Verifikasi read-only pasca-deploy: `eth_getCode` di alamat kontrak = 7.827
  byte (tidak kosong); `registry()` → `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`
  ✅ persis registry resmi; `uniqueInteractors()` = 0; `isAgent(wallet tuan)`
  = true; `handleOf(wallet tuan)` = "begundaall" — kontrak membaca registry
  asli dengan benar end-to-end.
- Verifikasi source: **Sourcify — EXACT MATCH** (creation + runtime),
  matchId 59469281, verifiedAt 2026-11-18T13:05:40Z, job
  `126a0ae7-941d-40a6-b3f1-7aded961410b`
  (https://sourcify.dev/#/lookup/0x50c3ec6393e62090a349b717247890ac94e8f639).
  Verifikasi native BscScan: **PENDING** — API BscScan butuh API key (tidak
  ada key tersedia di VM) / jalur web butuh akun BscScan tuan; belum
  dilakukan, jangan dianggap terverifikasi di BscScan.
- Repo publik: source proyek ter-push ke
  https://github.com/Hasanbae0807/agentvouch (12 file ter-track; tanpa file
  rahasia — tidak ada key/.env di repo).

## Fase 2 — FRONT-END + PAKET SUBMIT SELESAI (2026-11-18, lokal)

- Front-end statis di `web/` (index.html + app.js + style.css; vanilla, tanpa
  build step; ethers v6 via CDN jsdelivr):
  - Connect wallet standar `window.ethereum` (MetaMask / Binance Web3 Wallet);
    TANPA login QR, tanpa pengumpulan seed/private key, tanpa janji imbal
    hasil, tanpa branding meniru Binance/BNB (footer menyatakan proyek
    independen).
  - Menampilkan: status Agent ID wallet terhubung (`isAgent` + `handleOf`
    dari kontrak), `uniqueInteractors`, `totalEndorsementsMade`, profil per
    handle (`ownerOfHandle` via registry + `getProfileByHandle` +
    `totalEndorsementCount`), form `registerProfile`, form
    `endorse`/`revokeEndorsement`, dan daftar endorsement terbaru dari event
    `Endorsed` (queryFilter ±200.000 blok terakhir).
  - Semua tx ditulis user dari wallet-nya sendiri; halaman hanya menyiapkan
    tx via provider. Banner UI menegaskan: "No funds, no approvals —
    endorsements only." Read publik via https://bsc-dataseed.binance.org/.
    Footer: alamat kontrak + link Sourcify + link repo GitHub.
  - ABI di app.js disalin verbatim dari artifact
    `out/AgentVouch.sol/AgentVouch.json`.
- Hasil uji lokal (2026-11-18):
  - `node --check web/app.js` — OK.
  - Cek fungsi: semua fungsi AgentVouch yang dipanggil app.js ADA di ABI
    artifact (endorse, registerProfile, revokeEndorsement, getProfileByHandle,
    handleOf, isAgent, totalEndorsementCount, totalEndorsementsMade,
    uniqueInteractors; `queryFilter` adalah method ethers.js, bukan fungsi
    kontrak). Event filter `Endorsed` ada di ABI. Fungsi registry yang
    dipanggil (`ownerOfHandle`) ada di interface terverifikasi.
  - HTML: semua id yang dipakai JS ada di index.html; tag seimbang, tanpa
    error parser.
  - Smoke test read-only live (cast call ke BSC): `uniqueInteractors()` = 0,
    `totalEndorsementsMade()` = 0, `handleOf(wallet tuan)` = "begundaall" —
    persis yang akan dirender front-end.
- Cara menjalankan front-end: sajikan folder `web/` via static server lokal
  (mis. `python3 -m http.server -d web`) atau via GitHub Pages dari repo
  agentvouch — Pages SUDAH LIVE (lihat bagian GO-LIVE di bawah).
- `SUBMIT-PACKET.md` — draf isian form submit lengkap (nama, kategori
  Innovation, alamat kontrak, deskripsi Agent ID ±150 kata Inggris, catatan
  hosting, checklist). Alamat penerima hadiah = wallet agentic, bertanda
  menunggu konfirmasi final tuan.
- `X-POST-DRAFT.md` — 2 draf post X Community Promotion (hashtag
  #BinanceWalletHackathon + #AgenticWallet + link repo). DRAF saja, belum
  diposting.

## Langkah sisa fase 2

1. ~~Front-end statis~~ — SELESAI dan SUDAH TAYANG (push + GitHub Pages
   LIVE, lihat bagian GO-LIVE di bawah).
2. Konfirmasi tuan: nama final "AgentVouch" + alamat penerima hadiah →
   submit proyek ke Binance sebelum **9 Des 2026 15:00 WIB**
   (pakai SUBMIT-PACKET.md; website untuk form =
   https://hasanbae0807.github.io/agentvouch/).
3. Strategi ≥30 interaksi Agent ID (posting X dari akun tuan — draf di
   X-POST-DRAFT.md — + ajakan endorse timbal balik di komunitas Agent ID /
   SPACE ID, pantau `uniqueInteractors` on-chain).
4. (Opsional) Verifikasi native BscScan bila API key/akun tersedia.

## Fase 2 — GO-LIVE SELESAI (2026-11-18 ~20:11–20:16 WIB, perintah tuan "Gas")

- Push ke `main` repo https://github.com/Hasanbae0807/agentvouch via
  gh_push.py: commit remote **`bef432d9daea8cd9c7d938d40b1ae4e94bf72413`**
  (17 file: seluruh proyek fase 1+2 termasuk `web/index.html`,
  `web/app.js`, `web/style.css`, `SUBMIT-PACKET.md`, `X-POST-DRAFT.md`,
  `STATUS.md`). Terverifikasi via API: folder `web/` di main memuat persis
  app.js/index.html/style.css; SUBMIT-PACKET.md & X-POST-DRAFT.md ada.
- GitHub Pages: branch khusus **`gh-pages`** dibuat (ref dibuat via Git
  Data API menunjuk commit main, lalu isinya diganti tree bersih berisi
  HANYA 3 file web/ di root branch) — commit gh-pages
  **`fdd14e129b573d334eeb4bb112183a642810d12f`**. Membuat branch gh-pages
  otomatis mengaktifkan Pages (build_type legacy, source gh-pages `/`),
  jadi POST /pages tidak diperlukan. Build terakhir (id 1380987124)
  status **built**, error null.
  - Catatan teknis: percobaan pertama push gh-pages gagal di tahap seed
    helper — persisnya PUT contents dengan branch yang belum ada menjawab
    404 `{"message":"Branch gh-pages not found",...}`; diatasi dengan
    membuat ref gh-pages lebih dulu via POST /git/refs.
- **URL LIVE: https://hasanbae0807.github.io/agentvouch/** — terverifikasi
  2026-11-18 13:12 UTC (±20:12 WIB): halaman termuat (judul "AgentVouch —
  Reputation & Endorsements for Agent ID Holders", banner "No funds, no
  approvals — endorsements only", seksi Network stats / Look up a profile /
  Endorse a holder / Latest endorsements). `app.js` ikut ter-serve penuh
  dan memuat `AGENTVOUCH_ADDRESS =
  "0x50c3ec6393e62090a349b717247890ac94e8f639"`; index.html memuat alamat
  kontrak yang sama (footer, link BscScan + Sourcify) dan
  `<script src="app.js"></script>`.
- TIDAK ada submit ke Binance, TIDAK ada posting X, TIDAK ada tanda
  tangan/deploy apa pun di run go-live ini.
