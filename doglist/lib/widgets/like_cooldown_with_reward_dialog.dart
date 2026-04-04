import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/l10n/gen/app_localizations.dart';
import '/l10n/gen/app_localizations_en.dart';
import '../businesslogic/like_bloc_cubit.dart';
import '../services/rewarded_ad_manager.dart';
import '../parameters/ads_config.dart';

class LikeCooldownWithRewardDialog extends StatefulWidget {
  final String dogId;
  final String dogName;

  const LikeCooldownWithRewardDialog({
    super.key,
    required this.dogId,
    required this.dogName,
  });

  @override
  State<LikeCooldownWithRewardDialog> createState() => _LikeCooldownWithRewardDialogState();
}

class _LikeCooldownWithRewardDialogState extends State<LikeCooldownWithRewardDialog> {
  final RewardedAdManager _adManager = RewardedAdManager();
  bool _isLoadingAd = false;
  bool _isProcessingReward = false;

  @override
  void initState() {
    super.initState();
    // Preload ad when dialog opens (only if ads are enabled)
    if (AdsConfig.areAdsEnabled) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    setState(() => _isLoadingAd = true);
    await _adManager.loadAd();
    if (mounted) {
      setState(() => _isLoadingAd = false);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _watchAdAndLike() async {
    if (_isProcessingReward || _isLoadingAd) return;

    if (!_adManager.isAdReady()) {
      if (mounted) {
        final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.likeRewardedAdNotReady),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isProcessingReward = true);

    await _adManager.showAd((success) async {
      if (!mounted) return;

      if (success) {
        // User watched the ad, now submit rewarded like
        final likeCubit = context.read<LikeCubit>();
        
        // Optimistic update
        likeCubit.incrementLikeCountOptimistically(widget.dogId);
        
        // Submit rewarded like
        final likeSuccess = await likeCubit.likeRewardedDog(widget.dogId);
        
        if (likeSuccess) {
          // Close dialog
          if (mounted) {
            final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
            Navigator.of(context).pop();
            
            // Show success message (callback fires after ad is dismissed)
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    appLocalizations.likeSuccess(widget.dogName),
                    style: const TextStyle(fontSize: 15),
                  ),
                  backgroundColor: Colors.green.shade700,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        } else {
          // Revert on failure
          likeCubit.revertLikeCount(widget.dogId);
          
          if (mounted) {
            final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(appLocalizations.likeRewardedFailed),
                backgroundColor: Colors.red.shade700,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        // User didn't complete the ad
        if (mounted) {
          final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLocalizations.likeRewardedIncomplete),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      if (mounted) {
        setState(() => _isProcessingReward = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final likeCubit = context.read<LikeCubit>();
    final bool adsEnabled = AdsConfig.areAdsEnabled;

    return AlertDialog(
      title: Row(
        children: [
          Text(appLocalizations.likeRewardedDialogTitle),
        ],
      ),
      content: StreamBuilder<Duration>(
        stream: likeCubit.getCooldownStream(widget.dogId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (adsEnabled)
                  Center(
                    child: ElevatedButton(
                      onPressed: _isProcessingReward || _isLoadingAd ? null : _watchAdAndLike,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: _isProcessingReward || _isLoadingAd
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isLoadingAd ? appLocalizations.likeRewardedLoading : appLocalizations.likeRewardedProcessing,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            )
                          : Text(
                              appLocalizations.likeRewardedWatchAdButton,
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                if (adsEnabled) const SizedBox(height: 16),
                Text(
                  appLocalizations.likeCanLikeSoon,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
              ],
            );
          }

          final remaining = snapshot.data!;
          final canLikeAgainAt = DateTime.now().toUtc().add(remaining).toLocal();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (adsEnabled)
                Center(
                  child: ElevatedButton(
                    onPressed: _isProcessingReward || _isLoadingAd ? null : _watchAdAndLike,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: _isProcessingReward || _isLoadingAd
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isLoadingAd ? appLocalizations.likeRewardedLoading : appLocalizations.likeRewardedProcessing,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        : Text(
                            appLocalizations.likeRewardedWatchAdButton,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              if (adsEnabled) const SizedBox(height: 20),
              Text(
                appLocalizations.likeCanLikeAgainIn,
                style: TextStyle(fontSize: 15, color: Colors.purple.shade700),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(remaining),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                appLocalizations.likeComeBackAt(_formatTime(canLikeAgainAt)),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.purple.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                adsEnabled ? appLocalizations.likeRewardedNotNow : appLocalizations.likeRewardedClose,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Don't dispose the ad manager here - it's a singleton
    super.dispose();
  }
}
