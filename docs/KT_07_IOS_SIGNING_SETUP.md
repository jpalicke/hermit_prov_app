# KT_07: iOS Release Signing Setup

This document covers the one-time human setup required for issues #28 and #29 before
the `ios-release.yml` CI workflow can produce a signed IPA.

Prerequisites:
- A Mac with Xcode 14+ installed
- A paid Apple Developer account (developer.apple.com, $99/yr)
- Admin access to the `jpalicke/hermit_prov_app` GitHub repository (Settings > Secrets)

---

## Issue #28: Apple Developer Portal Setup

### Step 1: Create an App ID

1. Go to developer.apple.com and sign in.
2. Navigate to Certificates, Identifiers & Profiles > Identifiers.
3. Click the + button and select "App IDs", then "App".
4. Fill in:
   - Description: `Hermit Prov`
   - Bundle ID (Explicit): `com.hermitprov.hermit_prov_app`
5. Enable any capabilities you need (none required for v1).
6. Click Continue, then Register.

### Step 2: Generate a Distribution Certificate

A Distribution certificate requires a Certificate Signing Request (CSR) generated on your Mac.

**Generate the CSR:**

1. Open Keychain Access on your Mac.
2. Menu: Keychain Access > Certificate Assistant > Request a Certificate from a Certificate Authority.
3. Fill in:
   - User Email Address: your Apple ID email
   - Common Name: `Hermit Prov Distribution`
   - Request is: Saved to disk
4. Save the `.certSigningRequest` file somewhere you can find it.

**Create the certificate on Apple:**

1. In the Developer Portal, go to Certificates > + button.
2. Select "Apple Distribution" (for App Store and TestFlight).
3. Upload the `.certSigningRequest` file you just saved.
4. Click Continue, then Download. You get a `distribution.cer` file.
5. Double-click `distribution.cer` to install it into Keychain Access.

**Export as .p12:**

1. In Keychain Access, under "My Certificates", find "Apple Distribution: [your name or org]".
2. Right-click it and choose "Export...".
3. Save as `hermit_prov_dist.p12`.
4. Set a strong password when prompted. Save this password -- you need it as a GitHub secret.
5. The private key stays on this Mac. The `.p12` file can be moved.

**Get your Team ID:**

1. In the Developer Portal, click your account name (top right) or go to Membership.
2. Copy the Team ID (10-character alphanumeric string, e.g. `AB12CD34EF`).

### Step 3: Create a Provisioning Profile

1. In the Developer Portal, go to Profiles > + button.
2. Select "App Store Connect" (for App Store distribution).
3. Select the App ID you created: `com.hermitprov.hermit_prov_app`.
4. Select the Distribution certificate you just created.
5. Name the profile: `HermitProv AppStore Distribution`
6. Click Generate, then Download. You get a `.mobileprovision` file.

**Note the profile name exactly** -- you need it as a GitHub secret.

---

## Issue #29: Add GitHub Repository Secrets

You need 6 secrets in GitHub. Go to:
`https://github.com/jpalicke/hermit_prov_app/settings/secrets/actions`

Click "New repository secret" for each of the following:

### Secret: IOS_CERT_P12

The Distribution certificate exported as base64.

```bash
base64 -i hermit_prov_dist.p12 | pbcopy
```

Paste the clipboard contents as the secret value.

### Secret: IOS_CERT_PASSWORD

The password you set when exporting the `.p12` file in Step 2 above.

### Secret: IOS_KEYCHAIN_PASSWORD

An arbitrary strong password for the ephemeral CI keychain. It is never used after
the job ends -- the keychain is deleted at cleanup. Generate one with:

```bash
openssl rand -base64 32 | pbcopy
```

### Secret: IOS_PROVISION_PROFILE

The provisioning profile encoded as base64.

```bash
base64 -i ~/Downloads/HermitProv_AppStore_Distribution.mobileprovision | pbcopy
```

Paste the clipboard contents as the secret value.

### Secret: IOS_PROVISION_PROFILE_NAME

The exact name of the provisioning profile as shown in the Developer Portal.
If you named it `HermitProv AppStore Distribution`, the value is:

```
HermitProv AppStore Distribution
```

### Secret: IOS_TEAM_ID

Your 10-character Apple Team ID from Step 2 above (e.g. `AB12CD34EF`).

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
| `Code signing is required for product type 'Application'` | `CODE_SIGN_STYLE` not patched | Check all occurrences with `grep -c 'CODE_SIGN_STYLE' ios/Runner.xcodeproj/project.pbxproj` -- should be 0 after the sed step |
| `No signing certificate "Apple Distribution" found` | Cert password wrong, or `.p12` corrupted | Re-export the `.p12` and re-base64 it |
| `No profile for team ... matching ...` | Profile name mismatch | Check `IOS_PROVISION_PROFILE_NAME` matches the portal exactly |
| `error: exportArchive: No applicable devices found` | Wrong export method | Ensure `method` in `ExportOptions.plist` is `app-store` |

---

## Certificate Renewal

Apple Distribution certificates expire after 1 year. When the cert expires:

1. Repeat Step 2 (generate CSR, create new cert, export new `.p12`).
2. Update the `IOS_CERT_P12` and `IOS_CERT_PASSWORD` secrets in GitHub.
3. The provisioning profile may also need to be regenerated (it is tied to the certificate).

Set a calendar reminder for 11 months after the cert creation date.
