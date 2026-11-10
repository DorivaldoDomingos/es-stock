# Guia: testar a app no telemóvel com o computador como servidor

O computador corre a base de dados MySQL e a API; o telemóvel Android liga-se por Wi-Fi.

## Antes de começar
- Computador e telemóvel **na mesma rede Wi-Fi**.
- MySQL a correr e a base `es_stock` criada e populada (`database/create.sql` e `populate.sql`).
- Servidor a correr: `cd server`, `npm start`. Deve aparecer `ES Stock API a correr em http://localhost:3000`.

## 1. Preparar a rede (uma vez)
1. Abrir o PowerShell **como administrador**.
2. Executar: `powershell -ExecutionPolicy Bypass -File scripts\preparar_rede_local.ps1`
3. O script abre a porta 3000 na firewall e mostra o IP do computador, por exemplo `http://192.168.1.20:3000`.

Para confirmar, abrir no browser do telemóvel `http://192.168.1.20:3000/saude`. Deve aparecer `{"estado":"ok"}`. Se não aparecer, ver "Se não ligar".

## 2. Gerar o APK
Na pasta `app`, depois de `flutter create .` e `dart run tool/configurar_android.dart`:

```bash
flutter pub get
flutter build apk --release
```

O ficheiro fica em `app/build/app/outputs/flutter-apk/app-release.apk`. Para já levar o endereço certo: `flutter build apk --release --dart-define=API_URL=http://192.168.1.20:3000`.

## 3. Instalar no telemóvel
- **Por cabo:** ativar a depuração USB no telemóvel e executar `flutter install` (ou `adb install -r app-release.apk`).
- **Sem cabo:** enviar o `.apk` para o telemóvel (WhatsApp, email ou Drive), abri-lo e permitir a instalação de fontes desconhecidas.

## 4. Ligar a app ao servidor
No ecrã de login, tocar em **Servidor: ...** no rodapé, escrever `192.168.1.20:3000` e guardar. O endereço fica guardado no telemóvel. Entrar com um utilizador de teste ou tocar em **Criar conta**.

## 5. Ler o QR com a câmara
1. Na app, como gestor, abrir Artigos e um artigo, menu ⋮ e **Ver QR Code**.
2. Mostrar o QR no ecrã do computador (ou imprimi-lo) e, noutro telemóvel ou no mesmo, tocar no botão central e apontar a câmara.
3. A app abre a ficha do artigo e daí regista-se a saída ou a entrada.

## Se não ligar
| Sintoma | O que fazer |
|---|---|
| `/saude` não abre no telemóvel | Confirmar o IP, a mesma rede e a regra de firewall; a rede do Windows tem de ser **Privada** |
| Funciona em casa e não na universidade | O Wi-Fi da universidade pode isolar os dispositivos. Ligar o computador à **partilha de internet do telemóvel** e usar o IP que o computador receber |
| A app diz "Não foi possível ligar ao servidor" | Verificar o endereço no rodapé do login e se o `npm start` está a correr |
| O IP mudou | Executar outra vez o script, ver o novo IP e alterá-lo no rodapé do login |
| Erro ao compilar o APK | `flutter doctor` e `flutter doctor --android-licenses` |

## Antes da apresentação
- Testar tudo na rede que vão usar, com antecedência.
- Ter o plano B: partilha de internet do telemóvel de um elemento do grupo.
- Ter a app também aberta no Chrome (`flutter run -d chrome`) caso o telemóvel falhe.
