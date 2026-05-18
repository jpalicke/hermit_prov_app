# iOS TestFlight Pipeline — Setup Guide

## Overview

Every push to `master` triggers a GitHub Actions build that runs tests, builds
a signed IPA, and uploads it to TestFlight automatically.

---

## Step 1 — Enroll in the Apple Developer Program

Go to https://developer.apple.com/programs/enroll/ and enroll with your Apple ID.
Cost: $99/yr. Allow up to 48 hours for approval.

Once approved, note your **Team ID** — it's a 10-character string visible at
https://developer.apple.com/account → Membership Details.

---

## Step 2 — Create the App ID

In the Developer Portal (https://developer.apple.com/account/resources/identifiers):

1. Click **+** → App IDs → App
2. Bundle ID: `com.hermitprov` (explicit, not wildcard)
3. Enable any capabilities you need (none required for this app)
4. Register it

---

## Step 3 — Create the App in App Store Connect

Go to https://appstoreconnect.apple.com → My Apps → **+** → New App:

- Platform: iOS
- Name: Hermit Prov
- Bundle ID: com.hermitprov (from Step 2)
- SKU: hermit-prov (any unique string)

---

## Step 4 — Create a Distribution Certificate

In Keychain Access on a Mac (or use the Developer Portal directly):

1. Developer Portal → Certificates → **+** → Apple Distribution
2. Upload a Certificate Signing Request (CSR) generated from Keychain Access
3. Download the `.cer` and install it in Keychain Access
4. Export the certificate as a `.p12` file (File → Export, set a password)
5. Base64-encode it:
   ```
   base64 -i certificate.p12 | pbcopy
   ```
   This copies the encoded string to your clipboard.

---

## Step 5 — Create a Provisioning Profile

Developer Portal → Profiles → **+** → App Store Distribution:

1. Select the App ID: `com.hermitprov`
2. Select the Distribution Certificate from Step 4
3. Name it something memorable, e.g. `HermitProv AppStore`
4. Download the `.mobileprovision` file
5. Base64-encode it:
   ```
   base64 -i HermitProv_AppStore.mobileprovision | pbcopy
   ```

---

## Step 6 — Create an App Store Connect API Key

App Store Connect → Users and Access → Integrations → App Store Connect API → **+**:

- Name: GitHub Actions
- Access: Developer (sufficient for TestFlight uploads)

Download the `.p8` file — **you can only download it once**.

Note the **Key ID** and **Issuer ID** shown on that page.

Base64-encode the key:
```
base64 -i AuthKey_XXXXXXXX.p8 | pbcopy
```

---

## Step 7 — Update ExportOptions.plist

Edit `ios/ExportOptions.plist` and replace:
- `YOUR_TEAM_ID` → your 10-character Team ID from Step 1
- `YOUR_PROVISIONING_PROFILE_NAME` → the profile name from Step 5 (e.g. `HermitProv AppStore`)

Commit and push that change.

---

## Step 8 — Add GitHub Secrets

In your GitHub repo: Settings → Secrets and variables → Actions → New repository secret.

Add each of these:

| Secret name | Value |
|---|---|
| `APPLE_DISTRIBUTION_CERT_BASE64` | Base64 string from Step 4 |
| `APPLE_DISTRIBUTION_CERT_PASSWORD` | Password you set when exporting the .p12 |
| `KEYCHAIN_PASSWORD` | Any random string (used for the temporary CI keychain) |
| `APPLE_PROVISIONING_PROFILE_BASE64` | Base64 string from Step 5 |
| `APP_STORE_CONNECT_KEY_ID` | Key ID from Step 6 |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from Step 6 |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64 string from Step 6 |

---

## Step 9 — First Build

Push any commit to `master`. The Actions tab will show the workflow running.
First build takes ~15 minutes. On success, the build appears in TestFlight
under your app within a few minutes.

Install TestFlight on your iPhone, open it, and the build will be waiting.

---

## Troubleshooting

**"No signing certificate found"** — The p12 import failed. Check that
`APPLE_DISTRIBUTION_CERT_BASE64` is a valid base64-encoded .p12 and the
password matches.

**"Provisioning profile doesn't match"** — The profile name in
`ExportOptions.plist` must exactly match the profile name in the Developer
Portal (Step 5).

**"Invalid API key"** — The .p8 file must be at
`~/.private_keys/AuthKey_<KEY_ID>.p8`. The workflow handles this automatically
— check that `APP_STORE_CONNECT_KEY_ID` matches the filename.
