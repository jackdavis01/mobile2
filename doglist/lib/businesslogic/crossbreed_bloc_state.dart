import '../models/crossbreed_models.dart';

enum CrossbreedPhase {
  idle,
  preparingIntent,
  awaitingAd,

  /// Rewarded ad loading or on screen; results are never shown during this phase.
  showingAd,
  redeeming,
  generating,
  succeeded,
  failed,
}

class CrossbreedFlowState {
  const CrossbreedFlowState({
    required this.phase,
    this.displayDogIds,
    this.fulfillment,
    this.pairId,
    this.result,
    this.errorCode,
    this.retryable = false,
    this.needsNewAd = false,
    this.retryAfterSeconds,
  });

  static const idle = CrossbreedFlowState(phase: CrossbreedPhase.idle);

  final CrossbreedPhase phase;

  /// Pair in the user's selection order (display only; the server canonicalises).
  final List<String>? displayDogIds;
  final FulfillmentKind? fulfillment;
  final String? pairId;
  final CrossbreedResult? result;

  /// Safe error code: a contract code, NETWORK_ERROR/TIMEOUT/INVALID_RESPONSE, or a local ad code
  /// (AD_NOT_COMPLETED, AD_UNAVAILABLE, ADS_UNSUPPORTED).
  final String? errorCode;

  /// The same pending command can be retried without watching another ad.
  final bool retryable;

  /// Another rewarded ad is needed for this pair.
  final bool needsNewAd;
  final int? retryAfterSeconds;

  bool get isBusy =>
      phase == CrossbreedPhase.preparingIntent ||
      phase == CrossbreedPhase.showingAd ||
      phase == CrossbreedPhase.redeeming ||
      phase == CrossbreedPhase.generating;

  @override
  String toString() => 'CrossbreedFlowState($phase, error: $errorCode, retryable: $retryable, needsNewAd: $needsNewAd)';
}
