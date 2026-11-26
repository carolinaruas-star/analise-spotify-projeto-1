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
*Referência BigQuery:* `` `laboratoria-dados.spotify.track_in_spotify` `` *(843 registros brutos | 838 únicos válidos após saneamento)*

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
    - Preservar todos os registros válidos em ambas as tabelas para evitar perda de dados íntegros de *streams* e métricas multiplataforma.
    - Preencher `main_music_genre` e `main_country` com `'Não informado'` via `COALESCE` na etapa de saneamento.
    - Preencher `in_spotify_charts` e `in_shazam_charts` com `0` via `COALESCE(coluna, 0)`, padronizando o comportamento numérico de ausência nos rankings com `in_apple_charts` e `in_deezer_charts`.
- **Identificação e Remoção de Duplicidades (Meta 3 — Concluída):** 
  - *Diagnóstico:*
    - **`track_in_spotify` — Duplicatas exatas por `track_id` (4 casos | 8 linhas):** Identificados 4 `track_id`s duplicados com todas as colunas 100% idênticas (`3108815` – *BackOutsideBoyz*, `8174233` – *Broke Boys*, `4322356` – *Privileged Rappers* e `4343383` – *The Astronaut*).
    - **`track_in_spotify` — Mesma música + artista com `track_id`s distintos (4 pares | 8 linhas):** As faixas *About Damn Time* (`5080031` e `7173596`), *SNAP* (`3814670` e `5675634`), *SPIT IN MY FACE!* (`4967469` e `8173823`) e *Take My Breath* (`1119309` e `4586215`) aparecem duas vezes com IDs distintos e métricas diferentes de playlists/charts, representando cadastros separados no catálogo (ex.: versão *single* vs. versão de *álbum*).
    - **`track_in_competition` (953 linhas):** 0 duplicatas identificadas (`track_id` 100% único).
    - **Integridade referencial e divergência de tipagem (`STRING` vs. `INT64`):** Durante o cruzamento diagnóstico entre as tabelas (`ON c.track_id = s.track_id`), o BigQuery acusou incompatibilidade de assinatura (`No matching signature for operator = for argument types: STRING, INT64`), revelando que `track_id` foi inferido como `INT64` em uma tabela e `STRING` na outra. Após normalização via `SAFE_CAST`, confirmou-se que **100% das faixas únicas** da `track_in_spotify` possuem correspondência exata na `track_in_competition`, enquanto **114 faixas** existem exclusivamente na `track_in_competition` (sem dados de *streams* no recorte do Spotify).
  - *Decisão:*
    - Remover as 4 cópias idênticas da `track_in_spotify` (via `QUALIFY ROW_NUMBER() OVER (PARTITION BY SAFE_CAST(track_id AS INT64) ORDER BY track_id) = 1`), evitando contagem dupla de *streams*.
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
- **Tratamento de Variáveis Numéricas e Outliers (Meta 5 — Concluída):** 
  - *Diagnóstico:*
    - **Validação de tipagem (`SAFE_CAST`) e extremos (`MIN`, `MAX`, `AVG`) na `track_in_spotify`:** Identificado **1 registro corrompido** (`track_id: 4061483` – *Love Grows (Where My Rosemary Goes)*, Edison Lighthouse) onde atributos de áudio (`BPM110KeyAModeMajor...`) vazaram para dentro da coluna `in_spotify_playlists` (falhando no `SAFE_CAST(..., INT64)`) e a coluna `streams` veio preenchida com o valor impossível **`-1`**.
    - **Faixas de volume baixo legítimo:** A inspeção de registros com `streams <= 10.000` identificou apenas uma faixa válida (`track_id: 8110201` – *Que Vuelvas*, Carin Leon, Grupo Frontera, com `streams = 2.762` e `in_spotify_playlists = 763`).
    - **Demais variáveis numéricas e outliers superiores:** Datas válidas (`released_year` entre `1942` e `2023`; `released_month` entre `1` e `12`; `released_day` entre `1` e `31`) e `artist_count` entre `1` e `8` (média `1,51`). Na `track_in_competition`, todas as 5 métricas numéricas passaram limpas com `0` erros de tipagem e sem valores negativos (`min = 0` em todas). Os outliers superiores de `streams` (máximo de `3.703.895.074`) e `in_spotify_playlists` (máximo de `52.898`) refletem megahits globais reais do catálogo.
  - *Decisão:*
    - **Excluir** o registro corrompido `track_id = 4061483` aplicando `WHERE SAFE_CAST(streams AS INT64) > 0`, reduzindo a `track_in_spotify` de 843 para **842 linhas válidas** (que, combinadas à remoção das 4 duplicatas exatas da Meta 3, consolidam **838 faixas únicas íntegras**).
    - **Manter** o registro de baixo volume legítimo (`track_id: 8110201`, `2.762` streams) e os megahits do topo da distribuição, adotando a **mediana** em conjunto com a **média** na análise exploratória para mitigar assimetria.
- **Integração Relacional (`JOIN`) (Meta 6 — Concluída):** 
  - *Estratégia e Implementação:* Criação de duas views saneadas intermediárias (`vw_track_in_spotify_limpa` com 838 registros únicos e `vw_track_in_competition_limpa` com 953 registros únicos) e união relacional na view analítica final **`laboratoria-dados.spotify.vw_spotify_consolidada`** utilizando **`LEFT JOIN`** a partir de `vw_track_in_spotify_limpa` sobre a chave padronizada `track_id` (`INT64`).
  - *Validação:* A query de validação pós-união confirmou exatamente **838 registros únicos** (`17` colunas da view + `1` métrica automática `Record Count` no Looker Studio), `0` registros sem correspondência na tabela concorrente e `0` valores inválidos de `streams`, evitando a inclusão dos 114 registros da `track_in_competition` sem métricas de *streams* no Spotify.

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
  COUNTIF(in_apple_playlists IS NULL) AS nulos_apple_playlists,
  COUNTIF(in_apple_charts IS NULL) AS nulos_apple_charts,
  COUNTIF(in_deezer_playlists IS NULL) AS nulos_deezer_playlists,
  COUNTIF(in_deezer_charts IS NULL) AS nulos_deezer_charts,
  COUNTIF(in_shazam_charts IS NULL) AS nulos_shazam_charts
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

-- ============================================================================
-- META 5: DIAGNÓSTICO DE VARIÁVEIS NUMÉRICAS, TIPAGEM E OUTLIERS
-- Projeto: laboratoria-dados | Dataset: spotify
-- ============================================================================

-- 1. Validar tipagem com SAFE_CAST na tabela track_in_spotify
SELECT
  COUNT(*) AS total_linhas,
  COUNTIF(SAFE_CAST(artist_count AS INT64) IS NULL AND artist_count IS NOT NULL) AS erro_artist_count,
  COUNTIF(SAFE_CAST(released_year AS INT64) IS NULL AND released_year IS NOT NULL) AS erro_released_year,
  COUNTIF(SAFE_CAST(released_month AS INT64) IS NULL AND released_month IS NOT NULL) AS erro_released_month,
  COUNTIF(SAFE_CAST(released_day AS INT64) IS NULL AND released_day IS NOT NULL) AS erro_released_day,
  COUNTIF(SAFE_CAST(in_spotify_playlists AS INT64) IS NULL AND in_spotify_playlists IS NOT NULL) AS erro_spotify_playlists,
  COUNTIF(SAFE_CAST(in_spotify_charts AS INT64) IS NULL AND in_spotify_charts IS NOT NULL) AS erro_spotify_charts,
  COUNTIF(SAFE_CAST(streams AS INT64) IS NULL AND streams IS NOT NULL) AS erro_streams
FROM `laboratoria-dados.spotify.track_in_spotify`;

-- 2. Validar tipagem com SAFE_CAST na tabela track_in_competition
SELECT
  COUNT(*) AS total_linhas,
  COUNTIF(SAFE_CAST(in_apple_playlists AS INT64) IS NULL AND in_apple_playlists IS NOT NULL) AS erro_apple_playlists,
  COUNTIF(SAFE_CAST(in_apple_charts AS INT64) IS NULL AND in_apple_charts IS NOT NULL) AS erro_apple_charts,
  COUNTIF(SAFE_CAST(in_deezer_playlists AS INT64) IS NULL AND in_deezer_playlists IS NOT NULL) AS erro_deezer_playlists,
  COUNTIF(SAFE_CAST(in_deezer_charts AS INT64) IS NULL AND in_deezer_charts IS NOT NULL) AS erro_deezer_charts,
  COUNTIF(SAFE_CAST(in_shazam_charts AS INT64) IS NULL AND in_shazam_charts IS NOT NULL) AS erro_shazam_charts
FROM `laboratoria-dados.spotify.track_in_competition`;

-- 3. Verificar MIN, MAX e AVG das variáveis numéricas da track_in_spotify
SELECT
  MIN(SAFE_CAST(artist_count AS INT64)) AS min_artist_count,
  MAX(SAFE_CAST(artist_count AS INT64)) AS max_artist_count,
  ROUND(AVG(SAFE_CAST(artist_count AS INT64)), 2) AS avg_artist_count,
  MIN(SAFE_CAST(released_year AS INT64)) AS min_year,
  MAX(SAFE_CAST(released_year AS INT64)) AS max_year,
  MIN(SAFE_CAST(released_month AS INT64)) AS min_month,
  MAX(SAFE_CAST(released_month AS INT64)) AS max_month,
  MIN(SAFE_CAST(released_day AS INT64)) AS min_day,
  MAX(SAFE_CAST(released_day AS INT64)) AS max_day,
  MIN(SAFE_CAST(in_spotify_playlists AS INT64)) AS min_playlists,
  MAX(SAFE_CAST(in_spotify_playlists AS INT64)) AS max_playlists,
  ROUND(AVG(SAFE_CAST(in_spotify_playlists AS INT64)), 2) AS avg_playlists,
  MIN(SAFE_CAST(in_spotify_charts AS INT64)) AS min_charts,
  MAX(SAFE_CAST(in_spotify_charts AS INT64)) AS max_charts,
  ROUND(AVG(SAFE_CAST(in_spotify_charts AS INT64)), 2) AS avg_charts,
  MIN(SAFE_CAST(streams AS INT64)) AS min_streams,
  MAX(SAFE_CAST(streams AS INT64)) AS max_streams,
  ROUND(AVG(SAFE_CAST(streams AS INT64)), 2) AS avg_streams
FROM `laboratoria-dados.spotify.track_in_spotify`;

-- 4. Verificar MIN, MAX e AVG das variáveis numéricas da track_in_competition
SELECT
  MIN(SAFE_CAST(in_apple_playlists AS INT64)) AS min_apple_playlists,
  MAX(SAFE_CAST(in_apple_playlists AS INT64)) AS max_apple_playlists,
  ROUND(AVG(SAFE_CAST(in_apple_playlists AS INT64)), 2) AS avg_apple_playlists,
  MIN(SAFE_CAST(in_apple_charts AS INT64)) AS min_apple_charts,
  MAX(SAFE_CAST(in_apple_charts AS INT64)) AS max_apple_charts,
  ROUND(AVG(SAFE_CAST(in_apple_charts AS INT64)), 2) AS avg_apple_charts,
  MIN(SAFE_CAST(in_deezer_playlists AS INT64)) AS min_deezer_playlists,
  MAX(SAFE_CAST(in_deezer_playlists AS INT64)) AS max_deezer_playlists,
  ROUND(AVG(SAFE_CAST(in_deezer_playlists AS INT64)), 2) AS avg_deezer_playlists,
  MIN(SAFE_CAST(in_deezer_charts AS INT64)) AS min_deezer_charts,
  MAX(SAFE_CAST(in_deezer_charts AS INT64)) AS max_deezer_charts,
  ROUND(AVG(SAFE_CAST(in_deezer_charts AS INT64)), 2) AS avg_deezer_charts,
  MIN(SAFE_CAST(in_shazam_charts AS INT64)) AS min_shazam_charts,
  MAX(SAFE_CAST(in_shazam_charts AS INT64)) AS max_shazam_charts,
  ROUND(AVG(SAFE_CAST(in_shazam_charts AS INT64)), 2) AS avg_shazam_charts
FROM `laboratoria-dados.spotify.track_in_competition`;

-- 5. Inspecionar registros anômalos em in_spotify_playlists e streams (<= 0 ou muito baixos)
SELECT *
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE SAFE_CAST(in_spotify_playlists AS INT64) IS NULL
   OR SAFE_CAST(streams AS INT64) <= 10000
   OR SAFE_CAST(in_spotify_playlists AS INT64) <= 0;

-- 6. Validar extremos (MIN, MAX, AVG) após remoção do registro corrompido (track_id = 4061483)
SELECT
  COUNT(*) AS total_linhas_validas,
  MIN(SAFE_CAST(in_spotify_playlists AS INT64)) AS min_playlists,
  MAX(SAFE_CAST(in_spotify_playlists AS INT64)) AS max_playlists,
  ROUND(AVG(SAFE_CAST(in_spotify_playlists AS INT64)), 2) AS avg_playlists,
  MIN(SAFE_CAST(streams AS INT64)) AS min_streams,
  MAX(SAFE_CAST(streams AS INT64)) AS max_streams,
  ROUND(AVG(SAFE_CAST(streams AS INT64)), 2) AS avg_streams
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE SAFE_CAST(streams AS INT64) > 0;

-- ============================================================================
-- META 6: INTEGRAÇÃO RELACIONAL (VIEWS LIMPAS + LEFT JOIN)
-- Projeto: laboratoria-dados | Dataset: spotify
-- ============================================================================

-- 1. Criar View limpa da tabela track_in_spotify (838 faixas únicas válidas)
CREATE OR REPLACE VIEW `laboratoria-dados.spotify.vw_track_in_spotify_limpa` AS
SELECT
  SAFE_CAST(track_id AS INT64) AS track_id,
  TRIM(track_name) AS track_name,
  TRIM(artists_name) AS artists_name,
  SAFE_CAST(artist_count AS INT64) AS artist_count,
  CASE
    WHEN main_music_genre IS NULL THEN 'Não informado'
    WHEN main_music_genre IN ('Main genre', 'Grunge') THEN 'Rock'
    WHEN main_music_genre = 'Heavy metal' THEN 'Hip-hop'
    WHEN main_music_genre = 'Disco-pop' THEN 'Disco pop'
    ELSE main_music_genre
  END AS main_music_genre,
  CASE
    WHEN main_country IS NULL THEN 'Não informado'
    WHEN main_country = 'MX' THEN 'Mexico'
    WHEN main_country = 'PR' THEN 'Puerto Rico'
    WHEN main_country = 'USA' THEN 'United States'
    ELSE main_country
  END AS main_country,
  SAFE_CAST(released_year AS INT64) AS released_year,
  SAFE_CAST(released_month AS INT64) AS released_month,
  SAFE_CAST(released_day AS INT64) AS released_day,
  SAFE_CAST(in_spotify_playlists AS INT64) AS in_spotify_playlists,
  COALESCE(SAFE_CAST(in_spotify_charts AS INT64), 0) AS in_spotify_charts,
  SAFE_CAST(streams AS INT64) AS streams
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE SAFE_CAST(streams AS INT64) > 0
QUALIFY ROW_NUMBER() OVER (PARTITION BY SAFE_CAST(track_id AS INT64) ORDER BY track_id) = 1;

-- 2. Criar View limpa da tabela track_in_competition (953 faixas únicas)
CREATE OR REPLACE VIEW `laboratoria-dados.spotify.vw_track_in_competition_limpa` AS
SELECT
  SAFE_CAST(track_id AS INT64) AS track_id,
  SAFE_CAST(in_apple_playlists AS INT64) AS in_apple_playlists,
  SAFE_CAST(in_apple_charts AS INT64) AS in_apple_charts,
  SAFE_CAST(in_deezer_playlists AS INT64) AS in_deezer_playlists,
  SAFE_CAST(in_deezer_charts AS INT64) AS in_deezer_charts,
  COALESCE(SAFE_CAST(in_shazam_charts AS INT64), 0) AS in_shazam_charts
FROM `laboratoria-dados.spotify.track_in_competition`;

-- 3. Criar View unificada (LEFT JOIN entre as duas views limpas)
CREATE OR REPLACE VIEW `laboratoria-dados.spotify.vw_spotify_consolidada` AS
SELECT
  s.track_id,
  s.track_name,
  s.artists_name,
  s.artist_count,
  s.main_music_genre,
  s.main_country,
  s.released_year,
  s.released_month,
  s.released_day,
  s.in_spotify_playlists,
  s.in_spotify_charts,
  s.streams,
  c.in_apple_playlists,
  c.in_apple_charts,
  c.in_deezer_playlists,
  c.in_deezer_charts,
  c.in_shazam_charts
FROM `laboratoria-dados.spotify.vw_track_in_spotify_limpa` AS s
LEFT JOIN `laboratoria-dados.spotify.vw_track_in_competition_limpa` AS c
  ON s.track_id = c.track_id;

-- 4. Validar integridade da união (contagem de linhas, duplicidades e nulos pós-JOIN)
SELECT
  COUNT(*) AS total_linhas_consolidadas,
  COUNT(DISTINCT track_id) AS track_ids_unicos,
  COUNTIF(in_apple_playlists IS NULL) AS sem_correspondencia_competition,
  COUNTIF(streams IS NULL OR streams <= 0) AS streams_invalidos
FROM `laboratoria-dados.spotify.vw_spotify_consolidada`;

-- ============================================================================
-- META 9: MATRIZ DE CORRELAÇÃO DE PEARSON (CORR)
-- Projeto: laboratoria-dados | Dataset: spotify
-- ============================================================================

SELECT
  -- 1. Curadoria Editorial e Rankings no Spotify
  ROUND(CORR(in_spotify_playlists, streams), 4) AS corr_spotify_playlists_streams,
  ROUND(CORR(in_spotify_charts, streams), 4) AS corr_spotify_charts_streams,

  -- 2. Ecossistema Multiplataforma e Sinais Precoces
  ROUND(CORR(in_apple_playlists, streams), 4) AS corr_apple_playlists_streams,
  ROUND(CORR(in_apple_charts, streams), 4) AS corr_apple_charts_streams,
  ROUND(CORR(in_deezer_playlists, streams), 4) AS corr_deezer_playlists_streams,
  ROUND(CORR(in_deezer_charts, streams), 4) AS corr_deezer_charts_streams,
  ROUND(CORR(in_shazam_charts, streams), 4) AS corr_shazam_charts_streams,

  -- 3. Correlação Cruzada entre Playlists das Plataformas
  ROUND(CORR(in_spotify_playlists, in_apple_playlists), 4) AS corr_playlists_spotify_apple,
  ROUND(CORR(in_spotify_playlists, in_deezer_playlists), 4) AS corr_playlists_spotify_deezer,

  -- 4. Atributos da Faixa e Lançamento
  ROUND(CORR(artist_count, streams), 4) AS corr_artist_count_streams,
  ROUND(CORR(released_year, streams), 4) AS corr_released_year_streams,
  ROUND(CORR(released_month, streams), 4) AS corr_released_month_streams
FROM `laboratoria-dados.spotify.vw_spotify_consolidada`;

-- ============================================================================
-- META 10: CONSULTAS COMPLEMENTARES PARA RESPOSTAS DE NEGÓCIO
-- Projeto: laboratoria-dados | Dataset: spotify
-- ============================================================================

-- 1. Pergunta 1.2: Desempenho de faixas que entraram nos charts vs. fora dos charts (Spotify)
SELECT
  CASE
    WHEN in_spotify_charts > 0 THEN 'Com presença em Charts (> 0)'
    ELSE 'Fora dos Charts (= 0)'
  END AS status_chart_spotify,
  COUNT(*) AS qtd_faixas,
  ROUND(AVG(streams), 0) AS media_streams,
  APPROX_QUANTILES(streams, 2)[OFFSET(1)] AS mediana_streams,
  ROUND(AVG(in_spotify_playlists), 1) AS media_playlists
FROM `laboratoria-dados.spotify.vw_spotify_consolidada`
GROUP BY status_chart_spotify
ORDER BY media_streams DESC;

-- 2. Pergunta 3.1: Desempenho por quantidade de artistas (Solo vs. Colaborações)
SELECT
  CASE
    WHEN artist_count = 1 THEN '1 Artista (Solo)'
    WHEN artist_count = 2 THEN '2 Artistas (Feat Duplo)'
    ELSE '3 ou mais Artistas (Multi-feat)'
  END AS formato_colaboracao,
  COUNT(*) AS qtd_faixas,
  ROUND(AVG(streams), 0) AS media_streams,
  APPROX_QUANTILES(streams, 2)[OFFSET(1)] AS mediana_streams,
  ROUND(AVG(in_spotify_playlists), 1) AS media_playlists
FROM `laboratoria-dados.spotify.vw_spotify_consolidada`
GROUP BY formato_colaboracao
ORDER BY media_streams DESC;
```

### 3. Análise Exploratória (EDA) e Correlações (Metas 7 a 9)
- **Configuração da Fonte de Dados (Looker Studio):**
  - Conexão direta com `laboratoria-dados.spotify.vw_spotify_consolidada` (17 colunas da view + métrica automática `Record Count`).
  - Padronização de agregações padrão: `track_id` configurado como `Contar diferentes` (`COUNT_DISTINCT`), `artist_count` como `Médio` (`AVG`) e `released_month` como tipo `Mês` ordenado por `MIN(released_month)` crescente (`janeiro` a `dezembro`).
- **Agrupamentos e Tabelas Dinâmicas (Meta 7 — Concluída):**
  - *Tabela Dinâmica por Gênero Musical (`main_music_genre`):*
    - **Liderança em volume total:** **Pop** concentra o maior catálogo (**154 faixas**) e volume absoluto (**115.199.778.779** *streams* | média de **748,05 mi**/faixa | média de **6.178,21** playlists), seguido por **Hip-hop** (**116 faixas** | **49.717.038.279** *streams* | média de **428,60 mi** | **5.804,84** playlists), **Reggaeton** (**74 faixas** | **34.401.804.381** *streams* | média de **464,89 mi**) e **R&B** (**55 faixas** | **31.695.498.290** *streams* | média de **576,28 mi**).
    - **Eficiência média por faixa vs. tamanho do catálogo:** Gêneros de nicho ou catálogo menor superam o Pop em desempenho médio por faixa e penetração editorial: **EDM** (**8 faixas** | média de **1,27 bi** *streams* e **20.936,50** playlists), **Indie rock** (**11 faixas** | média de **1,17 bi** *streams* e **15.836,55** playlists), **Alternative rock** (**11 faixas** | média de **1,09 bi** *streams* e **18.670,09** playlists) e **Pop rock** (**17 faixas** | média de **1,02 bi** *streams* e **8.422,47** playlists).
    - **Efeito *Fanbase* vs. Curadoria Editorial:** **K-pop** ocupa o 4º lugar em quantidade de faixas (**57**), mas registra média baixa de playlists no Spotify (**962,25**) e de *streams* (**287,90 mi**), indicando alta mobilização inicial de fãs sem ampla inserção em playlists editoriais generalistas.
- **Visualizações Exploratórias e Tendências (Meta 8 — Concluída):**
  - *Gráfico de Colunas por País (`main_country` — Top 10):*
    - **Domínio Anglo-Saxão:** Os **Estados Unidos** lideram com mais de **200 bilhões** de *streams* (~360 faixas), seguidos pelo **Reino Unido** (~86 bi | ~105 faixas) e **Canadá** (~41 bi).
    - **Destaques Regionais:** **Porto Rico** (~28 bi) e **Coreia do Sul** (~17 bi) completam o Top 5 em volume; a **Austrália** destaca-se pela elevada média de *streams* por faixa apesar do catálogo reduzido.
  - *Gráfico de Combinação Mensal (`released_month` — Janeiro a Dezembro):*
    - **Pico Duplo em Janeiro:** Maior volume de lançamentos do ano (~117 faixas) combinado a uma das maiores médias de *streams* (~780 mi).
    - **Janelas de Menor Concorrência (Agosto e Setembro):** **Setembro** atinge o pico anual de média de *streams* por faixa (~800 mi) com baixo volume de lançamentos (~50 faixas), acompanhado por **Agosto** (~660 mi de média com o menor volume de lançamentos do ano). Já **Maio** apresenta o segundo maior volume de lançamentos (~109 faixas), porém com média de *streams* mais diluída (~435 mi).
- **Análise de Correlação (Meta 9 — Concluída):**
  - *Matriz de Correlação de Pearson (`CORR()` no BigQuery):*

| Par de Variáveis | Coeficiente ($r$) | Intensidade e Direção | Interpretação Analítica |
| :--- | :---: | :--- | :--- |
| `in_spotify_playlists` $\times$ `streams` | **`0,7882`** | Positiva forte | Principal preditor linear de volume acumulado de *streams* na base. |
| `in_apple_playlists` $\times$ `streams` | **`0,7748`** | Positiva forte | Forte alinhamento de sucesso entre curadoria Apple Music e *streams* no Spotify. |
| `in_deezer_playlists` $\times$ `streams` | **`0,5990`** | Positiva moderada | Presença em playlists da Deezer acompanha o desempenho no Spotify. |
| `in_spotify_playlists` $\times$ `in_deezer_playlists` | **`0,8279`** | Positiva muito forte | Estratégias de inserção editorial ocorrem de forma altamente coordenada entre plataformas. |
| `in_spotify_playlists` $\times$ `in_apple_playlists` | **`0,7121`** | Positiva forte | Consistência curatorial entre os dois maiores ecossistemas de *streaming*. |
| `in_apple_charts` $\times$ `streams` | **`0,3169`** | Positiva fraca | *Charts* capturam picos momentâneos, com menor peso no acumulado total. |
| `in_spotify_charts` $\times$ `streams` | **`0,2417`** | Positiva fraca | Rankings instantâneos não garantem acúmulo de longo prazo como as playlists. |
| `in_deezer_charts` $\times$ `streams` | **`0,2280`** | Positiva fraca | Mesmo comportamento de curto prazo observado nos *charts* do Spotify. |
| `released_year` $\times$ `streams` | **`-0,2404`** | Negativa fraca | Faixas de anos anteriores (*catálogo de fundo*) acumulam mais *streams* pelo maior tempo de exposição. |
| `artist_count` $\times$ `streams` | **`-0,1233`** | Negativa muito fraca / nula | Maior número de artistas (*feats*) não implica linearmente mais *streams*. |
| `released_month` $\times$ `streams` | **`-0,0406`** | Nula | A sazonalidade ocorre em picos pontuais (jan./set.), sem relação linear crescente ao longo dos meses. |
| `in_shazam_charts` $\times$ `streams` | **`-0,0140`** | Nula | Reconhecimento pontual de áudio no Shazam não se traduz diretamente em volume acumulado no Spotify. |

  - *Gráfico de Dispersão (`in_spotify_playlists` $\times$ `streams` com linha de tendência linear no Looker Studio):*
    - **Confirmação Visual:** A nuvem de 838 pontos acompanha a inclinação ascendente da linha de tendência, com maior densidade concentrada abaixo de **10 mil playlists** e **1 bilhão de *streams***.
    - **Dispersão e Saturação:** Acima de **20 mil playlists**, observa-se abertura em forma de cone (heterocedasticidade), evidenciando tanto *super-hits* que ultrapassam **2,5 bi – 3,7 bi de *streams*** com **15 mil – 44 mil playlists** quanto faixas com **40 mil – 53 mil playlists** que estacionam abaixo de **2 bi de *streams*** (saturação editorial sem tração orgânica equivalente).

---

## 💡 Resultados e Conclusões (Meta 10 — Concluída)

### Respostas às Perguntas de Negócio
1. **[Prioridade 1 — Curadoria Editorial (Playlists e Charts vs. Streams)]:**
   - *1.1. Playlists:* **Sim, há forte associação positiva ($r = 0{,}7882$).** Quanto maior a presença em playlists do Spotify, maior tende a ser o volume acumulado de *streams*, com maior ganho marginal na faixa de entrada (até 10 mil playlists). Acima de 20 mil playlists surgem retornos decrescentes (faixas em 40 mil–53 mil playlists estacionando abaixo de 2 bi de *streams* sem tração orgânica equivalente). Como a base não possui série temporal diária, a relação indica retroalimentação (playlists impulsionam *streams* e sucessos orgânicos atraem mais playlists), não causalidade isolada.
   - *1.2. Presença em Charts:* **Sim, entrar nos rankings do Spotify quase dobra a mediana de reproduções.** As **473 faixas** presentes em *charts* (`> 0`) alcançam mediana de **405,14 milhões** de *streams* (média de **663,00 mi** e **6.591,9 playlists**), frente à mediana de **213,44 milhões** (média de **372,82 mi** e **4.182,8 playlists**) nas **365 faixas** fora dos *charts* (**+89,8%** na mediana).
2. **[Prioridade 2 — Sinais Precoces e Alcance Multiplataforma]:**
   - *2.1. Ecossistema Concorrente:* **Playlists externas são sinais precoces confiáveis; Shazam não sustenta volume isoladamente.** A presença em playlists da **Apple Music ($r = 0{,}7748$)** e **Deezer ($r = 0{,}5990$)** correlaciona-se fortemente com os *streams* no Spotify e reflete alta sincronia editorial entre plataformas ($r = 0{,}8279$ com Deezer; $r = 0{,}7121$ com Apple Music). Já o **Shazam ($r = -0{,}0140$)** tem correlação nula com o acumulado total, indicando descobertas pontuais de curto prazo que dependem de conversão posterior em playlists.
3. **[Prioridade 3 — Padrões de Catálogo (Gênero, País, Nº de Artistas) e Lançamento]:**
   - *3.1. Atributos da Faixa:*
     - **Quantidade de Artistas:** **Faixas solo superam colaborações.** Músicas com **1 artista (536 faixas)** lideram com mediana de **328,21 mi** de *streams* (média de **583,10 mi** e **6.032,1 playlists**), superando **feats duplos (208 faixas | mediana de 252,87 mi)** e **multi-feats de 3+ artistas (94 faixas | mediana de 223,58 mi)** ($r = -0{,}1233$).
     - **Gênero Musical:** **Pop** lidera em volume total (**154 faixas** | **115,20 bi** de *streams*), seguido por **Hip-hop** (**116 faixas** | **49,72 bi**). Entretanto, gêneros menores apresentam maior eficiência média por faixa e penetração editorial: **EDM** (**1,27 bi**/faixa e **20.936,5 playlists**), **Indie rock** (**1,17 bi**/faixa) e **Alternative rock** (**1,09 bi**/faixa). **K-pop** (**57 faixas**) destaca-se pela mobilização inicial de *fanbase*, mas com baixa inserção em playlists (**962,25** em média) e menor média de *streams* (**287,90 mi**).
     - **País de Origem:** Forte concentração nos **Estados Unidos** (> **200 bi** de *streams* | ~360 faixas), **Reino Unido** (~86 bi) e **Canadá** (~41 bi), com **Porto Rico** (~28 bi) e **Coreia do Sul** (~17 bi) como principais polos não anglófonos.
   - *3.2. Momento de Lançamento:* Faixas de anos anteriores acumulam mais *streams* totais pelo maior tempo de catálogo ($r = -0{,}2404$). Na sazonalidade mensal, **Janeiro** combina alto volume de lançamentos (~117 faixas) e alta média de *streams* (~780 mi), enquanto **Agosto** (~660 mi/faixa) e **Setembro** (~800 mi/faixa) oferecem janelas de menor concorrência e maior retorno médio por faixa, ao contrário de **Maio** (~109 lançamentos com média diluída de ~435 mi).

### Principais Insights e Recomendações ao Board / Time Editorial
- **Insight 1 (Teto de Saturação Editorial):** Inserir uma faixa em mais de 40 mil playlists não garante retorno proporcional se não houver engajamento orgânico equivalente (efeito cone observado acima de 20 mil playlists). $\rightarrow$ **Recomendação:** Redistribuir orçamento e espaço editorial de faixas saturadas para apostas de alta eficiência média por faixa (como *EDM*, *Indie rock*, *Alternative rock* e faixas de *K-pop* com alta tração inicial de fãs mas baixa penetração em playlists generalistas).
- **Insight 2 (Radar Multiplataforma como Gatilho de Priorização):** Playlists na Apple Music ($r = 0{,}7748$) e Deezer ($r = 0{,}5990$) são fortes indicadores antecedentes de sucesso no Spotify, enquanto picos isolados no Shazam ($r = -0{,}0140$) não se convertem sozinhos em volume acumulado. $\rightarrow$ **Recomendação:** Usar a tração simultânea em playlists concorrentes e a entrada nos *charts* do Spotify (que eleva a mediana de *streams* em +89,8%) como gatilhos objetivos para escalar faixas para playlists editoriais de topo.
- **Insight 3 (Planejamento de Calendário e Portfólio):** Faixas solo superam *multi-feats* em mediana de *streams* (+46,8% sobre 3+ artistas), e meses de menor oferta (agosto e setembro) entregam picos de média de *streams* por lançamento. $\rightarrow$ **Recomendação:** Priorizar lançamentos estratégicos nas janelas de menor concorrência (agosto/setembro) e evitar concentrar apostas de catálogo apenas em períodos saturados como maio.

---

## 📊 Dashboard Executivo no Looker Studio (Meta 11 — Concluída)
- **Estrutura da Página Executiva:** Página única organizada em quatro faixas horizontais conectadas diretamente à view `laboratoria-dados.spotify.vw_spotify_consolidada` (838 faixas únicas), com identidade visual em verde e grafite e bloqueio de cruzamento de filtros para evitar efeitos indesejados nos gráficos comparativos:
  - **Cabeçalho e Filtros:** Título e contexto do projeto à esquerda (com ícone do Spotify) e três listas suspensas alinhadas (`Gênero Musical`, `País` e `Ano de Lançamento`).
  - **Cartões de KPI (Compactados):** `Faixas Analisadas` (**838**), `Média de Streams` (**536,6 mi**), `Média de Playlists Spotify` (**5,5 mil**) e `Total de Streams` (**449,7 bi**).
  - **Grade Visual Principal:** Gráfico de dispersão *Playlists Spotify × Streams ($r = 0{,}79$)* com linha de tendência linear, gráfico de colunas *Top 10 Países por Streams e Faixas*, tabela dinâmica *Desempenho por Gênero Musical* (com linha de *Total geral*) e gráfico de combinação *Sazonalidade Mensal (Lançamentos vs. Média de Streams)* ordenado de janeiro a dezembro.
  - **Faixa de Conclusões:** Resumo executivo no rodapé destacando o teto de saturação editorial e o papel dos *charts*, sinais multiplataforma, faixas solo e janelas sazonais.

---

## 🎤 Storytelling e Apresentação Executiva (Meta 12 — Concluída)
- **Roteiro Narrativo (6 Blocos):** Estruturado para audiência executiva (Marina Costa, Rafael Tenório e Bianca Ferraz) seguindo o arco *Gancho $\rightarrow$ Contexto $\rightarrow$ Jornada $\rightarrow$ Descoberta $\rightarrow$ Recomendação $\rightarrow$ Riscos/Limitações*, apoiado exclusivamente nos gráficos do dashboard no Looker Studio e em métricas validadas na Ficha Técnica.
- **Entrega e Sessão de Reflexão:** Preparação da submissão na plataforma (Ficha Técnica + link do dashboard/apresentação) e do pitch executivo para troca de feedback com o coach e colegas.

---

## 🚀 Próximos Passos e Evolução da Coleta
- **Sugestões para Data Engineering:** Incorporar série temporal diária de *streams* e logs de data de entrada em playlists editoriais para permitir testes A/B e análise de causalidade temporal (pré vs. pós-curadoria), além de padronizar o tipo de dado da chave `track_id` (`INT64`) e validar o dicionário de gêneros na ingestão.

---

## 🔗 Links de Interesse
- **Repositório Principal:** [README.md](../README.md)
- **Plano de Execução e Metas:** [plano-execucao.md](./plano-execucao.md)
- **Scripts SQL:** [`/sql`](../sql/)
- **Dashboard Interativo (Data Studio): [https://datastudio.google.com/s/n5KY2J52el4]