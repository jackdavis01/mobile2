import 'package:flutter/material.dart';
import 'package:feature_discovery/feature_discovery.dart';

class PageFeatureDiscovery {
  final BuildContext context;
  final String pageKey;
  final List<String> featureIds;
  final VoidCallback onCompleted;
  final bool Function() getMounted;

  PageFeatureDiscovery({
    required this.context,
    required this.pageKey,
    required this.featureIds,
    required this.onCompleted,
    required this.getMounted,
  });

  Future<void> showDiscovery() async {
    if (!getMounted()) return;

    // Start feature discovery
    if (context.mounted) {
      FeatureDiscovery.discoverFeatures(
        context,
        featureIds.toSet(),
      );

      // Check completion after a delay to allow user to complete the discovery
      Future.delayed(const Duration(seconds: 2), () {
        if (getMounted()) {
          _checkAndCompleteIfDone();
        }
      });
    }
  }

  Future<void> _checkAndCompleteIfDone() async {
    bool allCompleted = await checkAllFeaturesCompleted();
    if (allCompleted) {
      onCompleted();
    } else {
      // Check again after another delay in case user is still going through features
      Future.delayed(const Duration(seconds: 2), () {
        if (getMounted()) {
          _checkAndCompleteIfDone();
        }
      });
    }
  }

  Future<bool> checkAllFeaturesCompleted() async {
    for (final featureId in featureIds) {
      if (!getMounted()) return false;
      final isCompleted = await FeatureDiscovery.hasPreviouslyCompleted(context, featureId);
      if (isCompleted != true) return false;
    }
    return true;
  }

  Future<void> clearDiscovery() async {
    await FeatureDiscovery.clearPreferences(
      context,
      featureIds.toSet(),
    );
  }
}
