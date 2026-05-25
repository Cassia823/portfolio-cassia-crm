# Carrinho Abandonado — Salesforce Marketing Cloud

Estrutura SQL desenvolvida para recuperação de leads com abandono de checkout utilizando Salesforce Marketing Cloud.

## Objetivo

Identificar usuários com abandono de processo de compra e realizar campanhas automatizadas de recuperação com segmentação comportamental.

---

## Regras de negócio

- Exclusão de clientes já ativos
- Controle de consentimento (opt-in)
- Exclusão de bounces
- Controle de status no _Subscribers
- Janela de acesso recente
- Deduplicação por e-mail

---

## Técnicas utilizadas

- ROW_NUMBER()
- LEFT JOIN
- UNION ALL
- Data Views
- Segmentação comportamental
- Tratamento de base
- Deduplicação de registros

---

## Data Views utilizadas

- _Subscribers
- _Bounce

---

## Objetivos da automação

- Recuperação de leads
- Reengajamento
- Conversão
- Escalabilidade de campanhas
- Governança de dados

---

## Conceitos aplicados

- Lifecycle Marketing
- CRM Analytics
- Customer Segmentation
- Behavioral Marketing
- Data Governance
- SQL for Marketing Automation
