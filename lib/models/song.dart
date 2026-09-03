import 'package:on_audio_query/on_audio_query.dart';

/// Música do aparelho, num formato próprio para poder ser salva no Hive
/// e reaparecer imediatamente ao abrir o app, antes mesmo de uma nova varredura.
class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final int? albumId;
  final int durationMs;
  final String uri;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.albumId,
    required this.durationMs,
    required this.uri,
  });

  Duration get duration => Duration(milliseconds: durationMs);

  factory Song.fromModel(SongModel m) => Song(
        id: m.id,
        title: m.title,
        artist: (m.artist == null || m.artist == '<unknown>')
            ? 'Artista desconhecido'
            : m.artist!,
        album: (m.album == null || m.album == '<unknown>')
            ? 'Álbum desconhecido'
            : m.album!,
        albumId: m.albumId,
        durationMs: m.duration ?? 0,
        uri: m.uri ?? m.data,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'albumId': albumId,
        'durationMs': durationMs,
        'uri': uri,
      };

  factory Song.fromMap(Map map) => Song(
        id: map['id'] as int,
        title: map['title'] as String,
        artist: map['artist'] as String,
        album: map['album'] as String,
        albumId: map['albumId'] as int?,
        durationMs: map['durationMs'] as int,
        uri: map['uri'] as String,
      );
}

/// Informações que o usuário gera sobre cada música e que ficam salvas.
class SongMeta {
  bool favorite;
  int playCount;
  DateTime? lastPlayed;

  SongMeta({this.favorite = false, this.playCount = 0, this.lastPlayed});

  Map<String, dynamic> toMap() => {
        'favorite': favorite,
        'playCount': playCount,
        'lastPlayed': lastPlayed?.millisecondsSinceEpoch,
      };

  factory SongMeta.fromMap(Map? map) {
    if (map == null) return SongMeta();
    return SongMeta(
      favorite: map['favorite'] as bool? ?? false,
      playCount: map['playCount'] as int? ?? 0,
      lastPlayed: map['lastPlayed'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['lastPlayed'] as int),
    );
  }
}
