# 🤖 Hermes Agent — Telegram & Discord Bot (Railway, Groq)

Bot AI pribadi berbasis **Hermes Agent** (open-source resmi dari Nous Research),  
di-deploy di **Railway**, terhubung ke **Telegram** dan **Discord** sekaligus,  
menggunakan **Groq** dengan model **OpenAI GPT-OSS 120B** sebagai satu-satunya provider model.

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
Telegram + Discord, dengan **Groq** sebagai provider model tunggal.

Model utama yang digunakan:

```text
OpenAI GPT-OSS 120B
Model ID: openai/gpt-oss-120b
Provider: Groq
```

Semua konfigurasi teknis utama seperti provider, model, timezone, dan pengaturan
Discord sudah **di-hardcode di dalam `Dockerfile`**.

API key dan data pribadi tetap dimasukkan melalui Railway Variables.

### Alur model

```text
Chat masuk
    ↓
Groq
    ↓
OpenAI GPT-OSS 120B
    ↓
Jawaban Hermes Agent
```

Hermes menggunakan endpoint OpenAI-compatible milik Groq:

```text
https://api.groq.com/openai/v1
```

Konfigurasi Hermes menggunakan custom provider:

```yaml
providers:
  groq:
    api: https://api.groq.com/openai/v1
    key_env: GROQ_API_KEY

model:
  default: openai/gpt-oss-120b
  provider: custom:groq
```

Tidak ada fallback provider dalam konfigurasi ini.

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

### Langkah 3 — Buat API Key Groq

1. Buat akun Groq.
2. Buka dashboard API key.
3. Buat API key baru.
4. Copy API key tersebut.

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

Pastikan `GOOGLE_API_KEY` sudah tidak digunakan lagi.

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
  groq
  openai/gpt-oss-120b

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
# ===== GROQ =====
GROQ_API_KEY=ganti-api-key-groq

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

### ❌ Variable Gemini tidak digunakan lagi

Hapus jika masih ada:

```env
GOOGLE_API_KEY=
```

Tidak perlu memasang Gemini sebagai fallback.

---

## 🧠 Provider & Model yang Dipakai

| Urutan | Provider | Model | Model ID |
|---|---|---|---|
| Utama | Groq | OpenAI GPT-OSS 120B | `openai/gpt-oss-120b` |

Konfigurasi hanya menggunakan **satu provider dan satu model**.

```text
Provider:
Groq

Model:
openai/gpt-oss-120b

Fallback:
Tidak ada
```

GPT-OSS 120B di Groq mendukung kemampuan seperti reasoning, tool use, code execution, dan JSON/structured output.

### ⚠️ Tentang batas penggunaan

Groq tetap memiliki **rate limit dan quota**, termasuk pada free plan. Jadi konfigurasi ini bukan berarti request tidak terbatas selamanya.

Untuk `openai/gpt-oss-120b`, dokumentasi Groq saat ini mencantumkan free-plan limit **30 RPM, 1.000 RPD, 8K TPM, dan 200K TPD**. Batas dapat berubah sesuai kebijakan Groq.

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

### Model Groq

Untuk konfigurasi custom provider Groq, format model adalah:

```text
/model custom:groq:openai/gpt-oss-120b
```

Konfigurasi provider custom dengan format `custom:<provider>:<model>` memang merupakan format yang digunakan Hermes untuk provider OpenAI-compatible seperti Groq.

---

## 🛠️ Troubleshooting

| Masalah | Solusi |
|---|---|
| Container exit langsung | Periksa Railway Variables dan pastikan tidak ada typo |
| `Permission denied` di `/opt/data` | Pastikan menggunakan GitHub repo + Dockerfile dan Mount Path `/opt/data` |
| Bot Telegram tidak membalas | Periksa `TELEGRAM_ALLOWED_USERS` dan `TELEGRAM_HOME_CHANNEL` |
| Bot Discord tidak membalas | Periksa `DISCORD_ALLOWED_CHANNELS` dan `DISCORD_ALLOWED_USERS` |
| Error `401` | Periksa `GROQ_API_KEY` |
| Error `403` | Periksa API key dan akses endpoint Groq |
| Error `429` | Rate limit/quota Groq sedang tercapai; tunggu reset atau gunakan plan dengan limit lebih tinggi |
| `Model not found` | Periksa kembali model ID Groq yang tersedia |
| Reasoning muncul di chat | Gunakan `/reasoning hide` |
| Volume tidak menyimpan data | Pastikan Mount Path adalah `/opt/data` |
| Gemini masih muncul di log | Hapus konfigurasi/API key Gemini dan redeploy image terbaru |

---

## 🔒 Keamanan

**Jangan pernah commit API key atau bot token ke GitHub.**

Jangan memasukkan:

```text
GROQ_API_KEY
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

### Q: Kenapa memakai Groq?

Groq menyediakan endpoint OpenAI-compatible yang dapat digunakan Hermes melalui custom provider. Hermes sendiri mendokumentasikan konfigurasi Groq menggunakan `api: https://api.groq.com/openai/v1`, `GROQ_API_KEY`, dan `provider: custom:groq`.

---

### Q: Apakah Hermes Agent ini versi resmi?

Ya.

Image yang digunakan:

```text
nousresearch/hermes-agent:latest
```

Repository ini hanya menyediakan konfigurasi deployment. Hermes Agent tetap berasal dari Nous Research.

---

### Q: Apakah ada fallback Gemini?

Tidak.

Konfigurasi ini sengaja hanya menggunakan:

```text
Groq
└── openai/gpt-oss-120b
```

Tidak ada:

```text
Gemini
OpenRouter
Claude
DeepSeek
OpenCode Zen
```

sebagai fallback.

---

### Q: Apakah bisa mengganti model Groq?

Bisa.

Contohnya jika ingin mengganti model, ubah:

```python
cfg["model"] = {
    "default": "openai/gpt-oss-120b",
    "provider": "custom:groq"
}
```

Namun pastikan model tersebut tersedia di Groq.

Katalog model Groq dapat berubah, sehingga model ID sebaiknya selalu disesuaikan dengan daftar model Groq terbaru.

---

### Q: Apakah GPT-OSS 120B cocok untuk coding?

Model ini memang ditujukan untuk penggunaan agentic dan memiliki kemampuan reasoning serta software engineering/coding.

---

### Q: Apakah Groq benar-benar tanpa limit?

Tidak.

Free plan tetap memiliki batas request dan token. Untuk `openai/gpt-oss-120b`, batas free plan saat dokumentasi ini diperiksa adalah:

```text
30 requests/minute
1.000 requests/day
8.000 tokens/minute
200.000 tokens/day
```

Batas tersebut dapat berubah dari waktu ke waktu.

---

### Q: Kenapa model dan provider di-hardcode di Dockerfile?

Karena provider dan model bukan data rahasia.

Dengan meng-hardcode:

```text
Provider → Groq
Model    → openai/gpt-oss-120b
```

jumlah variable yang harus diisi di Railway menjadi lebih sedikit.

Credential rahasia tetap disimpan di Railway:

```text
GROQ_API_KEY
TELEGRAM_BOT_TOKEN
DISCORD_BOT_TOKEN
```

---

## 📚 Referensi

- Hermes Agent — dokumentasi provider
- Groq — dokumentasi model
- Groq — dokumentasi rate limits
- OpenAI GPT-OSS 120B — halaman model di Groq
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
│   └── Groq
│
├── Model
│   └── openai/gpt-oss-120b
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
