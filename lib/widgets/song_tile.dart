import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/player_provider.dart';
import '../theme.dart';
import 'artwork.dart';
import 'playlist_picker.dart';

String formatDuration(Duration d) {
  final m = d.inMinutes.remainder(60).toString();
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return d.inHours > 0 ? '${d.inHours}:${m.padLeft(2, '0')}:$s' : '$m:$s';
}

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onRemove,
    this.trailingHandle,
  });

  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onRemove; // quando aparece dentro de uma playlist
  final Widget? trailingHandle;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final playing = p.current?.id == song.id;
    final fav = p.isFavorite(song.id);

    return ListTile(
      onTap: onTap,
      leading: Artwork(id: song.id, type: ArtworkType.AUDIO),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: playing ? Palette.accent : Palette.text,
        ),
      ),
      subtitle: Text(
        '${song.artist}  ${formatDuration(song.duration)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fav) const Icon(Icons.favorite, color: Palette.accent, size: 18),
          PopupMenuButton<String>(
            color: Palette.surfaceHigh,
            onSelected: (v) async {
              switch (v) {
                case 'fav':
                  p.toggleFavorite(song.id);
                case 'add':
                  showPlaylistPicker(context, song);
                case 'remove':
                  onRemove?.call();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'fav',
                child: Text(fav ? 'Remover dos favoritos' : 'Favoritar'),
              ),
              const PopupMenuItem(
                value: 'add', child: Text('Adicionar à playlist')),
              if (onRemove != null)
                const PopupMenuItem(
                  value: 'remove', child: Text('Remover desta playlist')),
            ],
          ),
          if (trailingHandle != null) trailingHandle!,
        ],
      ),
    );
  }
}
