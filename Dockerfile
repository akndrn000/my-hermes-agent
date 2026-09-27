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
# PRIMARY MODEL - ATRIA DAWN PREVIEW
# ============================================================

cfg["model"] = {
    "default": "Atria-Dawn-Preview",
    "provider": "custom:atria"
}

# ============================================================
# REASONING
# ============================================================

cfg.setdefault("agent", {})
cfg["agent"]["reasoning_effort"] = "low"

# ============================================================
# COMPRESSION - COMPRESS HISTORY EARLIER TO SAVE TOKENS
# ============================================================

cfg["compression"] = {
    "enabled": True,
    "threshold": 0.3
}

# ============================================================
# MEMORY - SMALLER LIMITS TO REDUCE PER-SESSION TOKEN COST
# ============================================================

cfg["memory"] = {
    "memory_enabled": True,
    "user_profile_enabled": True,
    "memory_char_limit": 1200,
    "user_char_limit": 800
}

# ============================================================
# CUSTOM PROVIDERS - ATRIA (primary) + GROQ (fallback)
# ============================================================

cfg["providers"] = {
    "atria": {
        "api": "https://api.atria-asi.ai/v1",
        "key_env": "ATRIA_API_KEY"
    }
}

# ============================================================
# API MODE
# ============================================================

cfg["providers"]["atria"]["api_mode"] = "chat_completions"

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
print("  Provider : custom:atria")
print("  Model    : Atria-Dawn-Preview")
print("")
print("REASONING:")
print("  Effort   : low")
print("")
print("COMPRESSION:")
print("  Enabled  : True")
print("  Threshold: 0.3")
print("")
print("MEMORY:")
print("  Memory char limit : 1200")
print("  User char limit   : 800")
print("")
print("API:")
print("  Endpoint : https://api.atria-asi.ai/v1")
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
