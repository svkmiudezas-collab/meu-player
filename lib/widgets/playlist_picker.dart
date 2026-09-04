import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../providers/player_provider.dart';
import '../theme.dart';

Future<String?> askName(BuildContext context,
    {String title = 'Nova playlist', String initial = ''}) {
  final ctrl = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Nome da playlist'),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, ctrl.text),
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}

/// Folha inferior para escolher em qual playlist colocar a música.
Future<void> showPlaylistPicker(BuildContext context, Song song) {
  final p = context.read<PlayerProvider>();
  return showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Adicionar "${song.title}" a',
                      style: Theme.of(ctx).textTheme.titleMedium,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_rounded, color: Palette.accent),
            title: const Text('Nova playlist'),
            onTap: () async {
              final name = await askName(ctx);
              if (name == null || name.trim().isEmpty) return;
              final pl = await p.createPlaylist(name);
              await p.addToPlaylist(pl, song.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
          ...p.playlists.map((pl) {
            final has = pl.songIds.contains(song.id);
            return ListTile(
              leading: Icon(has ? Icons.check_rounded : Icons.queue_music_rounded,
                  color: has ? Palette.accent : Palette.muted),
              title: Text(pl.name),
              subtitle: Text('${pl.songIds.length} músicas'),
              onTap: has
                  ? null
                  : () async {
                      await p.addToPlaylist(pl, song.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
