import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/player_provider.dart';
import '../theme.dart';

/// Só aparece na primeira abertura (ou se a permissão for revogada nas
/// configurações do aparelho). Depois de concedida, o app entra direto.
class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Icon(Icons.library_music_rounded, size: 56, color: Palette.accent),
              const SizedBox(height: 24),
              Text('Suas músicas,\nno seu aparelho.',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 16),
              Text(
                'Para montar sua biblioteca, o app precisa ler os arquivos de '
                'áudio do celular. Você autoriza uma única vez e o acesso fica '
                'guardado nas próximas aberturas.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.read<PlayerProvider>().requestPermission(),
                  child: const Text('Permitir acesso às músicas'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
