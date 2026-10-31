import 'package:doglist/l10n/gen/app_localizations.dart';
import 'package:doglist/widgets/download_app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('download-app dialog shows the feature message, both stores and closes on OK', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => showDownloadAppDialog(context,
              message: AppLocalizations.of(context)!.crossbreedWebDialogMessage),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Download the App'), findsOneWidget);
    expect(find.textContaining('AI crossbreeds'), findsOneWidget);
    expect(find.text('Google Play Store'), findsOneWidget);
    expect(find.text('Apple App Store'), findsOneWidget);

    await tester.tap(find.byType(TextButton).last);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
