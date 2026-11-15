#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
output_file="${script_dir}/prayertimes-widget.plasmoid"

if ! command -v zip >/dev/null 2>&1; then
    echo "Error: zip is required to build the widget package." >&2
    exit 1
fi

cd "${script_dir}"
zip -q -r -FS "${output_file}" metadata.json contents

echo "Created: ${output_file}"
