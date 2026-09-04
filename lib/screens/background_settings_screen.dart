import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../theme.dart';

/// Ajustes que fazem a notificação com controles e a reprodução em segundo
/// plano funcionarem em aparelhos com restrições agressivas (Xiaomi, Samsung, Huawei).
class BackgroundSettingsScreen extends StatefulWidget {
  const BackgroundSettingsScreen({super.key});

  @override
  State<BackgroundSettingsScreen> createState() => _BackgroundSettingsScreenState();
}

class _BackgroundSettingsScreenState extends State<BackgroundSettingsScreen>
    with WidgetsBindingObserver {
  bool _notif = false;
  bool _battery = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final lib = context.read<PlayerProvider>().library;
    final n = await lib.notificationsAllowed;
    final b = Platform.isAndroid ? await lib.batteryUnrestricted : true;
    if (mounted) setState(() { _notif = n; _battery = b; });
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.read<PlayerProvider>().library;
    final body = Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15, height: 1.5);

    return Scaffold(
      appBar: AppBar(title: const Text('Segundo plano', style: TextStyle(fontSize: 22))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          Text(
            'Para os controles aparecerem na barra de notificações e na tela de bloqueio, '
            'e para a música não parar quando você minimiza o app, confira os itens abaixo.',
            style: body,
          ),
          const SizedBox(height: 20),
          _Item(
            ok: _notif,
            title: 'Notificações permitidas',
            subtitle: 'É a notificação que mostra pausar, avançar e voltar.',
            action: 'Permitir',
            onTap: () async {
              await lib.ensureNotificationPermission();
              await _refresh();
              if (!_notif) lib.openSystemSettings();
            },
          ),
          if (Platform.isAndroid)
            _Item(
              ok: _battery,
              title: 'Bateria sem restrições',
              subtitle: 'Impede o sistema de encerrar a música em segundo plano.',
              action: 'Liberar',
              onTap: () async {
                await lib.requestIgnoreBatteryOptimizations();
                await _refresh();
              },
            ),
          if (Platform.isAndroid)
            _Item(
              ok: null,
              title: 'Início automático (Xiaomi, Redmi, POCO)',
              subtitle: 'Em Configurações › Apps › Gerenciar apps › Meu Player, ative '
                  '"Início automático" e, em "Economia de bateria", escolha "Sem restrições". '
                  'Em Notificações, ative "Mostrar na tela de bloqueio" e "Notificações flutuantes".',
              action: 'Abrir configurações',
              onTap: lib.openSystemSettings,
            ),
          const SizedBox(height: 24),
          Text(
            'Depois de ajustar, toque uma música e minimize o app: os controles devem aparecer '
            'na barra de notificações, na tela de bloqueio e, nos Xiaomi com HyperOS, na ilha de notificação.',
            style: body,
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.ok, required this.title, required this.subtitle,
      required this.action, required this.onTap});
  final bool? ok;
  final String title, subtitle, action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ok == null ? Icons.info_outline_rounded
                    : ok! ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                color: ok == true ? Palette.accent : Palette.muted,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4)),
          if (ok != true) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)),
                onPressed: onTap,
                child: Text(action),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
