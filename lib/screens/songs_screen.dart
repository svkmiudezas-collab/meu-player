import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../theme.dart';
import '../widgets/song_tile.dart';
import 'background_settings_screen.dart';

class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final q = _search.toLowerCase();
    final list = q.isEmpty
        ? p.songs
        : p.songs
            .where((s) => s.title.toLowerCase().contains(q) ||
                s.artist.toLowerCase().contains(q) ||
                s.album.toLowerCase().contains(q))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Músicas'),
        actions: [
          IconButton(
            tooltip: 'Segundo plano e notificações',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BackgroundSettingsScreen())),
            icon: const Icon(Icons.settings_outlined),
          ),
          if (p.scanning)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Palette.accent)),
            )
          else
            IconButton(
              tooltip: 'Procurar músicas novas',
              onPressed: p.rescan,
              icon: const Icon(Icons.refresh_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Buscar por título, artista ou álbum',
                prefixIcon: Icon(Icons.search_rounded, color: Palette.muted),
              ),
            ),
          ),
          if (list.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Row(
                children: [
                  Text('${list.length} músicas',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      await p.playQueue(list, 0);
                      await p.player.setShuffleModeEnabled(true);
                      await p.player.shuffle();
                    },
                    icon: const Icon(Icons.shuffle_rounded, size: 18),
                    label: const Text('Aleatório'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: list.isEmpty
                ? _Empty(status: p.status, hasSearch: q.isNotEmpty)
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) => SongTile(
                      song: list[i],
                      onTap: () => p.playQueue(list, i),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.status, required this.hasSearch});
  final LibraryStatus status;
  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    final msg = hasSearch
        ? 'Nada com esse nome na sua biblioteca.'
        : status == LibraryStatus.loading
            ? 'Procurando músicas no aparelho…'
            : 'Nenhuma música encontrada. Coloque arquivos de áudio no celular e toque em atualizar.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(msg, textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16)),
      ),
    );
  }
}
