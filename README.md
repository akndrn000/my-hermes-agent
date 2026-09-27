# 🤖 Hermes Agent — Telegram & Discord Bot (Railway, Atria)

Bot AI pribadi berbasis **Hermes Agent** (open-source resmi dari Nous Research),  
di-deploy di **Railway**, terhubung ke **Telegram** dan **Discord** sekaligus,  
menggunakan **Atria** dengan model **Atria Dawn Preview** sebagai satu-satunya provider model.

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
Telegram + Discord, dengan **Atria** sebagai provider model tunggal.

Model utama yang digunakan:

```text
Atria Dawn Preview
Model ID: Atria-Dawn-Preview
Provider: Atria
```

Semua konfigurasi teknis utama seperti provider, model, timezone, dan pengaturan
Discord sudah **di-hardcode di dalam `Dockerfile`**.

API key dan data pribadi tetap dimasukkan melalui Railway Variables.

### Alur model

```text
Chat masuk
    ↓
Atria
    ↓
Atria Dawn Preview
    ↓
Jawaban Hermes Agent
```

Hermes menggunakan endpoint OpenAI-compatible milik Atria:

```text
https://api.atria-asi.ai/v1
```

Konfigurasi Hermes menggunakan custom provider:

```yaml
providers:
  atria:
    api: https://api.atria-asi.ai/v1
    key_env: ATRIA_API_KEY

model:
  default: Atria-Dawn-Preview
  provider: custom:atria
```

Tidak ada fallback provider dalam konfigurasi ini.

> ⚠️ Atria Dawn Preview menerima **input teks saja** (tidak menerima gambar).
> Jika kamu mengirim foto/attachment ke bot, permintaan tersebut kemungkinan
> akan ditolak oleh endpoint dengan error 400.

---

## 📁 Struktur Repo

```text
repo-ini/
├── Dockerfile       # Build + konfigurasi provider/model
├── railway.toml     # Konfigurasi deploy Railway
├── .gitignore       # Mencegah file rahasia ikut ter-upload
└── README.md        # Dokumentasi ini
```

Upload 4 file tersebut ke root repository GitHub.

**Private repository disarankan.**

> ⚠️ Jangan deploy sebagai "Deploy a Docker Image" langsung dari Railway.
>
> Gunakan repository GitHub yang berisi `Dockerfile`, kemudian biarkan
> Dockerfile menentukan proses startup.
>
> **Custom Start Command di Railway harus dikosongkan.**

---

## 🚀 Cara Pemasangan

### Langkah 1 — Buat Bot Telegram

1. Buka **BotFather** di Telegram.
2. Kirim `/newbot`.
3. Ikuti instruksi sampai bot dibuat.
4. Simpan **Bot Token**.
5. Gunakan bot informasi user untuk mengetahui **User ID** Telegram kamu.

---

### Langkah 2 — Buat Bot Discord

1. Buka **Discord Developer Portal**.
2. Buat **New Application**.
3. Masuk ke bagian **Bot**.
4. Buat/reset **Bot Token**.
5. Aktifkan:
   - Message Content Intent
   - Server Members Intent
6. Di Discord aktifkan **Developer Mode**.
7. Copy **User ID** Discord kamu.
8. Gunakan **OAuth2 → URL Generator**.
9. Pilih:
   - `bot`
   - `applications.commands`
10. Berikan permission yang diperlukan seperti:
   - Send Messages
   - Read Message History
   - Attach Files
11. Invite bot ke server.
12. Copy **Channel ID** channel yang akan digunakan.

---

### Langkah 3 — Buat API Key Atria

1. Buka `https://api.atria-asi.ai/console`.
2. Buat akun / login.
3. Buka bagian API key.
4. Buat API key baru (biasanya berformat `atr_...` dan hanya ditampilkan sekali).
5. Copy API key tersebut.

Simpan API key dengan aman.

**Jangan masukkan API key langsung ke Dockerfile.**

---

### Langkah 4 — Upload Repo ke GitHub

Buat repository baru kemudian upload:

```text
Dockerfile
railway.toml
.gitignore
README.md
```

Pastikan `GROQ_API_KEY` dan `GOOGLE_API_KEY` sudah tidak digunakan lagi.

---

### Langkah 5 — Deploy ke Railway

1. Buka Railway.
2. Pilih **New Project**.
3. Pilih **Deploy from GitHub repo**.
4. Pilih repository Hermes Agent.
5. Tambahkan **Volume** ke service.
6. Gunakan Mount Path:

```text
/opt/data
```

7. Buka tab **Variables**.
8. Masukkan environment variables dari bagian berikutnya.
9. Buka:

```text
Settings → Deploy
```

10. Pastikan **Custom Start Command kosong**.
11. Deploy/redeploy service.
12. Buka **View Logs**.

Jika berhasil, startup script akan menampilkan:

```text
========================================
HERMES MODEL CONFIG
========================================

PRIMARY:
  atria
  Atria-Dawn-Preview

FALLBACKS:
  (tidak ada)

========================================
```

Kemudian tunggu sampai gateway Telegram dan Discord terhubung.

---

## 🔑 Environment Variables

Masukkan di:

```text
Railway → Variables → Raw Editor
```

Gunakan:

```env
# ===== ATRIA =====
ATRIA_API_KEY=ganti-api-key-atria

# ===== TELEGRAM =====
TELEGRAM_BOT_TOKEN=ganti-token-botfather
TELEGRAM_HOME_CHANNEL=ganti-user-id-kamu
TELEGRAM_HOME_CHANNEL_NAME=Nama Bebas
TELEGRAM_ALLOWED_USERS=ganti-user-id-kamu

# ===== DISCORD =====
DISCORD_BOT_TOKEN=ganti-token-discord
DISCORD_ALLOWED_USERS=ganti-discord-user-id
DISCORD_ALLOWED_CHANNELS=ganti-channel-id
DISCORD_FREE_RESPONSE_CHANNELS=ganti-channel-id
```

### Tidak perlu diisi manual

Nilai berikut sudah diatur di Dockerfile:

```text
HERMES_HOME=/opt/data
HERMES_TIMEZONE=Asia/Jakarta
DISCORD_AUTO_THREAD=false
DISCORD_TOOL_PROGRESS=off
```

### ❌ Variable Groq dan Gemini tidak digunakan lagi

Hapus jika masih ada:

```env
GROQ_API_KEY=
GOOGLE_API_KEY=
```

Tidak perlu memasang Groq atau Gemini sebagai fallback.

---

## 🧠 Provider & Model yang Dipakai

| Urutan | Provider | Model | Model ID |
|---|---|---|---|
| Utama | Atria | Atria Dawn Preview | `Atria-Dawn-Preview` |

Konfigurasi hanya menggunakan **satu provider dan satu model**.

```text
Provider:
Atria

Model:
Atria-Dawn-Preview

Fallback:
Tidak ada
```

Atria Dawn Preview adalah model agentic (MoE, ~744B parameter) yang ditujukan untuk
pemahaman lingkungan berkelanjutan, penggunaan tool, dan penyelesaian tugas multi-langkah
(riset, coding, pembuatan dokumen/laporan, hingga analisis keamanan).

### ⚠️ Tentang batas penggunaan

Atria kemungkinan tetap memiliki rate limit/quota tersendiri sesuai kebijakan penyedianya,
meskipun saat ini beberapa akses ke model ini tercatat gratis. Selalu cek dashboard/console
Atria untuk detail limit terbaru, karena kebijakan ini dapat berubah sewaktu-waktu.

Jika melewati limit, API dapat mengembalikan:

```text
HTTP 429 Too Many Requests
```

---

## 💬 Command di Chat

Command dapat digunakan melalui Telegram atau Discord:

| Command | Fungsi |
|---|---|
| `/model` | Melihat model yang aktif |
| `/model <id> --provider <provider>` | Mengganti model secara manual |
| `/reasoning show` | Menampilkan reasoning |
| `/reasoning hide` | Menyembunyikan reasoning |
| `/sethome` | Menjadikan chat sebagai home channel |
| `/new` | Memulai sesi baru |
| `/reset` | Mereset sesi |
| `/status` | Melihat status sesi |
| `/usage` | Melihat penggunaan token |
| `/help` | Melihat command yang tersedia |

### Model Atria

Untuk konfigurasi custom provider Atria, format model adalah:

```text
/model custom:atria:Atria-Dawn-Preview
```

Konfigurasi provider custom dengan format `custom:<provider>:<model>` memang merupakan
format yang digunakan Hermes untuk provider OpenAI-compatible seperti Atria.

---

## 🛠️ Troubleshooting

| Masalah | Solusi |
|---|---|
| Container exit langsung | Periksa Railway Variables dan pastikan tidak ada typo |
| `Permission denied` di `/opt/data` | Pastikan menggunakan GitHub repo + Dockerfile dan Mount Path `/opt/data` |
| Bot Telegram tidak membalas | Periksa `TELEGRAM_ALLOWED_USERS` dan `TELEGRAM_HOME_CHANNEL` |
| Bot Discord tidak membalas | Periksa `DISCORD_ALLOWED_CHANNELS` dan `DISCORD_ALLOWED_USERS` |
| Error `401` | Periksa `ATRIA_API_KEY` |
| Error `403` | Periksa API key dan akses endpoint Atria |
| Error `429` | Rate limit/quota Atria sedang tercapai; tunggu reset atau cek plan di console |
| Error `400` saat kirim gambar | Atria Dawn Preview tidak menerima input gambar, kirim teks saja |
| `Model not found` | Periksa kembali model ID Atria yang tersedia di console |
| Reasoning muncul di chat | Gunakan `/reasoning hide` |
| Volume tidak menyimpan data | Pastikan Mount Path adalah `/opt/data` |
| Groq/Gemini masih muncul di log | Hapus konfigurasi/API key lama dan redeploy image terbaru |

---

## 🔒 Keamanan

**Jangan pernah commit API key atau bot token ke GitHub.**

Jangan memasukkan:

```text
ATRIA_API_KEY
TELEGRAM_BOT_TOKEN
DISCORD_BOT_TOKEN
```

langsung ke `Dockerfile`.

Gunakan:

```text
Railway → Variables
```

Jika API key atau bot token terlanjur bocor:

1. Revoke/delete credential lama.
2. Buat credential baru.
3. Ganti value di Railway Variables.
4. Redeploy service.

Repository **Private** juga lebih disarankan untuk konfigurasi bot pribadi.

---

## ❓ FAQ

### Q: Kenapa memakai Atria?

Atria menyediakan endpoint OpenAI-compatible (Chat Completions API) yang dapat digunakan
Hermes melalui custom provider, dengan `api: https://api.atria-asi.ai/v1`,
`ATRIA_API_KEY`, dan `provider: custom:atria`.

---

### Q: Apakah Hermes Agent ini versi resmi?

Ya.

Image yang digunakan:

```text
nousresearch/hermes-agent:latest
```

Repository ini hanya menyediakan konfigurasi deployment. Hermes Agent tetap berasal dari Nous Research.

---

### Q: Apakah ada fallback provider lain?

Tidak.

Konfigurasi ini sengaja hanya menggunakan:

```text
Atria
└── Atria-Dawn-Preview
```

Tidak ada:

```text
Groq
Gemini
OpenRouter
Claude
DeepSeek
OpenCode Zen
```

sebagai fallback.

---

### Q: Apakah bisa mengganti model Atria?

Bisa, jika Atria menambah model lain di katalognya.

Contohnya jika ingin mengganti model, ubah:

```python
cfg["model"] = {
    "default": "Atria-Dawn-Preview",
    "provider": "custom:atria"
}
```

Namun pastikan model tersebut tersedia di katalog Atria (cek di console).

---

### Q: Apakah Atria Dawn Preview cocok untuk coding?

Ya. Model ini dirancang untuk tugas agentic dengan kemampuan reasoning, penggunaan tool,
implementasi kode, eksekusi eksperimen, hingga analisis dan perbaikan hasil — termasuk
skenario software engineering.

---

### Q: Apakah Atria Dawn Preview menerima gambar?

Tidak. Model ini hanya menerima input teks. Jika bot menerima attachment gambar dari
Telegram/Discord dan meneruskannya ke model, permintaan akan gagal dengan error 400.

---

### Q: Apakah Atria benar-benar tanpa limit?

Belum tentu. Kebijakan rate limit/quota Atria dapat berubah sewaktu-waktu — selalu cek
console resmi (`https://api.atria-asi.ai/console`) untuk informasi limit terbaru.

---

### Q: Kenapa model dan provider di-hardcode di Dockerfile?

Karena provider dan model bukan data rahasia.

Dengan meng-hardcode:

```text
Provider → Atria
Model    → Atria-Dawn-Preview
```

jumlah variable yang harus diisi di Railway menjadi lebih sedikit.

Credential rahasia tetap disimpan di Railway:

```text
ATRIA_API_KEY
TELEGRAM_BOT_TOKEN
DISCORD_BOT_TOKEN
```

---

## 📚 Referensi

- Hermes Agent — dokumentasi provider
- Atria — console & dokumentasi API (`https://api.atria-asi.ai/console`)
- Railway — dokumentasi deployment

---

## ✅ Konfigurasi Akhir

```text
Hermes Agent
│
├── Telegram
│
├── Discord
│
├── Provider
│   └── Atria
│
├── Model
│   └── Atria-Dawn-Preview
│
├── Fallback
│   └── Tidak ada
│
├── Home
│   └── /opt/data
│
└── Timezone
    └── Asia/Jakarta
```
