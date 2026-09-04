import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'providers/player_provider.dart';
import 'screens/home_screen.dart';
import 'services/library_service.dart';
import 'services/storage_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'br.meuplayer.audio',
    androidNotificationChannelName: 'Reprodução de música',
    androidNotificationOngoing: true,
    // Ícone monocromático exclusivo para a notificação. O ícone adaptativo do
    // app não serve aqui e faria o Android descartar a notificação.
    androidNotificationIcon: 'drawable/ic_stat_music',
    // Mantém o serviço vivo mesmo pausado: evita que MIUI/HyperOS encerre o app.
    androidStopForegroundOnPause: false,
    androidShowNotificationBadge: true,
  );

  final storage = StorageService();
  await storage.init();

  final provider = PlayerProvider(storage, LibraryService());
  runApp(
    ChangeNotifierProvider.value(value: provider, child: const MeuPlayerApp()),
  );
  // Inicializa depois do primeiro frame para a tela abrir na hora.
  provider.init();
}

class MeuPlayerApp extends StatelessWidget {
  const MeuPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Player',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}
