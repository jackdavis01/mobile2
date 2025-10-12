import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../businesslogic/filter_bloc_cubit.dart';
import '../businesslogic/filter_bloc_state.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';

class FilterInputWidget extends StatefulWidget {
  const FilterInputWidget({super.key});

  @override
  State<FilterInputWidget> createState() => _FilterInputWidgetState();
}

class _FilterInputWidgetState extends State<FilterInputWidget> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    
    return BlocConsumer<FilterCubit, FilterState>(
      listener: (context, state) {
        // Update text controller if search query is cleared programmatically
        if (state.searchQuery.isEmpty && _textController.text.isNotEmpty) {
          _textController.clear();
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search input field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _textController,
                onChanged: (value) {
                  context.read<FilterCubit>().updateSearchQuery(value);
                },
                decoration: InputDecoration(
                  hintText: appLocalizations.filterSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: state.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _textController.clear();
                            context.read<FilterCubit>().clearSearchQuery();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.red, width: 2.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.red, width: 2.0),
                  ),
                ),
              ),
            ),
            

          ],
        );
      },
    );
  }
}