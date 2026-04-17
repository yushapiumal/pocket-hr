#!/bin/sh
set -eu

USER_HOME="${HOME:-$(dscl . -read "/Users/$(id -un)" NFSHomeDirectory | awk '{print $2}')}"
DERIVED_DATA="$USER_HOME/Library/Developer/Xcode/DerivedData"
GLOBAL_MODULE_CACHE_DIR="$DERIVED_DATA/ModuleCache.noindex"
GLOBAL_SDK_STAT_CACHE_DIR="$DERIVED_DATA/SDKStatCaches.noindex"
GLOBAL_SESSION_FILE="$GLOBAL_MODULE_CACHE_DIR/Session.modulevalidation"

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
  for build_root in "$DERIVED_DATA"/Runner-*/Build/Intermediates.noindex; do
    if [ ! -d "$build_root" ]; then
      continue
    fi

    ensure_session_file "$build_root/Pods.build/Session.modulevalidation"

    for build_dir in "$build_root"/*.build \
      "$build_root"/ArchiveIntermediates/*/IntermediateBuildFilesPath/*.build; do
      if [ -d "$build_dir" ]; then
        ensure_session_file "$build_dir/Session.modulevalidation"
      fi
    done
  done
}

ensure_archive_intermediate_sessions() {
  for build_dir in "$DERIVED_DATA"/Runner-*/Build/Intermediates.noindex/ArchiveIntermediates/Runner/IntermediateBuildFilesPath/*.build; do
    if [ -d "$build_dir" ]; then
      ensure_file "$build_dir/Session.modulevalidation"
    fi
  done
}

ensure_cache() {
  attempt=0
  while [ "$attempt" -lt 50 ]; do
    ensure_dir "$DERIVED_DATA"
    ensure_dir "$GLOBAL_MODULE_CACHE_DIR"
    ensure_dir "$GLOBAL_SDK_STAT_CACHE_DIR"

    if [ -n "${MODULE_CACHE_DIR:-}" ]; then
      ensure_dir "$MODULE_CACHE_DIR"
    fi

    if [ -n "${SDK_STAT_CACHE_DIR:-}" ]; then
      ensure_dir "$SDK_STAT_CACHE_DIR"
    fi

    if [ -n "${CLANG_MODULES_BUILD_SESSION_FILE:-}" ]; then
      ensure_dir "$(dirname "$CLANG_MODULES_BUILD_SESSION_FILE")"
      ensure_file "$CLANG_MODULES_BUILD_SESSION_FILE"
    fi

    ensure_intermediate_sessions
    ensure_archive_intermediate_sessions

    if ensure_file "$GLOBAL_SESSION_FILE" 2>/dev/null; then
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
