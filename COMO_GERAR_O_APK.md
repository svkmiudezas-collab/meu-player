# Como gerar o APK sem instalar nada

1. Crie uma conta em https://github.com e clique em **New repository**. Dê o nome `meu-player` e deixe **Public**.
2. Na página do repositório vazio, clique em **uploading an existing file** e arraste TODO o conteúdo desta pasta
   (inclusive a pasta oculta `.github`). Clique em **Commit changes**.
   - Se o seu navegador não enviar a pasta `.github`, crie o arquivo manualmente: **Add file > Create new file**,
     nome `.github/workflows/build-apk.yml`, e cole o conteúdo do arquivo de mesmo nome que está aqui.
3. Abra a aba **Actions**. A tarefa "Gerar APK" começa sozinha e leva de 5 a 10 minutos.
4. Quando ficar verde, clique nela e, na seção **Artifacts**, baixe `meu-player-apk`. Dentro do zip está o `app-release.apk`.
5. Envie o APK para o celular (WhatsApp, Drive, cabo) e toque nele para instalar.
   O Android vai pedir para permitir "instalar apps de fontes desconhecidas"; aceite só para essa instalação.
6. Na primeira abertura o app pede a permissão de ler as músicas. Depois disso ela fica salva.

Se a tarefa ficar vermelha, abra-a, copie a mensagem de erro e me envie que eu corrijo.
