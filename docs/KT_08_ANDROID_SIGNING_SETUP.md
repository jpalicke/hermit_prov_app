# Hermit Prov — Android Signing and Play Store Setup

This document covers everything needed to get the `android-release.yml` workflow shipping to the Google Play Store.

---

## Overview

The workflow needs 5 GitHub secrets and a one-time manual AAB upload to Play Console before automation takes over.

| Secret | What it is |
|--------|-----------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded release keystore (.jks) |
| `ANDROID_KEY_ALIAS` | Alias of the key inside the keystore |
| `ANDROID_KEY_PASSWORD` | Password for the key |
| `ANDROID_STORE_PASSWORD` | Password for the keystore file itself |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Full JSON content of a Play Console service account key |

---

## Step 1 — Generate the Release Keystore (one time only)

If you do not already have a keystore, generate one. Store it somewhere safe outside the repo.

```bash
keytool -genkey -v \
  -keystore ~/hermit-prov-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias hermit_prov
```

You will be prompted for:
- A keystore password (save this — it becomes `ANDROID_STORE_PASSWORD`)
- A key password (save this — it becomes `ANDROID_KEY_PASSWORD`)
- Name, org, location info (can be anything)

**The alias you enter** (`hermit_prov` above) becomes `ANDROID_KEY_ALIAS`.

Keep the `.jks` file backed up. If you lose it, you can never update the app on Play Store.

---

## Step 2 — Encode the Keystore

Use the helper script to get the base64 value:

```bash
bash scripts/android_secrets.sh ~/hermit-prov-release.jks
```

This prints the four keystore-related secrets ready to copy-paste into GitHub.

Or manually:

```bash
base64 ~/hermit-prov-release.jks | tr -d '\n'
```

---

## Step 3 — Set Up Google Play Console

### 3a. Create the app in Play Console

1. Go to https://play.google.com/console
2. Create app > App name: `Hermit Prov`
3. Choose Free, Contains no ads
4. Fill in the store listing (description, screenshots, etc.) — this can be done after first upload

### 3b. Create a service account

Google Play API access goes through a Google Cloud service account.

1. In Play Console: **Setup > API access**
2. Click **Link to a Google Cloud project** (create one if prompted — use any project name)
3. Click **View in Google Cloud Console**
4. In Google Cloud Console: **IAM & Admin > Service Accounts > Create Service Account**
   - Name: `hermit-prov-ci` (or anything descriptive)
   - Skip optional fields, click Done
5. Click the new service account, go to **Keys** tab
6. **Add Key > Create new key > JSON** — this downloads a `.json` file
7. Keep this file secure — it is a credential

### 3c. Grant the service account access in Play Console

Back in Play Console: **Setup > API access**

- Find your new service account in the list
- Click **Grant access**
- Permission level: **Release manager** (needed to upload to internal track)
- Click **Apply** then **Save**

### 3d. Get the service account JSON content

Open the downloaded `.json` file in a text editor. The entire file content (from `{` to `}`) is the value of `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`.

---

## Step 4 — Add the 5 Secrets to GitHub

Go to: https://github.com/jpalicke/hermit_prov_app/settings/secrets/actions

Add each secret:

| Secret name | Where to get it |
|-------------|----------------|
| `ANDROID_KEYSTORE_BASE64` | Output of `scripts/android_secrets.sh` or manual `base64` command |
| `ANDROID_KEY_ALIAS` | The alias you used in `keytool` (e.g. `hermit_prov`) |
| `ANDROID_KEY_PASSWORD` | The key password from `keytool` |
| `ANDROID_STORE_PASSWORD` | The keystore password from `keytool` |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Full content of the service account `.json` file |

---

## Step 5 — First Manual AAB Upload (Required by Play)

Google Play requires the very first upload to be done manually through the UI. The API cannot create a new app — it can only update an existing one.

1. Build a release AAB locally:
   ```bash
   flutter build appbundle --release
   ```
   Output: `build/app/outputs/bundle/release/app-release.aab`

2. In Play Console: **Internal testing > Create new release**
3. Upload the `.aab` file
4. Add release notes (can be anything: "Initial release")
5. Save and roll out to internal testing

After this one manual upload, every subsequent release can be pushed by the `android-release.yml` workflow.

---

## Step 6 — Trigger the Workflow

The workflow fires on any `v*` tag push or manually via workflow_dispatch.

```bash
git tag v1.0.1
git push origin v1.0.1
```

Or trigger manually from: https://github.com/jpalicke/hermit_prov_app/actions/workflows/android-release.yml

The workflow:
1. Runs all tests
2. Restores the keystore from `ANDROID_KEYSTORE_BASE64`
3. Builds a signed AAB
4. Uploads to the **internal** track on Play Console
5. Saves the AAB as a workflow artifact (30-day retention)

---

## Local Release Builds

The workflow handles signing automatically in CI. For local signed builds, create `android/key.properties` (gitignored):

```properties
storeFile=/absolute/path/to/hermit-prov-release.jks
storePassword=<your store password>
keyAlias=hermit_prov
keyPassword=<your key password>
```

`build.gradle.kts` reads this file automatically when present.

---

## Troubleshooting

**"Package not found" from upload-google-play:** The app in Play Console must exist before the API can upload to it. Complete Step 5 (first manual upload) first.

**"Invalid keystore" during build:** The base64 encoding of the JKS file may have embedded newlines. Make sure you used `tr -d '\n'` when encoding, or use `scripts/android_secrets.sh`.

**"Permission denied" from Play API:** The service account needs **Release manager** access in Play Console (Step 3c). It is not enough to just have the service account in Google Cloud — it must also be granted in Play Console.

**Workflow passes but AAB not in internal track:** Check that the `track: internal` setting matches a track that exists on your app. Play Console creates internal, alpha, beta, and production tracks by default.
