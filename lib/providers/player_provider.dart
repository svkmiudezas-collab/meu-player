import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models/playlist.dart';
import '../models/song.dart';
import '../services/library_service.dart';
import '../services/storage_service.dart';

enum LibraryStatus { needsPermission, loading, ready, empty }

class PlayerProvider extends ChangeNotifier {
  PlayerProvider(this._storage, this._library);

  final StorageService _storage;
  final LibraryService _library;
  final AudioPlayer player = AudioPlayer();

  LibraryStatus status = LibraryStatus.loading;
  bool scanning = false;

  List<Song> songs = [];
  List<Song> queue = [];
  List<Playlist> playlists = [];

  final Map<int, Song> _byId = {};
  Timer? _saveTimer;
  StreamSubscription? _indexSub;
  StreamSubscription? _positionSub;

  // ---------- Leituras rápidas ----------
  Song? get current {
    final i = player.currentIndex;
    if (i == null || i < 0 || i >= queue.length) return null;
    return queue[i];
  }

  Song? byId(int id) => _byId[id];
  SongMeta metaOf(int id) => _storage.getMeta(id);
  bool isFavorite(int id) => _storage.getMeta(id).favorite;

  List<Song> get favorites =>
      _storage.favoriteIds.map(byId).whereType<Song>().toList();

  List<Song> songsOf(Playlist p) =>
      p.songIds.map(byId).whereType<Song>().toList();

  /// Álbuns do aparelho, agrupados a partir das músicas.
  Map<String, List<Song>> get albums {
    final map = <String, List<Song>>{};
    for (final s in songs) {
      map.putIfAbsent(s.album, () => []).add(s);
    }
    return map;
  }

  // ---------- Inicialização ----------
  Future<void> init() async {
    playlists = _storage.getPlaylists();

    // 1. Mostra imediatamente o que estava salvo da última vez.
    _setSongs(_storage.getCachedSongs());

    // 2. Se a permissão já foi dada antes, não pergunta de novo: só confere.
    final granted = await _library.ensurePermissionSilently();
    if (!granted) {
      status = songs.isEmpty ? LibraryStatus.needsPermission : LibraryStatus.ready;
      notifyListeners();
      return;
    }
    await _storage.setPermissionGranted();

    _listenToPlayer();
    await _restoreLastPlayed();
    status = songs.isEmpty ? LibraryStatus.loading : LibraryStatus.ready;
    notifyListeners();

    // 3. Revarre o aparelho em segundo plano para pegar músicas novas/removidas.
    await rescan();
  }

  /// Chamado pelo botão "Permitir acesso" na primeira abertura.
  Future<void> requestPermission() async {
    status = LibraryStatus.loading;
    notifyListeners();
    final granted = await _library.ensurePermission();
    if (!granted) {
      status = LibraryStatus.needsPermission;
      notifyListeners();
      return;
    }
    await _storage.setPermissionGranted();
    _listenToPlayer();
    await rescan();
  }

  Future<void> rescan() async {
    if (scanning) return;
    scanning = true;
    notifyListeners();
    try {
      final fresh = await _library.loadSongs();
      _setSongs(fresh);
      await _storage.cacheSongs(fresh);
      status = fresh.isEmpty ? LibraryStatus.empty : LibraryStatus.ready;
    } finally {
      scanning = false;
      notifyListeners();
    }
  }

  void _setSongs(List<Song> list) {
    songs = list;
    _byId
      ..clear()
      ..addEntries(list.map((s) => MapEntry(s.id, s)));
  }

  // ---------- Reprodução ----------
  Future<void> playQueue(List<Song> newQueue, int startIndex,
      {bool autoplay = true, Duration? position}) async {
    if (newQueue.isEmpty) return;
    queue = List.of(newQueue);
    final source = ConcatenatingAudioSource(
      children: queue.map(_toSource).toList(),
    );
    await player.setAudioSource(source,
        initialIndex: startIndex, initialPosition: position);
    if (autoplay) player.play();
    notifyListeners();
    _scheduleSave(immediate: true);
  }

  AudioSource _toSource(Song s) => AudioSource.uri(
        Uri.parse(s.uri),
        tag: MediaItem(
          id: s.id.toString(),
          title: s.title,
          artist: s.artist,
          album: s.album,
          duration: s.duration,
        ),
      );

  void togglePlay() => player.playing ? player.pause() : player.play();
  Future<void> next() => player.seekToNext();
  Future<void> previous() => player.seekToPrevious();
  Future<void> seek(Duration d) => player.seek(d);

  Future<void> toggleShuffle() async {
    final on = !player.shuffleModeEnabled;
    if (on) await player.shuffle();
    await player.setShuffleModeEnabled(on);
    notifyListeners();
    _scheduleSave(immediate: true);
  }

  Future<void> cycleLoop() async {
    const order = [LoopMode.off, LoopMode.all, LoopMode.one];
    final next = order[(order.indexOf(player.loopMode) + 1) % order.length];
    await player.setLoopMode(next);
    notifyListeners();
    _scheduleSave(immediate: true);
  }

  // ---------- Favoritos ----------
  Future<void> toggleFavorite(int id) async {
    final m = _storage.getMeta(id);
    m.favorite = !m.favorite;
    await _storage.setMeta(id, m);
    notifyListeners();
  }

  // ---------- Playlists ----------
  Future<Playlist> createPlaylist(String name) async {
    final p = Playlist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
    );
    await _storage.savePlaylist(p);
    playlists = _storage.getPlaylists();
    notifyListeners();
    return p;
  }

  Future<void> renamePlaylist(Playlist p, String name) async {
    p.name = name.trim();
    await _storage.savePlaylist(p);
    notifyListeners();
  }

  Future<void> deletePlaylist(Playlist p) async {
    await _storage.deletePlaylist(p.id);
    playlists = _storage.getPlaylists();
    notifyListeners();
  }

  Future<void> addToPlaylist(Playlist p, int songId) async {
    if (p.songIds.contains(songId)) return;
    p.songIds.add(songId);
    await _storage.savePlaylist(p);
    notifyListeners();
  }

  Future<void> removeFromPlaylist(Playlist p, int songId) async {
    p.songIds.remove(songId);
    await _storage.savePlaylist(p);
    notifyListeners();
  }

  Future<void> reorderPlaylist(Playlist p, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final id = p.songIds.removeAt(oldIndex);
    p.songIds.insert(newIndex, id);
    await _storage.savePlaylist(p);
    notifyListeners();
  }

  // ---------- Persistência do estado ----------
  void _listenToPlayer() {
    if (_indexSub != null) return;

    _indexSub = player.currentIndexStream.listen((i) {
      final s = current;
      if (s != null && player.playing) _countPlay(s.id);
      notifyListeners();
      _scheduleSave(immediate: true);
    });

    // Salva a posição a cada 5 s enquanto toca, e imediatamente ao pausar.
    _positionSub = player.positionStream.listen((_) => _scheduleSave());
    player.playingStream.listen((playing) {
      if (!playing) _scheduleSave(immediate: true);
      notifyListeners();
    });
  }

  Future<void> _countPlay(int id) async {
    final m = _storage.getMeta(id);
    m.playCount++;
    m.lastPlayed = DateTime.now();
    await _storage.setMeta(id, m);
  }

  void _scheduleSave({bool immediate = false}) {
    if (queue.isEmpty || player.currentIndex == null) return;
    if (immediate) {
      _saveTimer?.cancel();
      _saveTimer = null;
      _saveNow();
      return;
    }
    _saveTimer ??= Timer(const Duration(seconds: 5), () {
      _saveTimer = null;
      _saveNow();
    });
  }

  Future<void> _saveNow() => _storage.saveLastPlayed(
        queueIds: queue.map((s) => s.id).toList(),
        index: player.currentIndex ?? 0,
        position: player.position,
        shuffle: player.shuffleModeEnabled,
        loopMode: player.loopMode.index,
      );

  Future<void> _restoreLastPlayed() async {
    final last = _storage.getLastPlayed();
    if (last == null) return;
    final restored = (last['queueIds'] as List<int>)
        .map(byId)
        .whereType<Song>()
        .toList();
    if (restored.isEmpty) return;

    final index = (last['index'] as int).clamp(0, restored.length - 1);
    await player.setLoopMode(LoopMode.values[last['loopMode'] as int]);
    await player.setShuffleModeEnabled(last['shuffle'] as bool);
    try {
      await playQueue(restored, index,
          autoplay: false,
          position: Duration(milliseconds: last['positionMs'] as int));
    } catch (_) {
      // Arquivo pode ter sido apagado do aparelho; ignora e segue.
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _indexSub?.cancel();
    _positionSub?.cancel();
    player.dispose();
    super.dispose();
  }
}
