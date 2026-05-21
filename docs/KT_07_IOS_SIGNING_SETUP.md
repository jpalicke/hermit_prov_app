# KT_07: iOS Release Signing Setup

This document covers the one-time human setup required for issues #28 and #29 before
the `ios-release.yml` CI workflow can produce a signed IPA.

**No Mac required.** All certificate generation steps use `openssl`, which is available
in Git Bash, WSL, or PowerShell on Windows. You only need a browser for the Apple
Developer portal.

Prerequisites:
- A paid Apple Developer account (developer.apple.com, $99/yr)
- Git Bash, WSL, or PowerShell with openssl available
- Admin access to the `jpalicke/hermit_prov_app` GitHub repository (Settings > Secrets)
- A browser

**Verify openssl is available** before starting:

```bash
openssl version
# Expected: OpenSSL 3.x.x ...
```

If not found in Git Bash, WSL has it: `wsl openssl version`

---

## Issue #28: Apple Developer Portal Setup

### Step 1: Create an App ID

1. Go to developer.apple.com and sign in.
2. Navigate to Certificates, Identifiers & Profiles > Identifiers.
3. Click the + button and select "App IDs", then "App".
4. Fill in:
   - Description: `Hermit Prov`
   - Bundle ID (Explicit): `com.hermitprov.hermitProvApp`
5. Enable any capabilities you need (none required for v1).
6. Click Continue, then Register.

### Step 2: Generate a Distribution Certificate (Windows / openssl)

Apple requires a Certificate Signing Request (CSR) to issue a certificate. You generate
the CSR locally -- the private key never leaves your machine.

**Generate the private key and CSR** (run in Git Bash, WSL, or a directory you can find):

```bash
# 1. Generate a 2048-bit RSA private key
openssl genrsa -out hermit_prov_dist.key 2048

# 2. Generate the CSR
#    Replace the email with your Apple ID email
openssl req -new \
  -key hermit_prov_dist.key \
  -out HermitProvDistribution.certSigningRequest \
  -subj "/emailAddress=your@appleid.com/CN=Hermit Prov Distribution/C=US"
```

You now have two files:
- `hermit_prov_dist.key` -- the private key. Keep this safe; you need it later.
- `HermitProvDistribution.certSigningRequest` -- upload this to Apple.

**Upload the CSR and download the certificate:**

1. In the Developer Portal, go to Certificates > + button.
2. Select "Apple Distribution" (for App Store and TestFlight).
3. Upload `HermitProvDistribution.certSigningRequest`.
4. Click Continue, then Download. You get `distribution.cer`.

**Convert the .cer and bundle into a .p12:**

```bash
# 3. Convert the DER-encoded .cer to PEM format
openssl x509 -in distribution.cer -inform DER -out distribution.pem -outform PEM

# 4. Bundle the private key + cert into a .p12 file
#    You will be prompted for an export password -- save this; it becomes IOS_CERT_PASSWORD
openssl pkcs12 -export \
  -out hermit_prov_dist.p12 \
  -inkey hermit_prov_dist.key \
  -in distribution.pem
```

When prompted for "Export Password", choose a strong password and save it. This is
`IOS_CERT_PASSWORD` in GitHub secrets.

**Get your Team ID:**

1. In the Developer Portal, click your account name (top right) or go to Membership.
2. Copy the Team ID (10-character alphanumeric string, e.g. `AB12CD34EF`).

### Step 3: Create a Provisioning Profile

1. In the Developer Portal, go to Profiles > + button.
2. Select "App Store Connect" (for App Store distribution).
3. Select the App ID you created: `com.hermitprov.hermitProvApp`.
4. Select the Distribution certificate you just created.
5. Name the profile: `HermitProv AppStore Distribution`
6. Click Generate, then Download. You get a `.mobileprovision` file.

**Note the profile name exactly** -- you need it as a GitHub secret.

---

## Issue #29: Add GitHub Repository Secrets

You need 6 secrets in GitHub. Go to:
`https://github.com/jpalicke/hermit_prov_app/settings/secrets/actions`

Click "New repository secret" for each of the following.

### Secret: IOS_CERT_P12

Base64-encode the .p12 file and paste the result as the secret value.

**Git Bash or WSL:**
```bash
base64 hermit_prov_dist.p12
```

**PowerShell:**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes('hermit_prov_dist.p12'))
```

Copy the entire output (it will be a long single line or wrapped lines -- paste it all).

### Secret: IOS_CERT_PASSWORD

The export password you set in Step 2 when running `openssl pkcs12 -export`.

### Secret: IOS_KEYCHAIN_PASSWORD

An arbitrary strong password for the ephemeral CI keychain. It is created and deleted
within the same CI job. Generate one:

**Git Bash or WSL:**
```bash
openssl rand -base64 32
```

**PowerShell:**
```powershell
[Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
```

### Secret: IOS_PROVISION_PROFILE

Base64-encode the `.mobileprovision` file from Step 3.

**Git Bash or WSL** (adjust path to where you downloaded it):
```bash
base64 ~/Downloads/HermitProv_AppStore_Distribution.mobileprovision
```

**PowerShell:**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\Downloads\HermitProv_AppStore_Distribution.mobileprovision"))
```

### Secret: IOS_PROVISION_PROFILE_NAME

The exact name of the provisioning profile as shown in the Developer Portal.
If you named it `HermitProv AppStore Distribution`, the value is:

```
HermitProv AppStore Distribution
```

### Secret: IOS_TEAM_ID

Your 10-character Apple Team ID from Step 2 (e.g. `AB12CD34EF`).

---

## Verify the Setup

Once all 6 secrets are added, trigger the workflow manually:

1. Go to github.com/jpalicke/hermit_prov_app/actions.
2. Select "iOS Release" from the left sidebar.
3. Click "Run workflow" > "Run workflow" (on the main branch or a test branch).
4. Watch the run. A successful run uploads a `.ipa` artifact (retained 30 days).

Common failure modes:

| Error | Cause | Fix |
|---|---|---|
| `security: SecKeychainItemImport: The specified item already exists` | Cert already in keychain | Usually harmless, the import still works |
| `Code signing is required for product type 'Application'` | `CODE_SIGN_STYLE` not patched | Check occurrences: `grep -c 'CODE_SIGN_STYLE' ios/Runner.xcodeproj/project.pbxproj` should be 0 after the sed step |
| `No signing certificate "Apple Distribution" found` | Cert password wrong or .p12 corrupted | Re-run the openssl pkcs12 step and re-encode |
| `No profile for team ... matching ...` | Profile name mismatch | Verify `IOS_PROVISION_PROFILE_NAME` matches the portal name exactly |
| `error: exportArchive: No applicable devices found` | Wrong export method | Ensure `method` in `ExportOptions.plist` is `app-store` |
| `unable to load Private Key` | Wrong openssl pkcs12 syntax | Re-run step 4; confirm `-inkey` points at `hermit_prov_dist.key` |

---

## Certificate Renewal

Apple Distribution certificates expire after 1 year. When the cert expires:

1. Repeat Step 2: generate a new key + CSR, upload to Apple, download new .cer, bundle new .p12.
2. Update `IOS_CERT_P12` and `IOS_CERT_PASSWORD` secrets in GitHub.
3. The provisioning profile may also need to be regenerated (it is tied to the certificate).

Set a calendar reminder for 11 months after the cert creation date.

---

## Key File Reference

| File | Keep safe? | Purpose |
|---|---|---|
| `hermit_prov_dist.key` | Yes, never share | Private key; needed to re-export .p12 if lost |
| `HermitProvDistribution.certSigningRequest` | Optional | Uploaded to Apple; can be regenerated |
| `distribution.cer` | Optional | Downloaded from Apple; can be re-downloaded |
| `distribution.pem` | Optional | Intermediate conversion step |
| `hermit_prov_dist.p12` | Yes | Uploaded to GitHub as `IOS_CERT_P12` |
| `*.mobileprovision` | Optional | Re-downloadable from Apple Developer Portal |
