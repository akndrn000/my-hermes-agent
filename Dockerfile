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
# PRIMARY MODEL - GROQ GPT-OSS 120B
# ============================================================

cfg["model"] = {
    "default": "openai/gpt-oss-120b",
    "provider": "custom:groq"
}

# ============================================================
# REASONING
# ============================================================

cfg.setdefault("agent", {})
cfg["agent"]["reasoning_effort"] = "medium"

# ============================================================
# CUSTOM PROVIDER - GROQ
# ============================================================

cfg["providers"] = {
    "groq": {
        "api": "https://api.groq.com/openai/v1",
        "key_env": "GROQ_API_KEY"
    }
}

# ============================================================
# API MODE
# ============================================================

cfg["providers"]["groq"]["api_mode"] = "chat_completions"

# ============================================================
# NO FALLBACK
# ============================================================

cfg.pop("fallback_model", None)
cfg["fallback_providers"] = []

# ============================================================
# SAVE CONFIG
# ============================================================

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
print("  Provider : custom:groq")
print("  Model    : openai/gpt-oss-120b")
print("")
print("REASONING:")
print("  Effort   : medium")
print("")
print("API:")
print("  Endpoint : https://api.groq.com/openai/v1")
print("  Mode     : chat_completions")
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
