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

## Langkah sisa fase 2

1. Front-end statis (halaman profil + endorse; koneksi wallet standar, TANPA
   login QR; semua tx dikonfirmasi user di wallet-nya sendiri).
2. Submit proyek ke Binance sebelum **9 Des 2026 15:00 WIB** (nama, website,
   alamat kontrak `0x50c3ec6393e62090a349b717247890ac94e8f639`, deskripsi
   pemakaian Agent ID) — butuh konfirmasi nama final + alamat penerima hadiah.
3. Strategi ≥30 interaksi Agent ID (pengumuman X + hashtag resmi, ajakan
   endorse timbal balik, pantau `uniqueInteractors` on-chain).
4. (Opsional) Verifikasi native BscScan bila API key/akun tersedia.
