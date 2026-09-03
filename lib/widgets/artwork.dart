import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../theme.dart';

/// Capa do álbum lida do aparelho, com um bloco discreto caso não exista.
class Artwork extends StatelessWidget {
  const Artwork({super.key, required this.id, required this.type,
      this.size = 52, this.radius = 10});

  final int id;
  final ArtworkType type;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: id,
      type: type,
      artworkWidth: size,
      artworkHeight: size,
      artworkBorder: BorderRadius.circular(radius),
      artworkFit: BoxFit.cover,
      keepOldArtwork: true,
      nullArtworkWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Palette.surfaceHigh,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(Icons.music_note_rounded,
            color: Palette.muted, size: size * 0.42),
      ),
    );
  }
}
