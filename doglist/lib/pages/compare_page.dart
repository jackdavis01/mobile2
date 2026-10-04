import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/compare_bloc_cubit.dart';
import '../businesslogic/compare_bloc_state.dart';
import '../businesslogic/like_bloc_cubit.dart';
import '../models/compare_sort_order.dart';
import '../models/dog.dart';
import '../repositories/dogs_data_repository.dart';
import '../widgets/dog_list_item.dart';
import '../widgets/spinkitwidgets.dart';
import '../widgets/ad_banner.dart';

/// Compare selection page: users pin exactly 2 breeds, then open the
/// side-by-side comparison via the floating action button.
class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final DogsDataRepository _repository = DogsDataRepository();
  List<Dog> _dogs = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadDogs();
    context.read<LikeCubit>().loadAllLikeCounts();
  }

  Future<void> _loadDogs() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final dogs = await _repository.getDogs();
      if (!mounted) return;
      setState(() {
        _dogs = dogs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Future<void> _handleToggle(String dogId) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final success = await context.read<CompareCubit>().togglePin(dogId);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.compareMaxReached),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSortOptions() {
    final compareCubit = context.read<CompareCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => BlocProvider.value(
        value: compareCubit,
        child: BlocBuilder<CompareCubit, CompareState>(
          builder: (context, state) {
            final appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
            final directionLabels = switch (state.sortOrder) {
              CompareSortOrder.unsorted || CompareSortOrder.alphabetical => (
                  ascending: appLocalizations.compareSortNamesAscending,
                  descending: appLocalizations.compareSortNamesDescending,
                ),
              CompareSortOrder.likes => (
                  ascending: appLocalizations.compareSortLikesAscending,
                  descending: appLocalizations.compareSortLikesDescending,
                ),
              CompareSortOrder.size => (
                  ascending: appLocalizations.compareSortSizeAscending,
                  descending: appLocalizations.compareSortSizeDescending,
                ),
            };

            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(appLocalizations.compareSortTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    RadioGroup<CompareSortOrder>(
                      groupValue: state.sortOrder,
                      onChanged: (order) {
                        if (order != null) compareCubit.setSortOrder(order);
                      },
                      child: Column(
                        children: [
                          for (final order in CompareSortOrder.values)
                            RadioListTile<CompareSortOrder>(
                              value: order,
                              contentPadding: EdgeInsets.zero,
                              title: Text(switch (order) {
                                CompareSortOrder.unsorted => appLocalizations.compareSortUnsorted,
                                CompareSortOrder.alphabetical => appLocalizations.compareSortAlphabetical,
                                CompareSortOrder.likes => appLocalizations.compareSortLikes,
                                CompareSortOrder.size => appLocalizations.size,
                              }),
                            ),
                        ],
                      ),
                    ),
                    if (state.sortOrder != CompareSortOrder.unsorted) ...[
                      const SizedBox(height: 12),
                      SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(
                            value: true,
                            icon: const Icon(Icons.arrow_upward),
                            label: Text(directionLabels.ascending),
                          ),
                          ButtonSegment(
                            value: false,
                            icon: const Icon(Icons.arrow_downward),
                            label: Text(directionLabels.descending),
                          ),
                        ],
                        selected: {state.sortAscending},
                        onSelectionChanged: (selection) {
                          compareCubit.setSortOrder(state.sortOrder, ascending: selection.single);
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        style: TextButton.styleFrom(textStyle: const TextStyle(fontSize: 18)),
                        onPressed: () => Navigator.pop(context),
                        child: Text(appLocalizations.compareSortDone),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.compareTitle),
        centerTitle: true,
        actions: [
          BlocBuilder<CompareCubit, CompareState>(
            builder: (context, state) => IconButton(
              tooltip: appLocalizations.compareSortTitle,
              icon: const Icon(Icons.sort),
              color: state.sortOrder == CompareSortOrder.unsorted ? null : Theme.of(context).colorScheme.primary,
              onPressed: _showSortOptions,
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<CompareCubit, CompareState>(
        builder: (context, state) {
          if (!state.hasTwoPinned || _dogs.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/compare-details', arguments: {'dogs': _dogs}),
            icon: const Icon(Icons.compare_arrows),
            label: Text(appLocalizations.compareButton),
          );
        },
      ),
      body: _buildBody(appLocalizations),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [AdBanner()],
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations appLocalizations) {
    if (_loading) return const CustomSpinKitThreeInOut();

    if (_error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                appLocalizations.internetConnectionError,
                style: const TextStyle(fontSize: 18, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDogs, child: Text(appLocalizations.reloadButton)),
          ],
        ),
      );
    }

    return BlocBuilder<CompareCubit, CompareState>(
      builder: (context, state) {
        final likeCounts = context.select((LikeCubit cubit) => cubit.state.likeCounts);
        final pinnedDogs = [
          for (final dogId in state.pinnedIds)
            for (final dog in _dogs)
              if (dog.id == dogId) dog,
        ];
        final unpinnedDogs = state.sortOrder.sortDogs(
          _dogs.where((dog) => !state.pinnedIds.contains(dog.id)),
          ascending: state.sortAscending,
          likeCounts: likeCounts,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                appLocalizations.compareInstructions,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
            ),
            for (final dog in pinnedDogs) _buildDogItem(dog, isPinned: true),
            if (pinnedDogs.isNotEmpty)
              Divider(
                height: 16,
                thickness: 1,
                indent: 12,
                endIndent: 12,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            Expanded(
              child: ListView.builder(
                key: ValueKey((state.sortOrder, state.sortAscending)),
                padding: MediaQuery.of(context).padding.bottom > 0
                    ? EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom)
                    : EdgeInsets.zero,
                itemCount: unpinnedDogs.length,
                itemBuilder: (context, index) {
                  return _buildDogItem(unpinnedDogs[index], isPinned: false);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDogItem(Dog dog, {required bool isPinned}) {
    return DogListItem(
      key: ValueKey(dog.id),
      dog: dog,
      type: DogListItemType.compare,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      imageSize: 72.0,
      isPinned: isPinned,
      onPinToggled: () => _handleToggle(dog.id),
      onTap: () => _handleToggle(dog.id),
    );
  }
}
