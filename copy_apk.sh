#!/usr/bin/env bash
# copy_apk.sh
# Reliably copies the Flutter app-release.apk to the Connected_Living/app/ directory
# for preview system compatibility. Uses the script's own directory to derive absolute paths.
#
# Usage: bash copy_apk.sh
#   Can be called from any working directory.

set -e

# Resolve the base directory (parent of the Flutter container directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

SOURCE_APK="${BASE_DIR}/hello-world-flutter-app-10256-10266/app/app-release.apk"
TARGET_DIR="${BASE_DIR}/Connected_Living/app"
TARGET_APK="${TARGET_DIR}/app-release.apk"

# Ensure target directory exists
mkdir -p "${TARGET_DIR}"

if [ -f "${SOURCE_APK}" ]; then
    cp "${SOURCE_APK}" "${TARGET_APK}"
    echo "SUCCESS: Copied APK to ${TARGET_APK}"
else
    echo "WARNING: Source APK not found at ${SOURCE_APK}"
    exit 1
fi
