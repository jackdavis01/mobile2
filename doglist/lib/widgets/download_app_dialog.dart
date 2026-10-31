import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../platform/platform_info.dart';

final Uri googlePlayStoreUri = Uri.parse('https://play.google.com/store/apps/details?id=com.proflutter.doglist');
final Uri appleAppStoreUri = Uri.parse('https://apps.apple.com/us/app/dog-list/id6756811861');

/// Shown on web instead of features that need the app (the web build ships no API keys).
/// Keep the button/menu item visible on web and call this from its handler.
Future<void> showDownloadAppDialog(BuildContext context, {required String message}) {
  final l = AppLocalizations.of(context) ?? AppLocalizationsEn();
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l.likeWebDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          ..._storeLinks(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l.likeDialogOk, style: const TextStyle(fontSize: 20)),
        ),
      ],
    ),
  );
}

List<Widget> _storeLinks() {
  const android = 'Google Play Store';
  const ios = 'Apple App Store';
  if (PlatformInfo.isAndroid) {
    return [
      _storeLink(android, googlePlayStoreUri, emphasize: true),
      const SizedBox(height: 8),
      _storeLink(ios, appleAppStoreUri),
    ];
  }
  if (PlatformInfo.isIOS) {
    return [
      _storeLink(ios, appleAppStoreUri, emphasize: true),
      const SizedBox(height: 8),
      _storeLink(android, googlePlayStoreUri),
    ];
  }
  return [
    _storeLink(android, googlePlayStoreUri),
    const SizedBox(height: 8),
    _storeLink(ios, appleAppStoreUri),
  ];
}

Widget _storeLink(String label, Uri uri, {bool emphasize = false}) {
  return Link(
    uri: uri,
    target: LinkTarget.blank,
    builder: (context, followLink) => InkWell(
      onTap: followLink,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          label,
          style: TextStyle(
            fontSize: emphasize ? 20 : 18,
            color: emphasize ? Colors.blue.shade800 : Colors.blue,
            fontWeight: emphasize ? FontWeight.w600 : FontWeight.w400,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
  );
}
