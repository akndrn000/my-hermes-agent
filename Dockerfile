FROM nousresearch/hermes-agent:latest

ENV HERMES_HOME=/opt/data
ENV HERMES_TIMEZONE=Asia/Jakarta
ENV DISCORD_AUTO_THREAD=false
ENV DISCORD_TOOL_PROGRESS=off

COPY <<'EOF' /usr/local/bin/hermes-startup.sh
#!/bin/sh
set -e

python3 - <<'PYEOF'
import os
import yaml

home = os.environ.get("HERMES_HOME", "/opt/data")
path = os.path.join(home, "config.yaml")

os.makedirs(home, exist_ok=True)

try:
    with open(path, "r") as f:
        cfg = yaml.safe_load(f) or {}
except FileNotFoundError:
    cfg = {}

if not isinstance(cfg, dict):
    cfg = {}

# ============================================================
# PRIMARY MODEL - Google Gemini (satu-satunya provider)
# ============================================================

cfg["model"] = {
    "provider": "gemini",
    "default": "gemini-3.8-flash"
}

cfg.pop("fallback_model", None)

# ============================================================
# CUSTOM PROVIDER - Google Gemini
# (endpoint kompatibel format OpenAI chat/completions)
# ============================================================

providers = {}

if os.environ.get("GEMINI_API_KEY"):
    providers["gemini"] = {
        "api": "https://generativelanguage.googleapis.com/v1beta/openai",
        "key_env": "GEMINI_API_KEY",
        "transport": "chat_completions"
    }

if providers:
    cfg["providers"] = providers
else:
    cfg.pop("providers", None)

# ============================================================
# FALLBACK CHAIN - tidak ada, hanya satu model (Gemini 3.5 Flash)
# ============================================================

fallbacks = []

cfg["fallback_providers"] = fallbacks

with open(path, "w") as f:
    yaml.safe_dump(cfg, f, sort_keys=False, default_flow_style=False)

print("")
print("========================================")
print("HERMES MODEL CONFIG")
print("========================================")
print("")
print("PRIMARY:")
print("  gemini")
print("  gemini-3.8-flash")
print("")
print("FALLBACKS:")

if fallbacks:
    for i, item in enumerate(fallbacks, 1):
        print(f"  {i}. {item['provider']} -> {item['model']}")
else:
    print("  (tidak ada)")

print("")
print("========================================")

PYEOF

exec hermes gateway run
EOF

RUN chmod +x /usr/local/bin/hermes-startup.sh

CMD ["/usr/local/bin/hermes-startup.sh"]
