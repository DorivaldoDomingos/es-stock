#!/usr/bin/env bash
# =============================================================================
# ES Stock — Criação do GitHub Project via CLI (gh)
# Projeto Mobile · IADE / Universidade Europeia · L-EI · 2026-27 · Grupo 07
#
# O que este script faz:
#   1. Cria (ou reutiliza) o repositório do projeto
#   2. Cria as labels e as 3 milestones (1.ª, 2.ª e 3.ª entrega)
#   3. Cria o GitHub Project (v2) e liga-o ao repositório
#   4. Cria os campos: Área, Entrega, Prioridade, Início, Fim
#   5. Cria uma issue por tarefa (a partir do plano e da WBS), adiciona-a ao
#      Project e preenche os campos
#
# Requisitos: gh (>= 2.40), jq, git e sessão iniciada (gh auth login)
# Uso:        chmod +x criar_github_project.sh && ./criar_github_project.sh
#
# Variáveis opcionais (podem ser passadas no comando):
#   REPO_NAME=es-stock  VISIBILITY=private  ORG=<organização>  \
#   USER_ALCIDES=<user>  USER_DORIVALDO=<user>  USER_VLADMIR=<user>
# =============================================================================
set -euo pipefail

# ----------------------------- Configuração ----------------------------------
REPO_NAME="${REPO_NAME:-es-stock}"
VISIBILITY="${VISIBILITY:-private}"          # private | public
ORG="${ORG:-}"                               # vazio = conta pessoal
PROJECT_TITLE="${PROJECT_TITLE:-ES Stock — Projeto Mobile (Grupo 07)}"
REPO_DESC="ES Stock: aplicação móvel (Flutter/Dart) de gestão de inventário com QR Code para a ElectroSmart Solutions. Node.js REST + MySQL. Projeto Mobile, IADE 2026-27."

# Utilizadores GitHub dos elementos (opcional; sem valor, as issues ficam sem responsável)
USER_ALCIDES="${USER_ALCIDES:-}"     # Alcides Sequeira
USER_DORIVALDO="${USER_DORIVALDO:-}" # Dorivaldo Domingos
USER_VLADMIR="${USER_VLADMIR:-}"     # Vladmir Benoliel

# Datas das entregas (ano 2026)
D1="2026-10-02"; D2="2026-11-06"; D3="2026-12-11"

# ----------------------------- Utilitários -----------------------------------
c_ok()   { printf '\033[32m✔ %s\033[0m\n' "$*"; }
c_info() { printf '\033[34m➜ %s\033[0m\n' "$*"; }
c_err()  { printf '\033[31m✘ %s\033[0m\n' "$*" >&2; }

for bin in gh jq git; do
  command -v "$bin" >/dev/null 2>&1 || { c_err "Falta instalar: $bin"; exit 1; }
done

gh auth status >/dev/null 2>&1 || { c_err "Sem sessão no GitHub. Corre: gh auth login"; exit 1; }

# O comando 'gh project' precisa do scope 'project'
if ! gh auth status 2>&1 | grep -qi "project"; then
  c_info "A pedir o scope 'project' (abre o browser)..."
  gh auth refresh -s project
fi

LOGIN="$(gh api user --jq .login)"
OWNER="${ORG:-$LOGIN}"
PROJECT_OWNER="${ORG:-@me}"
REPO="$OWNER/$REPO_NAME"
c_info "Conta: $LOGIN · Repositório: $REPO"

# ----------------------------- 1. Repositório --------------------------------
if gh repo view "$REPO" >/dev/null 2>&1; then
  c_ok "Repositório já existe: $REPO"
else
  c_info "A criar o repositório $REPO ($VISIBILITY)..."
  gh repo create "$REPO" "--$VISIBILITY" --description "$REPO_DESC" \
     --add-readme >/dev/null
  c_ok "Repositório criado"
fi

# ----------------------------- 2. Labels -------------------------------------
c_info "A criar labels..."
mk_label() { gh label create "$1" --color "$2" --description "$3" --repo "$REPO" --force >/dev/null; }
mk_label "gestão"          "5319E7" "Planeamento, reuniões e GitHub Projects"
mk_label "análise"         "0E8A16" "Requisitos, modelo ER, personas"
mk_label "design"          "C6F135" "Mockups, usabilidade e Figma"
mk_label "base-de-dados"   "1D76DB" "MySQL: create, populate, queries"
mk_label "servidor"        "0B3A6F" "API REST em Node.js"
mk_label "app-flutter"     "02569B" "App móvel Flutter/Dart"
mk_label "testes"          "FBCA04" "Testes da API e de usabilidade"
mk_label "documentação"    "BFD4F2" "Relatórios, manual, poster e vídeo"
mk_label "prioridade-alta" "B60205" "Faz parte do MVP"
mk_label "prioridade-média" "D93F0B" "Importante mas não bloqueia o MVP"
mk_label "prioridade-baixa" "C2E0C6" "Extra, se houver tempo"
c_ok "Labels criadas"

# ----------------------------- 3. Milestones ---------------------------------
c_info "A criar milestones..."
mk_milestone() { # título, data, descrição
  local existing
  existing="$(gh api "repos/$REPO/milestones?state=all&per_page=100" --jq ".[] | select(.title==\"$1\") | .number")"
  if [ -z "$existing" ]; then
    gh api "repos/$REPO/milestones" -f title="$1" -f due_on="${2}T23:59:59Z" -f description="$3" >/dev/null
  fi
}
mk_milestone "1.ª Entrega — Proposta (02/10)" "$D1" "Proposta inicial, planeamento e mockups no Figma"
mk_milestone "2.ª Entrega — Protótipo alfa (06/11)" "$D2" "API Node.js, base de dados MySQL e app a ler QR e a consumir a API"
mk_milestone "3.ª Entrega — App final (11/12)" "$D3" "App completa em telemóvel real, documentação, poster e vídeo"
c_ok "Milestones criadas"
M1="1.ª Entrega — Proposta (02/10)"
M2="2.ª Entrega — Protótipo alfa (06/11)"
M3="3.ª Entrega — App final (11/12)"

# ----------------------------- 4. Project ------------------------------------
c_info "A criar o GitHub Project..."
EXISTING_NUM="$(gh project list --owner "$PROJECT_OWNER" --format json \
  --jq ".projects[] | select(.title==\"$PROJECT_TITLE\") | .number" 2>/dev/null | head -n1 || true)"

if [ -n "$EXISTING_NUM" ]; then
  PNUM="$EXISTING_NUM"
  c_ok "Project já existe (#$PNUM) — a reutilizar"
else
  PNUM="$(gh project create --owner "$PROJECT_OWNER" --title "$PROJECT_TITLE" --format json --jq .number)"
  c_ok "Project criado (#$PNUM)"
fi

gh project edit "$PNUM" --owner "$PROJECT_OWNER" \
  --description "Planeamento e acompanhamento do ES Stock (Flutter + Node.js + MySQL)." \
  --readme "# ES Stock — Grupo 07
Aplicação móvel de inventário com QR Code para a ElectroSmart Solutions (empresa fictícia).

**Entregas:** 02/10 · 06/11 · 11/12 (2026)
**Equipa:** Alcides Sequeira · Dorivaldo Domingos · Vladmir Benoliel
**Docente:** Fábio Guilherme

Estados: Todo → In Progress → Done." >/dev/null

gh project link "$PNUM" --owner "$PROJECT_OWNER" --repo "$REPO" >/dev/null 2>&1 || true
c_ok "Project ligado ao repositório"

PROJECT_ID="$(gh project view "$PNUM" --owner "$PROJECT_OWNER" --format json --jq .id)"
PROJECT_URL="$(gh project view "$PNUM" --owner "$PROJECT_OWNER" --format json --jq .url)"

# ----------------------------- 5. Campos -------------------------------------
c_info "A criar campos personalizados..."
have_field() { gh project field-list "$PNUM" --owner "$PROJECT_OWNER" --format json \
  --jq ".fields[] | select(.name==\"$1\") | .id" | grep -q .; }

have_field "Área"       || gh project field-create "$PNUM" --owner "$PROJECT_OWNER" --name "Área" \
  --data-type SINGLE_SELECT \
  --single-select-options "Gestão,Análise e desenho,Base de dados,Servidor REST,App Flutter,Testes,Documentação" >/dev/null
have_field "Entrega"    || gh project field-create "$PNUM" --owner "$PROJECT_OWNER" --name "Entrega" \
  --data-type SINGLE_SELECT --single-select-options "1.ª (02/10),2.ª (06/11),3.ª (11/12)" >/dev/null
have_field "Prioridade" || gh project field-create "$PNUM" --owner "$PROJECT_OWNER" --name "Prioridade" \
  --data-type SINGLE_SELECT --single-select-options "Alta,Média,Baixa" >/dev/null
have_field "Início"     || gh project field-create "$PNUM" --owner "$PROJECT_OWNER" --name "Início" --data-type DATE >/dev/null
have_field "Fim"        || gh project field-create "$PNUM" --owner "$PROJECT_OWNER" --name "Fim" --data-type DATE >/dev/null
c_ok "Campos criados"

FIELDS_JSON="$(gh project field-list "$PNUM" --owner "$PROJECT_OWNER" --format json)"
fid()  { jq -r --arg n "$1" '.fields[] | select(.name==$n) | .id' <<<"$FIELDS_JSON"; }
oid()  { jq -r --arg f "$1" --arg o "$2" '.fields[] | select(.name==$f) | .options[] | select(.name==$o) | .id' <<<"$FIELDS_JSON"; }

F_AREA="$(fid "Área")"; F_ENTR="$(fid "Entrega")"; F_PRIO="$(fid "Prioridade")"
F_INI="$(fid "Início")"; F_FIM="$(fid "Fim")";     F_STAT="$(fid "Status")"

set_select() { gh project item-edit --id "$1" --project-id "$PROJECT_ID" --field-id "$2" --single-select-option-id "$3" >/dev/null; }
set_date()   { gh project item-edit --id "$1" --project-id "$PROJECT_ID" --field-id "$2" --date "$3" >/dev/null; }

# ----------------------------- 6. Tarefas ------------------------------------
# Formato: Título | Área | Entrega(1/2/3) | Prioridade | Início | Fim | Resp(A/D/V/-) | Label | Estado | Descrição
TASKS=$(cat <<'EOF'
Proposta inicial (relatório g07-proposta-v1)|Documentação|1|Alta|2026-09-28|2026-10-02|D|documentação|Done|Relatório com os 11 pontos do briefing, anexos e bibliografia. PDF com o nome indicado no enunciado.
Mockups no Figma (14 ecrãs, 3 guiões)|Análise e desenho|1|Alta|2026-09-28|2026-10-02|A|design|Done|14 ecrãs 390×844, guia de estilo e componentes. Exportar imagens para o arquivo (≥10 imagens, lado maior ≥3000 px).
Configurar repositório, README e GitHub Projects|Gestão|1|Alta|2026-10-02|2026-10-04|D|gestão|In Progress|Estrutura de pastas, README, .gitignore, regras de branches e este quadro.
Requisitos funcionais e não funcionais|Análise e desenho|2|Alta|2026-10-04|2026-10-18|A|análise|Todo|Fechar RF01–RF11 e RNF01–RNF07, com prioridades e critérios de aceitação.
Modelo entidade-relação (MySQL Workbench)|Análise e desenho|2|Alta|2026-10-04|2026-10-18|D|base-de-dados|Todo|ER com Utilizador, Categoria, Localização, Artigo, Movimento e Alerta. Base do create.sql.
Personas e guiões de teste finais|Análise e desenho|2|Média|2026-10-11|2026-10-25|A|design|Todo|Rever as 3 personas e os 3 guiões com a UC de Interfaces e Usabilidade.
create.sql e populate.sql (dados fictícios)|Base de dados|2|Alta|2026-10-11|2026-10-28|D|base-de-dados|Todo|Criação das tabelas e povoamento com dados fictícios (RGPD).
queries.sql, views e stored procedures|Base de dados|2|Média|2026-10-25|2026-11-05|D|base-de-dados|Todo|Consultas de stock, movimentos e alertas; views e procedimentos.
API REST: autenticação (login, JWT, bcrypt)|Servidor REST|2|Alta|2026-10-11|2026-10-25|V|servidor|Todo|POST /auth/login com hash bcrypt e token JWT.
API REST: artigos (CRUD, QR e filtros)|Servidor REST|2|Alta|2026-10-18|2026-11-05|V|servidor|Todo|GET/POST/PUT /artigos e GET /artigos/:id (também pelo código QR).
API REST: movimentos e alertas|Servidor REST|3|Alta|2026-10-25|2026-11-15|V|servidor|Todo|POST/GET /movimentos e GET /alertas; impedir saída maior que o stock.
Flutter: estrutura MVC, navegação e ecrã de login|App Flutter|2|Alta|2026-10-11|2026-10-28|A|app-flutter|Todo|models/, services/, screens/, widgets/, providers/. Ecrãs 01 e 02.
Flutter: leitura de QR e ficha do artigo|App Flutter|2|Alta|2026-10-25|2026-11-05|V|app-flutter|Todo|Pacote mobile_scanner; consumir GET /artigos/:id. Ecrãs 03 e 04.
Flutter: registo de entradas e saídas|App Flutter|3|Alta|2026-11-01|2026-11-22|V|app-flutter|Todo|Ecrãs 05, 06, 10 e 11, ligados à API de movimentos.
Flutter: lista, novo artigo e QR gerado|App Flutter|3|Alta|2026-11-01|2026-11-22|A|app-flutter|Todo|Ecrãs 07, 08 e 09; qr_flutter para a etiqueta.
Flutter: alertas, histórico e filtros|App Flutter|3|Média|2026-11-08|2026-12-01|A|app-flutter|Todo|Ecrãs 12, 13 e 14.
Relatório intermédio e BD Report|Documentação|2|Alta|2026-10-25|2026-11-06|D|documentação|Todo|Relatório da 2.ª entrega e relatório de Bases de Dados.
Documentação da API REST|Documentação|3|Média|2026-11-08|2026-11-28|V|documentação|Todo|Formato indicado no briefing (ver Bocoup, Documenting Your API).
Testes da API (Postman / REST Client)|Testes|3|Média|2026-11-08|2026-11-22|V|testes|Todo|Coleção de pedidos para todos os endpoints.
Testes de usabilidade e correções|Testes|3|Alta|2026-11-22|2026-12-06|A|testes|Todo|Testes com utilizadores, heurísticas de Nielsen e lista de correções.
Teste da app em telemóvel real (Android)|Testes|3|Alta|2026-11-22|2026-12-06|V|testes|Todo|Registo de movimento em menos de 30 segundos.
Manual, poster, vídeo e slides finais|Documentação|3|Alta|2026-11-22|2026-12-11|D|documentação|Todo|Materiais da apresentação final.
Extra: notificação local de stock baixo|App Flutter|3|Baixa|2026-11-22|2026-12-08|V|app-flutter|Todo|RF11, só se houver tempo.
Extra: estatísticas e simulação de Monte Carlo|App Flutter|3|Baixa|2026-11-22|2026-12-08|D|app-flutter|Todo|RF10 e extra de Matemática Discreta (a confirmar com os docentes).
EOF
)

user_of() { case "$1" in A) echo "$USER_ALCIDES";; D) echo "$USER_DORIVALDO";; V) echo "$USER_VLADMIR";; *) echo "";; esac; }
milestone_of() { case "$1" in 1) echo "$M1";; 2) echo "$M2";; *) echo "$M3";; esac; }
entrega_of()   { case "$1" in 1) echo "1.ª (02/10)";; 2) echo "2.ª (06/11)";; *) echo "3.ª (11/12)";; esac; }
prio_label()   { case "$1" in Alta) echo "prioridade-alta";; Média) echo "prioridade-média";; *) echo "prioridade-baixa";; esac; }

c_info "A criar issues e a preencher o Project..."
N=0
while IFS='|' read -r -u 3 TITLE AREA ENTR PRIO INI FIM RESP LABEL STATE DESC; do
  [ -z "${TITLE:-}" ] && continue
  N=$((N+1))

  # Evita duplicados se o script for corrido outra vez
  EXIST_URL="$(gh issue list --repo "$REPO" --state all --search "\"$TITLE\" in:title" \
      --json title,url --jq ".[] | select(.title==\"$TITLE\") | .url" | head -n1 || true)"

  if [ -n "$EXIST_URL" ]; then
    ISSUE_URL="$EXIST_URL"
  else
    ARGS=(--repo "$REPO" --title "$TITLE"
          --label "$LABEL" --label "$(prio_label "$PRIO")"
          --milestone "$(milestone_of "$ENTR")"
          --body "## Descrição
$DESC

## Critérios de conclusão
- [ ] Implementado ou redigido
- [ ] Revisto por outro elemento do grupo
- [ ] Integrado no ramo \`main\`

**Prazo:** $FIM · **Entrega:** $(entrega_of "$ENTR")")
    U="$(user_of "$RESP")"; [ -n "$U" ] && ARGS+=(--assignee "$U")
    ISSUE_URL="$(gh issue create "${ARGS[@]}")"
  fi

  ITEM_ID="$(gh project item-add "$PNUM" --owner "$PROJECT_OWNER" --url "$ISSUE_URL" --format json --jq .id)"

  set_select "$ITEM_ID" "$F_AREA" "$(oid "Área" "$AREA")"
  set_select "$ITEM_ID" "$F_ENTR" "$(oid "Entrega" "$(entrega_of "$ENTR")")"
  set_select "$ITEM_ID" "$F_PRIO" "$(oid "Prioridade" "$PRIO")"
  set_date   "$ITEM_ID" "$F_INI" "$INI"
  set_date   "$ITEM_ID" "$F_FIM" "$FIM"
  set_select "$ITEM_ID" "$F_STAT" "$(oid "Status" "$STATE" 2>/dev/null || true)" 2>/dev/null || true

  # Tarefas já concluídas: fechar a issue
  if [ "$STATE" = "Done" ]; then gh issue close "$ISSUE_URL" --repo "$REPO" >/dev/null 2>&1 || true; fi
  printf '  %02d. %s\n' "$N" "$TITLE"
done 3<<< "$TASKS"
c_ok "$N tarefas criadas e adicionadas ao Project"

# ----------------------------- Resumo ----------------------------------------
cat <<EOF

=====================================================================
 Tudo pronto.
   Repositório : https://github.com/$REPO
   Project     : $PROJECT_URL

 Falta fazer à mão (o gh ainda não cria vistas):
   1. Abrir o Project > "+ New view" e criar:
        • Quadro (Board)   agrupado por Status
        • Tabela (Table)   com Área, Entrega, Prioridade, Início, Fim
        • Roadmap          com Início/Fim para ver o Gantt
   2. Project > Settings > Manage access: adicionar os 3 elementos e o
      docente Fábio Guilherme (Settings do repositório > Collaborators).
   3. Atribuir responsáveis nas issues, se não passaste USER_* ao script.
   4. Colar o link do repositório na capa do relatório.
=====================================================================
EOF
