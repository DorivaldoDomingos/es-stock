# Memória descritiva — ES Stock

## Enquadramento
A ElectroSmart Solutions é uma empresa fictícia de segurança eletrónica, redes, IoT e automação de edifícios. O controlo manual do material do armazém gera diferenças de stock, falta de material no momento da instalação e falta de rastreabilidade.

## Proposta
O ES Stock é uma app móvel em Flutter em que cada artigo tem um QR Code. A leitura com a câmara abre a ficha do artigo e permite registar entradas e saídas em poucos toques. O stock atualiza-se automaticamente, são gerados alertas de stock baixo e todos os movimentos ficam num histórico com filtros.

## Arquitetura
App Flutter (câmara + QR Code) → API REST Node.js/Express (MVC) → base de dados MySQL. A app comunica apenas com a API, em HTTP/JSON, com autenticação por token JWT. Ver `02_Imagens/img_15.jpg` e `04_Documentacao_Tecnica/`.

## Interfaces
Catorze ecrãs desenhados no Figma, organizados em três guiões: (1) saída de material, (2) novo artigo e entrada de stock, (3) alertas e histórico. Identidade visual em azul-marinho e verde-lima, tipografia Inter, botões grandes para uso com uma mão. Ver `05_Artefactos/` e `02_Imagens/`.

## Planeamento
Entregas a 02/10/2026, 06/11/2026 e 11/12/2026. Gráfico de Gantt em `02_Imagens/img_19.jpg` e WBS em `img_20.jpg`.

## Dados e RGPD
Todos os dados (utilizadores, artigos, movimentos, fornecedores) são fictícios. Não são tratados dados pessoais reais.

## Limitações da 1.ª entrega
Não existe ainda código funcional. A integração entre app, API e base de dados será feita na 2.ª entrega.
