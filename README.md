# Meu Player

Player de música para Android e iOS, feito em Flutter, que lê as músicas guardadas no aparelho
e mantém tudo o que você faz salvo entre aberturas do app.

## O que ele faz

- Lê os arquivos de áudio do celular (MP3, AAC, FLAC, OGG, WAV, etc.) via MediaStore/MPMediaLibrary.
- Pede a permissão de leitura **uma única vez**. Depois de concedida, o sistema a mantém e o app entra direto na biblioteca.
- Biblioteca em cache: ao abrir, as músicas aparecem na hora (do banco local) e o aparelho é revarrido em segundo plano.
- Favoritos, playlists (criar, renomear, excluir, reordenar, adicionar/remover músicas), contagem de reproduções e data da última vez tocada — tudo gravado em disco (Hive).
- Ao fechar e abrir de novo, a última fila, a música e a posição exata onde parou são restauradas (pausadas, prontas para continuar), inclusive modo aleatório e repetição.
- Controles na notificação e tela de bloqueio, reprodução em segundo plano.
- Abas: Músicas (com busca), Álbuns, Playlists, Favoritos; mini player fixo e tela cheia do player.

## Estrutura

```
lib/
  main.dart                  inicialização (Hive, áudio em segundo plano, Provider)
  theme.dart                 paleta e tema
  models/                    Song, SongMeta, Playlist (serializáveis para o Hive)
  services/
    storage_service.dart     tudo que persiste: cache da biblioteca, metadados, playlists, último estado
    library_service.dart     permissão e leitura das músicas do aparelho
  providers/
    player_provider.dart     estado central: reprodução, fila, favoritos, playlists, salvar/restaurar
  screens/                   telas
  widgets/                   mini player, tile de música, capa, seletor de playlist
android/app/src/main/AndroidManifest.xml   permissões e serviço de áudio
ios/Runner/Info.plist.adicionar.txt        chaves a adicionar no Info.plist
```

## Como rodar

1. Instale o Flutter (3.22 ou mais recente): https://docs.flutter.dev/get-started/install
2. Crie a casca nativa do projeto e copie estes arquivos por cima:
   ```bash
   flutter create --org br.meuplayer --project-name meu_player meu_player_novo
   # copie lib/, pubspec.yaml e README.md deste pacote para dentro de meu_player_novo/
   # substitua android/app/src/main/AndroidManifest.xml pelo daqui
   # adicione ao ios/Runner/Info.plist as chaves de ios/Runner/Info.plist.adicionar.txt
   ```
3. No `android/app/build.gradle`, garanta `minSdk = 21` (ou maior) e `compileSdk = 34`.
4. Instale as dependências e rode:
   ```bash
   cd meu_player_novo
   flutter pub get
   flutter run
   ```

## Sobre a permissão

- **Android 13+**: usa `READ_MEDIA_AUDIO`. **Android 12 ou anterior**: `READ_EXTERNAL_STORAGE`.
- Na primeira abertura aparece a tela "Permitir acesso às músicas". Ao tocar, o sistema mostra o diálogo nativo.
- Nas aberturas seguintes o app apenas confere `permissionsStatus()` sem abrir diálogo nenhum. A permissão só se perde se o usuário a revogar manualmente nas configurações do aparelho — nesse caso a tela inicial volta a aparecer.

## Onde os dados ficam salvos

Quatro caixas do Hive no armazenamento privado do app:

| Caixa          | Conteúdo                                                        |
|----------------|-----------------------------------------------------------------|
| `songs`        | cache da biblioteca (id, título, artista, álbum, duração, uri)  |
| `song_meta`    | por música: favorito, vezes tocada, última reprodução           |
| `playlists`    | playlists com nome, ordem das músicas e data de criação         |
| `player_state` | fila atual, índice, posição em ms, aleatório, repetição, flag de permissão |

A posição é gravada a cada 5 s durante a reprodução e imediatamente ao pausar ou trocar de faixa.
