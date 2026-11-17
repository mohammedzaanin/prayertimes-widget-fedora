#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "${script_dir}/.." && pwd)"
release_tag="${1:-}"

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required to validate metadata.json." >&2
    exit 1
fi

python3 - "${project_dir}" "${release_tag}" <<'PY'
import json
import re
import sys
from pathlib import Path

project_dir = Path(sys.argv[1])
release_tag = sys.argv[2]
metadata_path = project_dir / "metadata.json"

try:
    metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
except (OSError, json.JSONDecodeError) as error:
    raise SystemExit(f"Error: invalid metadata.json: {error}")

plugin = metadata.get("KPlugin", {})
plugin_id = plugin.get("Id", "")
version = plugin.get("Version", "")

checks = {
    "KPackageStructure must be Plasma/Applet": metadata.get("KPackageStructure") == "Plasma/Applet",
    "X-Plasma-API-Minimum-Version must be 6.0": metadata.get("X-Plasma-API-Minimum-Version") == "6.0",
    "KPlugin.Id must be com.mo7ammed.prayertimes": plugin_id == "com.mo7ammed.prayertimes",
    "KPlugin.Version must use semantic versioning (for example 1.5.1)": bool(
        re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+(?:[-+][0-9A-Za-z.-]+)?", version)
    ),
    "contents/ui/main.qml is required": (project_dir / "contents/ui/main.qml").is_file(),
}

for message, passed in checks.items():
    if not passed:
        raise SystemExit(f"Error: {message}.")

if release_tag and release_tag != f"v{version}":
    raise SystemExit(
        f"Error: release tag {release_tag!r} does not match metadata version v{version}."
    )

print(f"Validated {plugin_id} version {version}")
PY
