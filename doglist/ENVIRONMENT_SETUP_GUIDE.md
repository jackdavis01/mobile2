# Environment Configuration Guide

## Overview

This project uses **split environment files** and **obfuscation** for secure advertisement configuration management.

## File Structure

| File | Git Status | Purpose | Contains |
|------|-----------|---------|----------|
| `.env.public` | ✅ Committed | Public template with test values | Google test AdMob IDs, safe defaults |
| `.env` | ❌ Gitignored | Private production configuration | Your real ad unit IDs (NEVER commit!) |
| `ads_config.g.dart` | ❌ Gitignored | Generated obfuscated code | Built by build_runner |

## Quick Start (New Developers)

### 1. Create Your Local Environment File

```bash
cd /Users/jackdavis/GreatMobileProjects/mobile2/doglist
cp .env.public .env
```

### 2. Generate Configuration

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. You're Ready!

The default `.env` has:
- ✅ `ADS_ENABLED=false` (ads disabled for development)
- ✅ Google's official test ad unit IDs
- ✅ Safe to run immediately

## Production Setup

### For Production Deployment

1. **Edit `.env` (NOT `.env.public`)**:
   ```bash
   nano .env
   ```

2. **Update these values**:
   ```properties
   ADS_ENABLED=true
   
   # Replace with YOUR AdMob App IDs
   ADMOB_APP_ID_ANDROID=ca-app-pub-YOUR_PUBLISHER_ID~YOUR_APP_ID
   ADMOB_APP_ID_IOS=ca-app-pub-YOUR_PUBLISHER_ID~YOUR_APP_ID
   
   # Replace with YOUR AdMob Ad Unit IDs
   ADMOB_ANDROID_BANNER_ID=ca-app-pub-YOUR_PUBLISHER_ID/YOUR_AD_UNIT_ID
   ADMOB_IOS_BANNER_ID=ca-app-pub-YOUR_PUBLISHER_ID/YOUR_AD_UNIT_ID
   
   # Replace with YOUR IronSource App Keys
   IRONSOURCE_APP_KEY_ANDROID=your_actual_android_key
   IRONSOURCE_APP_KEY_IOS=your_actual_ios_key
   
   # Set to false for production
   ENABLE_DEBUG_LOGGING=false
   ```

3. **Regenerate with obfuscation**:
   ```bash
   fvm dart run build_runner build --delete-conflicting-outputs
   ```

4. **Build production app**:
   ```bash
   fvm flutter build apk --release
   fvm flutter build ios --release
   ```

## Security Features

### 🔒 Obfuscation

All sensitive ad credentials are obfuscated in the compiled binary:
- AdMob App IDs
- AdMob Ad Unit IDs
- IronSource App Keys
- IronSource Ad Unit IDs

This is achieved through:
- `@Envied(obfuscate: true)` at class level
- `@EnviedField(obfuscate: true)` on sensitive fields
- Runtime deobfuscation (fields are `final`, not `const`)

### 🚫 Git Protection

The `.gitignore` is configured to:
```gitignore
.env              # ✅ Ignored - contains production secrets
!.env.public      # ✅ Allowed - contains only test values
*.g.dart          # ✅ Ignored - generated code
```

### ⚠️ Critical Security Rules

1. **NEVER commit `.env`** to version control
2. **ALWAYS use `.env.public`** for team collaboration
3. **Store production credentials** in a password manager (1Password, LastPass, etc.)
4. **Verify before committing**:
   ```bash
   git status  # Should NOT show .env
   ```

## How It Works

### Development Workflow

1. **Clone repository** → Get `.env.public` automatically
2. **Copy to `.env`** → `cp .env.public .env`
3. **Run build_runner** → Generates obfuscated config
4. **Start developing** → Ads disabled by default

### Production Workflow

1. **Get production credentials** from password manager
2. **Update `.env`** with real values
3. **Enable ads** → `ADS_ENABLED=true`
4. **Regenerate config** → Obfuscates production IDs
5. **Build release** → Production app with secured credentials

### Obfuscation Explanation

When you use `obfuscate: true`, Envied:
1. Splits your strings into character arrays
2. Scrambles them with XOR operations
3. Stores them as integer arrays in the binary
4. Reconstructs them at runtime with a deobfuscation function

This means:
- ✅ Can't see credentials in plain text in binary
- ✅ Fields must be `final` (runtime deobfuscation)
- ✅ Adds minimal runtime overhead
- ❌ Not encryption, but makes extraction harder

## Troubleshooting

### Issue: "Can't find .env file"
**Solution**: Copy `.env.public` to `.env`
```bash
cp .env.public .env
```

### Issue: "Const variables must be initialized with constant value"
**Solution**: With obfuscation, fields must be `final`, not `const`
```dart
// ❌ Wrong
static const String value = _AdsConfig.value;

// ✅ Correct
static final String value = _AdsConfig.value;
```

### Issue: "Build errors after changing .env"
**Solution**: Regenerate configuration
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

### Issue: "Accidentally committed .env"
**Solution**: Remove from git history immediately
```bash
git rm --cached .env
git commit -m "Remove accidentally committed .env"
git push
# Then rotate ALL credentials in .env
```

## Environment Variables Reference

| Variable | Required | Obfuscated | Example |
|----------|----------|------------|---------|
| `ADS_ENABLED` | Yes | No | `true` or `false` |
| `ADMOB_APP_ID_ANDROID` | Yes | Yes | `ca-app-pub-XXX~YYY` |
| `ADMOB_APP_ID_IOS` | Yes | Yes | `ca-app-pub-XXX~YYY` |
| `ADMOB_ANDROID_BANNER_ID` | Yes | Yes | `ca-app-pub-XXX/YYY` |
| `ADMOB_IOS_BANNER_ID` | Yes | Yes | `ca-app-pub-XXX/YYY` |
| `IRONSOURCE_APP_KEY_ANDROID` | Yes | Yes | `your_android_key` |
| `IRONSOURCE_APP_KEY_IOS` | Yes | Yes | `your_ios_key` |
| `IRONSOURCE_ANDROID_BANNER_ID` | Yes | Yes | `DefaultBanner` |
| `IRONSOURCE_IOS_BANNER_ID` | Yes | Yes | `DefaultBanner` |
| `IRONSOURCE_PLACEMENT_NAME` | Yes | No | `DefaultBanner` |
| `ADMOB_ANDROID_TEST_DEVICE_1` | No | No | Test device ID |
| `ADMOB_ANDROID_TEST_DEVICE_2` | No | No | Test device ID |
| `ADMOB_IOS_TEST_DEVICE_1` | No | No | Test device ID |
| `AD_REFRESH_RATE_SECONDS` | No | No | `60` |
| `AD_REQUEST_TIMEOUT_SECONDS` | No | No | `30` |
| `ENABLE_DEBUG_LOGGING` | No | No | `true` or `false` |

## Best Practices

### ✅ DO

- Use `.env.public` for team collaboration
- Store production credentials in password manager
- Test with `ADS_ENABLED=false` during development
- Regenerate config after changing `.env`
- Verify `.env` is not in git before committing

### ❌ DON'T

- Commit `.env` to version control
- Share production credentials via Slack/email
- Use production IDs during development
- Hardcode ad unit IDs in source code
- Forget to regenerate after `.env` changes

## Team Collaboration

### For Team Leads

1. Store production credentials in team password manager
2. Share access with authorized team members only
3. Document any credential changes
4. Rotate credentials if team member leaves

### For Team Members

1. Get production credentials from password manager
2. Create local `.env` from `.env.public`
3. Never commit `.env`
4. Keep credentials secure

## Additional Resources

- [Envied Package Documentation](https://pub.dev/packages/envied)
- [AdMob Setup Guide](https://developers.google.com/admob/flutter/quick-start)
- [IronSource Integration](https://developers.is.com/ironsource-mobile/flutter/flutter-plugin/)
- Project-specific: See `ADVERTISEMENT_README.md`
