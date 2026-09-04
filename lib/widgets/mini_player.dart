import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../screens/player_screen.dart';
import '../theme.dart';
import 'artwork.dart';

/// Barra fixa acima da navegação com a música atual.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final song = p.current;
    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const PlayerScreen(),
          transitionsBuilder: (_, a, __, child) => SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Palette.surfaceHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Artwork(id: song.id, type: ArtworkType.AUDIO, size: 44, radius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: p.previous,
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                StreamBuilder<bool>(
                  stream: p.player.playingStream,
                  builder: (_, s) => IconButton(
                    onPressed: p.togglePlay,
                    iconSize: 32,
                    color: Palette.accent,
                    icon: Icon((s.data ?? false)
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded),
                  ),
                ),
                IconButton(
                  onPressed: p.next,
                  icon: const Icon(Icons.skip_next_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            StreamBuilder<Duration>(
              stream: p.player.positionStream,
              builder: (_, s) {
                final total = song.durationMs;
                final v = total == 0 ? 0.0 : (s.data?.inMilliseconds ?? 0) / total;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: v.clamp(0, 1),
                    minHeight: 2,
                    backgroundColor: Palette.surface,
                    color: Palette.accent,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
