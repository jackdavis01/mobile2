import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/filter_bloc_cubit.dart';
import '../businesslogic/filter_bloc_state.dart';
import '../widgets/filter_expansion_widget.dart';
import '../widgets/spinkitwidgets.dart';
import '../widgets/dog_list_item.dart';
import '../models/dog.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final GlobalKey<FilterExpansionWidgetState> filterKey = GlobalKey<FilterExpansionWidgetState>();

    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, state) {
        // Auto-expand filter section and scroll to Quick Filters if the flag is set
        // This only happens once when the initial quick filter is applied
        if (state.shouldScrollToQuickFilters) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            filterKey.currentState?.expandFilter();
            filterKey.currentState?.scrollToQuickFilters();
            // Clear the flag so it doesn't trigger again
            context.read<FilterCubit>().clearScrollFlag();
          });
        }
        return Scaffold(
            appBar: AppBar(
              title: Text(appLocalizations.filterTitle),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    state.hasActiveFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                    size: 32,
                    color: Colors.blue[800],
                  ),
                  onPressed: () {
                    filterKey.currentState?.toggleExpansion();
                  },
                ),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate 1/2 of the available height for the filter expansion widget
                final filterMaxHeight = (constraints.maxHeight * 1 / 2);
                
                return Column(
                  children: [
                    // Permanent stripe showing match count
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        state.isSearchQueryValid || state.searchQuery.isEmpty
                            ? appLocalizations.filterMatchesCount(state.matchCount)
                            : appLocalizations.filterErrorMinLength,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: state.showValidationError ? Colors.red : Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Filter expansion widget with calculated height
                    FilterExpansionWidget(
                      key: filterKey,
                      maxHeight: filterMaxHeight,
                    ),
                
                    // Divider
                    const Divider(height: 1),
                    
                    // Results list
                    Expanded(
                      child: _buildResultsList(context, state, appLocalizations),
                    ),
                  ],
                );
              },
            ),
          );
      },
    );
  }

  Widget _buildResultsList(BuildContext context, FilterState state, AppLocalizations appLocalizations) {
    if (state.isLoading) {
      return const Center(child: CustomSpinKitThreeInOut());
    }

    if (state.hasError) {
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
            ElevatedButton(
              onPressed: () => context.read<FilterCubit>().reloadData(),
              child: Text(appLocalizations.reloadButton),
            ),
          ],
        ),
      );
    }

    if (state.showValidationError) {
      return SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  appLocalizations.filterErrorMinLength,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.filteredDogs.isEmpty && state.searchQuery.isNotEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  appLocalizations.filterMatchesCount(0),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: state.filteredDogs.length,
      itemBuilder: (context, index) {
        final Dog dog = state.filteredDogs[index];
        return _buildDogListTile(context, dog, index, state.filteredDogs);
      },
    );
  }

  Widget _buildDogListTile(BuildContext context, Dog dog, int index, List<Dog> filteredDogs) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, state) {
        final bool isFavorite = state.favorites.any((fav) => fav.id == dog.id);
        
        return DogListItem(
          dog: dog,
          isFavorite: isFavorite,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          imageSize: 72.0,
          onFavoritePressed: () => context.read<FilterCubit>().toggleFavorite(dog.id),
          onTap: () async {
            // Navigate to details page with all filtered dogs and correct index
            final filterCubit = context.read<FilterCubit>();
            final navigator = Navigator.of(context);
            final focusScope = FocusScope.of(context);
            
            // Check if any text field currently has focus (indicating keyboard is open)
            final hasFocus = focusScope.hasFocus;
            
            // Dismiss keyboard
            focusScope.unfocus();
            
            // Wait for keyboard to actually disappear if it was open
            if (hasFocus) {
              // Wait for focus to be released
              var attempts = 0;
              while (focusScope.hasFocus && attempts < 50) {
                await Future.delayed(const Duration(milliseconds: 16));
                if (!context.mounted) return;
                attempts++;
              }
              
              // Additional wait for layout stabilization after keyboard dismissal
              // This prevents the 50px jump by ensuring the viewport is fully settled
              await Future.delayed(const Duration(milliseconds: 200));
            }

            // Check if widget is still mounted before navigation
            if (!context.mounted) return;
        
            await navigator.pushNamed(
              '/details',
              arguments: {
                'dogs': filteredDogs, // Pass all filtered dogs
                'index': index, // Pass the actual index of tapped dog in filtered list
              },
            );
            // Refresh favorites when returning from DetailsPage
            filterCubit.refreshFavorites();
          },
        );
      },
    );
  }
}