#!/usr/bin/env bash
# =============================================================================
# build_release.sh — Release build helper for incidents_managment
#
# Usage:
#   ./build_release.sh          # builds both APK and IPA
#   ./build_release.sh apk      # Android only
#   ./build_release.sh ios      # iOS only
#
# Requirements:
#   - Flutter SDK on PATH
#   - For iOS: Xcode + valid code-signing identity configured
# =============================================================================

set -euo pipefail

TARGET="${1:-all}"
DEBUG_INFO_DIR="build/debug-info"

# Ensure debug-info directory exists (git-ignored; used for symbolication)
mkdir -p "$DEBUG_INFO_DIR"

# ── Helpers ───────────────────────────────────────────────────────────────────

log()  { echo "▶ $*"; }
ok()   { echo "✔ $*"; }
fail() { echo "✘ $*" >&2; exit 1; }

check_flutter() {
  command -v flutter >/dev/null 2>&1 || fail "flutter not found on PATH"
  log "Flutter version: $(flutter --version --machine 2>/dev/null | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d["frameworkVersion"])' 2>/dev/null || flutter --version | head -1)"
}

# ── Android ───────────────────────────────────────────────────────────────────

build_apk() {
  log "Building release APK (split-debug-info + obfuscate)…"
  flutter build apk \
    --release \
    --split-debug-info="$DEBUG_INFO_DIR/android" \
    --obfuscate
  ok "APK → build/app/outputs/flutter-apk/app-release.apk"
}

build_aab() {
  log "Building release App Bundle (split-debug-info + obfuscate)…"
  flutter build appbundle \
    --release \
    --split-debug-info="$DEBUG_INFO_DIR/android" \
    --obfuscate
  ok "AAB → build/app/outputs/bundle/release/app-release.aab"
}

# ── iOS ───────────────────────────────────────────────────────────────────────

build_ios() {
  log "Building release IPA (split-debug-info + obfuscate)…"
  flutter build ipa \
    --release \
    --split-debug-info="$DEBUG_INFO_DIR/ios" \
    --obfuscate \
    --export-options-plist=ios/ExportOptions.plist 2>/dev/null \
    || flutter build ipa \
         --release \
         --split-debug-info="$DEBUG_INFO_DIR/ios" \
         --obfuscate
  ok "IPA → build/ios/ipa/"
}

# ── Main ──────────────────────────────────────────────────────────────────────

check_flutter

case "$TARGET" in
  apk)
    build_apk
    ;;
  aab)
    build_aab
    ;;
  ios)
    build_ios
    ;;
  all)
    build_apk
    build_aab
    build_ios
    ;;
  *)
    fail "Unknown target '$TARGET'. Use: apk | aab | ios | all"
    ;;
esac

log "Done. Debug symbols saved to $DEBUG_INFO_DIR/"
log "Keep these symbols to decode obfuscated stack traces with: flutter symbolize"
