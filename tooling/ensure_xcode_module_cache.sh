#!/bin/sh
set -eu

# Determine script directory and project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

USER_HOME="${HOME:-$(dscl . -read "/Users/$(id -un)" NFSHomeDirectory | awk '{print $2}')}"

# Global DerivedData paths
GLOBAL_DERIVED_DATA="$USER_HOME/Library/Developer/Xcode/DerivedData"
GLOBAL_MODULE_CACHE_DIR="$GLOBAL_DERIVED_DATA/ModuleCache.noindex"
GLOBAL_SDK_STAT_CACHE_DIR="$GLOBAL_DERIVED_DATA/SDKStatCaches.noindex"
GLOBAL_SESSION_FILE="$GLOBAL_MODULE_CACHE_DIR/Session.modulevalidation"

# Local workspace-relative DerivedData paths
LOCAL_DERIVED_DATA="$PROJECT_ROOT/ios/DerivedData"
LOCAL_MODULE_CACHE_DIR="$LOCAL_DERIVED_DATA/ModuleCache.noindex"
LOCAL_SDK_STAT_CACHE_DIR="$LOCAL_DERIVED_DATA/SDKStatCaches.noindex"
LOCAL_SESSION_FILE="$LOCAL_MODULE_CACHE_DIR/Session.modulevalidation"

ensure_dir() {
  target_dir="$1"
  if [ -e "$target_dir" ] && [ ! -d "$target_dir" ]; then
    rm -f "$target_dir"
  fi
  mkdir -p "$target_dir"
}

ensure_file() {
  target_file="$1"
  if [ -d "$target_file" ]; then
    rmdir "$target_file" 2>/dev/null || rm -rf "$target_file"
  fi
  : >> "$target_file"
}

ensure_session_file() {
  target_file="$1"
  ensure_dir "$(dirname "$target_file")"
  ensure_file "$target_file"
}

ensure_intermediate_sessions() {
  # Search in both Global DerivedData and Local DerivedData, supporting both Runner-* (standard Xcode) and direct Build (workspace relative) structures.
  for build_root in "$GLOBAL_DERIVED_DATA"/Runner-*/Build/Intermediates.noindex \
                     "$LOCAL_DERIVED_DATA"/Build/Intermediates.noindex \
                     "$LOCAL_DERIVED_DATA"/Runner-*/Build/Intermediates.noindex; do
    if [ ! -d "$build_root" ]; then
      continue
    fi

    # Support any build folders (e.g. Pods.build, Runner.build, or any scheme build folder)
    for build_dir in "$build_root"/*.build \
      "$build_root"/ArchiveIntermediates/*/IntermediateBuildFilesPath/*.build; do
      if [ -d "$build_dir" ]; then
        ensure_session_file "$build_dir/Session.modulevalidation"
      fi
    done
  done
}

ensure_archive_intermediate_sessions() {
  # Support any scheme name instead of just 'Runner' in ArchiveIntermediates
  for build_dir in "$GLOBAL_DERIVED_DATA"/Runner-*/Build/Intermediates.noindex/ArchiveIntermediates/*/IntermediateBuildFilesPath/*.build \
                   "$LOCAL_DERIVED_DATA"/Build/Intermediates.noindex/ArchiveIntermediates/*/IntermediateBuildFilesPath/*.build \
                   "$LOCAL_DERIVED_DATA"/Runner-*/Build/Intermediates.noindex/ArchiveIntermediates/*/IntermediateBuildFilesPath/*.build; do
    if [ -d "$build_dir" ]; then
      ensure_file "$build_dir/Session.modulevalidation"
    fi
  done
}

ensure_cache() {
  attempt=0
  while [ "$attempt" -lt 50 ]; do
    # Ensure Global DerivedData directories
    ensure_dir "$GLOBAL_DERIVED_DATA" 2>/dev/null || true
    ensure_dir "$GLOBAL_MODULE_CACHE_DIR" 2>/dev/null || true
    ensure_dir "$GLOBAL_SDK_STAT_CACHE_DIR" 2>/dev/null || true

    # Ensure Local DerivedData directories
    ensure_dir "$LOCAL_DERIVED_DATA" 2>/dev/null || true
    ensure_dir "$LOCAL_MODULE_CACHE_DIR" 2>/dev/null || true
    ensure_dir "$LOCAL_SDK_STAT_CACHE_DIR" 2>/dev/null || true

    if [ -n "${MODULE_CACHE_DIR:-}" ]; then
      ensure_dir "$MODULE_CACHE_DIR" 2>/dev/null || true
    fi

    if [ -n "${SDK_STAT_CACHE_DIR:-}" ]; then
      ensure_dir "$SDK_STAT_CACHE_DIR" 2>/dev/null || true
    fi

    if [ -n "${CLANG_MODULES_BUILD_SESSION_FILE:-}" ]; then
      ensure_dir "$(dirname "$CLANG_MODULES_BUILD_SESSION_FILE")" 2>/dev/null || true
      ensure_file "$CLANG_MODULES_BUILD_SESSION_FILE" 2>/dev/null || true
    fi

    ensure_intermediate_sessions
    ensure_archive_intermediate_sessions

    # Ensure session files are created. If both succeed, return.
    if ensure_file "$GLOBAL_SESSION_FILE" 2>/dev/null && ensure_file "$LOCAL_SESSION_FILE" 2>/dev/null; then
      return 0
    fi

    attempt=$((attempt + 1))
    /bin/sleep 0.1
  done

  echo "Failed to prepare Xcode module cache files" >&2
  return 1
}

if [ "${1:-}" = "--watch" ]; then
  while true; do
    ensure_cache
    /bin/sleep 0.1
  done
fi

ensure_cache
