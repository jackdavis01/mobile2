# Ad Mode Switching Guide

## Overview

The app now supports **seamless switching** between test and production ad unit IDs via the `AD_MODE` environment variable. This allows you to:

- ✅ Test with Google's official test ads during development
- ✅ Switch to production ads for release builds
- ✅ Use the same codebase for both scenarios
- ✅ No code changes needed - just change one environment variable!

## Quick Start

### For Development (Test Ads)

1. Open `.env` file
2. Set these values:
   ```properties
   ADS_ENABLED=true
   AD_MODE=test
   ```
3. Regenerate configuration:
   ```bash
   fvm dart run build_runner build --delete-conflicting-outputs
   ```
4. Run the app - you'll see Google's test ads!

### For Production (Real Ads)

1. Open `.env` file
2. Update production ad unit IDs:
   ```properties
   PRODUCTION_ADMOB_APP_ID_ANDROID=ca-app-pub-YOUR_ID~YOUR_APP_ID
   PRODUCTION_ADMOB_APP_ID_IOS=ca-app-pub-YOUR_ID~YOUR_APP_ID
   PRODUCTION_ADMOB_ANDROID_BANNER_ID=ca-app-pub-YOUR_ID/YOUR_AD_UNIT_ID
   PRODUCTION_ADMOB_IOS_BANNER_ID=ca-app-pub-YOUR_ID/YOUR_AD_UNIT_ID
   PRODUCTION_IRONSOURCE_APP_KEY_ANDROID=your_android_key
   PRODUCTION_IRONSOURCE_APP_KEY_IOS=your_ios_key
   ```
3. Set mode to production:
   ```properties
   ADS_ENABLED=true
   AD_MODE=production
   ```
4. Regenerate configuration:
   ```bash
   fvm dart run build_runner build --delete-conflicting-outputs
   ```
5. Build release:
   ```bash
   fvm flutter build apk --release
   fvm flutter build ios --release
   ```

## How It Works

### Environment Variables

The `.env` file now contains TWO sets of ad unit IDs:

| Prefix | Used When | Obfuscated | Purpose |
|--------|-----------|------------|---------|
| (none) | `AD_MODE=test` | No | Google's public test IDs |
| `PRODUCTION_*` | `AD_MODE=production` | Yes | Your real ad unit IDs |

### Smart Getters in AdsConfig

The `AdsConfig` class provides intelligent getter methods that automatically switch based on `AD_MODE`:

```dart
// These getters check AD_MODE and return appropriate IDs
AdsConfig.currentAdmobAppIdAndroid       // Test or Production based on AD_MODE
AdsConfig.currentAdmobAppIdIos           // Test or Production based on AD_MODE
AdsConfig.currentAdmobAndroidBannerId    // Test or Production based on AD_MODE
AdsConfig.currentAdmobIosBannerId        // Test or Production based on AD_MODE
AdsConfig.currentIronSourceAppKeyAndroid // Test or Production based on AD_MODE
AdsConfig.currentIronSourceAppKeyIos     // Test or Production based on AD_MODE
```

### Code Implementation

The ad widgets use these smart getters:

**Before (old way)**:
```dart
adUnitId: AdsConfig.admobAndroidBannerId  // Always used one set of IDs
```

**After (new way)**:
```dart
adUnitId: AdsConfig.currentAdmobAndroidBannerId  // Automatically switches!
```

## Configuration Reference

### .env File Structure

```properties
# ========================================
# Advertisement Control
# ========================================
ADS_ENABLED=true          # Enable/disable ads entirely
AD_MODE=test              # 'test' or 'production'

# ========================================
# TEST Configuration (AD_MODE=test)
# ========================================
# Google's official test IDs - safe to use
ADMOB_APP_ID_ANDROID=ca-app-pub-3940256099942544~3347511713
ADMOB_APP_ID_IOS=ca-app-pub-3940256099942544~1458002511
ADMOB_ANDROID_BANNER_ID=ca-app-pub-3940256099942544/9214589741
ADMOB_IOS_BANNER_ID=ca-app-pub-3940256099942544/2435281174

IRONSOURCE_APP_KEY_ANDROID=test_android_key
IRONSOURCE_APP_KEY_IOS=test_ios_key
IRONSOURCE_ANDROID_BANNER_ID=DefaultBanner
IRONSOURCE_IOS_BANNER_ID=DefaultBanner

# ========================================
# PRODUCTION Configuration (AD_MODE=production)
# ========================================
# YOUR real ad unit IDs - replace these!
PRODUCTION_ADMOB_APP_ID_ANDROID=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
PRODUCTION_ADMOB_APP_ID_IOS=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
PRODUCTION_ADMOB_ANDROID_BANNER_ID=ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY
PRODUCTION_ADMOB_IOS_BANNER_ID=ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY

PRODUCTION_IRONSOURCE_APP_KEY_ANDROID=your_production_android_key
PRODUCTION_IRONSOURCE_APP_KEY_IOS=your_production_ios_key
PRODUCTION_IRONSOURCE_ANDROID_BANNER_ID=ProductionBanner
PRODUCTION_IRONSOURCE_IOS_BANNER_ID=ProductionBanner
```

## Use Cases

### 1. Local Development
```properties
ADS_ENABLED=true
AD_MODE=test
```
- See how ads look and behave
- No need for AdMob/IronSource accounts
- No risk of invalid traffic
- No revenue impact

### 2. Internal Testing (QA)
```properties
ADS_ENABLED=true
AD_MODE=test
```
- Test ad integration
- Test ad layout and positioning
- Verify fallback logic (AdMob → IronSource)
- Test orientation changes

### 3. Beta/Staging Builds
```properties
ADS_ENABLED=true
AD_MODE=test
```
- Safe for external testers
- No risk of accidental clicks affecting metrics
- Test user experience with ads

### 4. Production Release
```properties
ADS_ENABLED=true
AD_MODE=production
```
- Real ads from your accounts
- Generate actual revenue
- Production metrics tracked in AdMob/IronSource dashboards

### 5. Soft Launch (No Ads)
```properties
ADS_ENABLED=false
AD_MODE=test  # Doesn't matter, ads are disabled
```
- Initial release without monetization
- Gather user feedback first
- Enable ads later via configuration change

## Security Notes

### Test IDs (Not Obfuscated)
- Google's official test IDs
- Public knowledge, safe to commit
- Used when `AD_MODE=test`
- No obfuscation needed

### Production IDs (Obfuscated)
- Your real ad unit IDs
- Prefixed with `PRODUCTION_*`
- Obfuscated in compiled binary
- Used when `AD_MODE=production`
- **Never commit these to git!**

## Workflow Examples

### Development Workflow

```bash
# 1. Start with test ads
echo "AD_MODE=test" >> .env
echo "ADS_ENABLED=true" >> .env

# 2. Regenerate config
fvm dart run build_runner build --delete-conflicting-outputs

# 3. Run app
fvm flutter run

# Result: Google test ads appear
```

### Release Workflow

```bash
# 1. Update .env for production
vi .env  # Change AD_MODE=production and verify PRODUCTION_* IDs

# 2. Regenerate config (obfuscates production IDs)
fvm dart run build_runner build --delete-conflicting-outputs

# 3. Build release
fvm flutter build apk --release

# 4. Verify .env is NOT in build
git status  # Should not show .env

# Result: Production ads in release build
```

### Quick Toggle Workflow

```bash
# Switch to test mode
sed -i '' 's/AD_MODE=production/AD_MODE=test/' .env
fvm dart run build_runner build --delete-conflicting-outputs

# Switch to production mode
sed -i '' 's/AD_MODE=test/AD_MODE=production/' .env
fvm dart run build_runner build --delete-conflicting-outputs
```

## Troubleshooting

### Issue: Seeing test ads in production build

**Cause**: `AD_MODE=test` in `.env`

**Solution**:
```bash
# 1. Check current mode
grep AD_MODE .env

# 2. Should see:
AD_MODE=production

# 3. If not, update it
echo "AD_MODE=production" >> .env

# 4. Regenerate
fvm dart run build_runner build --delete-conflicting-outputs
```

### Issue: Seeing production ads in development

**Cause**: `AD_MODE=production` in `.env`

**Solution**:
```bash
# Switch to test mode
echo "AD_MODE=test" >> .env
fvm dart run build_runner build --delete-conflicting-outputs
```

### Issue: No ads showing at all

**Checklist**:
```bash
# 1. Check if ads enabled
grep ADS_ENABLED .env
# Should be: ADS_ENABLED=true

# 2. Check mode
grep AD_MODE .env
# Should be: AD_MODE=test or AD_MODE=production

# 3. If production mode, verify you have real IDs
grep PRODUCTION_ADMOB .env
# Should NOT be: ca-app-pub-XXXXXXXXXXXXXXXX
```

### Issue: Build errors after changing .env

**Solution**: Always regenerate after changes
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

## Best Practices

### ✅ DO

1. **Use test mode for development**
   ```properties
   AD_MODE=test
   ```

2. **Use production mode only for releases**
   ```properties
   AD_MODE=production
   ```

3. **Regenerate after changing AD_MODE**
   ```bash
   fvm dart run build_runner build --delete-conflicting-outputs
   ```

4. **Verify mode before building release**
   ```bash
   grep AD_MODE .env  # Should show: production
   ```

5. **Keep .env private**
   ```bash
   git status  # Should NOT show .env
   ```

### ❌ DON'T

1. **Don't use production mode in development**
   - Wastes ad impressions
   - Affects your metrics
   - Risk of invalid traffic

2. **Don't commit .env with production IDs**
   - Security risk
   - Exposed credentials

3. **Don't forget to regenerate**
   - Changes won't take effect
   - App will use old IDs

4. **Don't use test mode in production**
   - No revenue
   - Test ads shown to users

## Platform-Specific Notes

### Android Manifest

The `AndroidManifest.xml` contains a hardcoded test App ID:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

**This is intentional!** The App ID in the manifest is just for SDK initialization. The actual ad unit IDs used at runtime come from `AdsConfig` getters and automatically switch based on `AD_MODE`.

### iOS Info.plist

Similarly, `Info.plist` contains:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```

**This is also intentional!** Runtime ad unit IDs are controlled by `AD_MODE`.

## Summary

| Scenario | ADS_ENABLED | AD_MODE | Result |
|----------|-------------|---------|--------|
| Development | true | test | Google test ads |
| QA Testing | true | test | Google test ads |
| Beta | true | test | Google test ads (safe) |
| Production | true | production | Your real ads ($$) |
| Soft Launch | false | (any) | No ads |

**Key Takeaway**: Change one variable (`AD_MODE`), rebuild config, and you're done! No code changes needed.
