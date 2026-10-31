import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/crossbreed_bloc_cubit.dart';
import '../businesslogic/crossbreed_bloc_state.dart';
import '../models/crossbreed_models.dart';
import '../parameters/netservices.dart';

/// Opens the AI crossbreed sheet for two distinct breeds in the user's display order.
Future<void> showCrossbreedSheet(BuildContext context, {required List<String> dogIds, required List<String> names}) async {
  final cubit = CrossbreedCubit();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => BlocProvider.value(value: cubit, child: CrossbreedSheet(dogIds: dogIds, names: names)),
  );
  // A finished success/failure is cleared; a pending command stays with the coordinator.
  await cubit.acknowledge();
  await cubit.close();
}

class CrossbreedSheet extends StatefulWidget {
  const CrossbreedSheet({super.key, required this.dogIds, required this.names});

  final List<String> dogIds;
  final List<String> names;

  @override
  State<CrossbreedSheet> createState() => _CrossbreedSheetState();
}

class _CrossbreedSheetState extends State<CrossbreedSheet> {
  late Future<CrossbreedSourcePreview> _preview;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  void _loadPreview() {
    _preview = context.read<CrossbreedCubit>().previewSources(widget.dogIds[0], widget.dogIds[1]);
  }

  bool _isThisPair(List<String>? ids) => ids != null && ids.toSet().containsAll(widget.dogIds) && ids.length == 2;

  Future<void> _generate(CrossbreedSourcePreview preview) async {
    setState(() => _starting = true);
    try {
      await context.read<CrossbreedCubit>().generate(displayDogIds: widget.dogIds, catalogVersion: preview.catalogVersion);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context) ?? AppLocalizationsEn();
    return BlocBuilder<CrossbreedCubit, CrossbreedFlowState>(
      builder: (context, state) {
        final cubit = context.read<CrossbreedCubit>();
        final ownFlow = _isThisPair(state.displayDogIds) && state.phase != CrossbreedPhase.idle;
        final otherPending = !ownFlow && state.displayDogIds != null && state.isBusy;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.crossbreedTitle, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              if (ownFlow && state.phase != CrossbreedPhase.failed)
                _FlowView(state: state, onWatchAd: cubit.watchAd, onCancel: cubit.cancel)
              else ...[
                _buildPreview(l, cubit, blocked: otherPending || _starting),
                if (otherPending) _Message(l.crossbreedOtherPending),
                if (ownFlow) ..._failure(l, state, cubit),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Widget> _failure(AppLocalizations l, CrossbreedFlowState state, CrossbreedCubit cubit) => [
        _Message(crossbreedErrorText(l, state.errorCode), error: true),
        if (state.retryable) FilledButton(onPressed: cubit.retry, child: Text(l.crossbreedRetry)),
      ];

  Widget _buildPreview(AppLocalizations l, CrossbreedCubit cubit, {required bool blocked}) {
    return FutureBuilder<CrossbreedSourcePreview>(
      future: _preview,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [const CircularProgressIndicator(), const SizedBox(height: 12), Text(l.crossbreedLoadingPreview)]),
          );
        }
        if (snap.hasError || snap.data == null) {
          return Column(children: [
            _Message(l.crossbreedPreviewError, error: true),
            TextButton(onPressed: () => setState(_loadPreview), child: Text(l.crossbreedRetry)),
          ]);
        }
        final preview = snap.data!;
        final byId = {for (final s in preview.sources) s.dogId: s};
        final canGenerate = preview.generateAllowed && cubit.adsSupported && !blocked;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                for (var i = 0; i < 2; i++) ...[
                  if (i == 1) const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.close)),
                  Expanded(child: _SourceTile(source: byId[widget.dogIds[i]], fallbackName: widget.names[i])),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(l.crossbreedExplanation, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.auto_awesome, size: 18),
              const SizedBox(width: 6),
              Text(l.crossbreedAiLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: canGenerate ? () => _generate(preview) : null,
              icon: const Icon(Icons.ondemand_video),
              label: Text(l.crossbreedGenerate),
            ),
            if (!cubit.adsSupported)
              _Message(l.crossbreedAdsUnsupported)
            else if (!preview.generateAllowed)
              _Message(crossbreedErrorText(l, preview.reason)),
          ],
        );
      },
    );
  }
}

class _FlowView extends StatelessWidget {
  const _FlowView({required this.state, required this.onWatchAd, required this.onCancel});

  final CrossbreedFlowState state;
  final Future<void> Function() onWatchAd;
  final Future<bool> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context) ?? AppLocalizationsEn();
    switch (state.phase) {
      case CrossbreedPhase.awaitingAd:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (state.errorCode != null) _Message(crossbreedErrorText(l, state.errorCode), error: true),
          FilledButton.icon(onPressed: onWatchAd, icon: const Icon(Icons.ondemand_video), label: Text(l.crossbreedWatchAdAgain)),
          TextButton(onPressed: onCancel, child: Text(l.crossbreedCancel)),
        ]);
      case CrossbreedPhase.succeeded:
        final result = state.result!;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _Message(l.crossbreedReady),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(result.thumbnailUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text('${result.breedNames.join(' × ')} · ${l.crossbreedAiLabel}', textAlign: TextAlign.center),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.crossbreedClose)),
        ]);
      default:
        final text = switch (state.phase) {
          CrossbreedPhase.showingAd => l.crossbreedLoadingAd,
          CrossbreedPhase.redeeming => l.crossbreedRedeeming,
          CrossbreedPhase.generating => l.crossbreedGenerating,
          _ => l.crossbreedPreparing,
        };
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(text, textAlign: TextAlign.center)]),
        );
    }
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source, required this.fallbackName});

  final CrossbreedPreviewSource? source;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final s = source;
    return Column(children: [
      AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: s != null && s.available && s.imageUrl != null
              ? CachedNetworkImage(imageUrl: s.imageUrl!, cacheManager: LongTermCacheManager(), fit: BoxFit.cover)
              : ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Center(child: Text(l.crossbreedPhotoUnavailable, textAlign: TextAlign.center)),
                ),
        ),
      ),
      const SizedBox(height: 6),
      Text(s?.breedName ?? fallbackName,
          textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
    ]);
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(text,
            textAlign: TextAlign.center, style: TextStyle(color: error ? Theme.of(context).colorScheme.error : null)),
      );
}

/// Localized text for a safe crossbreed error/eligibility code.
String crossbreedErrorText(AppLocalizations l, String? code) => switch (code) {
      'AD_NOT_COMPLETED' || 'REWARDED_AD_REQUIRED' => l.crossbreedAdNotCompleted,
      'AD_UNAVAILABLE' => l.crossbreedAdUnavailable,
      'ADS_UNSUPPORTED' || 'WEB_UNSUPPORTED' => l.crossbreedAdsUnsupported,
      'GENERATION_DISABLED' || 'FEATURE_DISABLED' => l.crossbreedGenerationPaused,
      'DAILY_LIMIT_REACHED' || 'CAPACITY_UNAVAILABLE' || 'RATE_LIMITED' => l.crossbreedLimitReached,
      'GENERATION_FAILED' => l.crossbreedFailed,
      'PAIR_UNAVAILABLE' => l.crossbreedPairUnavailable,
      'SOURCE_VERSION_CHANGED' => l.crossbreedSourceChanged,
      'INTENT_EXPIRED' => l.crossbreedExpired,
      'SERVICE_UNAVAILABLE' || 'NETWORK_ERROR' || 'TIMEOUT' || 'INTERNAL_ERROR' || 'INVALID_RESPONSE' => l.crossbreedTemporaryError,
      _ => l.crossbreedNotAvailable,
    };
