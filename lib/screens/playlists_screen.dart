import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/playlist.dart';
import '../providers/player_provider.dart';
import '../theme.dart';
import '../widgets/playlist_picker.dart';
import '../widgets/song_tile.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Palette.accent,
        foregroundColor: Palette.bg,
        onPressed: () async {
          final name = await askName(context);
          if (name != null && name.trim().isNotEmpty) p.createPlaylist(name);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova playlist'),
      ),
      body: p.playlists.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'Crie uma playlist e adicione músicas pelo menu de cada faixa. Elas ficam salvas mesmo depois de fechar o app.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 160),
              itemCount: p.playlists.length,
              itemBuilder: (_, i) {
                final pl = p.playlists[i];
                return ListTile(
                  leading: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: Palette.surfaceHigh, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.queue_music_rounded, color: Palette.accent),
                  ),
                  title: Text(pl.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${pl.songIds.length} músicas'),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlist: pl))),
                  trailing: PopupMenuButton<String>(
                    color: Palette.surfaceHigh,
                    onSelected: (v) async {
                      if (v == 'rename') {
                        final n = await askName(context, title: 'Renomear', initial: pl.name);
                        if (n != null && n.trim().isNotEmpty) p.renamePlaylist(pl, n);
                      } else if (v == 'delete') {
                        p.deletePlaylist(pl);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('Renomear')),
                      PopupMenuItem(value: 'delete', child: Text('Excluir')),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({super.key, required this.playlist});
  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final songs = p.songsOf(playlist);

    return Scaffold(
      appBar: AppBar(title: Text(playlist.name, style: const TextStyle(fontSize: 22))),
      body: songs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'Playlist vazia. Na aba Músicas, abra o menu de uma faixa e escolha "Adicionar à playlist".',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    children: [
                      FilledButton.icon(
                        onPressed: () => p.playQueue(songs, 0),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Tocar'),
                      ),
                      const SizedBox(width: 12),
                      Text('Arraste para reordenar',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    itemCount: songs.length,
                    onReorder: (a, b) => p.reorderPlaylist(playlist, a, b),
                    itemBuilder: (_, i) => SongTile(
                      key: ValueKey(songs[i].id),
                      song: songs[i],
                      onTap: () => p.playQueue(songs, i),
                      onRemove: () => p.removeFromPlaylist(playlist, songs[i].id),
                      trailingHandle: ReorderableDragStartListener(
                        index: i,
                        child: const Icon(Icons.drag_handle_rounded, color: Palette.muted),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
