# 🗓️ Plano de Execução e Metodologia — Projeto 1 (Rota B)

Este documento registra a estruturação ágil e o planejamento de entregas do **Projeto 1: Análise Spotify (Rota B)**, desenvolvido no programa **Ativa sua Carreira — Laboratória Brasil**.

---

## 🎯 Estratégia de Execução (Sprint Acelerada)

Para viabilizar a entrega completa dos **dois projetos** previstos na trilha com alto rigor técnico, o desenvolvimento foi dividido em 4 blocos operacionais focados nos critérios de aceitação obrigatórios:

| Sprint / Bloco | Foco Principal | Metas Cobertas | Status |
| :--- | :--- | :--- | :--- |
| **Bloco 1: Negócio & Setup** | Definição do problema, formulação de hipóteses e ingestão no BigQuery | **Metas 0 e 1** | ✅ Concluído |
| **Bloco 2: Saneamento SQL** | Qualidade de dados (nulos, duplicatas, outliers categóricos/numéricos) e `JOIN` | **Metas 2 a 6** | ✅ Concluído |
| **Bloco 3: EDA & Insights** | Agregações, visualizações exploratórias, correlações e respostas ao negócio | **Metas 7 a 10** | ✅ Concluído |
| **Bloco 4: BI & Entrega** | Construção do painel interativo no Looker Studio e apresentação final | **Metas 11 e 12** | ✅ Concluído |

---

## 📋 Checklist Operacional por Habilidade (Rota B)

### 🔹 Etapa 1: Entendimento do Negócio e Ambiente
- [x] **Meta 0:** Utilizar IA para mapear o problema de negócio e formular as perguntas estratégicas.
- [x] **Meta 1:** Criar projeto (`laboratoria-dados`), dataset (`spotify`) e importar as tabelas (`track_in_spotify` e `track_in_competition`) no Google BigQuery com integração via VS Code.

### 🔹 Etapa 2: Preparação e Limpeza da Base (BigQuery / SQL)
- [x] **Meta 2:** Identificar e tratar valores nulos (`NULL`) em `track_in_spotify` e `track_in_competition`.
- [x] **Meta 3:** Identificar e remover registros duplicados exatos (`track_id`) e padronizar tipagem para cruzamento.
- [x] **Meta 4:** Tratar valores atípicos e inconsistências em variáveis categóricas (`main_country` e `main_music_genre`).
- [x] **Meta 5:** Tratar valores atípicos e *outliers* em variáveis numéricas, removendo o registro corrompido (`track_id: 4061483`) e consolidando 838 faixas únicas válidas.
- [x] **Meta 6:** Unir as tabelas tratadas (`vw_track_in_spotify_limpa` e `vw_track_in_competition_limpa`) utilizando `LEFT JOIN` e consolidando a view analítica `vw_spotify_consolidada` (838 registros únicos, 17 colunas).

### 🔹 Etapa 3: Exploração e Análise de Resultados
- [x] **Meta 7:** Agrupar e resumir dados em tabelas dinâmicas no Looker Studio conectadas à `vw_spotify_consolidada` (análise por `main_music_genre` com contagem distinta de `track_id`, soma/média de `streams` e média de `in_spotify_playlists`).
- [x] **Meta 8:** Visualizar e interpretar distribuições e tendências por meio de gráficos no Looker Studio (gráfico de colunas por `main_country` e gráfico de combinação mensal por `released_month` ordenado cronologicamente).
- [x] **Meta 9:** Calcular a matriz de correlação de Pearson (`CORR()`) no BigQuery e visualizar a dispersão com linha de tendência linear no Looker Studio (`in_spotify_playlists` $\times$ `streams`, $r = 0{,}7882$).
- [x] **Meta 10:** Responder formalmente às perguntas de negócio com base nas evidências encontradas (consultas comparativas de *charts* e colaborações + consolidação de insights e recomendações estratégicas).

### 🔹 Etapa 4: Visualização Executiva e Entrega
- [x] **Meta 11:** Construir o dashboard executivo interativo no Looker Studio conectado à `vw_spotify_consolidada` com KPIs compactados, filtros (`Gênero Musical`, `País`, `Ano de Lançamento`), grade visual (dispersão, países, tabela por gênero e sazonalidade mensal) e síntese de conclusões.
- [x] **Meta 12:** Estruturar roteiro com storytelling de dados para o comitê executivo, preparar a entrega na plataforma (Ficha Técnica + link do dashboard/apresentação) e alinhar o pitch para a sessão de reflexão.

---

## 💡 Boas Práticas Adotadas
- **Priorização do Essencial (MVP Analítico):** Foco total no cumprimento dos critérios obrigatórios antes de explorar análises secundárias.
- **Fluxo Iterativo:** Avanço sequencial entre preparação, exploração e visualização, retornando ao saneamento SQL sempre que novos ruídos forem identificados na EDA.
- **Documentação Contínua:** Registro imediato de todas as queries, decisões de tratamento de dados e achados na [`Ficha Técnica`](./ficha-tecnica.md).