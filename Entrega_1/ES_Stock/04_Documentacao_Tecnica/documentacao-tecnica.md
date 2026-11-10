# Documentação técnica (versão preliminar)

## Arquitetura
Ver `../02_Imagens/img_15.jpg`. Camadas: app Flutter, servidor Node.js + Express, MySQL.

## Organização do código (MVC)
- App: `models/`, `services/`, `screens/`, `widgets/`, `providers/`
- Servidor: `routes/`, `controllers/`, `models/`, acesso a dados

## Modelo de domínio e ER
`../02_Imagens/img_16.jpg` (domínio) e `img_17.jpg` (ER).

## Entidades
Utilizador, Categoria, Localizacao, Artigo, Movimento, Alerta.

## Endpoints previstos
`POST /auth/login` · `GET/POST /artigos` · `GET/PUT /artigos/:id` · `GET/POST /movimentos` · `GET /alertas`

## Regras de negócio
- Uma saída não pode exceder o stock atual.
- Se `stock_atual < stock_minimo` após um movimento, cria-se um alerta.
- O código QR do artigo é o seu código único (por exemplo, `ES-CAM-0042`).
