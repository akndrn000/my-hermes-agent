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
# PRIMARY MODEL - OpenCode Zen (satu-satunya provider)
# ============================================================

cfg["model"] = {
    "provider": "opencode",
    "default": "deepseek-v4-flash-free"
}

cfg.pop("fallback_model", None)

# ============================================================
# CUSTOM PROVIDER - OpenCode Zen
# (endpoint terpusat, kompatibel format OpenAI chat/completions)
# ============================================================

providers = {}

if os.environ.get("OPENCODE_API_KEY"):
    providers["opencode"] = {
        "api": "https://opencode.ai/zen/v1",
        "key_env": "OPENCODE_API_KEY",
        "transport": "chat_completions"
    }

if providers:
    cfg["providers"] = providers
else:
    cfg.pop("providers", None)

# ============================================================
# FALLBACK CHAIN - model gratis lain di dalam OpenCode Zen
# ============================================================

fallbacks = []

if os.environ.get("OPENCODE_API_KEY"):
    fallbacks.append({"provider": "opencode", "model": "mimo-v2.5-free"})
    fallbacks.append({"provider": "opencode", "model": "nemotron-3-ultra-free"})

cfg["fallback_providers"] = fallbacks

with open(path, "w") as f:
    yaml.safe_dump(cfg, f, sort_keys=False, default_flow_style=False)

print("")
print("========================================")
print("HERMES MODEL CONFIG")
print("========================================")
print("")
print("PRIMARY:")
print("  opencode")
print("  deepseek-v4-flash-free")
print("")
print("FALLBACKS:")

for i, item in enumerate(fallbacks, 1):
    print(f"  {i}. {item['provider']} -> {item['model']}")

print("")
print("========================================")

PYEOF

exec hermes gateway run
EOF

RUN chmod +x /usr/local/bin/hermes-startup.sh

CMD ["/usr/local/bin/hermes-startup.sh"]
