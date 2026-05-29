#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# copy_firebase_plist.sh
#
# Copies the correct GoogleService-Info.plist for the active Xcode scheme/
# Flutter flavor into the Runner bundle at build time.
#
# HOW TO USE IN XCODE:
#   1. Open ios/Runner.xcworkspace in Xcode
#   2. Select the Runner target → Build Phases
#   3. Click "+" → "New Run Script Phase"
#   4. Move it ABOVE "Copy Bundle Resources"
#   5. Paste this script path or its contents:
#        "${SRCROOT}/Runner/copy_firebase_plist.sh"
#      OR paste the body of this script directly.
#   6. Add to "Input Files":
#        $(SRCROOT)/Runner/firebase/domex/GoogleService-Info.plist
#        $(SRCROOT)/Runner/firebase/digitable/GoogleService-Info.plist
#        $(SRCROOT)/Runner/firebase/mahajana/GoogleService-Info.plist
#   7. Add to "Output Files":
#        $(DERIVED_FILE_DIR)/GoogleService-Info.plist
#
# FLAVOR DIRECTORIES (place the correct plist from Firebase Console in each):
#   ios/Runner/firebase/domex/GoogleService-Info.plist
#   ios/Runner/firebase/digitable/GoogleService-Info.plist
#   ios/Runner/firebase/mahajana/GoogleService-Info.plist
# ─────────────────────────────────────────────────────────────────────────────

set -e

# Detect flavor from the Xcode scheme name (Flutter sets DART_DEFINES which
# includes the flavor, or you can match on PRODUCT_BUNDLE_IDENTIFIER).
FLAVOR=""

# Try to extract from DART_DEFINES (set by `flutter build --flavor <name>`)
if [ -n "$DART_DEFINES" ]; then
  DECODED=$(echo "$DART_DEFINES" | tr ',' '\n' | while read line; do echo "$line" | base64 -d 2>/dev/null || true; done)
  if echo "$DECODED" | grep -qi "domex";     then FLAVOR="domex"; fi
  if echo "$DECODED" | grep -qi "digitable"; then FLAVOR="digitable"; fi
  if echo "$DECODED" | grep -qi "mahajana";  then FLAVOR="mahajana"; fi
fi

# Fallback: match on bundle identifier
if [ -z "$FLAVOR" ]; then
  case "$PRODUCT_BUNDLE_IDENTIFIER" in
    *domex*)    FLAVOR="domex"    ;;
    *mahajana*) FLAVOR="mahajana" ;;
    *)          FLAVOR="digitable" ;;
  esac
fi

PLIST_SRC="${SRCROOT}/Runner/firebase/${FLAVOR}/GoogleService-Info.plist"
PLIST_DST="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"

if [ ! -f "$PLIST_SRC" ]; then
  echo "error: Firebase plist not found at ${PLIST_SRC}. Please add it from the Firebase Console."
  exit 1
fi

cp -f "$PLIST_SRC" "$PLIST_DST"
echo "Copied ${FLAVOR} GoogleService-Info.plist → ${PLIST_DST}"
