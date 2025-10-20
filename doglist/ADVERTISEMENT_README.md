# Advertisement Implementation Guide

This project implements banner ads using AdMob (primary) and IronSource (fallback) with secure environment variable management via the Envied plugin with obfuscation.

## Features

- **Switchable Advertisements**: Enable/disable ads via environment variable
- **Test/Production Mode Switching**: Seamlessly switch between test and production ad IDs via `AD_MODE`
- **Dual Ad Network Support**: AdMob as primary, IronSource as fallback
- **Secure Configuration**: Environment variables managed with Envied and obfuscation
- **Split Environment Files**: Public test values (`.env.public`) and private production values (`.env`)
- **Adaptive Banner Ads**: Responsive design for all screen sizes
- **Dynamic Space Management**: Banner space only reserved when ads enabled
- **Modern Best Practices**: Latest Flutter ad implementation patterns
- **Test Ad Support**: Easy testing with Google's official test ad unit IDs

## Setup Instructions

### 1. Initial Setup (New Developers)

1. **Copy the public environment file to create your private configuration**:
   ```bash
   cp .env.public .env
   ```

2. **The `.env` file is now ready for development with test IDs**
   - Default configuration has `ADS_ENABLED=false` (ads disabled)
   - Default mode is `AD_MODE=test` (uses Google's test ad IDs)
   - Contains Google's official test ad unit IDs
   - Safe to use immediately for development

3. **To enable test ads during development**:
   ```bash
   # Edit .env
   ADS_ENABLED=true
   AD_MODE=test
   ```

4. **For production deployment**, update `.env`:
   - Set `ADS_ENABLED=true` to enable advertisements
   - Set `AD_MODE=production` to use real ad unit IDs
   - Update all `PRODUCTION_*` variables with your actual AdMob/IronSource credentials
   - Add your test device IDs for development testing

### 2. Generate Configuration Classes

Run build_runner to generate the Envied configuration with obfuscation:
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

This generates `lib/parameters/ads_config.g.dart` with obfuscated ad unit IDs for security.

### 3. Environment File Structure

#### `.env.public` (Committed to Git)
- Contains test/default values
- Uses Google's official test AdMob IDs
- Safe to share publicly
- Serves as documentation for required variables
- **This file IS committed to version control**

#### `.env` (Private, Gitignored)
- Contains your production ad unit IDs
- **Never commit this file to git**
- Created by copying `.env.public`
- Replace placeholders with your real values
- **This file is NOT committed to version control**

### 4. Platform-Specific Setup

#### Android
- Google Play Services dependencies are already configured in `android/app/build.gradle`
- Minimum SDK version: 21 (automatically set by Flutter)

#### iOS
- SKAdNetwork, App Transport Security, and ATT configurations are already set in `ios/Runner/Info.plist`
- Minimum iOS version: 12.0 (Flutter default)

## Architecture

### Components

1. **AdsConfig** (`lib/parameters/ads_config.dart`)
   - Secure environment variable management using Envied
   - Type-safe access to ad configuration

2. **AdBanner** (`lib/widgets/ad_banner.dart`)
   - Reusable banner ad widget
   - Implements AdMob primary and IronSource fallback logic
   - Handles ad lifecycle management

3. **ListPage Integration**
   - Banner ad positioned at bottom of screen
   - Non-intrusive anchored adaptive design
   - Proper spacing for content above

### Ad Flow

1. Check if `ADS_ENABLED=true` in environment configuration
2. If disabled, AdBanner returns empty widget and no space is reserved
3. If enabled, initialize AdMob SDK in `main.dart`
4. AdBanner widget attempts to load AdMob banner
5. If AdMob fails, automatically falls back to IronSource
6. Displays appropriate ad or gracefully hides if both fail
7. ListView automatically adjusts bottom padding based on ad state

## Security Features

### Obfuscation
All sensitive ad unit IDs are obfuscated in the compiled binary using Envied's obfuscation feature:
- AdMob App IDs (Android & iOS)
- AdMob Banner Ad Unit IDs
- IronSource App Keys
- IronSource Banner IDs

This makes it significantly harder to extract your ad credentials from the compiled app.

### Git Security
- `.env` file is in `.gitignore` - never committed
- `.env.public` uses only test values - safe to commit
- Production credentials stay on developer machines and deployment servers only

### Best Practices
1. **Never commit `.env`** - it contains your production secrets
2. **Use `.env.public`** for team collaboration and onboarding
3. **Store production values** in secure password managers (1Password, LastPass, etc.)
4. **Rotate credentials** if you suspect they've been compromised
5. **Use test device IDs** during development to see test ads without affecting metrics

## Environment Variables

### Core Control Variables

| Variable | Description | Values | Default |
|----------|-------------|--------|---------|
| `ADS_ENABLED` | Enable/disable all advertisements | `true` or `false` | `false` |
| `AD_MODE` | Switch between test and production ad IDs | `test` or `production` | `test` |

### Test Ad Configuration (Used when AD_MODE=test)

These use Google's official test ad unit IDs - safe for development:

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `ADMOB_APP_ID_ANDROID` | AdMob Android app ID | `ca-app-pub-3940256099942544~3347511713` |
| `ADMOB_APP_ID_IOS` | AdMob iOS app ID | `ca-app-pub-3940256099942544~1458002511` |
| `ADMOB_ANDROID_BANNER_ID` | AdMob Android banner ID | `ca-app-pub-3940256099942544/9214589741` |
| `ADMOB_IOS_BANNER_ID` | AdMob iOS banner ID | `ca-app-pub-3940256099942544/2435281174` |
| `IRONSOURCE_APP_KEY_ANDROID` | IronSource Android key | `test_android_key` |
| `IRONSOURCE_APP_KEY_IOS` | IronSource iOS key | `test_ios_key` |

### Production Ad Configuration (Used when AD_MODE=production)

These must be updated with YOUR actual ad unit IDs:

| Variable | Description | Example |
|----------|-------------|---------|
| `PRODUCTION_ADMOB_APP_ID_ANDROID` | Your AdMob Android app ID | `ca-app-pub-YOUR_ID~YOUR_APP_ID` |
| `PRODUCTION_ADMOB_APP_ID_IOS` | Your AdMob iOS app ID | `ca-app-pub-YOUR_ID~YOUR_APP_ID` |
| `PRODUCTION_ADMOB_ANDROID_BANNER_ID` | Your Android banner ID | `ca-app-pub-YOUR_ID/YOUR_AD_UNIT` |
| `PRODUCTION_ADMOB_IOS_BANNER_ID` | Your iOS banner ID | `ca-app-pub-YOUR_ID/YOUR_AD_UNIT` |
| `PRODUCTION_IRONSOURCE_APP_KEY_ANDROID` | Your IronSource Android key | `your_production_key` |
| `PRODUCTION_IRONSOURCE_APP_KEY_IOS` | Your IronSource iOS key | `your_production_key` |

### Other Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `ENABLE_DEBUG_LOGGING` | Enable debug logging | `true` |
| `AD_REFRESH_RATE_SECONDS` | Ad refresh interval | `60` |
| `AD_REQUEST_TIMEOUT_SECONDS` | Request timeout | `30` |

## AD_MODE Switching

The app now supports seamless switching between test and production ad IDs:

- **Test Mode** (`AD_MODE=test`): Uses Google's official test ad IDs - perfect for development
- **Production Mode** (`AD_MODE=production`): Uses your real ad unit IDs - for release builds

**See [AD_MODE_GUIDE.md](AD_MODE_GUIDE.md) for detailed instructions on switching modes.**

### Quick Reference

```bash
# Development with test ads
echo "ADS_ENABLED=true" >> .env
echo "AD_MODE=test" >> .env
fvm dart run build_runner build --delete-conflicting-outputs

# Production with real ads
echo "ADS_ENABLED=true" >> .env
echo "AD_MODE=production" >> .env
# Update PRODUCTION_* variables in .env first!
fvm dart run build_runner build --delete-conflicting-outputs
```

## Testing

### Test Ad Unit IDs (Already Configured)

- **AdMob Android Banner**: `ca-app-pub-3940256099942544/9214589741`
- **AdMob iOS Banner**: `ca-app-pub-3940256099942544/2435281174`

### Test Device Setup

1. Run the app and check logs for your device's test ID
2. Add the test device ID to your `.env` file
3. Rebuild the app to see test ads

## Production Deployment

### Enabling Ads for Production

1. Edit your `.env` file (not `.env.public`):
   ```bash
   # Open .env in your editor
   nano .env
   ```

2. Update the configuration:
   - Set `ADS_ENABLED=true`
   - Replace all placeholder IDs (ca-app-pub-XXXXXXXXXXXXXXXX) with your real AdMob IDs
   - Replace IronSource test keys with your production app keys
   - Set `ENABLE_DEBUG_LOGGING=false` for production

3. Regenerate the obfuscated configuration:
   ```bash
   fvm dart run build_runner build --delete-conflicting-outputs
   ```

4. Test thoroughly:
   - Test on physical devices (not just emulators)
   - Verify ads load correctly
   - Check that fallback to IronSource works
   - Monitor logs for any errors

5. **Important**: Verify `.env` is NOT in your git repository:
   ```bash
   git status  # Should NOT show .env
   ```

### Soft Launch (Ads Disabled)

For initial releases without ads (current configuration):
- Keep `ADS_ENABLED=false` in `.env`
- No ad SDKs will initialize
- Zero impact on app performance
- No wasted space at bottom of lists
- Easy to enable later by changing one environment variable and rebuilding

### Deployment Checklist

- [ ] `.env` contains production ad unit IDs
- [ ] `ADS_ENABLED=true` in `.env`
- [ ] `ENABLE_DEBUG_LOGGING=false` in `.env`
- [ ] Regenerated config with `build_runner`
- [ ] Tested on physical Android device
- [ ] Tested on physical iOS device
- [ ] Verified `.env` is not in git (run `git status`)
- [ ] Documented production credentials in team password manager

## Troubleshooting

### Common Issues

1. **Ads not showing**: Check test device IDs and network connection
2. **Build errors**: Ensure all dependencies are installed with `fvm flutter pub get`
3. **Configuration errors**: Regenerate config with `build_runner build`

### Debug Logging

Set `ENABLE_DEBUG_LOGGING=true` in `.env` to see detailed ad loading logs.

## Security Notes

- ⚠️ **The `.env` file contains sensitive ad unit IDs and is excluded from version control**
- 🔒 **Envied provides obfuscation of environment variables in compiled code**
- ✅ **`.env.public` is safe to commit and contains only test values**
- 🚫 **Never commit actual production ad unit IDs to public repositories**
- 🔑 **Store production credentials in a secure password manager**
- 🔄 **Rotate credentials immediately if compromised**

## File Ownership Summary

| File | Git Status | Contains | Purpose |
|------|-----------|----------|---------|
| `.env.public` | ✅ Committed | Test IDs | Developer onboarding, documentation |
| `.env` | ❌ Gitignored | Production IDs | Actual app deployment |
| `.env.example` | ⚠️ Deprecated | - | Replaced by `.env.public` |
| `ads_config.g.dart` | ❌ Gitignored | Generated code | Created by build_runner |

## Dependencies

- `google_mobile_ads: ^6.0.0` - Google Mobile Ads SDK
- `ironsource_mediation: ^3.2.0` - IronSource ad mediation
- `envied: ^0.5.4+1` - Environment variable management
- `envied_generator: ^0.5.4+1` - Code generation for Envied
- `build_runner: ^2.4.8` - Build system for code generation

## Phase Implementation Status

✅ **Phase 1 Complete**: ListPage banner ads with fallback system
🔄 **Phase 2 Planned**: DetailsPage banner ads
🔄 **Phase 3 Optional**: FilterPage banner ads

For questions or issues, refer to the official documentation:
- [AdMob Flutter Guide](https://developers.google.com/admob/flutter)
- [IronSource Flutter Plugin](https://developers.is.com/ironsource-mobile/flutter/flutter-plugin/)