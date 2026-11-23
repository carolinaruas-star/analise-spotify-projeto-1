-- %%
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

-- %%
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

-- %%
-- 3. Exemplo de inspeção detalhada (usando WHERE e IS NULL conforme o guia)
-- Substitua ou adicione colunas que apresentarem contagem > 0 acima
SELECT *
FROM `laboratoria-dados.spotify.track_in_competition`
WHERE in_shazam_charts IS NULL;

-- %%
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

-- %%
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

-- %%
-- 2. Verificar duplicados de música + artista na tabela track_in_spotify
-- (Detecta casos em que a mesma faixa entrou duas vezes com track_id diferente)
SELECT
  track_name,
  artists_name,
  COUNT(*) AS qtd_ocorrencias
FROM `laboratoria-dados.spotify.track_in_spotify`
GROUP BY track_name, artists_name
HAVING COUNT(*) > 1;

-- %%
-- 3. Verificar duplicados de track_id na tabela track_in_competition
SELECT
  track_id,
  COUNT(*) AS qtd_ocorrencias
FROM `laboratoria-dados.spotify.track_in_competition`
GROUP BY track_id
HAVING COUNT(*) > 1;

-- %%
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

-- %%
-- 5. Verificar por que track_in_competition tem 953 linhas e track_in_spotify tem 843
-- (Checa quantos track_ids existem em uma tabela e não existem na outra)
SELECT
  COUNT(*) AS total_competition,
  COUNT(s.track_id) AS encontrados_no_spotify,
  COUNT(*) - COUNT(s.track_id) AS ausentes_no_spotify
FROM `laboratoria-dados.spotify.track_in_competition` c
LEFT JOIN `laboratoria-dados.spotify.track_in_spotify` s
  ON c.track_id = s.track_id;

-- %%
-- 6. Verificar correspondência de track_id entre track_in_competition e track_in_spotify
-- (Com SAFE_CAST para resolver a divergência de tipagem STRING vs. INT64)
SELECT
  COUNT(*) AS total_competition,
  COUNT(s.track_id) AS encontrados_no_spotify,
  COUNT(*) - COUNT(s.track_id) AS ausentes_no_spotify
FROM `laboratoria-dados.spotify.track_in_competition` c
LEFT JOIN `laboratoria-dados.spotify.track_in_spotify` s
  ON SAFE_CAST(c.track_id AS INT64) = SAFE_CAST(s.track_id AS INT64);

-- %%
-- ============================================================================
-- META 4: DIAGNÓSTICO DE VARIÁVEIS CATEGÓRICAS (DISTINCT / GROUP BY)
-- Projeto: laboratoria-dados | Dataset: spotify
-- ============================================================================

-- 1. Listar todos os valores únicos e frequência de main_country
SELECT
  main_country,
  COUNT(*) AS qtd_faixas
FROM `laboratoria-dados.spotify.track_in_spotify`
GROUP BY main_country
ORDER BY main_country;

-- %%
-- 2. Listar todos os valores únicos e frequência de main_music_genre
SELECT
  main_music_genre,
  COUNT(*) AS qtd_faixas
FROM `laboratoria-dados.spotify.track_in_spotify`
GROUP BY main_music_genre
ORDER BY main_music_genre;

-- %%
-- 3. Verificar se existem espaços extras no início/fim ou variações de caixa (UPPER/LOWER)
SELECT
  COUNTIF(main_country != TRIM(main_country)) AS espacos_country,
  COUNTIF(main_music_genre != TRIM(main_music_genre)) AS espacos_genre,
  COUNT(DISTINCT main_country) AS paises_exatos,
  COUNT(DISTINCT LOWER(TRIM(main_country))) AS paises_normalizados,
  COUNT(DISTINCT main_music_genre) AS generos_exatos,
  COUNT(DISTINCT LOWER(TRIM(main_music_genre))) AS generos_normalizados
FROM `laboratoria-dados.spotify.track_in_spotify`;

-- %%
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

-- %%
-- 5. Auditar todos os artistas rotulados como 'Heavy metal' (97 linhas)
SELECT
  artists_name,
  COUNT(*) AS qtd_faixas
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE main_music_genre = 'Heavy metal'
GROUP BY artists_name
ORDER BY qtd_faixas DESC, artists_name;

-- %%
-- (Opcional) Conferir qual é o único registro classificado como 'Grunge' na base
SELECT
  track_id,
  track_name,
  artists_name,
  main_music_genre,
  streams
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE main_music_genre = 'Grunge';

-- %%
-- (Opcional) Conferir quais registros classificados como 'Rock' na base
SELECT
  track_id,
  track_name,
  artists_name,
  main_music_genre,
  streams
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE main_music_genre = 'Rock';

-- %%
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

-- %%
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

-- %%
-- ============================================================================
-- META 5: DIAGNÓSTICO DE VARIÁVEIS NUMÉRICAS, TIPAGEM E OUTLIERS
-- Projeto: laboratoria-dados | Dataset: spotify
-- ============================================================================

-- 1. Validar tipagem com SAFE_CAST na tabela track_in_spotify
-- (Verifica se há valores não numéricos ou formatados como texto que falham na conversão)
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

-- %%
-- 2. Validar tipagem com SAFE_CAST na tabela track_in_competition
SELECT
  COUNT(*) AS total_linhas,
  COUNTIF(SAFE_CAST(in_apple_playlists AS INT64) IS NULL AND in_apple_playlists IS NOT NULL) AS erro_apple_playlists,
  COUNTIF(SAFE_CAST(in_apple_charts AS INT64) IS NULL AND in_apple_charts IS NOT NULL) AS erro_apple_charts,
  COUNTIF(SAFE_CAST(in_deezer_playlists AS INT64) IS NULL AND in_deezer_playlists IS NOT NULL) AS erro_deezer_playlists,
  COUNTIF(SAFE_CAST(in_deezer_charts AS INT64) IS NULL AND in_deezer_charts IS NOT NULL) AS erro_deezer_charts,
  COUNTIF(SAFE_CAST(in_shazam_charts AS INT64) IS NULL AND in_shazam_charts IS NOT NULL) AS erro_shazam_charts
FROM `laboratoria-dados.spotify.track_in_competition`;

-- %%
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

-- %%
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

-- %%
-- 5. Inspecionar registros anômalos em in_spotify_playlists e streams (<= 0 ou muito baixos)
SELECT *
FROM `laboratoria-dados.spotify.track_in_spotify`
WHERE SAFE_CAST(in_spotify_playlists AS INT64) IS NULL
   OR SAFE_CAST(streams AS INT64) <= 10000
   OR SAFE_CAST(in_spotify_playlists AS INT64) <= 0;

-- %%
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

-- %%
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

-- %%
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

-- %%
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

-- %%
-- ============================================================================
-- META 9: MATRIZ DE CORRELAÇÃO DE PEARSON (CORR)
-- Projeto: laboratoria-dados | Dataset: spotify
-- ============================================================================

SELECT
  -- 1. Curadoria Editorial e Rankings no Spotify (Perguntas 1.1 e 1.2)
  ROUND(CORR(in_spotify_playlists, streams), 4) AS corr_spotify_playlists_streams,
  ROUND(CORR(in_spotify_charts, streams), 4) AS corr_spotify_charts_streams,

  -- 2. Ecossistema Multiplataforma e Sinais Precoces (Pergunta 2.1)
  ROUND(CORR(in_apple_playlists, streams), 4) AS corr_apple_playlists_streams,
  ROUND(CORR(in_apple_charts, streams), 4) AS corr_apple_charts_streams,
  ROUND(CORR(in_deezer_playlists, streams), 4) AS corr_deezer_playlists_streams,
  ROUND(CORR(in_deezer_charts, streams), 4) AS corr_deezer_charts_streams,
  ROUND(CORR(in_shazam_charts, streams), 4) AS corr_shazam_charts_streams,

  -- 3. Correlação Cruzada entre Playlists das Plataformas
  ROUND(CORR(in_spotify_playlists, in_apple_playlists), 4) AS corr_playlists_spotify_apple,
  ROUND(CORR(in_spotify_playlists, in_deezer_playlists), 4) AS corr_playlists_spotify_deezer,

  -- 4. Atributos da Faixa e Lançamento (Perguntas 3.1 e 3.2)
  ROUND(CORR(artist_count, streams), 4) AS corr_artist_count_streams,
  ROUND(CORR(released_year, streams), 4) AS corr_released_year_streams,
  ROUND(CORR(released_month, streams), 4) AS corr_released_month_streams
FROM `laboratoria-dados.spotify.vw_spotify_consolidada`;

-- %%
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

-- %%
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