import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../businesslogic/like_bloc_cubit.dart';

class LikeCooldownDialog extends StatelessWidget {
  final String dogId;
  final String dogName;

  const LikeCooldownDialog({
    super.key,
    required this.dogId,
    required this.dogName,
  });

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

  @override
  Widget build(BuildContext context) {
    final likeCubit = context.read<LikeCubit>();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.thumb_up, color: Colors.amber, size: 28),
          SizedBox(width: 8),
          Text('Already Liked!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You\'ve already liked $dogName today.',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          StreamBuilder<Duration>(
            stream: likeCubit.getCooldownStream(dogId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text(
                  'You can like this dog again soon!',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                );
              }

              final remaining = snapshot.data!;
              final canLikeAgainAt = DateTime.now().add(remaining);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You can like again in:',
                    style: TextStyle(fontSize: 15, color: Colors.purple.shade700),
                  ),
                  const SizedBox(height: 8),
                  Container(
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
                  const SizedBox(height: 12),
                  Text(
                    'Come back at ${_formatTime(canLikeAgainAt)} to like again!',
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'OK',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }
}
