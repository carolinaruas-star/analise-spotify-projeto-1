# 📄 Ficha Técnica: Projeto 1 – Análise Spotify (Rota B)

## 📌 Informações Gerais
- **Título do Projeto:** Análise Spotify (Rota B) — Performance de Playlists Editoriais e Sinais Precoces de Sucesso
- **Stakeholders (Contexto Simulado):** Marina Costa (VP de Produto), Rafael Tenório (Head de Curadoria Editorial) e Bianca Ferraz (Head de Analytics)
- **Objetivo:** Avaliar com rigor estatístico e exploratório se a presença em playlists editoriais impulsiona o volume de *streams* no Spotify (catálogo 2023) e identificar **sinais precoces** e padrões de catálogo (multiplataforma, gênero, país, colaborações e sazonalidade) para fundamentar a revisão orçamentária e a estratégia do time editorial.
- **Equipe:** Individual — Ana Carolina Pereira Ruas (`@carolinaruas-star`)
- **Programa:** Ativa sua Carreira — Laboratória Brasil
- **Ferramentas e Tecnologias:** 
  - **Armazenamento e Processamento:** Google BigQuery (Projeto: `laboratoria-dados` | Dataset: `spotify`)
  - **Ambiente de Desenvolvimento:** VS Code, Jupyter Notebook (BigQuery Magic / Python) e Console Web do BigQuery
  - **Visualização e BI:** Looker Studio
  - **Versionamento e Documentação:** Git & GitHub

---

## 🎯 Levantamento de Requisitos e Contexto de Negócio (Meta 0)

### 1. Problema de Negócio Central
O modelo de receita do Spotify (assinaturas Premium e publicidade) depende diretamente do tempo de retenção e descoberta musical dos usuários. Embora a empresa invista fortemente na curadoria humana de playlists, os resultados de *streams* entre lançamentos são inconsistentes. Para embasar a revisão orçamentária do próximo trimestre, a diretoria precisa validar se a curadoria gera retorno consistente (separando causalidade de mera correlação) e identificar indicadores precoces que reduzam a subjetividade na escolha das apostas editoriais.

### 2. Perguntas de Negócio (Priorizadas pela VP de Produto)
1. **[Prioridade 1 — Impacto da Curadoria Editorial]** É possível comprovar com dados que a curadoria editorial gera valor real?
  - *1.1.* Músicas presentes em um maior número de playlists do Spotify têm, de fato, mais *streams*?
  - *1.2.* Músicas que entram nos *charts* (rankings) do Spotify acumulam mais *streams* do que as que não entram?
2. **[Prioridade 2 — Sinais Precoces e Ecossistema Multiplataforma]** Existem sinais precoces que ajudem o time editorial a priorizar músicas antes que decolem ou fracassem?
  - *2.1.* Existe relação entre a presença em múltiplas plataformas (Spotify, Apple Music, Deezer e Shazam) e o volume de *streams* (sucesso global vs. isolado em uma plataforma)?
3. **[Prioridade 3 — Padrões de Catálogo e Lançamento]** Existem características da música ou do momento de lançamento que devem orientar a estratégia de curadoria?
  - *3.1.* Atributos da faixa (quantidade de artistas participantes, gênero principal e país de origem) têm relação com o volume de *streams*?
  - *3.2.* O momento de lançamento (ano e mês) influencia o volume acumulado de *streams*?

---

## 🗂️ Bases de Dados Disponíveis e Dicionário de Variáveis
O conjunto de dados abrange o catálogo de músicas populares no Spotify em **2023**, dividido em **duas tabelas** armazenadas no dataset `laboratoria-dados.spotify` e integráveis pela chave primária `track_id`:

### 1. Tabela `track_in_spotify` (Desempenho e Metadados no Spotify)
*Referência BigQuery:* `` `laboratoria-dados.spotify.track_in_spotify` `` *(843 registros brutos | 839 únicos após deduplicação)*

| Variável | Descrição |
| :--- | :--- |
| `track_id` | Identificador único da música (número inteiro de 7 dígitos). |
| `track_name` | Nome da música. |
| `artists_name` | Nome do(s) artista(s) da faixa. |
| `artist_count` | Número de artistas participantes na música. |
| `main_music_genre` | Principal gênero musical da música. |
| `main_country` | Principal país associado à música. |
| `released_year` | Ano de lançamento. |
| `released_month` | Mês de lançamento. |
| `released_day` | Dia do mês em que foi lançada. |
| `in_spotify_playlists` | Número de playlists do Spotify em que a música está incluída. |
| `in_spotify_charts` | Presença e posição da música nos rankings (*charts*) do Spotify. |
| `streams` | Número total de reproduções (*streams*) no Spotify. |

### 2. Tabela `track_in_competition` (Desempenho em Plataformas Concorrentes)
*Referência BigQuery:* `` `laboratoria-dados.spotify.track_in_competition` `` *(953 registros brutos | 100% únicos)*

| Variável | Descrição |
| :--- | :--- |
| `track_id` | Identificador único da música (chave de ligação para `JOIN`). |
| `in_apple_playlists` | Número de playlists do Apple Music em que a música está incluída. |
| `in_apple_charts` | Presença e posição da música nos rankings do Apple Music. |
| `in_deezer_playlists` | Número de playlists do Deezer em que a música está incluída. |
| `in_deezer_charts` | Presença e posição da música nos rankings do Deezer. |
| `in_shazam_charts` | Presença e posição da música nos rankings do Shazam. |

### ⚠️ Limitações Conhecidas da Base (Mapeadas na Meta 0)
- **Sem granularidade de investimento editorial:** A base não informa o custo ou o esforço editorial investido individualmente em cada faixa.
- **Sem série temporal diária:** Os dados não contêm o histórico dia a dia de evolução de *streams* nem o timestamp exato de entrada nas playlists, limitando a inferência direta de causalidade temporal (antes vs. depois da playlist).

---

## ⚙️ Processamento e Análises (Log de Decisões)

### 1. Diagnóstico e Saneamento de Dados (BigQuery / SQL)
- **Configuração e Importação (Meta 1 — Concluída):** 
  - Criação do projeto **`laboratoria-dados`** no Google Cloud Platform (ambiente BigQuery Sandbox) e do dataset **`spotify`**.
  - Importação das duas tabelas brutas: `track_in_spotify` (843 registros) e `track_in_competition` (953 registros).
  - Configuração da execução de queries e inspeção de *data quality* via VS Code, Jupyter Notebook integrado ao BigQuery e Console Web do BigQuery.
- **Tratamento de Valores Nulos (`NULL`) (Meta 2 — Concluída):** 
  - *Diagnóstico:*
    - **`track_in_spotify` (843 linhas | 5 registros afetados):** Identificados **1 nulo** em `main_music_genre` e **1 nulo** em `main_country` simultaneamente no mesmo registro (`track_id: 4796316` – *Style*, Taylor Swift), além de **4 nulos** em `in_spotify_charts` (`track_id` `1297061`, `2079388`, `8725160` e `4439384`). Todas as 5 linhas possuem métricas de *streams* e *playlists* íntegras. Demais colunas apresentam 0 nulos.
    - **`track_in_competition` (953 linhas | 50 registros afetados):** Identificados **50 nulos** (~5,25% da base) exclusivamente na coluna `in_shazam_charts`. A inspeção detalhada confirmou que todos os 50 registros possuem dados válidos e consistentes nas métricas de Apple Music e Deezer, descartando registros corrompidos. Demais colunas apresentam 0 nulos.
  - *Decisão:*
    - Preservar todos os registros em ambas as tabelas para evitar perda de dados válidos de *streams* e métricas multiplataforma.
    - Preencher `main_music_genre` e `main_country` com `'Não informado'` via `COALESCE` na etapa de saneamento.
    - Preencher `in_spotify_charts` e `in_shazam_charts` com `0` via `COALESCE(coluna, 0)`, padronizando o comportamento numérico de ausência nos rankings com `in_apple_charts` e `in_deezer_charts`.
- **Identificação e Remoção de Duplicidades (Meta 3 — Concluída):** 
  - *Diagnóstico:*
    - **`track_in_spotify` — Duplicatas exatas por `track_id` (4 casos | 8 linhas):** Identificados 4 `track_id`s duplicados com todas as colunas 100% idênticas (`3108815` – *BackOutsideBoyz*, `8174233` – *Broke Boys*, `4322356` – *Privileged Rappers* e `4343383` – *The Astronaut*).
    - **`track_in_spotify` — Mesma música + artista com `track_id`s distintos (4 pares | 8 linhas):** As faixas *About Damn Time* (`5080031` e `7173596`), *SNAP* (`3814670` e `5675634`), *SPIT IN MY FACE!* (`4967469` e `8173823`) e *Take My Breath* (`1119309` e `4586215`) aparecem duas vezes com IDs distintos e métricas diferentes de playlists/charts, representando cadastros separados no catálogo (ex.: versão *single* vs. versão de *álbum*).
    - **`track_in_competition` (953 linhas):** 0 duplicatas identificadas (`track_id` 100% único).
    - **Integridade referencial e divergência de tipagem (`STRING` vs. `INT64`):** Durante o cruzamento diagnóstico entre as tabelas (`ON c.track_id = s.track_id`), o BigQuery acusou incompatibilidade de assinatura (`No matching signature for operator = for argument types: STRING, INT64`), revelando que `track_id` foi inferido como `INT64` em uma tabela e `STRING` na outra. Após normalização via `SAFE_CAST`, confirmou-se que **100% das 839 faixas únicas** da `track_in_spotify` possuem correspondência exata na `track_in_competition`, enquanto **114 faixas** existem exclusivamente na `track_in_competition` (sem dados de *streams* no recorte do Spotify).
  - *Decisão:*
    - Remover as 4 cópias idênticas da `track_in_spotify` (via `SELECT DISTINCT` ou `ROW_NUMBER() OVER(PARTITION BY track_id)`), consolidando a base em **839 faixas únicas** e evitando contagem dupla de *streams*.
    - Manter os 4 pares de faixas com `track_id`s distintos, pois representam entidades únicas com métricas próprias de curadoria.
    - Padronizar a chave `track_id` com `SAFE_CAST(track_id AS INT64)` nas etapas de saneamento e `JOIN`.
- **Tratamento de Variáveis Categóricas (Meta 4 — Concluída):** 
  - *Diagnóstico:*
    - **Espaços e capitalização:** Checagem via `TRIM` e `LOWER` confirmou 0 espaços extras e 0 divergências de caixa (41 valores brutos em `main_country` e 84 em `main_music_genre`).
    - **Abreviações duplicadas em `main_country`:** Identificadas siglas isoladas duplicando nomes completos: `'MX'` (1 faixa) vs. `'Mexico'` (26); `'PR'` (1 faixa) vs. `'Puerto Rico'` (49); e `'USA'` (1 faixa) vs. `'United States'` (361).
    - **Inconsistências semânticas e de mapeamento em `main_music_genre`:**
      1. Variação de hífen entre `'Disco pop'` (1) e `'Disco-pop'` (1), ambas da artista Dua Lipa.
      2. Vazamento de rótulo genérico `'Main genre'` (2 faixas), ambas clássicos da banda Nirvana (*Smells Like Teen Spirit* e *Something In The Way*).
      3. Único registro classificado como `'Grunge'` (1 faixa) pertencente na verdade à banda Metallica; paralelamente, a inspeção dos 8 registros de `'Rock'` mostrou que a categoria já atua como guarda-chuva para diversas vertentes do gênero (Queen, Guns N' Roses, Aerosmith, The Police, Creedence Clearwater Revival, Chuck Berry, Ghost e Jack Black).
      4. Erro sistemático de classificação em `'Heavy metal'` (97 registros): auditoria completa dos artistas comprovou que 100% das 97 linhas são faixas de Hip-Hop/Rap (Kendrick Lamar, Drake, 21 Savage, Eminem, Kanye West, Dr. Dre, Snoop Dogg, etc.).
  - *Decisão:*
    - **Padronização de `main_music_genre` via `CASE WHEN`:** Reclassificar `'Heavy metal'` $\rightarrow$ `'Hip-hop'` (consolidando 119 faixas na base bruta / 116 únicas, 2º maior gênero do catálogo); consolidar `'Main genre'` (Nirvana) e `'Grunge'` (Metallica) dentro da categoria guarda-chuva `'Rock'` já existente (passando de 8 para 11 faixas); unificar `'Disco-pop'` $\rightarrow$ `'Disco pop'` (2 faixas); e mapear `NULL` $\rightarrow$ `'Não informado'` (1 faixa), consolidando **81 categorias** consistentes.
    - **Padronização de `main_country` via `CASE WHEN`:** Unificar `'MX'` $\rightarrow$ `'Mexico'` (27 faixas), `'PR'` $\rightarrow$ `'Puerto Rico'` (50 faixas), `'USA'` $\rightarrow$ `'United States'` (362 faixas) e `NULL` $\rightarrow$ `'Não informado'` (1 faixa), consolidando **39 categorias** limpas.
- **Tratamento de Variáveis Numéricas e Outliers (Meta 5):** 
  - *Diagnóstico:* [Preencher]
  - *Decisão:* [Preencher]
- **Integração Relacional (`JOIN`) (Meta 6):** 
  - *Estratégia:* União entre `laboratoria-dados.spotify.track_in_spotify` (839 faixas únicas) e `laboratoria-dados.spotify.track_in_competition` (953 faixas únicas) via `SAFE_CAST(track_id AS INT64)`, utilizando `INNER JOIN` (ou `LEFT JOIN` partindo de `track_in_spotify`) para evitar a inclusão de 114 registros sem métricas de *streams*.

### 2. Principais Consultas SQL Utilizadas
```sql
-- ============================================================================
-- META 2: DIAGNÓSTICO DE VALORES NULOS (NULL)
-- Projeto: laboratoria-dados | Dataset: spotify
-- ============================================================================

-- 1. Contagem de nulos por coluna na tabela track_in_spotify
SELECT
  COUNT(*) AS total_linhas,
  COUNTIF(track_id IS NULL) AS nulos_track_id,
  COUNTIF(track_name IS NULL) AS nulos_track_name,
  COUNTIF(artists_name IS NULL) AS nulos_artists_name,
  COUNTIF(artist_count IS NULL) AS nulos_artist_count,
  COUNTIF(main_music_genre IS NULL) AS nulos_main_music_genre,
  COUNTIF(main_country IS NULL) AS nulos_main_country,
  COUNTIF(released_year IS NULL) AS nulos_released_year,
  COUNTIF(released_month IS NULL) AS nulos_released_month,
  COUNTIF(released_day IS NULL) AS nulos_released_day,
  COUNTIF(in_spotify_playlists IS NULL) AS nulos_in_spotify_playlists,
  COUNTIF(in_spotify_charts IS NULL) AS nulos_in_spotify_charts,
  COUNTIF(streams IS NULL) AS nulos_streams
FROM `laboratoria-dados.spotify.track_in_spotify`;

-- 2. Contagem de nulos por coluna na tabela track_in_competition
SELECT
  COUNT(*) AS total_linhas,
  COUNTIF(track_id IS NULL) AS nulos_track_id,
  COUNTIF(in_apple_playlists IS NULL) AS nulos_in_apple_playlists,
  COUNTIF(in_apple_charts IS NULL) AS nulos_in_apple_charts,
  COUNTIF(in_deezer_playlists IS NULL) AS nulos_in_deezer_playlists,
  COUNTIF(in_deezer_charts IS NULL) AS nulos_in_deezer_charts,
  COUNTIF(in_shazam_charts IS NULL) AS nulos_in_shazam_charts
FROM `laboratoria-dados.spotify.track_in_competition`;

-- 3. Inspeção detalhada dos nulos em in_shazam_charts (track_in_competition)
SELECT *
FROM `laboratoria-dados.spotify.track_in_competition`
WHERE in_shazam_charts IS NULL;

-- 4. Inspeção detalhada dos registros com nulos na track_in_spotify
SELECT
  track_id,
  track_name,
  artists_name,
  main_music_genre,
  main_country,
  in_spotify_playlists,
  in_spotify_charts,
  streams
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE main_music_genre IS NULL
   OR main_country IS NULL
   OR in_spotify_charts IS NULL;

-- ============================================================================
-- META 3: DIAGNÓSTICO DE VALORES DUPLICADOS (GROUP BY / HAVING)
-- Projeto: laboratoria-dados | Dataset: spotify
-- ============================================================================

-- 1. Verificar duplicados de track_id na tabela track_in_spotify
SELECT
  track_id,
  COUNT(*) AS qtd_ocorrencias
FROM `laboratoria-dados.spotify.track_in_spotify`
GROUP BY track_id
HAVING COUNT(*) > 1;

-- 2. Verificar duplicados de música + artista na tabela track_in_spotify
-- (Detecta casos em que a mesma faixa entrou duas vezes com track_id diferente)
SELECT
  track_name,
  artists_name,
  COUNT(*) AS qtd_ocorrencias
FROM `laboratoria-dados.spotify.track_in_spotify`
GROUP BY track_name, artists_name
HAVING COUNT(*) > 1;

-- 3. Verificar duplicados de track_id na tabela track_in_competition
SELECT
  track_id,
  COUNT(*) AS qtd_ocorrencias
FROM `laboratoria-dados.spotify.track_in_competition`
GROUP BY track_id
HAVING COUNT(*) > 1;

-- 4. Inspeção detalhada das 8 músicas repetidas na track_in_spotify
SELECT *
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE track_name IN (
  'SNAP',
  'About Damn Time',
  'Take My Breath',
  'SPIT IN MY FACE!',
  'The Astronaut',
  'Privileged Rappers',
  'BackOutsideBoyz',
  'Broke Boys'
)
ORDER BY track_name, artists_name, track_id;

-- 5. Verificar correspondência de track_id entre track_in_competition e track_in_spotify
-- (Nota: comparação direta sem CAST gerou erro de assinatura STRING vs. INT64)
SELECT
  COUNT(*) AS total_competition,
  COUNT(s.track_id) AS encontrados_no_spotify,
  COUNT(*) - COUNT(s.track_id) AS ausentes_no_spotify
FROM `laboratoria-dados.spotify.track_in_competition` c
LEFT JOIN `laboratoria-dados.spotify.track_in_spotify` s
  ON c.track_id = s.track_id;

-- 6. Verificar correspondência de track_id entre track_in_competition e track_in_spotify
-- (Com SAFE_CAST para resolver a divergência de tipagem STRING vs. INT64)
SELECT
  COUNT(*) AS total_competition,
  COUNT(s.track_id) AS encontrados_no_spotify,
  COUNT(*) - COUNT(s.track_id) AS ausentes_no_spotify
FROM `laboratoria-dados.spotify.track_in_competition` c
LEFT JOIN `laboratoria-dados.spotify.track_in_spotify` s
  ON SAFE_CAST(c.track_id AS INT64) = SAFE_CAST(s.track_id AS INT64);

-- ============================================================================
-- META 4: DIAGNÓSTICO E PADRONIZAÇÃO DE VARIÁVEIS CATEGÓRICAS (CASE WHEN)
-- Projeto: laboratoria-dados | Dataset: spotify
-- ============================================================================

-- 1. Listar todos os valores únicos e frequência de main_country
SELECT
  main_country,
  COUNT(*) AS qtd_faixas
FROM `laboratoria-dados.spotify.track_in_spotify`
GROUP BY main_country
ORDER BY main_country;

-- 2. Listar todos os valores únicos e frequência de main_music_genre
SELECT
  main_music_genre,
  COUNT(*) AS qtd_faixas
FROM `laboratoria-dados.spotify.track_in_spotify`
GROUP BY main_music_genre
ORDER BY main_music_genre;

-- 3. Verificar espaços extras no início/fim ou variações de caixa (UPPER/LOWER)
SELECT
  COUNTIF(main_country != TRIM(main_country)) AS espacos_country,
  COUNTIF(main_music_genre != TRIM(main_music_genre)) AS espacos_genre,
  COUNT(DISTINCT main_country) AS paises_exatos,
  COUNT(DISTINCT LOWER(TRIM(main_country))) AS paises_normalizados,
  COUNT(DISTINCT main_music_genre) AS generos_exatos,
  COUNT(DISTINCT LOWER(TRIM(main_music_genre))) AS generos_normalizados
FROM `laboratoria-dados.spotify.track_in_spotify`;

-- 4. Inspecionar as faixas classificadas como 'Main genre' e amostra de 'Heavy metal'
SELECT
  track_id,
  track_name,
  artists_name,
  main_music_genre,
  main_country,
  streams
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE main_music_genre IN ('Main genre', 'Disco pop', 'Disco-pop')
   OR (main_music_genre = 'Heavy metal' AND track_id IN (
     SELECT track_id
     FROM `laboratoria-dados.spotify.track_in_spotify`
     WHERE main_music_genre = 'Heavy metal'
     LIMIT 15
   ))
ORDER BY main_music_genre, streams DESC;

-- 5. Auditar todos os artistas rotulados como 'Heavy metal' (97 linhas)
SELECT
  artists_name,
  COUNT(*) AS qtd_faixas
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE main_music_genre = 'Heavy metal'
GROUP BY artists_name
ORDER BY qtd_faixas DESC, artists_name;

-- Inspeção pontual: conferir o único registro classificado como 'Grunge' na base
SELECT
  track_id,
  track_name,
  artists_name,
  main_music_genre,
  streams
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE main_music_genre = 'Grunge';

-- Inspeção pontual: conferir os registros classificados como 'Rock' na base
SELECT
  track_id,
  track_name,
  artists_name,
  main_music_genre,
  streams
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE main_music_genre = 'Rock';

-- 6. Validar distribuição de main_music_genre após padronização
SELECT
  CASE
    WHEN main_music_genre IS NULL THEN 'Não informado'
    WHEN main_music_genre IN ('Main genre', 'Grunge') THEN 'Rock'  -- Nirvana (2) + Metallica (1) consolidados em Rock
    WHEN main_music_genre = 'Heavy metal' THEN 'Hip-hop'           -- 97 registros de Hip-Hop/Rap corrigidos
    WHEN main_music_genre = 'Disco-pop' THEN 'Disco pop'           -- Unificação de grafia com hífen
    ELSE main_music_genre
  END AS main_music_genre_padronizado,
  COUNT(*) AS qtd_faixas
FROM `laboratoria-dados.spotify.track_in_spotify`
GROUP BY main_music_genre_padronizado
ORDER BY qtd_faixas DESC, main_music_genre_padronizado;

-- 7. Validar distribuição de main_country após padronização
SELECT
  CASE
    WHEN main_country IS NULL THEN 'Não informado'
    WHEN main_country = 'MX' THEN 'Mexico'
    WHEN main_country = 'PR' THEN 'Puerto Rico'
    WHEN main_country = 'USA' THEN 'United States'
    ELSE main_country
  END AS main_country_padronizado,
  COUNT(*) AS qtd_faixas
FROM `laboratoria-dados.spotify.track_in_spotify`
GROUP BY main_country_padronizado
ORDER BY qtd_faixas DESC, main_country_padronizado;
```

### 3. Análise Exploratória (EDA) e Correlações (Metas 7 a 9)
- **Agrupamentos e Tabelas Dinâmicas:** [Preencher]
- **Análise de Correlação:** [Preencher]

---

## 💡 Resultados e Conclusões (Meta 10)
> *Preencher ao responder formalmente às perguntas de negócio.*

### Respostas às Perguntas de Negócio
1. **Curadoria Editorial (Playlists e Charts vs. Streams):** [Aguardando análise]
2. **Sinais Precoces e Alcance Multiplataforma:** [Aguardando análise]
3. **Padrões de Catálogo (Gênero, País, Nº de Artistas) e Lançamento:** [Aguardando análise]

### Principais Insights e Recomendações ao Board / Time Editorial
- **Insight 1:** [Aguardando análise] $\rightarrow$ **Recomendação:** [Ação sugerida]
- **Insight 2:** [Aguardando análise] $\rightarrow$ **Recomendação:** [Ação sugerida]

---

## 🚀 Próximos Passos e Evolução da Coleta
- **Sugestões para Data Engineering:** Incorporar série temporal diária de *streams* e logs de data de entrada em playlists editoriais para permitir testes A/B e análise de causalidade temporal (pré vs. pós-curadoria), além de padronizar o tipo de dado da chave `track_id` (`INT64`) e validar o dicionário de gêneros na ingestão.

---

## 🔗 Links de Interesse
- **Repositório Principal:** [README.md](../README.md)
- **Plano de Execução e Metas:** [plano-execucao.md](./plano-execucao.md)
- **Scripts SQL:** [`/sql`](../sql/)
- **Dashboard Interativo (Looker Studio):** *Em desenvolvimento*