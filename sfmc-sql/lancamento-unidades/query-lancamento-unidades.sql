/*
  Projeto: Lançamento de Unidades — Salesforce Marketing Cloud

  Objetivo:
  Criar segmentação unificada para campanhas de lançamento de unidades,
  utilizando clientes ativos, ex-clientes e leads.

  Observação:
  Estrutura anonimizada para preservação de confidencialidade.
*/

SELECT
    x.Email,
    x.Nome,
    x.Unidade_Lancamento,
    x.origem
FROM (

    SELECT
        base.Email,
        base.Nome,
        base.Unidade_Lancamento,
        base.origem,
        ROW_NUMBER() OVER (
            PARTITION BY base.Email, base.Unidade_Lancamento
            ORDER BY base.data_referencia DESC
        ) AS rn
    FROM (

        /* Clientes */

        SELECT
            cli.Email,
            cli.Nome,
            mapa.Unidade_Lancamento,
            cli.data_referencia,
            'Clientes' AS origem
        FROM [DE_CLIENTES] cli
        INNER JOIN [DE_MAPA_UNIDADES] mapa
            ON cli.sigla_unidade = mapa.sigla_unidade
        LEFT JOIN _Subscribers s
            ON cli.Email = s.SubscriberKey
        WHERE
            cli.flag_status_cliente IN ('Ativo', 'Cancelado')
            AND cli.permissao_email = 'S'
            AND cli.status_pagamento <> 'Inadimplente'
            AND (
                s.Status NOT IN ('Bounced', 'Held', 'Unsubscribed')
                OR s.SubscriberKey IS NULL
            )

        UNION ALL

        /* Leads Loja Física */

        SELECT
            lead.Email,
            lead.Nome,
            mapa.Unidade_Lancamento,
            lead.data_acesso AS data_referencia,
            'Lead Loja Fisica' AS origem
        FROM [DE_LEADS_LOJA] lead
        INNER JOIN [DE_MAPA_UNIDADES] mapa
            ON lead.sigla_unidade = mapa.sigla_unidade
        WHERE
            lead.permissao_email = 'S'

        UNION ALL

        /* Leads Checkout */

        SELECT
            checkout.Email,
            checkout.Nome,
            mapa.Unidade_Lancamento,
            checkout.data_acesso AS data_referencia,
            'Lead Checkout' AS origem
        FROM [DE_LEADS_CHECKOUT] checkout
        INNER JOIN [DE_MAPA_UNIDADES] mapa
            ON checkout.sigla_unidade = mapa.sigla_unidade
        WHERE
            checkout.permissao_email = 'S'

    ) base

) x
WHERE x.rn = 1
