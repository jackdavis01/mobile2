# Advertisement Toggle Quick Guide

## Current Status
✅ **Advertisements are DISABLED** for the first release

## How to Enable Ads

### Step 1: Update .env file
Change the `ADS_ENABLED` flag from `false` to `true`:

```env
# Advertisement Control
ADS_ENABLED=true
```

### Step 2: Regenerate Configuration
Run the build_runner to update the generated configuration:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

### Step 3: Rebuild the App
For Android:
```bash
fvm flutter build apk --release
```

For iOS:
```bash
fvm flutter build ipa --release
```

## How to Disable Ads

### Quick Disable
Simply set `ADS_ENABLED=false` in your `.env` file and rebuild:

```env
# Advertisement Control
ADS_ENABLED=false
```

Then regenerate and rebuild as shown above.

## What Happens When Ads Are Disabled?

- ✅ No ad SDKs are initialized (zero performance impact)
- ✅ No network calls to ad networks
- ✅ No ad space is reserved in the UI
- ✅ App behaves as if ad code doesn't exist
- ✅ Perfect for soft launches or ad-free versions

## What Happens When Ads Are Enabled?

- 📱 AdMob SDK initializes on app start
- 📱 IronSource SDK initializes as fallback
- 📱 Banner ads load at bottom of ListPage
- 📱 AdMob shown first, IronSource as fallback
- 📱 Ads refresh based on configuration

## Testing

### Test with Ads Disabled (Current)
```bash
# Already configured - just build and run
fvm flutter run
```

### Test with Ads Enabled
1. Set `ADS_ENABLED=true` in `.env`
2. Run: `fvm dart run build_runner build --delete-conflicting-outputs`
3. Run: `fvm flutter run`
4. Look for test ads at bottom of dog list

## Production Checklist

### For First Release (No Ads)
- [x] `ADS_ENABLED=false` in .env
- [x] Configuration generated
- [x] Release build tested
- [x] Ready to deploy!

### For Future Release (With Ads)
- [ ] Replace test ad IDs with production IDs in .env
- [ ] Set `ADS_ENABLED=true` in .env
- [ ] Set `ENABLE_DEBUG_LOGGING=false` in .env
- [ ] Run `fvm dart run build_runner build --delete-conflicting-outputs`
- [ ] Test on physical devices
- [ ] Build release version
- [ ] Deploy

## Benefits of This Approach

1. **Flexible Monetization**: Enable ads anytime without code changes
2. **A/B Testing**: Easy to test ad-free vs ad-supported versions
3. **Soft Launch**: Launch without ads, enable later when ready
4. **Emergency Disable**: Quickly disable ads if issues arise
5. **Clean Code**: Ad logic isolated and toggleable

## Notes

- Configuration is compiled into the app at build time
- Changes to `.env` require rebuilding the app
- `.env` file is not committed to version control (security)
- Different environments can have different settings