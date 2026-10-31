import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/crossbreed_models.dart';

/// One user Generate action, persisted so a pending redemption survives page disposal, app kill and
/// relaunch. Contains no credentials. Once [pairId]/[generationId] are set they never change.
class CrossbreedPendingCommand {
  const CrossbreedPendingCommand({
    required this.clientIntentId,
    required this.displayDogIds,
    required this.catalogVersion,
    required this.clientAdAttemptId,
    required this.createdAt,
    this.intentId,
    this.adEarned = false,
    this.adDismissed = false,
    this.redeemSubmitted = false,
    this.fulfillment,
    this.pairId,
    this.generationId,
  });

  final String clientIntentId;
  final List<String> displayDogIds;
  final String catalogVersion;
  final String clientAdAttemptId;
  final DateTime createdAt;
  final String? intentId;
  final bool adEarned;
  final bool adDismissed;
  final bool redeemSubmitted;
  final FulfillmentKind? fulfillment;
  final String? pairId;
  final String? generationId;

  bool get isFulfilled => pairId != null && generationId != null;

  CrossbreedPendingCommand copyWith({
    String? intentId,
    String? clientAdAttemptId,
    bool? adEarned,
    bool? adDismissed,
    bool? redeemSubmitted,
  }) =>
      CrossbreedPendingCommand(
        clientIntentId: clientIntentId,
        displayDogIds: displayDogIds,
        catalogVersion: catalogVersion,
        clientAdAttemptId: clientAdAttemptId ?? this.clientAdAttemptId,
        createdAt: createdAt,
        intentId: intentId ?? this.intentId,
        adEarned: adEarned ?? this.adEarned,
        adDismissed: adDismissed ?? this.adDismissed,
        redeemSubmitted: redeemSubmitted ?? this.redeemSubmitted,
        fulfillment: fulfillment,
        pairId: pairId,
        generationId: generationId,
      );

  /// Records the server mapping. A different mapping for an already fulfilled command is a contract
  /// violation and is rejected instead of silently replacing the first one.
  CrossbreedPendingCommand fulfilled(FulfillmentKind kind, String pairId, String generationId) {
    if (isFulfilled) {
      if (this.pairId != pairId || this.generationId != generationId) {
        throw const CrossbreedFormatException('fulfilled mapping is immutable');
      }
      return this;
    }
    return CrossbreedPendingCommand(
      clientIntentId: clientIntentId,
      displayDogIds: displayDogIds,
      catalogVersion: catalogVersion,
      clientAdAttemptId: clientAdAttemptId,
      createdAt: createdAt,
      intentId: intentId,
      adEarned: adEarned,
      adDismissed: adDismissed,
      redeemSubmitted: redeemSubmitted,
      fulfillment: kind,
      pairId: pairId,
      generationId: generationId,
    );
  }

  Map<String, dynamic> toJson() => {
        'clientIntentId': clientIntentId,
        'displayDogIds': displayDogIds,
        'catalogVersion': catalogVersion,
        'clientAdAttemptId': clientAdAttemptId,
        'createdAt': createdAt.toUtc().toIso8601String(),
        if (intentId != null) 'intentId': intentId,
        'adEarned': adEarned,
        'adDismissed': adDismissed,
        'redeemSubmitted': redeemSubmitted,
        if (fulfillment != null) 'fulfillment': fulfillment!.name,
        if (pairId != null) 'pairId': pairId,
        if (generationId != null) 'generationId': generationId,
      };

  static CrossbreedPendingCommand? tryFromJson(Map<String, dynamic> json) {
    try {
      final dogs = (json['displayDogIds'] as List).cast<String>();
      final clientIntentId = json['clientIntentId'] as String;
      final attempt = json['clientAdAttemptId'] as String;
      if (dogs.length != 2 || !isUuidV4(clientIntentId) || !isUuidV4(attempt)) return null;
      final kind = json['fulfillment'] as String?;
      return CrossbreedPendingCommand(
        clientIntentId: clientIntentId,
        displayDogIds: List.unmodifiable(dogs),
        catalogVersion: json['catalogVersion'] as String,
        clientAdAttemptId: attempt,
        createdAt: DateTime.parse(json['createdAt'] as String),
        intentId: json['intentId'] as String?,
        adEarned: json['adEarned'] as bool? ?? false,
        adDismissed: json['adDismissed'] as bool? ?? false,
        redeemSubmitted: json['redeemSubmitted'] as bool? ?? false,
        fulfillment: kind == null ? null : FulfillmentKind.values.byName(kind),
        pairId: json['pairId'] as String?,
        generationId: json['generationId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

abstract class CrossbreedStateStore {
  Future<CrossbreedPendingCommand?> load();
  Future<void> save(CrossbreedPendingCommand command);
  Future<void> clear();
}

class PrefsCrossbreedStateStore implements CrossbreedStateStore {
  static const key = 'crossbreed.pendingCommand.v1';

  @override
  Future<CrossbreedPendingCommand?> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(key);
    if (raw == null) return null;
    try {
      return CrossbreedPendingCommand.tryFromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(CrossbreedPendingCommand command) async =>
      (await SharedPreferences.getInstance()).setString(key, jsonEncode(command.toJson()));

  @override
  Future<void> clear() async => (await SharedPreferences.getInstance()).remove(key);
}

class InMemoryCrossbreedStateStore implements CrossbreedStateStore {
  CrossbreedPendingCommand? value;

  @override
  Future<CrossbreedPendingCommand?> load() async => value;

  @override
  Future<void> save(CrossbreedPendingCommand command) async => value = command;

  @override
  Future<void> clear() async => value = null;
}
