import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/filter_bloc_cubit.dart';
import '../businesslogic/filter_bloc_state.dart';
import '../widgets/filter_expansion_widget.dart';
import '../widgets/spinkitwidgets.dart';
import '../models/dog.dart';
import '../parameters/netservices.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final GlobalKey<FilterExpansionWidgetState> filterKey = GlobalKey<FilterExpansionWidgetState>();

    return BlocProvider(
      create: (_) => FilterCubit(),
      child: BlocBuilder<FilterCubit, FilterState>(
        builder: (context, state) {
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
      ),
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
      itemCount: state.filteredDogs.length,
      itemBuilder: (context, index) {
        final Dog dog = state.filteredDogs[index];
        return _buildDogListTile(context, dog, index, state.filteredDogs);
      },
    );
  }

  Widget _buildDogListTile(BuildContext context, Dog dog, int index, List<Dog> filteredDogs) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          imageUrl: NS.apiDogUrl + NS.apiDogImagesPage + dog.images.smallOutdoors,
          cacheManager: LongTermCacheManager(),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          placeholder: (context, url) => SizedBox(
            width: 56,
            height: 56,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Center(
                child: CustomSpinKitThreeInOut(),
              ),
            ),
          ),
          errorWidget: (context, url, error) => FittedBox(
            fit: BoxFit.contain,
            child: Icon(
              Icons.image,
              size: 56,
              color: Colors.grey,
            ),
          ),
        ),
      ),
      title: Text(dog.name),
      subtitle: Text("${dog.coatStyle}, ${dog.coatTexture}"),
      trailing: BlocBuilder<FilterCubit, FilterState>(
        builder: (context, state) {
          final bool isFavorite = state.favorites.any((fav) => fav.id == dog.id);
          return IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () => context.read<FilterCubit>().toggleFavorite(dog.id),
          );
        },
      ),
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
  }
}