import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/compare_bloc_cubit.dart';
import '../businesslogic/compare_bloc_state.dart';
import '../models/dog.dart';
import '../repositories/dogs_data_repository.dart';
import '../widgets/dog_list_item.dart';
import '../widgets/spinkitwidgets.dart';
import '../widgets/ad_banner.dart';
import '../parameters/ads_config.dart';
import '../platform/platform_info.dart';

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
        SnackBar(content: Text(appLocalizations.compareMaxReached), duration: const Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.compareTitle), centerTitle: true),
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
      body: Stack(
        children: [
          _buildBody(appLocalizations),
          const Positioned(left: 0, right: 0, bottom: 0, child: AdBanner()),
        ],
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

    final bool reserveAdSpace = AdsConfig.areAdsEnabled && (PlatformInfo.isAndroid || PlatformInfo.isIOS);

    return BlocBuilder<CompareCubit, CompareState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(bottom: reserveAdSpace ? 64 : 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Text(
                  appLocalizations.compareInstructions,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: MediaQuery.of(context).padding.bottom > 0
                      ? EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom)
                      : EdgeInsets.zero,
                  itemCount: _dogs.length,
                  itemBuilder: (context, index) {
                    final Dog dog = _dogs[index];
                    final bool isPinned = state.pinnedIds.contains(dog.id);
                    return DogListItem(
                      dog: dog,
                      type: DogListItemType.compare,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      imageSize: 72.0,
                      isPinned: isPinned,
                      onPinToggled: () => _handleToggle(dog.id),
                      onTap: () => _handleToggle(dog.id),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
