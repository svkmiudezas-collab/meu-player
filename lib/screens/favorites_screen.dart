import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../widgets/song_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PlayerProvider>();
    final favs = p.favorites;
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: favs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'Toque nos três pontos de qualquer música e escolha "Favoritar". Ela vai aparecer aqui.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: favs.length,
              itemBuilder: (_, i) => SongTile(
                song: favs[i], onTap: () => p.playQueue(favs, i)),
            ),
    );
  }
}
