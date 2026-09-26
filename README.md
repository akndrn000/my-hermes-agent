# 🤖 Hermes Agent — Telegram & Discord Bot (Railway, OpenCode Zen)

Bot AI pribadi berbasis **Hermes Agent** (open-source resmi dari Nous Research),
di-deploy di **Railway**, terhubung ke **Telegram** dan **Discord** sekaligus,
pakai **OpenCode Zen** sebagai satu-satunya provider model (dengan beberapa
model gratis di dalamnya sebagai fallback otomatis).

---

## 📖 Daftar Isi

1. [Pengertian](#-pengertian)
2. [Struktur Repo](#-struktur-repo)
3. [Cara Pemasangan](#-cara-pemasangan)
4. [Environment Variables](#-environment-variables)
5. [Provider & Model yang Dipakai](#-provider--model-yang-dipakai)
6. [Command di Chat](#-command-di-chat)
7. [Troubleshooting](#-troubleshooting)
8. [Keamanan](#-keamanan)
9. [FAQ](#-faq)

---

## 📌 Pengertian

Repo ini berisi konfigurasi siap pakai untuk men-deploy **Hermes Agent resmi**
(`nousresearch/hermes-agent`, bukan fork/modifikasi) ke Railway sebagai bot
Telegram + Discord, dengan **OpenCode Zen** sebagai provider model tunggal.

Semua nama model & pengaturan teknis (provider, model, timezone, dll) sudah
**di-hardcode di dalam `Dockerfile`** — jadi kamu cuma perlu isi **API key
OpenCode Zen dan data pribadi kamu** (token bot, ID user) di Railway.

### Alur fallback

```
Chat masuk
   ↓
OpenCode Zen — DeepSeek V4 Flash (Free)   ← provider utama
   ↓ kena limit / error?
OpenCode Zen — MiMo-V2.5 (Free)
   ↓ kena limit / error?
OpenCode Zen — Nemotron 3 Ultra (Free)
```

Semua model di atas jalan lewat **satu endpoint dan satu API key** OpenCode
Zen (`https://opencode.ai/zen/v1`), jadi nggak perlu daftar ke provider lain.

---

## 📁 Struktur Repo

```
repo-ini/
├── Dockerfile       # Instruksi build + provider/model sudah hardcode
├── railway.toml     # Konfigurasi deploy Railway (restart policy)
├── .gitignore       # Cegah file .env lokal ke-upload
└── README.md        # Dokumen ini
```

Upload 4 file ini ke root repo GitHub kamu (bikin repo baru, **Private**
disarankan).

> ⚠️ **Jangan** pakai opsi "Deploy a Docker Image" langsung dari Railway
> (pilih image dari Docker Hub tanpa Dockerfile). Itu berisiko menimpa
> entrypoint resmi image (s6-overlay) dan bikin error "Permission denied"
> di `/opt/data`. Selalu deploy dari repo GitHub berisi `Dockerfile` di
> atas, dan biarkan **Custom Start Command di Railway kosong** — biar
> Docker `CMD` bawaan Dockerfile ini yang jalan.

---

## 🚀 Cara Pemasangan

### Langkah 1 — Buat Bot Telegram

1. Chat **@BotFather** → `/newbot` → ikuti instruksi.
2. Simpan **Bot Token** (format: `123456789:AAxxxxxxxxxxxxxxxxxxxxxxxx`).
3. Chat **@userinfobot** → catat **User ID** kamu.

### Langkah 2 — Buat Bot Discord

1. Discord Developer Portal (discord.com/developers/applications) → **New Application** → **Bot** → **Reset Token** → simpan.
2. Aktifkan **Message Content Intent** & **Server Members Intent** di halaman Bot.
3. Discord → Settings → Advanced → aktifkan **Developer Mode**.
4. Klik kanan profil sendiri → **Copy User ID** → simpan.
5. **OAuth2 → URL Generator** → scope `bot` + `applications.commands`, permission `Send Messages`, `Read Message History`, `Attach Files` → buka URL → pilih server → **Authorize**.
6. Klik kanan channel yang mau dipakai → **Copy Channel ID** → simpan.

### Langkah 3 — Ambil API Key OpenCode Zen

1. Buka **opencode.ai/zen**, login/daftar.
2. Tambahkan detail billing (wajib walau mau pakai model gratis — hanya
   dikenakan biaya kalau pilih model berbayar).
3. Copy API key-nya (format `sk-...`).

### Langkah 4 — Upload Repo ke GitHub

Buat repo baru → upload `Dockerfile`, `railway.toml`, `.gitignore`, `README.md`.

### Langkah 5 — Deploy ke Railway

1. Railway → **New Project** → **Deploy from GitHub repo** → pilih repo.
2. Tekan `Ctrl+K`/`⌘K` di canvas project → **Volume** → hubungkan ke service ini → Mount Path: `/opt/data`
3. Tab **Variables** → **Raw Editor** → paste isi dari bagian Environment Variables di bawah → isi data asli kamu.
4. Pastikan tab **Settings → Deploy → Custom Start Command KOSONG** (tidak diisi manual).
5. Tab **Deployments** → titik tiga (⋮) → **Redeploy**.
6. **View Logs**, tunggu sampai muncul:
   ```
   HERMES MODEL CONFIG
   ```
   diikuti status gateway Telegram/Discord connected.

### Langkah 6 — Testing

Chat bot di Telegram, dan mention/chat bot di channel Discord yang diizinkan.

---

## 🔑 Environment Variables

Isi di Railway → Variables (tanpa tanda kutip di sekitar value):

```env
# ===== WAJIB =====
OPENCODE_API_KEY=sk-ganti-punya-kamu

TELEGRAM_BOT_TOKEN=ganti-token-botfather
TELEGRAM_HOME_CHANNEL=ganti-user-id-kamu
TELEGRAM_HOME_CHANNEL_NAME=Nama Bebas
TELEGRAM_ALLOWED_USERS=ganti-user-id-kamu

DISCORD_BOT_TOKEN=ganti-token-discord
DISCORD_ALLOWED_USERS=ganti-discord-user-id
DISCORD_ALLOWED_CHANNELS=ganti-channel-id
DISCORD_FREE_RESPONSE_CHANNELS=ganti-channel-id
```

### Sudah otomatis (tidak perlu diisi, sudah di-hardcode di Dockerfile)

```
HERMES_HOME=/opt/data
HERMES_TIMEZONE=Asia/Jakarta
DISCORD_AUTO_THREAD=false
DISCORD_TOOL_PROGRESS=off
```

Mau ganti salah satu nilai di atas, atau ganti model default? Ada 2 cara:
- **Permanen**: edit langsung di `Dockerfile` (baris `ENV ...` atau nama
  model di bagian Python), commit, Railway auto-rebuild.
- **Sementara/override**: isi variable dengan nama sama di Railway Variables
  (untuk `ENV`) — itu menang.

---

## 🧠 Provider & Model yang Dipakai

| Urutan | Model | Model ID | Kenapa |
|---|---|---|---|
| Utama | DeepSeek V4 Flash Free | `deepseek-v4-flash-free` | Paling stabil di antara model gratis OpenCode Zen |
| Fallback 1 | MiMo-V2.5 Free | `mimo-v2.5-free` | Alternatif kalau DeepSeek kena limit |
| Fallback 2 | Nemotron 3 Ultra Free | `nemotron-3-ultra-free` | Model reasoning besar, cadangan terakhir |

> ⚠️ Katalog model gratis OpenCode Zen bisa berubah sewaktu-waktu. Kalau ada
> yang error "model not found", cek daftar terbaru di `opencode.ai/zen`
> (atau `GET https://opencode.ai/zen/v1/models`), lalu update nama model di
> `Dockerfile`.

---

## 💬 Command di Chat

Kirim langsung di Telegram/Discord (sesi terpisah per platform):

| Command | Fungsi |
|---|---|
| /model | Lihat model yang aktif |
| /model id --provider opencode | Ganti model utama secara manual |
| /reasoning show / /reasoning hide | Tampilkan/sembunyikan proses berpikir model |
| /sethome | Jadikan chat ini home channel |
| /new / /reset | Mulai sesi baru |
| /status | Info sesi saat ini |
| /usage | Cek pemakaian token |
| /help | Semua command tersedia |

---

## 🛠️ Troubleshooting

| Masalah | Solusi |
|---|---|
| Container exit langsung | Cek Variables, tanpa tanda kutip, tidak ada yang typo |
| "Permission denied" di /opt/data | Pastikan deploy dari GitHub repo (Dockerfile), BUKAN "Deploy a Docker Image" langsung, dan Custom Start Command di Settings dikosongkan |
| Bot tidak balas (Telegram) | Cek TELEGRAM_ALLOWED_USERS/TELEGRAM_HOME_CHANNEL — baca log baris "Blocked unauthorized user" buat tahu ID yang benar |
| Bot tidak balas (Discord) | Cek DISCORD_ALLOWED_CHANNELS, atau kirim /sethome di channel itu |
| Error 401 | OPENCODE_API_KEY salah/belum diisi |
| "Model not found" | Model di-delist OpenCode Zen — update nama model di Dockerfile |
| Reasoning mentah di chat | Kirim /reasoning hide |
| Volume hilang setelah redeploy | Mount path harus persis /opt/data |

---

## 🔒 Keamanan

- **Jangan** commit `.env` asli ke GitHub — sudah dicegah lewat `.gitignore`.
- **Jangan** share token/API key di chat, forum, atau screenshot publik.
  Kalau sampai bocor, langsung **revoke** token itu di dashboard
  opencode.ai/zen dan ganti baru.
- Set TELEGRAM_ALLOWED_USERS & DISCORD_ALLOWED_USERS supaya bot cuma
  bisa dipakai orang tertentu.

---

## ❓ FAQ

**Q: Kenapa nama model di-hardcode di Dockerfile, bukan di Railway Variables?**
A: Nama model bukan data rahasia, jadi aman ditaruh di repo. Ini mengurangi
jumlah variable yang perlu diisi manual dan memperkecil kemungkinan salah
ketik. API key (yang rahasia) tetap di Railway Variables.

**Q: Apakah bisa nambah model berbayar OpenCode Zen selain yang gratis?**
A: Bisa, tinggal ganti/tambah `model` di daftar `fallbacks` pada Dockerfile
dengan model ID lain dari katalog OpenCode Zen — providernya tetap satu
(`opencode`), cuma ganti nama model.

**Q: Apakah ini Hermes Agent asli?**
A: Ya, `nousresearch/hermes-agent` resmi dari Nous Research, bukan fork.

---

## 📚 Referensi

- Hermes Agent: `nousresearch/hermes-agent` di Docker Hub
- OpenCode Zen: opencode.ai/zen
- Railway: railway.app
