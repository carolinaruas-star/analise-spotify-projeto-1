# 🗓️ Plano de Execução e Metodologia — Projeto 1 (Rota B)

Este documento registra a estruturação ágil e o planejamento de entregas do **Projeto 1: Análise Spotify (Rota B)**, desenvolvido no programa **Ativa sua Carreira — Laboratória Brasil**.

---

## 🎯 Estratégia de Execução (Sprint Acelerada)

Para viabilizar a entrega completa dos **dois projetos** previstos na trilha com alto rigor técnico, o desenvolvimento foi dividido em 4 blocos operacionais focados nos critérios de aceitação obrigatórios:

| Sprint / Bloco | Foco Principal | Metas Cobertas | Status |
| :--- | :--- | :--- | :--- |
| **Bloco 1: Negócio & Setup** | Definição do problema, formulação de hipóteses e ingestão no BigQuery | **Metas 0 e 1** | ✅ Concluído |
| **Bloco 2: Saneamento SQL** | Qualidade de dados (nulos, duplicatas, outliers categóricos/numéricos) e `JOIN` | **Metas 2 a 6** | 🔄 Em andamento |
| **Bloco 3: EDA & Insights** | Agregações, visualizações exploratórias, correlações e respostas ao negócio | **Metas 7 a 10** | ⏳ Pendente |
| **Bloco 4: BI & Entrega** | Construção do painel interativo no Looker Studio e apresentação final | **Metas 11 e 12** | ⏳ Pendente |

---

## 📋 Checklist Operacional por Habilidade (Rota B)

### 🔹 Etapa 1: Entendimento do Negócio e Ambiente
- [x] **Meta 0:** Utilizar IA para mapear o problema de negócio e formular as perguntas estratégicas.
- [x] **Meta 1:** Criar projeto (`laboratoria-dados`), dataset (`spotify`) e importar as tabelas (`track_in_spotify` e `track_in_competition`) no Google BigQuery com integração via VS Code[cite: 2].

### 🔹 Etapa 2: Preparação e Limpeza da Base (BigQuery / SQL)
- [ ] **Meta 2:** Identificar e tratar valores nulos (`NULL`).
- [ ] **Meta 3:** Identificar e remover registros duplicados.
- [ ] **Meta 4:** Tratar valores atípicos e inconsistências em variáveis categóricas.
- [ ] **Meta 5:** Tratar valores atípicos e *outliers* em variáveis numéricas.
- [ ] **Meta 6:** Unir as tabelas tratadas utilizando comandos `JOIN`.

### 🔹 Etapa 3: Exploração e Análise de Resultados
- [ ] **Meta 7:** Agrupar e resumir dados em tabelas dinâmicas / queries agregadas.
- [ ] **Meta 8:** Visualizar e interpretar distribuições e tendências por meio de gráficos.
- [ ] **Meta 9:** Calcular e visualizar a correlação entre variáveis (atributos de áudio, playlists e *streams*).
- [ ] **Meta 10:** Responder formalmente às perguntas de negócio com base nas evidências encontradas.

### 🔹 Etapa 4: Visualização Executiva e Entrega
- [ ] **Meta 11:** Construir o dashboard interativo no Looker Studio conectado à base limpa.
- [ ] **Meta 12:** Consolidar a apresentação final e compartilhar o link do repositório / Ficha Técnica.

---

## 💡 Boas Práticas Adotadas
* **Priorização do Essencial (MVP Analítico):** Foco total no cumprimento dos critérios obrigatórios antes de explorar análises secundárias.
* **Fluxo Iterativo:** Avanço sequencial entre preparação, exploração e visualização, retornando ao saneamento SQL sempre que novos ruídos forem identificados na EDA.
* **Documentação Contínua:** Registro imediato de todas as queries, decisões de tratamento de dados e achados na [`Ficha Técnica`](./ficha-tecnica.md).