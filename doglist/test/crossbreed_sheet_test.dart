import 'package:doglist/widgets/crossbreed_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sheet bottom padding keeps 36 on iPhone and clears taller Android navigation bars', () {
    expect(crossbreedSheetBottomPadding(0), 36);
    expect(crossbreedSheetBottomPadding(34), 36);
    expect(crossbreedSheetBottomPadding(48), 60);
  });

  testWidgets('a safe-area modal sheet still reports the bottom system inset', (tester) async {
    double? seen;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(400, 900),
          padding: EdgeInsets.only(top: 40, bottom: 48),
          viewPadding: EdgeInsets.only(top: 40, bottom: 48),
        ),
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                showDragHandle: true,
                builder: (context) {
                  seen = MediaQuery.viewPaddingOf(context).bottom;
                  return const SizedBox(height: 100);
                },
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(seen, 48);
    expect(crossbreedSheetBottomPadding(seen!), 60);
  });
}
