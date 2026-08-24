import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/compare_bloc_cubit.dart';
import '../businesslogic/compare_bloc_state.dart';
import '../models/dog.dart';
import '../models/dog_extended_info.dart';
import '../repositories/dogs_data_repository.dart';
import '../widgets/carousel_indicator.dart';
import '../widgets/rating_bar_widget.dart';
import '../widgets/spinkitwidgets.dart';
import '../widgets/ad_banner.dart';
import '../parameters/netservices.dart';
import '../parameters/ads_config.dart';
import '../platform/platform_info.dart';

/// Side-by-side comparison of the two pinned breeds.
class CompareDetailsPage extends StatefulWidget {
  const CompareDetailsPage({super.key});

  @override
  State<CompareDetailsPage> createState() => _CompareDetailsPageState();
}

class _CompareDetailsPageState extends State<CompareDetailsPage> {
  final DogsDataRepository _repository = DogsDataRepository();

  List<Dog> _allDogs = [];
  Dog? _dogA;
  Dog? _dogB;
  DogExtendedInfo? _infoA;
  DogExtendedInfo? _infoB;

  bool _loading = true;
  bool _error = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _allDogs = (args?['dogs'] as List<Dog>?) ?? [];
    _resolveAndLoad();
  }

  Dog? _findDog(String id) {
    try {
      return _allDogs.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _resolveAndLoad() async {
    final ids = context.read<CompareCubit>().state.pinnedIds;
    if (ids.length >= 2) {
      _dogA = _findDog(ids[0]);
      _dogB = _findDog(ids[1]);
    }
    await _loadInfo();
  }

  Future<void> _loadInfo() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    if (_dogA == null || _dogB == null) {
      setState(() {
        _error = true;
        _loading = false;
      });
      return;
    }

    try {
      final results = await Future.wait([
        _repository.getExtendedInfo(_dogA!.id),
        _repository.getExtendedInfo(_dogB!.id),
      ]);
      if (!mounted) return;

      final infoA = results[0];
      final infoB = results[1];
      if (infoA == null || infoB == null) {
        setState(() {
          _error = true;
          _loading = false;
        });
        return;
      }

      setState(() {
        _infoA = infoA;
        _infoB = infoB;
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();

    return BlocListener<CompareCubit, CompareState>(
      listener: (context, state) {
        // Returning to the selection page once fewer than two breeds remain pinned.
        if (state.pinnedIds.length < 2) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(appLocalizations.compareTitle), centerTitle: true),
        body: Stack(
          children: [
            _buildBody(appLocalizations),
            const Positioned(left: 0, right: 0, bottom: 0, child: AdBanner()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations appLocalizations) {
    if (_loading) return const CustomSpinKitThreeInOut();

    if (_error || _dogA == null || _dogB == null || _infoA == null || _infoB == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                appLocalizations.breedInfoLoadError,
                style: const TextStyle(fontSize: 18, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadInfo, child: Text(appLocalizations.reloadButton)),
          ],
        ),
      );
    }

    final bool reserveAdSpace = AdsConfig.areAdsEnabled && (PlatformInfo.isAndroid || PlatformInfo.isIOS);
    final Dog dogA = _dogA!;
    final Dog dogB = _dogB!;
    final DogExtendedInfo infoA = _infoA!;
    final DogExtendedInfo infoB = _infoB!;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: reserveAdSpace ? 64 : 0),
      child: Column(
        children: [
          _buildHeaderRow(appLocalizations, dogA, dogB),
          _buildAttribute(
            appLocalizations.temperament,
            _buildTraits(dogA),
            _buildTraits(dogB),
          ),
          _buildAttribute(
            appLocalizations.size,
            _buildSize(appLocalizations, infoA),
            _buildSize(appLocalizations, infoB),
          ),
          _buildAttribute(
            appLocalizations.lifespan,
            _buildLifespan(infoA),
            _buildLifespan(infoB),
          ),
          _buildAttribute(
            appLocalizations.sheddingAmount,
            RatingBarWidget(label: '', rating: dogA.sheddingAmount, colorMode: RatingColorMode.reversed),
            RatingBarWidget(label: '', rating: dogB.sheddingAmount, colorMode: RatingColorMode.reversed),
          ),
          _buildAttribute(
            appLocalizations.drooling,
            RatingBarWidget(label: '', rating: dogA.droolingFrequency, colorMode: RatingColorMode.reversed),
            RatingBarWidget(label: '', rating: dogB.droolingFrequency, colorMode: RatingColorMode.reversed),
          ),
          _buildAttribute(
            appLocalizations.barkingFrequency,
            RatingBarWidget(label: '', rating: dogA.barkingFrequency, colorMode: RatingColorMode.reversed),
            RatingBarWidget(label: '', rating: dogB.barkingFrequency, colorMode: RatingColorMode.reversed),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(AppLocalizations appLocalizations, Dog dogA, Dog dogB) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildBreedHeader(appLocalizations, dogA)),
        Expanded(child: _buildBreedHeader(appLocalizations, dogB)),
      ],
    );
  }

  Widget _buildBreedHeader(AppLocalizations appLocalizations, Dog dog) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _BreedCarousel(
            imagePaths: [dog.images.largeOutdoors, dog.images.largeIndoors, dog.images.largeStudio],
          ),
          const SizedBox(height: 8),
          Text(
            dog.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          TextButton.icon(
            onPressed: () => context.read<CompareCubit>().togglePin(dog.id),
            icon: const Icon(Icons.push_pin, size: 18),
            label: Text(appLocalizations.compareUnpin),
          ),
        ],
      ),
    );
  }

  Widget _buildAttribute(String label, Widget valueA, Widget valueB) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: valueA)),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: valueB)),
          ],
        ),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildTraits(Dog dog) {
    if (dog.personalityTraits.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: dog.personalityTraits
          .map((trait) => Chip(
                label: Text(trait, style: const TextStyle(fontSize: 13)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ))
          .toList(),
    );
  }

  Widget _buildSize(AppLocalizations appLocalizations, DogExtendedInfo info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${appLocalizations.height}: ${info.height > 0 ? '${info.height}"' : 'N/A'}',
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 4),
        Text(
          '${appLocalizations.weight}: ${info.weight > 0 ? '${info.weight} lbs' : 'N/A'}',
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildLifespan(DogExtendedInfo info) {
    return Text(
      info.lifespan > 0 ? '${info.lifespan} yrs' : 'N/A',
      style: const TextStyle(fontSize: 15),
    );
  }
}

/// Horizontal image carousel for a single breed.
class _BreedCarousel extends StatefulWidget {
  final List<String> imagePaths;

  const _BreedCarousel({required this.imagePaths});

  @override
  State<_BreedCarousel> createState() => _BreedCarouselState();
}

class _BreedCarouselState extends State<_BreedCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.imagePaths.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: NS.apiDogUrl + NS.apiDogImagesPage + widget.imagePaths[index],
                  cacheManager: LongTermCacheManager(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CustomSpinKitThreeInOut()),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.image, color: Colors.grey)),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        CarouselIndicator(totalPages: widget.imagePaths.length, currentPage: _currentPage),
      ],
    );
  }
}
