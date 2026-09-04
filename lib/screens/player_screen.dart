import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../theme.dart';
import '../widgets/artwork.dart';
import '../widgets/playlist_picker.dart';
import '../widgets/song_tile.dart';

/// Tela cheia: a capa grande e o título pesado são o ponto de destaque do app.
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final song = p.current;
    if (song == null) {
      return const Scaffold(body: Center(child: Text('Nada tocando')));
    }
    final fav = p.isFavorite(song.id);
    final meta = p.metaOf(song.id);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => showPlaylistPicker(context, song),
                    icon: const Icon(Icons.playlist_add_rounded),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: LayoutBuilder(
                  builder: (_, c) => Artwork(
                    id: song.id, type: ArtworkType.AUDIO,
                    size: c.maxWidth, radius: 24),
                ),
              ),
              const SizedBox(height: 36),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.title,
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 6),
                        Text('${song.artist}  ${song.album}',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15)),
                        if (meta.playCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              meta.playCount == 1
                                  ? 'Tocada 1 vez'
                                  : 'Tocada ${meta.playCount} vezes',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => p.toggleFavorite(song.id),
                    iconSize: 30,
                    color: fav ? Palette.accent : Palette.muted,
                    icon: Icon(fav ? Icons.favorite_rounded : Icons.favorite_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SeekBar(player: p.player, total: song.duration),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: p.toggleShuffle,
                    color: p.player.shuffleModeEnabled ? Palette.accent : Palette.muted,
                    icon: const Icon(Icons.shuffle_rounded),
                  ),
                  IconButton(
                    onPressed: p.previous,
                    iconSize: 40,
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  StreamBuilder<bool>(
                    stream: p.player.playingStream,
                    builder: (_, s) => IconButton(
                      onPressed: p.togglePlay,
                      iconSize: 78,
                      color: Palette.accent,
                      icon: Icon((s.data ?? false)
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded),
                    ),
                  ),
                  IconButton(
                    onPressed: p.next,
                    iconSize: 40,
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                  IconButton(
                    onPressed: p.cycleLoop,
                    color: p.player.loopMode == LoopMode.off ? Palette.muted : Palette.accent,
                    icon: Icon(p.player.loopMode == LoopMode.one
                        ? Icons.repeat_one_rounded
                        : Icons.repeat_rounded),
                  ),
                ],
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeekBar extends StatelessWidget {
  const _SeekBar({required this.player, required this.total});
  final AudioPlayer player;
  final Duration total;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (_, s) {
        final pos = s.data ?? Duration.zero;
        final max = total.inMilliseconds.toDouble().clamp(1, double.infinity);
        return Column(
          children: [
            Slider(
              value: pos.inMilliseconds.toDouble().clamp(0, max),
              max: max,
              onChanged: (v) => player.seek(Duration(milliseconds: v.round())),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(pos), style: Theme.of(context).textTheme.bodyMedium),
                  Text(formatDuration(total), style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
