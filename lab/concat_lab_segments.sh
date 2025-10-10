#!/usr/bin/env bash
set -euo pipefail

# concat_lab_segments.sh
# Combine welcome-screen.md and segments 0-5 into a single output file
# Skips instructions.md
# Usage: ./concat_lab_segments.sh [--dry-run]

DIR="$(dirname "$0")/instructions"
OUT="lab-script.md"

FILES=(
  "welcome-screen.md"
  "segment0-ai-gpu-playbook.md"
  "skillable_gpu_aca_lab.md"
  "skillable_langchain_aca_lab_1.md"
  "segment3-ollama.md"
  "segment4-mcp-shell.md"
  "segment5-goose-agent.md"
)

DRY_RUN=0
if [[ ${1-} == "--dry-run" || ${1-} == "-n" ]]; then
  DRY_RUN=1
fi

echo "Output file: $OUT"
if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run: will list files that would be concatenated."
fi

# Ensure output dir exists
mkdir -p "$(dirname "$OUT")"

first=1
for f in "${FILES[@]}"; do
  src="$DIR/$f"
  if [[ ! -f "$src" ]]; then
    echo "Warning: $src not found, skipping." >&2
    continue
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "Would append: $src"
    continue
  fi
  if [[ $first -eq 0 ]]; then
    printf "\n\n===\n\n" >> "$OUT"
  fi
  cat "$src" >> "$OUT"
  first=0
done

if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run complete. No file written."
  exit 0
fi

echo "Created $OUT"
ls -l "$OUT"
# Print a short summary
echo "Segments concatenated. Use the output file for instructor handouts or further processing."

exit 0
