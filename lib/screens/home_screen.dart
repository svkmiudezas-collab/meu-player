import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../widgets/mini_player.dart';
import 'albums_screen.dart';
import 'favorites_screen.dart';
import 'permission_screen.dart';
import 'playlists_screen.dart';
import 'songs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final status = context.select<PlayerProvider, LibraryStatus>((p) => p.status);

    if (status == LibraryStatus.needsPermission) return const PermissionScreen();

    const pages = [SongsScreen(), AlbumsScreen(), PlaylistsScreen(), FavoritesScreen()];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.music_note_outlined),
                  selectedIcon: Icon(Icons.music_note_rounded),
                  label: 'Músicas'),
              NavigationDestination(
                  icon: Icon(Icons.album_outlined),
                  selectedIcon: Icon(Icons.album_rounded),
                  label: 'Álbuns'),
              NavigationDestination(
                  icon: Icon(Icons.queue_music_outlined),
                  selectedIcon: Icon(Icons.queue_music_rounded),
                  label: 'Playlists'),
              NavigationDestination(
                  icon: Icon(Icons.favorite_outline_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: 'Favoritos'),
            ],
          ),
        ],
      ),
    );
  }
}
