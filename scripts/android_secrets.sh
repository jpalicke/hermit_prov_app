#!/bin/bash
# ABOUTME: Encodes an Android release keystore and prints the four GitHub secrets
# ABOUTME: needed by android-release.yml. Run: bash scripts/android_secrets.sh <path/to/keystore.jks>

set -e

JKS_FILE="$1"

if [ -z "$JKS_FILE" ]; then
  # Try to find a .jks file in common locations.
  CANDIDATES=( ~/hermit-prov-release.jks ~/Downloads/hermit-prov-release.jks )
  for c in "${CANDIDATES[@]}"; do
    if [ -f "$c" ]; then
      JKS_FILE="$c"
      break
    fi
  done
fi

if [ -z "$JKS_FILE" ] || [ ! -f "$JKS_FILE" ]; then
  echo "Usage: bash scripts/android_secrets.sh <path/to/keystore.jks>"
  echo ""
  echo "If you don't have a keystore yet, generate one:"
  echo "  keytool -genkey -v -keystore ~/hermit-prov-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias hermit_prov"
  exit 1
fi

KEYSTORE_B64=$(base64 "$JKS_FILE" | tr -d '\n')

echo ""
echo "================================================"
echo "  Add these at:"
echo "  github.com/jpalicke/hermit_prov_app/settings/secrets/actions"
echo "================================================"
echo ""
echo "Secret name:  ANDROID_KEYSTORE_BASE64"
echo "Secret value: $KEYSTORE_B64"
echo ""
echo "Secret name:  ANDROID_KEY_ALIAS"
echo "Secret value: <the alias you used in keytool, e.g. hermit_prov>"
echo ""
echo "Secret name:  ANDROID_KEY_PASSWORD"
echo "Secret value: <the key password you entered in keytool>"
echo ""
echo "Secret name:  ANDROID_STORE_PASSWORD"
echo "Secret value: <the keystore password you entered in keytool>"
echo ""
echo "================================================"
echo "  One more — the Play Store service account:"
echo ""
echo "Secret name:  GOOGLE_PLAY_SERVICE_ACCOUNT_JSON"
echo "Secret value: <full contents of the .json key file from Google Cloud Console>"
echo ""
echo "  See docs/KT_08_ANDROID_SIGNING_SETUP.md for how to create the service account."
echo "================================================"
echo ""
