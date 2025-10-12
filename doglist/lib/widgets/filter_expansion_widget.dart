import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../businesslogic/filter_bloc_cubit.dart';
import '../businesslogic/filter_bloc_state.dart';
import '../l10n/gen/app_localizations.dart';
import '../l10n/gen/app_localizations_en.dart';
import 'filter_input_widget.dart';

class FilterExpansionWidget extends StatefulWidget {
  final double? maxHeight;
  
  const FilterExpansionWidget({super.key, this.maxHeight});

  @override
  State<FilterExpansionWidget> createState() => FilterExpansionWidgetState();
}

class FilterExpansionWidgetState extends State<FilterExpansionWidget> {
  late final ScrollController _scrollController;
  late final ExpansibleController _expansibleController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _expansibleController = ExpansibleController();
  }

  void toggleExpansion() {
    if (_expansibleController.isExpanded) {
      _expansibleController.collapse();
    } else {
      _expansibleController.expand();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _expansibleController.dispose();
    super.dispose();
  }

  static const List<String> coatStyles = [
    'Straight',
    'Wavy', 
    'Curly',
    'Wire',
    'Hairless',
    'Corded',
  ];

  static const List<String> coatTextures = [
    'Smooth',
    'Rough',
    'Silky',
  ];

  static const List<String> personalityTraits = [
    'Adaptable', 'Brave', 'Companionable', 'Confident', 'Curious', 
    'Dignified', 'Faithful', 'Friendly', 'Happy', 'Hardworking',
    'Independent', 'Intelligent', 'Lively', 'Loving', 'Obedient', 
    'Playful', 'Relaxed', 'Reliable', 'Vigilant',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, state) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
        
        return Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          child: ExpansionTile(
            controller: _expansibleController,
            title: const FilterInputWidget(), // Breed input directly in title (no label)
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: widget.maxHeight ?? 400),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thickness: 8.0,
                  radius: const Radius.circular(3.0),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Coat style filter
                        DropdownButtonFormField<String>(
                          initialValue: state.selectedCoatStyle,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select coat style',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'All Coat Styles',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ...coatStyles.map((String coatStyle) {
                              return DropdownMenuItem<String>(
                                value: coatStyle,
                                child: Text(coatStyle),
                              );
                            }),
                          ],
                          onChanged: (String? newValue) {
                            context.read<FilterCubit>().updateCoatStyle(newValue);
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Coat texture filter
                        DropdownButtonFormField<String>(
                          initialValue: state.selectedCoatTexture,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select coat texture',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text(
                                'All Coat Textures',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ...coatTextures.map((String coatTexture) {
                              return DropdownMenuItem<String>(
                                value: coatTexture,
                                child: Text(coatTexture),
                              );
                            }),
                          ],
                          onChanged: (String? newValue) {
                            context.read<FilterCubit>().updateCoatTexture(newValue);
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Personality traits filter
                        const Text(
                          'Personality Traits (select 0-3):',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: personalityTraits.map((trait) {
                            final isSelected = state.selectedPersonalityTraits.contains(trait);
                            final canSelect = state.selectedPersonalityTraits.length < 3 || isSelected;
                            return FilterChip(
                              label: Text(trait),
                              selected: isSelected,
                              onSelected: canSelect ? (selected) {
                                final currentTraits = List<String>.from(state.selectedPersonalityTraits);
                                if (selected) {
                                  currentTraits.add(trait);
                                } else {
                                  currentTraits.remove(trait);
                                }
                                context.read<FilterCubit>().updatePersonalityTraits(currentTraits);
                              } : null,
                              backgroundColor: canSelect ? null : Colors.grey.shade300,
                              disabledColor: Colors.grey.shade300,
                            );
                          }).toList(),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Clear filters button
                        if (state.searchQuery.isNotEmpty || state.selectedCoatStyle != null || state.selectedCoatTexture != null || state.selectedPersonalityTraits.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => context.read<FilterCubit>().clearAllFilters(),
                              icon: const Icon(Icons.clear),
                              label: Text(appLocalizations.clearAllFilters),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}