#!/bin/bash
# Finds your App Store Connect .p8 key and prints the three GitHub secrets
# ready to copy-paste into github.com/jpalicke/hermit_prov_app/settings/secrets/actions

set -e

P8_FILES=( ~/Downloads/AuthKey_*.p8 )

if [ ${#P8_FILES[@]} -eq 0 ] || [ ! -f "${P8_FILES[0]}" ]; then
  echo "No AuthKey_*.p8 file found in ~/Downloads."
  echo "Download it from: https://appstoreconnect.apple.com/access/integrations/api"
  exit 1
fi

if [ ${#P8_FILES[@]} -gt 1 ]; then
  echo "Multiple .p8 files found — using the most recent one."
  P8_FILE=$(ls -t ~/Downloads/AuthKey_*.p8 | head -1)
else
  P8_FILE="${P8_FILES[0]}"
fi

KEY_ID=$(basename "$P8_FILE" .p8 | sed 's/AuthKey_//')
ASC_API_KEY=$(base64 -i "$P8_FILE" | tr -d '\n')

echo ""
echo "================================================"
echo "  Add these at:"
echo "  github.com/jpalicke/hermit_prov_app/settings/secrets/actions"
echo "================================================"
echo ""
echo "Secret name:  ASC_KEY_ID"
echo "Secret value: $KEY_ID"
echo ""
echo "Secret name:  ASC_API_KEY"
echo "Secret value: $ASC_API_KEY"
echo ""
echo "================================================"
echo "  One more — get this from App Store Connect:"
echo "  https://appstoreconnect.apple.com/access/integrations/api"
echo "  Copy the Issuer ID UUID at the top of the page."
echo ""
echo "Secret name:  ASC_ISSUER_ID"
echo "Secret value: <paste UUID from App Store Connect>"
echo "================================================"
echo ""
