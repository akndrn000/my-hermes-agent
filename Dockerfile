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

# PRIMARY MODEL - Groq
cfg["model"] = {
    "provider": "groq",
    "default": "openai/gpt-oss-120b"
}

# CUSTOM PROVIDER - Groq
providers = {}

if os.environ.get("GROQ_API_KEY"):
    providers["groq"] = {
        "api": "https://api.groq.com/openai/v1",
        "key_env": "GROQ_API_KEY",
        "transport": "chat_completions"
    }

if providers:
    cfg["providers"] = providers
else:
    cfg.pop("providers", None)

# Tidak menggunakan fallback
cfg.pop("fallback_model", None)
cfg["fallback_providers"] = []

with open(path, "w") as f:
    yaml.safe_dump(
        cfg,
        f,
        sort_keys=False,
        default_flow_style=False
    )

print("")
print("========================================")
print("HERMES MODEL CONFIG")
print("========================================")
print("")
print("PRIMARY:")
print("  Provider : groq")
print("  Model    : openai/gpt-oss-120b")
print("")
print("FALLBACKS:")
print("  (tidak ada)")
print("")
print("========================================")

PYEOF

exec hermes gateway run
EOF

RUN chmod +x /usr/local/bin/hermes-startup.sh

CMD ["/usr/local/bin/hermes-startup.sh"]
