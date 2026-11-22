# 🎵 Projeto 1: Análise Spotify (Rota B) — Laboratória Brasil

![Google BigQuery](https://img.shields.io/badge/Google_BigQuery-669DF6?style=for-the-badge&logo=google-bigquery&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=postgresql&logoColor=white)
![Looker Studio](https://img.shields.io/badge/Looker_Studio-4285F4?style=for-the-badge&logo=google-analytics&logoColor=white)
![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visual-studio-code&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

## 📋 Sobre o Projeto
Este repositório documenta o desenvolvimento do **Projeto 1 – Análise Spotify (Rota B)**, realizado como parte da trilha de Dados e Inteligência Artificial do programa **Ativa sua Carreira (Laboratória Brasil)**. 

O modelo de negócio do Spotify depende diretamente da retenção e do tempo de escuta dos usuários, impulsionados pela curadoria editorial de playlists e recomendações algorítmicas. O desafio deste projeto consiste em analisar dados reais de músicas populares em **2023** (no Spotify e em plataformas concorrentes como Apple Music, Deezer e Shazam) para **identificar sinais precoces de sucesso**, separar sinal de ruído e apoiar o time editorial com recomendações estratégicas baseadas em evidências.

---

## 🎯 Propósito e Competências Desenvolvidas (Marco 1)
Ao longo deste projeto, o foco está no desenvolvimento de competências analíticas essenciais para a atuação orientada a dados:

* **Formulação e Avaliação de Perguntas de Negócio:** Estruturar perguntas eficazes que guiem a investigação e avaliá-las por meio de técnicas de análise estatística e exploratória.
* **Análise de Relações e Rigor Estatístico:** Identificar relações significativas entre variáveis, distinguindo padrões reais e relevantes daqueles que podem ocorrer meramente ao acaso.
* **Saneamento e Modelagem de Dados:** Estruturar pipelines em SQL no BigQuery (`laboratoria-dados.spotify`) para diagnóstico de qualidade, tratamento de anomalias e integração relacional (`JOIN`) entre `track_in_spotify` e `track_in_competition`[cite: 2].
* **Recomendações Baseadas em Evidências:** Traduzir os achados analíticos em visualizações claras no Looker Studio e oferecer recomendações fundamentadas para a curadoria editorial.

---

## 🛠️ Stack Tecnológica
* **Armazenamento, Extração e Transformação:** Google BigQuery (SQL)
* **Ambiente de Desenvolvimento:** VS Code (*Google Cloud Data Agent Kit*)[cite: 2]
* **Visualização de Dados e Business Intelligence:** Looker Studio
* **Versionamento e Documentação:** Git & GitHub

---

## 🧭 Escopo e Metas de Aprendizagem (Roadmap)

### Fase 0: Entendimento do Negócio
- [x] **0. Entendimento do Negócio:** Compreender o problema da curadoria editorial e formular as perguntas estratégicas com apoio de IA.

### Fase 1: Processamento e Preparação da Base de Dados (BigQuery / SQL)
- [x] **1. Configuração do Ambiente:** Criar projeto (`laboratoria-dados`), dataset (`spotify`) e importar `track_in_spotify` e `track_in_competition` no BigQuery integrado ao VS Code[cite: 2].
- [ ] **2. Valores Nulos:** Usar comandos SQL para identificar e tratar valores nulos (`NULL`).
- [ ] **3. Valores Duplicados:** Usar comandos SQL para identificar e remover registros duplicados.
- [ ] **4. Variáveis Categóricas:** Usar comandos SQL para tratar valores atípicos em variáveis categóricas (`main_music_genre`, `main_country`, etc.).
- [ ] **5. Variáveis Numéricas:** Usar comandos SQL para tratar valores atípicos e *outliers* em variáveis numéricas.
- [ ] **6. Integração Relacional:** Unir as tabelas tratadas com `JOIN` via `track_id`.

### Fase 2: Análise Exploratória de Dados (EDA)
- [ ] **7. Agregação e Resumo:** Agrupar e resumir dados em tabelas dinâmicas e consultas analíticas.
- [ ] **8. Visualização Exploratória:** Visualizar e interpretar dados através de gráficos.
- [ ] **9. Análise de Correlação:** Visualizar e calcular correlação entre variáveis.

### Fase 3: Aplicação Analítica, Visualização e Entrega
- [ ] **10. Resposta às Perguntas de Negócio:** Aplicar técnicas de análise para responder formalmente às questões levantadas.
- [ ] **11. Dashboard Interativo:** Resumir informações e KPIs em um dashboard no Looker Studio.
- [ ] **12. Apresentação de Resultados:** Consolidar insights, recomendações e apresentar os resultados finais.

---

## ✅ Critérios de Aceitação e Entregáveis
- [ ] Base de dados limpa e tabelas unidas via SQL no BigQuery.
- [ ] Análises exploratórias realizadas (tabelas, gráficos e cálculo de correlações).
- [ ] Insights acionáveis e de valor para o time editorial extraídos a partir da análise.
- [ ] Dashboard interativo publicado no Looker Studio conectado à base tratada.
- [ ] **Ficha Técnica** documentada no repositório contendo consultas SQL, descrição do processo e resultados obtidos.

---

## 🗂️ Estrutura do Repositório
```text
├── sql/                     # Consultas de diagnóstico, limpeza, JOINs e modelagem (BigQuery)
├── docs/                    # Ficha Técnica, plano de execução, dicionário de dados e resultados
└── README.md                # Documentação principal e visão executiva do projeto
```

---

## 🔗 Links Rápidos
* **Ficha Técnica (Consultas, Processo e Resultados):** [`docs/ficha-tecnica.md`](./docs/ficha-tecnica.md)
* **Plano de Execução e Metas (Rota B):** [`docs/plano-execucao.md`](./docs/plano-execucao.md)
* **Dashboard Interativo (Looker Studio):** *Em desenvolvimento*
* **Programa:** Ativa sua Carreira — Laboratória Brasil

---

<div align="center">
  👩‍💻 Desenvolvido por <a href="https://github.com/carolinaruas-star"><strong>Carolina Ruas</strong></a> durante o programa <strong>Ativa sua Carreira — Laboratória Brasil</strong> 🚀<br>
  ⭐ Este repositório faz parte da minha trajetória de aprofundamento e prática em análise de dados, consultas SQL no BigQuery, visualização estratégica no Looker Studio e resolução de problemas de negócio orientados por dados.
</div>