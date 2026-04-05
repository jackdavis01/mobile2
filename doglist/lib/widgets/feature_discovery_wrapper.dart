import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../businesslogic/settings_bloc_cubit.dart';
import '../widgets/feature_discovery_manager.dart';

/// A StatefulWidget wrapper that handles feature discovery lifecycle
/// for StatelessWidget pages
class FeatureDiscoveryWrapper extends StatefulWidget {
  final String pageKey;
  final List<String> featureIds;
  final VoidCallback onCompleted;
  final Widget Function(VoidCallback? onDrawerClosed, VoidCallback? onDrawerOpened)? builder;
  final Widget? child;
  final bool delayDiscoveryUntilDrawerClosed;

  const FeatureDiscoveryWrapper({
    super.key,
    required this.pageKey,
    required this.featureIds,
    required this.onCompleted,
    this.builder,
    this.child,
    this.delayDiscoveryUntilDrawerClosed = false,
  }) : assert(
         (builder != null && child == null) || (builder == null && child != null),
         'Either builder or child must be provided, but not both',
       );

  @override
  State<FeatureDiscoveryWrapper> createState() => _FeatureDiscoveryWrapperState();
}

class _FeatureDiscoveryWrapperState extends State<FeatureDiscoveryWrapper> {
  PageFeatureDiscovery? _pageDiscovery;
  bool? _lastEnabledState;
  bool _discoveryPending = false;
  bool _hasShownDiscovery = false;
  bool _needsInitialization = false;
  bool _pendingShouldClear = false;
  bool _discoveryBlocked = false;
  bool _discoveryTriggerScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final settingsState = context.watch<SettingsCubit>().state;
    final isEnabled = _isDiscoveryEnabled(settingsState);

    // Initialize or reinitialize when discovery goes from disabled to enabled
    final shouldInitialize = (isEnabled && _lastEnabledState != true);

    if (shouldInitialize) {
      // Only clear when explicitly toggling from OFF to ON
      // Don't clear on first load (null → true) - let feature_discovery track completion
      final shouldClear = (_lastEnabledState == false);

      _hasShownDiscovery = false;
      _discoveryPending = false;
      _needsInitialization = true;
      _pendingShouldClear = shouldClear;
      // Check if route is currently visible before initializing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryInitializeIfVisible();
      });
    }

    _lastEnabledState = isEnabled;
  }

  void _tryInitializeIfVisible() {
    if (mounted && _needsInitialization && ModalRoute.of(context)?.isCurrent == true) {
      _needsInitialization = false;
      _initializeDiscovery(clearFirst: _pendingShouldClear);
      _pendingShouldClear = false;
    }
  }

  void _initializeDiscovery({bool clearFirst = false}) async {
    _pageDiscovery = PageFeatureDiscovery(
      context: context,
      pageKey: widget.pageKey,
      featureIds: widget.featureIds,
      onCompleted: widget.onCompleted,
      getMounted: () => mounted,
    );

    // Clear stored preferences when manually re-enabled (toggled from off to on)
    if (clearFirst) {
      await _pageDiscovery?.clearDiscovery();
    }

    // Mark as pending if we need to delay
    if (widget.delayDiscoveryUntilDrawerClosed) {
      // For delayed pages, discovery stays pending until the page explicitly signals
      // that all blocking UI (drawer / overlays) has been closed.
      _discoveryPending = true;
      _discoveryBlocked = true;
    } else {
      // Start discovery immediately (with delay to ensure widget is fully rendered)
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // Delay to ensure widget is stable, especially for drawer
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted && !_hasShownDiscovery) {
            _hasShownDiscovery = true;
            _pageDiscovery?.showDiscovery();
          }
        });
      });
    }
  }

  void _onDrawerOpened() {
    // Keep discovery pending so it can trigger when the blocking UI closes
    _discoveryBlocked = true;
    if (!_hasShownDiscovery) {
      _discoveryPending = true;
    }
  }

  void _triggerPendingDiscovery() {
    _discoveryBlocked = false;

    if (_discoveryPending && !_hasShownDiscovery && !_discoveryTriggerScheduled) {
      _discoveryTriggerScheduled = true;
      // Add delay to ensure drawer/overlay close animation completes before showing discovery
      Future.delayed(const Duration(milliseconds: 350), () {
        _discoveryTriggerScheduled = false;

        if (!mounted || _discoveryBlocked || !_discoveryPending || _hasShownDiscovery) {
          return;
        }

        _hasShownDiscovery = true;
        _discoveryPending = false;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _pageDiscovery?.showDiscovery();
        });
      });
    }
  }

  bool _isDiscoveryEnabled(dynamic settingsState) {
    switch (widget.pageKey) {
      case 'list':
        return settingsState.listPageDiscoveryEnabled;
      case 'details':
        return settingsState.detailsPageDiscoveryEnabled;
      case 'filter':
        return settingsState.filterPageDiscoveryEnabled;
      case 'navigation':
        return settingsState.navigationPageDiscoveryEnabled;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need to initialize discovery now that we're building
    // (e.g., user just returned from Settings page)
    if (_needsInitialization) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryInitializeIfVisible();
      });
    }

    if (widget.builder != null) {
      return widget.builder!(
        widget.delayDiscoveryUntilDrawerClosed ? _triggerPendingDiscovery : null,
        widget.delayDiscoveryUntilDrawerClosed ? _onDrawerOpened : null,
      );
    }
    return widget.child!;
  }
}
