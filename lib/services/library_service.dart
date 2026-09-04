import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';

/// Lê as músicas do armazenamento do aparelho.
class LibraryService {
  final OnAudioQuery _query = OnAudioQuery();

  /// A permissão só é pedida ao sistema se ainda não foi concedida.
  /// Depois de concedida, o Android/iOS a mantém entre aberturas do app.
  Future<bool> ensurePermission() async {
    if (await _query.permissionsStatus()) return true;
    return _query.permissionsRequest();
  }

  /// Só confere se a permissão existe, sem abrir a caixa de diálogo do sistema.
  /// Usado na abertura do app: se já foi concedida, entra direto na biblioteca.
  Future<bool> ensurePermissionSilently() => _query.permissionsStatus();

  /// Android 13+ exige pedir a permissão de notificação em tempo de execução;
  /// sem ela os controles de pausar/avançar não aparecem na barra.
  Future<void> ensureNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) await Permission.notification.request();
  }

  Future<bool> get notificationsAllowed async =>
      (await Permission.notification.status).isGranted;

  /// Pede para ignorar otimização de bateria (necessário em Xiaomi, Samsung etc.).
  Future<void> requestIgnoreBatteryOptimizations() async {
    if (!await Permission.ignoreBatteryOptimizations.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  Future<bool> get batteryUnrestricted =>
      Permission.ignoreBatteryOptimizations.isGranted;

  Future<void> openSystemSettings() => openAppSettings();

  Future<List<Song>> loadSongs() async {
    final models = await _query.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    return models
        .where((m) => (m.isMusic ?? true) && (m.duration ?? 0) > 30000)
        .map(Song.fromModel)
        .toList();
  }
}
