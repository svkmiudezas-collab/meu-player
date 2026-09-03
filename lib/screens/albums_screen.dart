import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/player_provider.dart';
import '../theme.dart';
import '../widgets/artwork.dart';
import '../widgets/song_tile.dart';

class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final albums = context.watch<PlayerProvider>().albums;
    final names = albums.keys.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Scaffold(
      appBar: AppBar(title: const Text('Álbuns')),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.78),
        itemCount: names.length,
        itemBuilder: (_, i) {
          final songs = albums[names[i]]!;
          final first = songs.first;
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AlbumDetailScreen(name: names[i], songs: songs)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, c) => Artwork(
                      id: first.albumId ?? first.id,
                      type: first.albumId != null ? ArtworkType.ALBUM : ArtworkType.AUDIO,
                      size: c.maxWidth, radius: 14),
                  ),
                ),
                const SizedBox(height: 8),
                Text(names[i], maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${first.artist}  ${songs.length} músicas',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AlbumDetailScreen extends StatelessWidget {
  const AlbumDetailScreen({super.key, required this.name, required this.songs});
  final String name;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    final p = context.read<PlayerProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(name, style: const TextStyle(fontSize: 22))),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: FilledButton.icon(
              onPressed: () => p.playQueue(songs, 0),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Tocar álbum'),
            ),
          ),
          ...List.generate(songs.length, (i) => SongTile(
                song: songs[i], onTap: () => p.playQueue(songs, i))),
          const SizedBox(height: 90),
        ],
      ),
      backgroundColor: Palette.bg,
    );
  }
}
