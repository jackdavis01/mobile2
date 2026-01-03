import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../models/dog.dart';
import '../models/dog_extended_info.dart';
import '../businesslogic/breed_info_bloc_cubit.dart';
import '../businesslogic/breed_info_bloc_state.dart';
import '../widgets/rating_bar_widget.dart';
import '../widgets/spinkitwidgets.dart';

class BreedInfoPage extends StatelessWidget {
  const BreedInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is! Map || !arguments.containsKey('dog')) {
      return Scaffold(
        appBar: AppBar(title: Text(appLocalizations.errorTitle)),
        body: Center(child: Text(appLocalizations.breedInfoNotAvailable)),
      );
    }

    final Dog dog = arguments['dog'] as Dog;

    return BlocProvider(
      create: (_) => BreedInfoCubit()
        ..loadExtendedInfo(
          dog,
          (error) => error == 'breedInfoLoadError'
              ? appLocalizations.breedInfoLoadError
              : appLocalizations.breedInfoLoadErrorDetails(error),
        ),
      child: BlocBuilder<BreedInfoCubit, BreedInfoState>(
        builder: (BuildContext context, BreedInfoState state) {
          final BreedInfoCubit cubit = context.read<BreedInfoCubit>();

          if (state.loading) {
            return Scaffold(
              appBar: AppBar(title: Text(dog.name)),
              body: const Center(child: CustomSpinKitThreeInOut()),
            );
          }

          if (state.errorMessage.isNotEmpty || state.extendedInfo == null) {
            return Scaffold(
              appBar: AppBar(title: Text(dog.name)),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => cubit.reloadData(
                          dog,
                          (error) => error == 'breedInfoLoadError'
                              ? appLocalizations.breedInfoLoadError
                              : appLocalizations.breedInfoLoadErrorDetails(error),
                        ),
                        child: Text(appLocalizations.reloadButton),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return _buildContent(context, dog, state.extendedInfo!, appLocalizations);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Dog dog, DogExtendedInfo extendedInfo, AppLocalizations appLocalizations) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dog.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).padding.bottom + 4.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with group and popularity
            _buildHeaderSection(dog, extendedInfo, appLocalizations),
            const SizedBox(height: 16),

            // Quick Stats Card
            _buildQuickStatsCard(extendedInfo, appLocalizations),
            const SizedBox(height: 16),

            // Short Description
            if (extendedInfo.shortDescription.isNotEmpty) ...[
              _buildSectionTitle(appLocalizations.quickOverview),
              const SizedBox(height: 8),
              _buildCard(
                child: Text(
                  extendedInfo.shortDescription,
                  style: const TextStyle(fontSize: 17, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Long Description
            if (extendedInfo.longDescription.isNotEmpty) ...[
              _buildSectionTitle(appLocalizations.aboutThisBreed),
              const SizedBox(height: 8),
              _buildCard(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final shouldUseColumns = screenWidth >= 600;

                    if (shouldUseColumns) {
                      // Split text into two parts for 2-column layout
                      final text = extendedInfo.longDescription;
                      final words = text.split(' ');
                      final midPoint = (words.length / 2).ceil();
                      final firstHalf = words.sublist(0, midPoint).join(' ');
                      final secondHalf = words.sublist(midPoint).join(' ');

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              firstHalf,
                              style: const TextStyle(fontSize: 17, height: 1.5),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Text(
                              secondHalf,
                              style: const TextStyle(fontSize: 17, height: 1.5),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Single column for narrow screens
                      return Text(
                        extendedInfo.longDescription,
                        style: const TextStyle(fontSize: 17, height: 1.5),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Physical Traits
            _buildSectionTitle(appLocalizations.physicalTraits),
            const SizedBox(height: 8),
            _buildPhysicalTraitsCard(dog, extendedInfo, appLocalizations),
            const SizedBox(height: 16),

            // Behavior
            _buildSectionTitle(appLocalizations.behaviorProfile),
            const SizedBox(height: 8),
            _buildBehaviorCard(dog, extendedInfo, appLocalizations),
            const SizedBox(height: 16),

            // Care
            _buildSectionTitle(appLocalizations.careRequirements),
            const SizedBox(height: 8),
            _buildCareCard(dog, extendedInfo, appLocalizations),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Dog dog, DogExtendedInfo info, AppLocalizations appLocalizations) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dog.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        info.group,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Popularity stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < info.popularity ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 24,
                  );
                }),
              ),
            ],
          ),
          if (info.rare) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.diamond, size: 16, color: Colors.purple.shade800),
                  const SizedBox(width: 6),
                  Text(
                    appLocalizations.rareBreed,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.purple.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStatsCard(DogExtendedInfo info, AppLocalizations appLocalizations) {
    return _buildCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.straighten, info.height > 0 ? '${info.height}"' : 'N/A', appLocalizations.height),
          _buildStatItem(Icons.fitness_center, info.weight > 0 ? '${info.weight} lbs' : 'N/A', appLocalizations.weight),
          _buildStatItem(Icons.favorite, info.lifespan > 0 ? '${info.lifespan} yrs' : 'N/A', appLocalizations.lifespan),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue.shade700),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildPhysicalTraitsCard(Dog dog, DogExtendedInfo info, AppLocalizations appLocalizations) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSizeRow(dog.size, appLocalizations),
          _buildTraitRow(appLocalizations.coatStyle, dog.coatStyle),
          _buildTraitRow(appLocalizations.coatTexture, dog.coatTexture),
          _buildTraitRow(appLocalizations.coatLength, _getCoatLengthText(info.coatLength, appLocalizations)),
          _buildTraitRow(appLocalizations.doubleCoat, info.doubleCoat ? appLocalizations.yes : appLocalizations.no),
          const Divider(height: 20),
          RatingBarWidget(
            label: appLocalizations.drooling,
            rating: dog.droolingFrequency,
            colorMode: RatingColorMode.reversed,
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorCard(Dog dog, DogExtendedInfo info, AppLocalizations appLocalizations) {
    return _buildCard(
      child: Column(
        children: [
          RatingBarWidget(
            label: appLocalizations.familyAffection,
            rating: info.familyAffection,
            colorMode: RatingColorMode.normal,
          ),
          RatingBarWidget(
            label: appLocalizations.childFriendly,
            rating: dog.childFriendly,
            colorMode: RatingColorMode.normal,
          ),
          RatingBarWidget(
            label: appLocalizations.dogSociability,
            rating: info.dogSociability,
            colorMode: RatingColorMode.normal,
          ),
          RatingBarWidget(
            label: appLocalizations.friendlyToStrangers,
            rating: info.friendlinessToStrangers,
            colorMode: RatingColorMode.normal,
          ),
          RatingBarWidget(
            label: appLocalizations.playfulness,
            rating: info.playfulness,
            colorMode: RatingColorMode.normal,
          ),
          RatingBarWidget(
            label: appLocalizations.protectiveInstincts,
            rating: info.protectiveInstincts,
            colorMode: RatingColorMode.normal,
          ),
          RatingBarWidget(
            label: appLocalizations.adaptability,
            rating: info.adaptability,
            colorMode: RatingColorMode.normal,
          ),
          RatingBarWidget(
            label: appLocalizations.barkingFrequency,
            rating: dog.barkingFrequency,
            colorMode: RatingColorMode.reversed,
          ),
        ],
      ),
    );
  }

  Widget _buildCareCard(Dog dog, DogExtendedInfo info, AppLocalizations appLocalizations) {
    return _buildCard(
      child: Column(
        children: [
          RatingBarWidget(
            label: appLocalizations.sheddingAmount,
            rating: dog.sheddingAmount,
            colorMode: RatingColorMode.reversed,
          ),
          RatingBarWidget(
            label: appLocalizations.groomingFrequency,
            rating: dog.groomingFrequency,
            colorMode: RatingColorMode.reversed,
          ),
          RatingBarWidget(
            label: appLocalizations.exerciseNeeds,
            rating: dog.exerciseNeeds,
            colorMode: RatingColorMode.neutral,
          ),
          RatingBarWidget(
            label: appLocalizations.mentalStimulation,
            rating: info.mentalStimulationNeeds,
            colorMode: RatingColorMode.normal,
          ),
          RatingBarWidget(
            label: appLocalizations.trainingDifficulty,
            rating: dog.trainingDifficulty,
            colorMode: RatingColorMode.reversed,
          ),
        ],
      ),
    );
  }

  Widget _buildTraitRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  /// Hybrid widget for size property: shows text label AND blue rating bar
  Widget _buildSizeRow(int size, AppLocalizations appLocalizations) {
    final String sizeText = _getSizeText(size, appLocalizations);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appLocalizations.size,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                sizeText,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: RatingBarWidget(
            label: '',
            rating: size,
            colorMode: RatingColorMode.neutral,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  String _getSizeText(int size, AppLocalizations appLocalizations) {
    switch (size) {
      case 1:
        return appLocalizations.sizeExtraSmall;
      case 2:
        return appLocalizations.sizeSmall;
      case 3:
        return appLocalizations.sizeMedium;
      case 4:
        return appLocalizations.sizeLarge;
      case 5:
        return appLocalizations.sizeExtraLarge;
      default:
        return appLocalizations.unknown;
    }
  }

  String _getCoatLengthText(int length, AppLocalizations appLocalizations) {
    switch (length) {
      case 1:
        return appLocalizations.coatLengthVeryShort;
      case 2:
        return appLocalizations.coatLengthShort;
      case 3:
        return appLocalizations.coatLengthMedium;
      case 4:
        return appLocalizations.coatLengthLong;
      case 5:
        return appLocalizations.coatLengthVeryLong;
      default:
        return appLocalizations.unknown;
    }
  }
}
