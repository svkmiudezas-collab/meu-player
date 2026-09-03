import 'package:hive_flutter/hive_flutter.dart';
import '../models/playlist.dart';
import '../models/song.dart';

/// Tudo que precisa sobreviver ao fechamento do app fica aqui (Hive, no disco).
class StorageService {
  late Box _songs; // cache da biblioteca
  late Box _meta; // favoritos, contagem de reproduções, etc.
  late Box _playlists;
  late Box _state; // última música, posição, fila, flags

  Future<void> init() async {
    await Hive.initFlutter();
    _songs = await Hive.openBox('songs');
    _meta = await Hive.openBox('song_meta');
    _playlists = await Hive.openBox('playlists');
    _state = await Hive.openBox('player_state');
  }

  // ---------- Biblioteca (cache) ----------
  List<Song> getCachedSongs() =>
      _songs.values.map((m) => Song.fromMap(m as Map)).toList();

  Future<void> cacheSongs(List<Song> songs) async {
    await _songs.clear();
    await _songs.putAll({for (final s in songs) s.id.toString(): s.toMap()});
  }

  // ---------- Metadados por música ----------
  SongMeta getMeta(int songId) =>
      SongMeta.fromMap(_meta.get(songId.toString()) as Map?);

  Future<void> setMeta(int songId, SongMeta meta) =>
      _meta.put(songId.toString(), meta.toMap());

  List<int> get favoriteIds => _meta.keys
      .where((k) => (_meta.get(k) as Map)['favorite'] == true)
      .map((k) => int.parse(k as String))
      .toList();

  // ---------- Playlists ----------
  List<Playlist> getPlaylists() {
    final list =
        _playlists.values.map((m) => Playlist.fromMap(m as Map)).toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<void> savePlaylist(Playlist p) => _playlists.put(p.id, p.toMap());
  Future<void> deletePlaylist(String id) => _playlists.delete(id);

  // ---------- Estado do player ----------
  bool get permissionGrantedOnce =>
      _state.get('permissionGranted', defaultValue: false) as bool;
  Future<void> setPermissionGranted() => _state.put('permissionGranted', true);

  Future<void> saveLastPlayed({
    required List<int> queueIds,
    required int index,
    required Duration position,
    required bool shuffle,
    required int loopMode,
  }) =>
      _state.putAll({
        'queueIds': queueIds,
        'index': index,
        'positionMs': position.inMilliseconds,
        'shuffle': shuffle,
        'loopMode': loopMode,
      });

  Map<String, dynamic>? getLastPlayed() {
    if (!_state.containsKey('queueIds')) return null;
    return {
      'queueIds': List<int>.from(_state.get('queueIds') as List),
      'index': _state.get('index') as int,
      'positionMs': _state.get('positionMs') as int,
      'shuffle': _state.get('shuffle', defaultValue: false) as bool,
      'loopMode': _state.get('loopMode', defaultValue: 0) as int,
    };
  }
}
