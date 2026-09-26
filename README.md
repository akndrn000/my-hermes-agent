# 🤖 Hermes Agent — Telegram & Discord Bot (Railway, Google Gemini)

Bot AI pribadi berbasis **Hermes Agent** (open-source resmi dari Nous Research),
di-deploy di **Railway**, terhubung ke **Telegram** dan **Discord** sekaligus,
pakai **Google Gemini** (`gemini-3.6-flash`) sebagai satu-satunya provider model.

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
Telegram + Discord, dengan **Google Gemini** sebagai provider model tunggal.

Semua nama model & pengaturan teknis (provider, model, timezone, dll) sudah
**di-hardcode di dalam `Dockerfile`** — jadi kamu cuma perlu isi **API key
Gemini dan data pribadi kamu** (token bot, ID user) di Railway.

### Alur model

```
Chat masuk
   ↓
Google Gemini — gemini-3.6-flash   ← satu-satunya model, tanpa fallback
```

Model di atas jalan lewat endpoint kompatibel-OpenAI milik Google
(`https://generativelanguage.googleapis.com/v1beta/openai`), pakai **satu
API key Gemini**, jadi nggak perlu daftar ke provider lain.

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

### Langkah 3 — Ambil API Key Google Gemini

1. Buka **[Google AI Studio](https://aistudio.google.com/apikey)**, login pakai akun Google.
2. Klik **Create API key** (pilih atau buat project Google Cloud kalau diminta).
3. Copy API key-nya.

> ℹ️ `gemini-3.6-flash` punya kuota gratis (free tier) di Google AI Studio.
> Kalau kuota gratis habis / kena rate limit, kamu perlu upgrade ke billing
> berbayar di Google Cloud Console kalau mau tetap pakai model ini terus-menerus.

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
GOOGLE_API_KEY=ganti-punya-kamu

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
| Utama (satu-satunya) | Gemini 3.6 Flash | `gemini-3.6-flash` | Cepat, murah/gratis (free tier), tanpa fallback lain |

> ⚠️ Katalog model Gemini bisa berubah sewaktu-waktu (misalnya model baru
> menggantikan yang lama, atau nama preview jadi stabil). Kalau ada error
> "model not found", cek daftar model terbaru lewat
> `GET https://generativelanguage.googleapis.com/v1beta/models` (pakai
> header `x-goog-api-key`), lalu update nama model di `Dockerfile`.

---

## 💬 Command di Chat

Kirim langsung di Telegram/Discord (sesi terpisah per platform):

| Command | Fungsi |
|---|---|
| /model | Lihat model yang aktif |
| /model id --provider gemini | Ganti model utama secara manual |
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
| Error 401 / 403 | GOOGLE_API_KEY salah/belum diisi, atau API key belum diaktifkan untuk Generative Language API |
| "Model not found" | Nama model Gemini berubah/di-deprecate — update nama model di Dockerfile |
| Error 429 (kena limit) | Kuota gratis Gemini habis — tunggu reset kuota atau aktifkan billing di Google Cloud Console |
| Reasoning mentah di chat | Kirim /reasoning hide |
| Volume hilang setelah redeploy | Mount path harus persis /opt/data |

---

## 🔒 Keamanan

- **Jangan** commit `.env` asli ke GitHub — sudah dicegah lewat `.gitignore`.
- **Jangan** share token/API key di chat, forum, atau screenshot publik.
  Kalau sampai bocor, langsung **revoke/hapus** API key itu di
  [Google AI Studio](https://aistudio.google.com/apikey) dan ganti baru.
- Set TELEGRAM_ALLOWED_USERS & DISCORD_ALLOWED_USERS supaya bot cuma
  bisa dipakai orang tertentu.

---

## ❓ FAQ

**Q: Kenapa nama model di-hardcode di Dockerfile, bukan di Railway Variables?**
A: Nama model bukan data rahasia, jadi aman ditaruh di repo. Ini mengurangi
jumlah variable yang perlu diisi manual dan memperkecil kemungkinan salah
ketik. API key (yang rahasia) tetap di Railway Variables.

**Q: Apakah bisa ganti ke model Gemini lain (misalnya Gemini Pro)?**
A: Bisa, tinggal ganti nilai `"default"` di bagian `cfg["model"]` pada
Dockerfile dengan model ID lain dari katalog Gemini (misalnya
`gemini-3-pro` atau versi lain) — providernya tetap satu (`gemini`), cuma
ganti nama model. Kamu juga bisa isi ulang list `fallbacks` di Dockerfile
kalau mau tambah model cadangan.

**Q: Apakah ini Hermes Agent asli?**
A: Ya, `nousresearch/hermes-agent` resmi dari Nous Research, bukan fork.

---

## 📚 Referensi

- Hermes Agent: `nousresearch/hermes-agent` di Docker Hub
- Google Gemini API: ai.google.dev/gemini-api
- Google AI Studio (buat API key): aistudio.google.com/apikey
- Railway: railway.app
