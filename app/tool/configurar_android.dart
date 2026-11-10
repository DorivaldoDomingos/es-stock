// Prepara o Android para usar a API e a câmara.
// Executar na pasta da app, depois de "flutter create .":
//   dart run tool/configurar_android.dart
import 'dart:io';

void main() {
  final ficheiro = File('android/app/src/main/AndroidManifest.xml');
  if (!ficheiro.existsSync()) {
    stderr.writeln('Não encontrei android/app/src/main/AndroidManifest.xml. '
        'Corra primeiro "flutter create ." na pasta da app.');
    exit(1);
  }

  var texto = ficheiro.readAsStringSync();
  var alterado = false;

  const permissoes = [
    '<uses-permission android:name="android.permission.INTERNET"/>',
    '<uses-permission android:name="android.permission.CAMERA"/>',
  ];
  for (final p in permissoes) {
    final nome = RegExp(r'android:name="([^"]+)"').firstMatch(p)!.group(1)!;
    if (!texto.contains(nome)) {
      texto = texto.replaceFirst('<application', '$p\n    <application');
      alterado = true;
    }
  }

  // a API em http (sem certificado) precisa disto a partir do Android 9
  if (!texto.contains('usesCleartextTraffic')) {
    texto = texto.replaceFirst(
        '<application', '<application android:usesCleartextTraffic="true"');
    alterado = true;
  }

  if (alterado) {
    ficheiro.writeAsStringSync(texto);
    stdout.writeln('AndroidManifest.xml atualizado.');
  } else {
    stdout.writeln('AndroidManifest.xml já estava configurado.');
  }
}
