import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/settings_bloc_cubit.dart';
import '../businesslogic/settings_bloc_state.dart';
import '../widgets/quick_filter_buttons.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final SettingsCubit settingsCubit = context.read<SettingsCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.settingsTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.quickFilterVisibilitySetting,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return SegmentedButton<QuickFilterVisibility>(
                  segments: [
                    ButtonSegment<QuickFilterVisibility>(
                      value: QuickFilterVisibility.switchedOff,
                      label: Text(appLocalizations.quickFilterNone),
                    ),
                    ButtonSegment<QuickFilterVisibility>(
                      value: QuickFilterVisibility.onlyBeforeXTap,
                      label: Text(appLocalizations.quickFilterFirstXTimes),
                      enabled: !state.isFirstXTimesDisabled,
                    ),
                    ButtonSegment<QuickFilterVisibility>(
                      value: QuickFilterVisibility.alwaysVisible,
                      label: Text(appLocalizations.quickFilterAlways),
                    ),
                  ],
                  selected: {state.quickFilterVisibility},
                  onSelectionChanged: (Set<QuickFilterVisibility> newSelection) {
                    settingsCubit.setQuickFilterVisibility(newSelection.first);
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              appLocalizations.featureDiscoverySection,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            appLocalizations.listPageDiscovery,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Switch(
                          value: state.listPageDiscoveryEnabled,
                          onChanged: (value) {
                            settingsCubit.toggleListPageDiscovery(value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            appLocalizations.detailsPageDiscovery,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Switch(
                          value: state.detailsPageDiscoveryEnabled,
                          onChanged: (value) {
                            settingsCubit.toggleDetailsPageDiscovery(value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            appLocalizations.filterPageDiscovery,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Switch(
                          value: state.filterPageDiscoveryEnabled,
                          onChanged: (value) {
                            settingsCubit.toggleFilterPageDiscovery(value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            appLocalizations.navigationPageDiscovery,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Switch(
                          value: state.navigationPageDiscoveryEnabled,
                          onChanged: (value) {
                            settingsCubit.toggleNavigationPageDiscovery(value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      appLocalizations.featureDiscoveryHelpText,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
