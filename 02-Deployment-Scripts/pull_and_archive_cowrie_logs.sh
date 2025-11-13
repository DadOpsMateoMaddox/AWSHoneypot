#!/usr/bin/env bash
# pull_and_archive_cowrie_logs.sh
# Usage:
#  sudo ./pull_and_archive_cowrie_logs.sh --out /tmp/cowrie-archive --to-s3 s3://my-bucket/path --convert-pcap
#
# What it does:
#  - Collects all files under /opt/cowrie/var/log/cowrie/ (json, text, rotations, downloads)
#  - Determines earliest log timestamp (file mtime) and reports date range
#  - Copies files into a staging dir, creates a tar.gz archive
#  - Generates a manifest (JSON) listing files, sizes, checksums
#  - Optionally converts the main JSON log into a PCAP using logs2pcap.py
#  - Optionally uploads archive and manifest to S3 (requires awscli configured)

set -euo pipefail

# Defaults
COWRIE_LOG_DIR="/opt/cowrie/var/log/cowrie"
OUT_DIR="/tmp/cowrie_logs_archive_$(date +%Y%m%d_%H%M%S)"
ARCHIVE_NAME="cowrie_logs_$(date +%Y%m%d_%H%M%S).tar.gz"
MANIFEST_NAME="cowrie_logs_manifest_$(date +%Y%m%d_%H%M%S).json"
TO_S3=""
CONVERT_PCAP=0
PCAP_OUT="/tmp/cowrie_traffic.pcap"
LOGS2PCAP_SCRIPT="$(dirname "$0")/logs2pcap.py"

show_help(){
  cat <<'EOF'
Usage: sudo ./pull_and_archive_cowrie_logs.sh [--out DIR] [--archive NAME] [--to-s3 s3://bucket/path] [--convert-pcap] [--pcap-file /tmp/out.pcap]

Options:
  --out DIR            Staging output directory (default /tmp/cowrie_logs_archive_TIMESTAMP)
  --archive NAME       Archive filename (default cowrie_logs_TIMESTAMP.tar.gz)
  --to-s3 S3PATH       If provided, upload archive and manifest to this S3 path (requires awscli)
  --convert-pcap       Convert JSON logs to PCAP using logs2pcap.py and include in archive
  --pcap-file FILE     Path for the generated PCAP (default /tmp/cowrie_traffic.pcap)
  -h, --help           Show this help

Example:
  sudo ./pull_and_archive_cowrie_logs.sh --to-s3 s3://my-bucket/cowrie-archives --convert-pcap
EOF
}

# Parse args
while [[ ${#} -gt 0 ]]; do
  case "$1" in
    --out)
      OUT_DIR="$2"; shift 2;;
    --archive)
      ARCHIVE_NAME="$2"; shift 2;;
    --to-s3)
      TO_S3="$2"; shift 2;;
    --convert-pcap)
      CONVERT_PCAP=1; shift 1;;
    --pcap-file)
      PCAP_OUT="$2"; shift 2;;
    -h|--help)
      show_help; exit 0;;
    *)
      echo "Unknown argument: $1"; show_help; exit 1;;
  esac
done

echo "[INFO] Cowrie log dir: $COWRIE_LOG_DIR"
if [ ! -d "$COWRIE_LOG_DIR" ]; then
  echo "[ERROR] Cowrie log dir not found: $COWRIE_LOG_DIR" >&2
  exit 2
fi

echo "[INFO] Creating staging dir: $OUT_DIR"
mkdir -p "$OUT_DIR"
chmod 700 "$OUT_DIR"

# Copy logs
echo "[INFO] Copying logs to staging dir..."
# Use rsync if available for reliable copy
if command -v rsync >/dev/null 2>&1; then
  rsync -a --info=progress2 "$COWRIE_LOG_DIR"/ "$OUT_DIR"/cowrie_logs/
else
  cp -a "$COWRIE_LOG_DIR" "$OUT_DIR"/cowrie_logs
fi

# Also include downloads and other potentially useful dirs
if [ -d "/opt/cowrie/var/lib/cowrie/downloads" ]; then
  mkdir -p "$OUT_DIR"/downloads
  rsync -a "/opt/cowrie/var/lib/cowrie/downloads/" "$OUT_DIR"/downloads/ || true
fi

# Determine earliest and latest file mtimes
earliest=$(find "$OUT_DIR" -type f -printf '%T@ %p\n' | sort -n | head -1 | awk '{print $1}') || true
latest=$(find "$OUT_DIR" -type f -printf '%T@ %p\n' | sort -n | tail -1 | awk '{print $1}') || true
if [ -n "$earliest" ] && [ -n "$latest" ]; then
  echo "[INFO] Logs date range: $(date -d "@$earliest" --iso-8601=seconds) -> $(date -d "@$latest" --iso-8601=seconds)"
else
  echo "[WARN] Could not determine date range (no files?)"
fi

# Optionally convert JSON to PCAP using logs2pcap.py
if [ "$CONVERT_PCAP" -eq 1 ]; then
  echo "[INFO] Converting JSON to PCAP using logs2pcap.py"
  JSON_FILE="$OUT_DIR/cowrie_logs/cowrie.json"
  if [ -f "$LOGS2PCAP_SCRIPT" ]; then
    if [ -f "$JSON_FILE" ]; then
      python3 "$LOGS2PCAP_SCRIPT" "$JSON_FILE" "$PCAP_OUT" || {
        echo "[ERROR] logs2pcap.py failed" >&2
      }
      # copy pcap to staging dir
      cp "$PCAP_OUT" "$OUT_DIR/"
    else
      echo "[WARN] JSON file not found in staging path: $JSON_FILE"
    fi
  else
    echo "[WARN] logs2pcap.py not found at: $LOGS2PCAP_SCRIPT"
  fi
fi

# Create manifest: list files, size, sha256
echo "[INFO] Generating manifest and checksums..."
MANIFEST_PATH="$OUT_DIR/$MANIFEST_NAME"
jq -n --arg created "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '{created: $created, files: []}' > "$MANIFEST_PATH"

# Iterate and append file entries
while IFS= read -r -d '' file; do
  relpath="${file#$OUT_DIR/}"
  size=$(stat -c%s "$file")
  sha256=$(sha256sum "$file" | awk '{print $1}')
  # Append entry to manifest
  jq --arg path "$relpath" --arg size "$size" --arg sha256 "$sha256" '.files += [{path: $path, size: ($size|tonumber), sha256: $sha256}]' "$MANIFEST_PATH" > "$MANIFEST_PATH.tmp" && mv "$MANIFEST_PATH.tmp" "$MANIFEST_PATH"
done < <(find "$OUT_DIR" -type f -print0)

# Create tar.gz archive
echo "[INFO] Creating archive: $ARCHIVE_NAME"
pushd "$OUT_DIR" >/dev/null
# archive contents at top level
tar -czf "/tmp/$ARCHIVE_NAME" .
ARCHIVE_PATH="/tmp/$ARCHIVE_NAME"
popd >/dev/null

echo "[INFO] Archive created: $ARCHIVE_PATH"
echo "[INFO] Manifest: $MANIFEST_PATH"

# Compute checksum of archive
ARCHIVE_SHA256=$(sha256sum "$ARCHIVE_PATH" | awk '{print $1}')
echo "[INFO] Archive SHA256: $ARCHIVE_SHA256"

# Optional upload to S3
if [ -n "$TO_S3" ]; then
  if command -v aws >/dev/null 2>&1; then
    echo "[INFO] Uploading to S3: $TO_S3"
    aws s3 cp "$ARCHIVE_PATH" "$TO_S3/$(basename "$ARCHIVE_PATH")" || { echo "[ERROR] S3 upload failed" >&2; }
    aws s3 cp "$MANIFEST_PATH" "$TO_S3/$(basename "$MANIFEST_PATH")" || { echo "[ERROR] S3 upload failed" >&2; }
    echo "[INFO] Uploaded archive and manifest to S3"
  else
    echo "[ERROR] aws CLI not found; cannot upload to S3" >&2
  fi
else
  echo "[INFO] No S3 target provided. Use --to-s3 s3://bucket/path to upload."
  echo "[INFO] To copy archive to your local machine via SCP, run on YOUR machine:"
  echo "  scp -i <key.pem> ec2-user@<host>:$ARCHIVE_PATH ./"
fi

echo "[DONE] Archive and manifest are ready."
echo "Archive: $ARCHIVE_PATH"
echo "Manifest: $MANIFEST_PATH"

exit 0
