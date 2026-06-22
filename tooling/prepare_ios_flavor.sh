#!/bin/bash
# tooling/prepare_ios_flavor.sh
set -e

FLAVOR="$1"

if [ -z "$FLAVOR" ]; then
  echo "Error: No flavor specified. Usage: ./prepare_ios_flavor.sh <flavor>"
  exit 1
fi

# Convert flavor to lowercase
FLAVOR=$(echo "$FLAVOR" | tr '[:upper:]' '[:lower:]')

echo "Preparing iOS assets and config for flavor: $FLAVOR"

SRCROOT="ios"

# Define target paths
APP_ICON_DST="$SRCROOT/Runner/Assets.xcassets/AppIcon.appiconset"
LAUNCH_IMAGE_DST="$SRCROOT/Runner/Assets.xcassets/LaunchImage.imageset"
LAUNCH_BG_DST="$SRCROOT/Runner/Assets.xcassets/LaunchBackground.imageset"
LAUNCH_STORYBOARD_DST="$SRCROOT/Runner/Base.lproj/LaunchScreen.storyboard"
FIREBASE_PLIST_DST="$SRCROOT/Runner/GoogleService-Info.plist"
INFO_PLIST="$SRCROOT/Runner/Info.plist"

# 1. Swap Firebase GoogleService-Info.plist
FIREBASE_PLIST_SRC="$SRCROOT/Runner/firebase/$FLAVOR/GoogleService-Info.plist"
if [ -f "$FIREBASE_PLIST_SRC" ]; then
  cp -f "$FIREBASE_PLIST_SRC" "$FIREBASE_PLIST_DST"
  echo "✓ Copied Firebase Plist from $FIREBASE_PLIST_SRC"
else
  echo "⚠️ Warning: Firebase Plist not found at $FIREBASE_PLIST_SRC"
fi

# 2. Swap App Icon
APP_ICON_SRC="$SRCROOT/Runner/Assets.xcassets/AppIcon-$FLAVOR.appiconset"
if [ -d "$APP_ICON_SRC" ]; then
  rm -rf "$APP_ICON_DST"
  cp -r "$APP_ICON_SRC" "$APP_ICON_DST"
  echo "✓ Swapped AppIcon with $APP_ICON_SRC"
else
  echo "⚠️ Warning: AppIcon asset catalog not found at $APP_ICON_SRC"
fi

# 3. Swap Launch Image
# Storyboards and catalogs usually capitalize the flavor name (e.g. LaunchImageDomex)
CAP_FLAVOR="$(echo "${FLAVOR:0:1}" | tr '[:lower:]' '[:upper:]')${FLAVOR:1}"
LAUNCH_IMAGE_SRC="$SRCROOT/Runner/Assets.xcassets/LaunchImage$CAP_FLAVOR.imageset"
if [ ! -d "$LAUNCH_IMAGE_SRC" ]; then
  LAUNCH_IMAGE_SRC="$SRCROOT/Runner/Assets.xcassets/LaunchImage$FLAVOR.imageset"
fi

if [ -d "$LAUNCH_IMAGE_SRC" ]; then
  rm -rf "$LAUNCH_IMAGE_DST"
  cp -r "$LAUNCH_IMAGE_SRC" "$LAUNCH_IMAGE_DST"
  echo "✓ Swapped LaunchImage with $LAUNCH_IMAGE_SRC"
else
  echo "⚠️ Warning: LaunchImage asset catalog not found at $LAUNCH_IMAGE_SRC"
fi

# 4. Swap Launch Background
LAUNCH_BG_SRC="$SRCROOT/Runner/Assets.xcassets/LaunchBackground$CAP_FLAVOR.imageset"
if [ ! -d "$LAUNCH_BG_SRC" ]; then
  LAUNCH_BG_SRC="$SRCROOT/Runner/Assets.xcassets/LaunchBackground$FLAVOR.imageset"
fi

if [ -d "$LAUNCH_BG_SRC" ]; then
  rm -rf "$LAUNCH_BG_DST"
  cp -r "$LAUNCH_BG_SRC" "$LAUNCH_BG_DST"
  echo "✓ Swapped LaunchBackground with $LAUNCH_BG_SRC"
else
  echo "⚠️ Warning: LaunchBackground asset catalog not found at $LAUNCH_BG_SRC"
fi

# 5. Swap Launch Storyboard
LAUNCH_STORYBOARD_SRC="$SRCROOT/Runner/Base.lproj/LaunchScreen$CAP_FLAVOR.storyboard"
if [ -f "$LAUNCH_STORYBOARD_SRC" ]; then
  cp -f "$LAUNCH_STORYBOARD_SRC" "$LAUNCH_STORYBOARD_DST"
  echo "✓ Swapped Launch Storyboard with $LAUNCH_STORYBOARD_SRC"
else
  echo "⚠️ Warning: Launch storyboard not found at $LAUNCH_STORYBOARD_SRC"
fi

# 6. Update App Display Name and Bundle Name in Info.plist
case "$FLAVOR" in
  domex)
    DISPLAY_NAME="My Domex"
    BUNDLE_ID="io.digitable.go.mydomex.human"
    ;;
  mahajana)
    DISPLAY_NAME="Mahajana HR"
    BUNDLE_ID="com.mahajana.human.pocket"
    ;;
  digitable|*)
    DISPLAY_NAME="Pocket HR"
    BUNDLE_ID="asia.ceynet.human.pocket"
    ;;
esac

echo "Updating app display name in Info.plist to: $DISPLAY_NAME"
echo "Updating bundle identifier in project.pbxproj to: $BUNDLE_ID"

if command -v plutil &> /dev/null; then
  # macOS native utility
  plutil -replace CFBundleDisplayName -string "$DISPLAY_NAME" "$INFO_PLIST"
  plutil -replace CFBundleName -string "$DISPLAY_NAME" "$INFO_PLIST"
  echo "✓ Updated display name using plutil"
else
  # Platform independent python solution (handles multi-line XML structures cleanly)
  python3 -c "
import re
with open('$INFO_PLIST', 'r') as f:
    content = f.read()

content = re.sub(
    r'(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)',
    r'\g<1>$DISPLAY_NAME\g<2>',
    content
)
content = re.sub(
    r'(<key>CFBundleName</key>\s*<string>)[^<]*(</string>)',
    r'\g<1>$DISPLAY_NAME\g<2>',
    content
)

with open('$INFO_PLIST', 'w') as f:
    f.write(content)
"
  echo "✓ Updated display name using python3"
fi

# 7. Update Bundle Identifier in project.pbxproj (handles both standard and sdk-specific keys)
python3 -c "
import re
pbxproj_path = '$SRCROOT/Runner.xcodeproj/project.pbxproj'
with open(pbxproj_path, 'r') as f:
    content = f.read()

# Replace PRODUCT_BUNDLE_IDENTIFIER = ...;
content = re.sub(
    r'(PRODUCT_BUNDLE_IDENTIFIER\s*=\s*)[^;]+(;)',
    r'\g<1>$BUNDLE_ID\g<2>',
    content
)

# Replace \"PRODUCT_BUNDLE_IDENTIFIER[sdk=iphoneos*]\" = ...;
content = re.sub(
    r'(\"PRODUCT_BUNDLE_IDENTIFIER\[sdk=iphoneos\*\]\"\s*=\s*)[^;]+(;)',
    r'\g<1>$BUNDLE_ID\g<2>',
    content
)

with open(pbxproj_path, 'w') as f:
    f.write(content)
"
echo "✓ Updated bundle identifier in project.pbxproj using python3"

echo "iOS Preparation for $FLAVOR completed successfully!"
