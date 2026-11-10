# Arranque rapido (Windows + MAMP)

1. MAMP: Start (MySQL verde).
2. MySQL Workbench: executar database/create.sql e depois database/populate.sql.
3. Pasta server: copiar .env.example para .env  (copy .env.example .env)
4. Terminal 1 (pasta server):  npm install   (so da 1.a vez)  e depois  npm start
   -> "ES Stock API a correr em http://localhost:3000"
   Teste: http://localhost:3000/saude  ->  {"estado":"ok"}
5. Terminal 2 (pasta app):  flutter create --project-name es_stock .   (so da 1.a vez)
   flutter pub get
   dart run tool/configurar_android.dart
   flutter run -d chrome
6. Login: dorivaldo.domingos@electrosmart.example / EsStock2026!

Porta 3000 ocupada (EADDRINUSE): netstat -ano | findstr :3000  e  taskkill /PID <numero> /F
Nao escrever os sinais < > nos comandos.
