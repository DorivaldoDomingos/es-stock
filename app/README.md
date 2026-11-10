# app/
App Flutter do ES Stock, no padrão models / controllers / views, a consumir a API REST.

```
lib/
├── main.dart, routes.dart
├── models/        # Artigo, Movimento (+ filtro e resultado), Estatistica; fromJson da API
├── controllers/   # artigo, movimento, utilizador, estatistica e dados (carregam da API e guardam em memória)
├── services/      # api_service.dart: pedidos HTTP, token e tratamento de erros
└── views/         # ecrãs, tema e widgets reutilizáveis
tool/configurar_android.dart   # permissões Android (internet e câmara)
test/widget_test.dart
```

## Executar

Com a base de dados e o servidor a correr (ver README principal):

```bash
flutter create .                       # só da primeira vez
dart run tool/configurar_android.dart  # só para Android
flutter pub get
flutter run -d chrome
```

Login de teste: `dorivaldo.domingos@electrosmart.example` (gestor) ou `alcides.sequeira@electrosmart.example` (operador), palavra-passe `EsStock2026!`.

O endereço do servidor aparece no rodapé do login e pode ser mudado ali. Emulador Android: `http://10.0.2.2:3000`. Telemóvel real: o IP do computador, na mesma rede Wi-Fi.

## Caminhos para testar

1. **Saída:** entrar como Alcides, tocar no botão do QR, introduzir `ES-SEN-0023`, registar saída de 3 unidades com destino. O artigo passa para os Alertas.
2. **Entrada:** na ficha do mesmo artigo, registar entrada de 3. Sai dos Alertas.
3. **Conta nova:** no login tocar em «Criar conta», preencher e entrar; a conta é de operador.
4. **Gestor:** entrar como Dorivaldo, Artigos → Novo artigo (o código é gerado) e Início → Estatísticas e stock mínimo → Aplicar sugestão.

## Dependências

`http` (pedidos à API), `shared_preferences` (guarda o endereço do servidor), `qr_flutter` (gerar o QR do artigo) e `mobile_scanner` (ler o QR com a câmara; no browser não é usado).
