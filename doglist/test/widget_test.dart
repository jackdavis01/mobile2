// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:doglist/app.dart';
import 'package:doglist/businesslogic/compare_bloc_cubit.dart';
import 'package:doglist/businesslogic/like_bloc_cubit.dart';
import 'package:doglist/models/compare_sort_order.dart';
import 'package:doglist/models/dog.dart';
import 'package:doglist/pages/compare_page.dart';
import 'package:doglist/pages/compare_details_page.dart';
import 'package:doglist/pages/onboarding_page.dart';
import 'package:doglist/platform/platform_info.dart';
import 'package:doglist/repositories/compare_repository.dart';
import 'package:doglist/widgets/ad_banner.dart';
import 'package:doglist/widgets/dog_list_item.dart';
import 'package:doglist/widgets/onboarding_feature_item.dart';
import 'package:doglist/widgets/onboarding_screen_compare.dart';
import 'package:doglist/widgets/onboarding_screen_6_navigation.dart';
import 'package:doglist/widgets/onboarding_screen_7_settings.dart';
import 'package:doglist/widgets/onboarding_screen_top_dogs.dart';
import 'package:doglist/widgets/rating_bar_widget.dart';

void main() {
  testWidgets('Dog List test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DogListApp());

  });

  testWidgets('Onboarding orders platform-available ranking and compare slides', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));

    final delegate = tester.widget<PageView>(find.byType(PageView)).childrenDelegate as SliverChildListDelegate;
    final pages = delegate.children;
    final topDogsIndex = pages.indexWhere((page) => page is OnboardingScreenTopDogs);
    final compareIndex = pages.indexWhere((page) => page is OnboardingScreenCompare);
    final navigationIndex = pages.indexWhere((page) => page is OnboardingScreen6Navigation);
    final settingsIndex = pages.indexWhere((page) => page is OnboardingScreen7Settings);

    expect(pages.length, PlatformInfo.isWeb ? 9 : 10);
    expect(topDogsIndex, PlatformInfo.isWeb ? -1 : 2);
    expect(compareIndex, greaterThan(navigationIndex));
    expect(compareIndex, lessThan(settingsIndex));
  });

  testWidgets('Onboarding feature rows remain centered on narrow phones', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(280, 720);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));
    final slideCount = tester
        .widget<PageView>(find.byType(PageView))
        .childrenDelegate
        .estimatedChildCount!;
    final checkedLabels = <String>{};
    const wrappedLabels = ['Your selected Best Dog', 'Tap a photo to open breed details'];

    for (var slide = 0; slide < slideCount; slide++) {
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Onboarding slide ${slide + 1} should fit at 280px width');
      for (final label in wrappedLabels) {
        final finder = find.text(label);
        if (finder.evaluate().isNotEmpty) {
          expect(tester.widget<Text>(finder).textAlign, TextAlign.center, reason: 'Wrapped label should stay centered: $label');
          final feature = find.ancestor(of: finder, matching: find.byType(OnboardingFeatureItem)).first;
          final icon = label == 'Your selected Best Dog' ? Icons.star : Icons.photo_library_outlined;
          final iconRect = tester.getRect(find.descendant(of: feature, matching: find.byIcon(icon)));
          final textRect = tester.getRect(finder);
          final paragraph = tester.renderObject<RenderParagraph>(find.descendant(of: finder, matching: find.byType(RichText)));
            final paintedTextRect = RegExp(r'\S+')
              .allMatches(label)
              .expand((word) => paragraph.getBoxesForSelection(TextSelection(baseOffset: word.start, extentOffset: word.end)))
              .map((box) => box.toRect().shift(paragraph.localToGlobal(Offset.zero)))
              .reduce((bounds, box) => bounds.expandToInclude(box));
          expect(iconRect.right, lessThanOrEqualTo(textRect.left));
          expect(
            paintedTextRect.left - iconRect.right,
            closeTo(12, 1),
            reason: 'Icon should stay beside the visible text: $label',
          );
          expect(
            iconRect.expandToInclude(paintedTextRect).center.dx,
            closeTo(tester.view.physicalSize.width / 2, 1),
            reason: 'Icon and wrapped text should center as one group: $label',
          );
          checkedLabels.add(label);
        }
      }
      if (slide + 1 < slideCount) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
    }

    expect(checkedLabels, wrappedLabels.toSet());
  });

  test('Comparison sort modes use their defaults and reverse without changing ties or source order', () {
    final dogs = [
      Dog.fromMap(_testBreedData(0, name: 'Zulu', size: 2)),
      Dog.fromMap(_testBreedData(1, name: 'alpha', size: 4)),
      Dog.fromMap(_testBreedData(2, name: 'Bravo', size: 1)),
      Dog.fromMap(_testBreedData(3, name: 'bravo', size: 4)),
    ];
    final originalIds = dogs.map((dog) => dog.id).toList();
    const likeCounts = {'breed-0': 2, 'breed-1': 8, 'breed-2': 8};

    List<String> sortedIds(CompareSortOrder order, {bool? ascending}) => order
        .sortDogs(dogs, ascending: ascending, likeCounts: likeCounts)
        .map((dog) => dog.id)
        .toList();

    expect(sortedIds(CompareSortOrder.unsorted), originalIds);
    expect(sortedIds(CompareSortOrder.unsorted, ascending: false), originalIds);
    expect(sortedIds(CompareSortOrder.alphabetical), ['breed-1', 'breed-2', 'breed-3', 'breed-0']);
    expect(sortedIds(CompareSortOrder.alphabetical, ascending: false), ['breed-0', 'breed-2', 'breed-3', 'breed-1']);
    expect(sortedIds(CompareSortOrder.likes), ['breed-1', 'breed-2', 'breed-0', 'breed-3']);
    expect(sortedIds(CompareSortOrder.likes, ascending: true), ['breed-3', 'breed-0', 'breed-1', 'breed-2']);
    expect(sortedIds(CompareSortOrder.size), ['breed-2', 'breed-0', 'breed-1', 'breed-3']);
    expect(sortedIds(CompareSortOrder.size, ascending: false), ['breed-1', 'breed-3', 'breed-0', 'breed-2']);
    expect(dogs.map((dog) => dog.id).toList(), originalIds);
  });

  test('Comparison sort preferences restore both mode and direction', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await CompareRepository().getSort(), (order: CompareSortOrder.unsorted, ascending: true));

    for (final order in CompareSortOrder.values) {
      for (final ascending in [true, false]) {
        await CompareRepository().saveSort(order, ascending);
        expect(await CompareRepository().getSort(), (order: order, ascending: ascending));
      }
    }

    for (final invalid in ['not json', '[]', '{"order":"unknown","ascending":false}']) {
      SharedPreferences.setMockInitialValues({'compare_sort_settings': invalid});
      expect(await CompareRepository().getSort(), (order: CompareSortOrder.unsorted, ascending: true));
    }
  });

  testWidgets('Comparison rating bars fill both padded columns', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final pageWidth in [320.0, 390.0, 1024.0]) {
      tester.view.physicalSize = Size(pageWidth, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                for (final rating in [4, 1])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: RatingBarWidget(label: '', rating: rating, colorMode: RatingColorMode.reversed),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

      final bars = find.byType(LinearProgressIndicator);
      expect(bars, findsNWidgets(2));
      for (final bar in bars.evaluate()) {
        expect(tester.getSize(find.byWidget(bar.widget)).width, closeTo(pageWidth / 2 - 24, 0.01));
      }
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Very Low'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Comparison photos open the selected breed in the existing details route',
      (WidgetTester tester) async {
    final dogs = [
      Dog.fromMap(_testBreedData(0, name: 'Breed 0')),
      Dog.fromMap(_testBreedData(1, name: 'Breed 1')),
    ];
    SharedPreferences.setMockInitialValues({
      'compare_pinned_ids': ['breed-1', 'breed-0'],
      'dogs_json_data': jsonEncode(dogs.map((dog) => dog.toMap()).toList()),
      'dogs_json_expiry': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
      'cache_version': 3,
    });
    final compareCubit = CompareCubit();
    final observer = _RouteObserver();

    await tester.pumpWidget(
      BlocProvider<CompareCubit>.value(
        value: compareCubit,
        child: MaterialApp(
          navigatorObservers: [observer],
          onGenerateRoute: (settings) {
            if (settings.name == '/compare-details') {
              return MaterialPageRoute<void>(
                settings: RouteSettings(name: settings.name, arguments: {'dogs': dogs}),
                builder: (_) => const CompareDetailsPage(),
              );
            }
            if (settings.name == '/details') {
              final args = settings.arguments! as Map<String, dynamic>;
              final selectedDog = (args['dogs'] as List<Dog>)[args['index'] as int];
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => Scaffold(body: Text('Details page: ${selectedDog.id}')),
              );
            }
            return null;
          },
          initialRoute: '/compare-details',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const ValueKey('breed-photo-breed-1')));
    await tester.pumpAndSettle();

    expect(observer.lastRouteName, '/details');
    expect(observer.lastArguments, isA<Map<String, dynamic>>());
    final args = observer.lastArguments! as Map<String, dynamic>;
    expect((args['dogs'] as List<Dog>).map((dog) => dog.id), ['breed-0', 'breed-1']);
    expect(args['index'], 1);
    expect(find.text('Details page: breed-1'), findsOneWidget);
  });

  testWidgets('Labelled rating bars keep their inline layout', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RatingBarWidget(label: 'Shedding Amount', rating: 4, colorMode: RatingColorMode.reversed),
        ),
      ),
    );

    final labelRect = tester.getRect(find.text('Shedding Amount'));
    final barRect = tester.getRect(find.byType(LinearProgressIndicator));
    final ratingTextRect = tester.getRect(find.text('High'));
    expect(barRect.left, greaterThan(labelRect.right));
    expect(barRect.right, lessThan(ratingTextRect.left));
    expect(barRect.center.dy, closeTo(ratingTextRect.center.dy, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sort sheet changes all unpinned orders while keeping pinned cards fixed',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final viewport in [const Size(320, 568), const Size(844, 390)]) {
      tester.view.physicalSize = viewport;
      final compareCubit = await _pumpComparePage(
        tester,
        pinnedIds: ['breed-5', 'breed-4'],
        breeds: [
          _testBreedData(0, name: 'Zulu', size: 2),
          _testBreedData(1, name: 'alpha', size: 4),
          _testBreedData(2, name: 'Bravo', size: 1),
          _testBreedData(3, name: 'bravo', size: 4),
          _testBreedData(4, name: 'Pinned Second', size: 5),
          _testBreedData(5, name: 'Pinned First', size: 1),
        ],
        likeCounts: const {'breed-0': 2, 'breed-1': 8, 'breed-2': 8},
      );
      final originalOrder = ['breed-0', 'breed-1', 'breed-2', 'breed-3'];
      final firstPinned = find.byKey(const ValueKey('breed-5'));
      final secondPinned = find.byKey(const ValueKey('breed-4'));
      final firstPinnedRect = tester.getRect(firstPinned);
      final secondPinnedRect = tester.getRect(secondPinned);
      final likeCubit = tester.element(find.byType(ComparePage)).read<LikeCubit>() as _TestLikeCubit;
      expect(likeCubit.loadRequests, 1);
      expect(compareCubit.state.sortOrder, CompareSortOrder.unsorted);
      _expectUnpinnedOrder(tester, originalOrder);

      await _chooseComparisonSort(tester, 'Alphabetical');
      expect(compareCubit.state.sortAscending, isTrue);
      _expectUnpinnedOrder(tester, ['breed-1', 'breed-2', 'breed-3', 'breed-0']);
      await _chooseComparisonSort(tester, 'Alphabetical', direction: 'Z-A');
      _expectUnpinnedOrder(tester, ['breed-0', 'breed-2', 'breed-3', 'breed-1']);

      await _chooseComparisonSort(tester, 'Number of likes');
      expect(compareCubit.state.sortAscending, isFalse);
      _expectUnpinnedOrder(tester, ['breed-1', 'breed-2', 'breed-0', 'breed-3']);
      await _chooseComparisonSort(tester, 'Number of likes', direction: 'Fewest first');
      _expectUnpinnedOrder(tester, ['breed-3', 'breed-0', 'breed-1', 'breed-2']);

      await _chooseComparisonSort(tester, 'Size');
      expect(compareCubit.state.sortAscending, isTrue);
      _expectUnpinnedOrder(tester, ['breed-2', 'breed-0', 'breed-1', 'breed-3']);
      await _chooseComparisonSort(tester, 'Size', direction: 'Largest first');
      _expectUnpinnedOrder(tester, ['breed-1', 'breed-3', 'breed-0', 'breed-2']);

      await _chooseComparisonSort(tester, 'Unsorted');
      _expectUnpinnedOrder(tester, originalOrder);
      await _chooseComparisonSort(tester, 'Number of likes');
      for (var count = 0; count < 7; count++) {
        likeCubit.incrementLikeCountOptimistically('breed-0');
      }
      await tester.pump();
      _expectUnpinnedOrder(tester, ['breed-0', 'breed-1', 'breed-2', 'breed-3']);
      expect(compareCubit.state.pinnedIds, ['breed-5', 'breed-4']);
      expect(tester.getRect(firstPinned), firstPinnedRect);
      expect(tester.getRect(secondPinned), secondPinnedRect);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('Saved sorting restores the list and controls after restarting comparison',
      (WidgetTester tester) async {
    await _pumpComparePage(
      tester,
      pinnedIds: ['breed-2'],
      breeds: [
        _testBreedData(0, name: 'Zulu', size: 1),
        _testBreedData(1, name: 'Alpha', size: 4),
        _testBreedData(2, name: 'Pinned breed', size: 3),
        _testBreedData(3, name: 'Bravo', size: 2),
      ],
    );
    await _chooseComparisonSort(tester, 'Size', direction: 'Largest first');
    _expectUnpinnedOrder(tester, ['breed-1', 'breed-3', 'breed-0']);
    await tester.pumpWidget(const SizedBox.shrink());

    final restored = await _pumpComparePage(tester, resetPreferences: false);
    expect(restored.state.sortOrder, CompareSortOrder.size);
    expect(restored.state.sortAscending, isFalse);
    expect(restored.state.pinnedIds, ['breed-2']);
    _expectUnpinnedOrder(tester, ['breed-1', 'breed-3', 'breed-0']);

    await tester.tap(find.byTooltip('Sort breeds'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.widget<RadioGroup<CompareSortOrder>>(find.byType(RadioGroup<CompareSortOrder>)).groupValue,
        CompareSortOrder.size);
    expect(tester.widget<SegmentedButton<bool>>(find.byType(SegmentedButton<bool>)).selected, {false});
    await tester.ensureVisible(find.text('Done'));
    await tester.tap(find.text('Done'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.descendant(
      of: find.byKey(const ValueKey('breed-2')),
      matching: find.byIcon(Icons.push_pin),
    ));
    await tester.pump();
    _expectUnpinnedOrder(tester, ['breed-1', 'breed-2', 'breed-3', 'breed-0']);
    expect(await CompareRepository().getSort(), (order: CompareSortOrder.size, ascending: false));

    await _chooseComparisonSort(tester, 'Unsorted');
    _expectUnpinnedOrder(tester, ['breed-0', 'breed-1', 'breed-2', 'breed-3']);
    expect(await CompareRepository().getSort(), (order: CompareSortOrder.unsorted, ascending: true));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Pinned breeds stay fixed while the remaining list scrolls', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    for (final viewport in [const Size(320, 568), const Size(844, 390)]) {
      tester.view.physicalSize = viewport;
      final compareCubit = await _pumpComparePage(tester);
      final breedList = find.byType(ListView);
      final firstPinned = find.byKey(const ValueKey('breed-1'));
      final secondPinned = find.byKey(const ValueKey('breed-0'));
      final divider = find.byType(Divider);

      expect(divider, findsNothing);

      await tester.tap(find.text('Breed 1'));
      await tester.pump();
      expect(divider, findsOneWidget);
      await tester.tap(find.text('Breed 0'));
      await tester.pump();

      expect(compareCubit.state.pinnedIds, ['breed-1', 'breed-0']);
      expect(divider, findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.descendant(of: breedList, matching: firstPinned), findsNothing);
      expect(find.descendant(of: breedList, matching: secondPinned), findsNothing);
      final firstPinnedRect = tester.getRect(firstPinned);
      final secondPinnedRect = tester.getRect(secondPinned);
      final dividerRect = tester.getRect(divider);
      expect(firstPinnedRect.bottom, lessThanOrEqualTo(secondPinnedRect.top));
      expect(secondPinnedRect.bottom, lessThanOrEqualTo(dividerRect.top));
      expect(dividerRect.bottom, lessThanOrEqualTo(tester.getRect(breedList).top));

      await tester.drag(breedList, const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 300));

      final scrollState = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollState.position.pixels, greaterThan(0));
      expect(tester.getRect(firstPinned), firstPinnedRect);
      expect(tester.getRect(secondPinned), secondPinnedRect);
      expect(tester.getRect(divider), dividerRect);

      await tester.tap(find.descendant(of: firstPinned, matching: find.byIcon(Icons.push_pin)));
      await tester.pump();
      expect(compareCubit.state.pinnedIds, ['breed-0']);
      expect(divider, findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);

      await tester.tap(find.descendant(of: secondPinned, matching: find.byIcon(Icons.push_pin)));
      await tester.pump();
      scrollState.position.jumpTo(0);
      await tester.pump();

      expect(compareCubit.state.pinnedIds, isEmpty);
      expect(divider, findsNothing);
      final visibleBreeds = tester.widgetList<DogListItem>(
        find.descendant(of: breedList, matching: find.byType(DogListItem)),
      );
      expect(visibleBreeds.take(2).map((item) => item.dog.id).toList(), ['breed-0', 'breed-1']);
      expect(visibleBreeds.every((item) => !item.isPinned), isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('Compare button stays above changing banner heights and bottom safe area',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.padding = const FakeViewPadding(bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await _pumpComparePage(tester, pinnedIds: ['breed-0', 'breed-1']);
    final banner = find.byType(AdBanner);
    final button = find.byType(FloatingActionButton);
    final bannerPlaceholder = tester.renderObject<RenderConstrainedBox>(
      find.descendant(of: banner, matching: find.byType(SizedBox)),
    );

    for (final adHeight in [0.0, 50.0, 90.0, 50.0, 0.0]) {
      final bannerHeight = adHeight == 0 ? 0.0 : adHeight + 34;
      bannerPlaceholder.additionalConstraints = BoxConstraints.tightFor(height: bannerHeight);
      await tester.pump();

      final bannerRect = tester.getRect(banner);
      final buttonRect = tester.getRect(button);
      expect(bannerRect.height, bannerHeight);
      expect(buttonRect.bottom, lessThanOrEqualTo(bannerRect.top - 16));
      expect(tester.getRect(find.byType(ListView)).bottom, lessThanOrEqualTo(bannerRect.top));
      expect(button.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Saved pins appear above the list in pin order and keep the two-breed limit',
      (WidgetTester tester) async {
    final compareCubit = await _pumpComparePage(tester, pinnedIds: ['breed-7', 'breed-2']);
    final breedList = find.byType(ListView);
    final firstPinned = find.byKey(const ValueKey('breed-7'));
    final secondPinned = find.byKey(const ValueKey('breed-2'));

    expect(firstPinned, findsOneWidget);
    expect(secondPinned, findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
    expect(tester.getRect(firstPinned).bottom, lessThanOrEqualTo(tester.getRect(secondPinned).top));
    expect(tester.getRect(secondPinned).bottom, lessThanOrEqualTo(tester.getRect(breedList).top));
    expect(find.descendant(of: breedList, matching: firstPinned), findsNothing);
    expect(find.descendant(of: breedList, matching: secondPinned), findsNothing);

    await tester.tap(find.text('Breed 0'));
    await tester.pump();

    expect(compareCubit.state.pinnedIds, ['breed-7', 'breed-2']);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Third-pin snackbar stays above the system bar and lifts the Compare button',
      (WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 800);
    tester.view.padding = const FakeViewPadding(bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await _pumpComparePage(tester, pinnedIds: ['breed-0', 'breed-1']);
    final compareButton = find.byType(FloatingActionButton);
    final buttonBeforeSnackbar = tester.getRect(compareButton);

    await tester.tap(find.text('Breed 2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final snackbarRect = tester.getRect(find.byType(SnackBar));
    final buttonWithSnackbar = tester.getRect(compareButton);
    expect(snackbarRect.bottom, lessThanOrEqualTo(800 - 34));
    expect(buttonWithSnackbar.bottom, lessThanOrEqualTo(snackbarRect.top));
    expect(buttonWithSnackbar.top, lessThan(buttonBeforeSnackbar.top));
    expect(compareButton.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<CompareCubit> _pumpComparePage(
  WidgetTester tester, {
  List<String> pinnedIds = const [],
  List<Map<String, dynamic>>? breeds,
  Map<String, int> likeCounts = const {},
  bool resetPreferences = true,
}) async {
  if (resetPreferences) {
    SharedPreferences.setMockInitialValues({
      'compare_pinned_ids': pinnedIds,
      'dogs_json_data': jsonEncode(breeds ?? List.generate(20, (index) => _testBreedData(index))),
      'dogs_json_expiry': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
      'cache_version': 3,
    });
  }
  final compareCubit = CompareCubit();
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<CompareCubit>(create: (_) => compareCubit),
        BlocProvider<LikeCubit>(create: (_) => _TestLikeCubit(likeCounts)),
      ],
      child: const MaterialApp(home: ComparePage()),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return compareCubit;
}

List<String> _visibleUnpinnedIds(WidgetTester tester) => tester
    .widgetList<DogListItem>(find.descendant(of: find.byType(ListView), matching: find.byType(DogListItem)))
    .map((item) => item.dog.id)
    .toList();

void _expectUnpinnedOrder(WidgetTester tester, List<String> expectedIds) {
  final visibleIds = _visibleUnpinnedIds(tester);
  expect(visibleIds, isNotEmpty);
  expect(visibleIds, expectedIds.take(visibleIds.length).toList());
}

Future<void> _chooseComparisonSort(WidgetTester tester, String mode, {String? direction}) async {
  await tester.tap(find.byTooltip('Sort breeds'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  double renderedFontSize(String label) => tester
      .renderObject<RenderParagraph>(find.descendant(of: find.text(label), matching: find.byType(RichText)))
      .text.style!.fontSize!;
  expect(renderedFontSize('Done'), greaterThan(renderedFontSize('Unsorted')));
  expect(renderedFontSize('Done'), lessThan(renderedFontSize('Sort breeds')));
  await tester.ensureVisible(find.text(mode));
  await tester.tap(find.text(mode));
  await tester.pump();
  if (mode == 'Unsorted') expect(find.byType(SegmentedButton<bool>), findsNothing);
  if (direction != null) {
    await tester.ensureVisible(find.text(direction));
    await tester.tap(find.text(direction));
    await tester.pump();
  }
  await tester.ensureVisible(find.text('Done'));
  await tester.tap(find.text('Done'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

class _TestLikeCubit extends LikeCubit {
  int loadRequests = 0;

  _TestLikeCubit(Map<String, int> likeCounts) {
    emit(state.copyWith(likeCounts: Map.of(likeCounts)));
  }

  @override
  Future<void> loadAllLikeCounts() async {
    loadRequests++;
  }

  @override
  void queueLikeCountRefresh(String dogId) {}
}

Map<String, dynamic> _testBreedData(int index, {String? name, int size = 3}) => {
  'id': 'breed-$index',
  'general': {'name': name ?? 'Breed $index', 'personalityTraits': <String>[]},
  'physical': {'coatStyle': 'Short', 'coatTexture': 'Smooth', 'size': size},
  'behavior': <String, dynamic>{},
  'care': <String, dynamic>{},
  'images': {
    'small': {'outdoors': 'breed-$index.jpg'},
    'large': {'outdoors': 'breed-$index.jpg', 'indoors': 'breed-$index.jpg', 'studio': 'breed-$index.jpg'},
  },
};

class _RouteObserver extends NavigatorObserver {
  String? lastRouteName;
  Object? lastArguments;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastRouteName = route.settings.name;
    lastArguments = route.settings.arguments;
  }
}
