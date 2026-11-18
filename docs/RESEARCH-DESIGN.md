# Riset & Desain — Binance Agent ID Hackathon (Fase 1)

Tanggal riset: 2026-11-18. Semua klaim on-chain diverifikasi read-only pada tanggal ini.

## 1. Event (sumber: halaman resmi Binance)

Sumber: https://www.binance.com/en/support/announcement/detail/95f5dbe0ea674a48a739b59e046648bf
("Agent ID Hackathon: Build Decentralized Applications (dApps) Around Agent ID to
Win 60,000 USDC Worth of Rewards", Binance Wallet × BNB Chain, 2026-11-18)

- Submission: 2026-11-18 08:00 UTC s/d 2026-12-09 08:00 UTC (15:00 WIB 9 Des 2026).
  Internal review 9–17 Des, public review 17–20 Des, hadiah ≤14 hari kerja setelahnya.
- Project Awards: 2 kategori × 29.000 USDC, masing-masing Top 10
  (10.000 / 6.000 / 4.000 / 3.000 / 2.000 / 800×5). Satu proyek max 1 award.
  Pemenang juga dapat slot klaim Agent ID 2-digit.
  - Kategori A: ranking data on-chain — jumlah alamat Agent ID yang interaksi,
    volume / jumlah tx, hanya dari kontrak yang disubmit, hanya selama periode.
  - Kategori B (Innovation): skor juri 100 poin —
    Agent ID Application Depth 30%, Practicality & Feasibility 25%,
    Product Completion 25%, Innovation 20%.
    Syarat minimum: produk LIVE + ≥30 alamat Agent ID interaksi selama periode.
- Community Promotion: 2.000 USDC / 20 pemenang (posting X + hashtag
  #BinanceWalletHackathon #AgenticWallet + submit survey) — jalur sampingan fase 2.
- Syarat teknis: deploy BNB Chain, source terverifikasi BscScan + open-source,
  "actively use Agent ID". Tanpa registrasi di muka — submit saat periode buka.
- Red lines (diskualifikasi): login QR web untuk Agentic Wallet; bypass konfirmasi
  user untuk operasi aset; transfer aset tanpa izin / approval tak terbatas diam-diam;
  kontrak tertutup / izin owner tidak didokumentasikan; impersonasi brand Binance/BNB;
  kumpulkan seed/private key/API secret/pairing code; janji return/"passive income";
  produk trading tanpa risk warning; Agent ID dikemas sebagai alat "lookup dompet
  orang lain by name"; manipulasi volume / mass-registration palsu.

## 2. Registry Agent ID (sumber: on-chain, terverifikasi)

Kontrak: `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` (BNB Chain / BSC mainnet, chainId 56)
- Halaman event: "SPACE ID Agent ID", symbol AI, ERC-721, non-transferable.
  Cara resmi cek holder menurut Binance: `balanceOf(address)` > 0.
- Verifikasi read-only via `https://bsc-dataseed.binance.org/` (eth_call/eth_getCode, 2026-11-18):
  - `eth_getCode` = 8.756 byte, BUKAN proxy (slot EIP-1967 kosong) → alamat ini implementasi langsung.
  - `name()` = "SPACE ID Agent ID", `symbol()` = "AI".
  - `totalSupply()` & `tokenOfOwnerByIndex` REVERT → tidak ada ERC721Enumerable.
  - Selector diekstrak dari bytecode (PUSH4 dispatcher) lalu diidentifikasi via
    Openchain signature database + keccak256 lokal (diverifikasi terhadap vektor uji).
- Interface yang relevan untuk dApp (semua terbukti ada di bytecode + sukses di-call):

| Fungsi | Selector | Bukti live (2026-11-18) |
|---|---|---|
| `balanceOf(address)` | 0x70a08231 | balanceOf(wallet tuan) = 1 |
| `handleOf(address)` | 0xc50a1514 | handleOf(wallet tuan) = "begundaall" |
| `ownerOfHandle(string)` | 0x1da94fb4 | ownerOfHandle("begundaall") = wallet tuan |
| `isValidHandle(string)` | 0x3ff4dbc2 | isValidHandle("begundaall") = true |
| `ownerOf(uint256)` | 0x6352211e | standar ERC-721 |
| `tokenURI(uint256)` | 0xc87b56dd | baseURI = https://agentid.prd.space.id/metadata/ |
| `minLen()` / `maxLen()` | 0x60351f9c / 0x583e1055 | 3 / 20 |
| `register(string,uint256,bytes)` | 0x8580974c | jalur klaim signature-gated (signer() 0x238ac933) — hanya via Binance App menurut event |
| `adminRegister(string,address)` | 0xc5c94763 | admin only |

- Error `Soulbound()` (0xa4420a95) ada di bytecode → transfer memang diblokir di level kontrak.
- Kesimpulan integrasi: gate = `balanceOf > 0` (persis cara resmi Binance);
  identitas dua arah = `handleOf(address)` dan `ownerOfHandle(string)`.
  dApp TIDAK perlu tahu tokenId sama sekali.

## 3. Tiga konsep + self-judge (rubrik juri event)

Skor per dimensi 0–100, dibobotkan: Depth 30% · Practicality 25% · Completion 25% · Innovation 20%.

### Kandidat A — "Wall of Agents" (guestbook on-chain khusus holder Agent ID)
Holder Agent ID menulis pesan permanen di dinding publik; kontrak mencap handle
pengirim (dari `handleOf`) di tiap pesan; holder lain bisa like per handle.
- Depth 55 — Agent ID = gate + cap nama, tapi model datanya tetap pesan bebas.
- Practicality 40 — guestbook itu mainan; nilai nyata tipis.
- Completion 90 — sangat sederhana, pasti selesai.
- Innovation 35 — sudah banyak guestbook Web3.
- **Total: 56,0**

### Kandidat B — "HandlePay" (link pembayaran ke handle, bukan alamat)
Kirim BNB/token ke `nama.ai`; kontrak resolve `ownerOfHandle` lalu meneruskan
dana + memo; halaman pay-page per handle digate Agent ID.
- Depth 85 — pembayaran memang use case yang disebut pengumuman; resolusi handle inti.
- Practicality 80 — alamat→nama memang masalah nyata.
- Completion 55 — aliran aset = permukaan risiko + beban review red-line paling berat;
  UX bayar lebih kompleks; selesai tepat waktu tidak pasti.
- Innovation 70 — ENS-like payments sudah ada; eksekusi di Agent ID yang membedakan.
- **Total: 73,3** — TAPI cacat fatal untuk event ini: interaksi mewajibkan orang
  MENGIRIM NILAI → friksi tinggi untuk syarat ≥30 alamat, dan tiap friksi aset
  mengundang risiko diskualifikasi red-line. Ditolak karena risiko, bukan skor.

### Kandidat C — "AgentVouch" (graf endorsement & profil reputasi antar Agent ID) ✅ PEMENANG
Profil publik + endorsement keahlian antar-holder, seluruhnya dikunci oleh handle:
1. `registerProfile(skill, bio)` — holder membuat kartu profil; kontrak mengambil
   handle-nya sendiri dari registry (bukan input user → tidak bisa dipalsukan).
2. `endorse(targetHandle, skill, note)` — holder mendukung holder lain per keahlian
   (builder/trader/artist/auditor/dst). Target di-resolve on-chain via
   `ownerOfHandle`; satu endorsement aktif per (pemberi, target, skill) → anti-spam
   struktural; bisa dicabut (`revokeEndorsement`).
3. Read API komposabel: `endorsementCount`, `hasEndorsement`, `getProfileByHandle` —
   dApp/agent lain bisa memakai graf ini sebagai primitif reputasi.
- Depth 90 — Agent ID bukan login tempelan: handle adalah kunci utama profil,
  kedua ujung endorsement di-resolve dari registry, gate di setiap aksi tulis.
- Practicality 75 — ekonomi agen butuh reputasi portabel (agen mempekerjakan agen);
  nol nilai/aset → aman dicoba siapa pun, nol risiko red-line aset.
- Completion 85 — kontrak tanpa dana sama sekali; front-end statis cukup;
  realistis live jauh sebelum 9 Des.
- Innovation 80 — belum ada graf reputasi khusus identitas agen; berbeda dari
  guestbook generik dan dari payment wrapper.
- **Total: 83,0** ✅

### Kenapa C menang
1. Skor rubrik tertinggi (83,0 vs 73,3 vs 56,0).
2. Jalur paling aman ke syarat ≥30 interaksi: interaksi pertama = 1 tx gas-only
   tanpa nilai, tanpa approval — friksi minimum, nol pelanggaran red-line.
3. Loop viral bawaan: endorsement mengundang target untuk balas/daftar profil.
4. Risiko diskualifikasi paling rendah: kontrak tidak menyentuh aset sama sekali.
