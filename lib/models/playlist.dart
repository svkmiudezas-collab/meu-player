/// Playlist criada pelo usuário (os "álbuns favoritos").
class Playlist {
  final String id;
  String name;
  List<int> songIds;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    List<int>? songIds,
    DateTime? createdAt,
  })  : songIds = songIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'songIds': songIds,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Playlist.fromMap(Map map) => Playlist(
        id: map['id'] as String,
        name: map['name'] as String,
        songIds: List<int>.from(map['songIds'] as List? ?? []),
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}
