/*
  Projeto: Campanha Promocional Recorrente — Salesforce Marketing Cloud

  Objetivo:
  Construir uma base unificada para campanha promocional recorrente,
  contemplando ex-clientes e leads, com filtros de elegibilidade,
  consentimento, engajamento e controle de status no _Subscribers.

  Observação:
  Nomes de Data Extensions e estruturas internas foram anonimizados
  para preservação de confidencialidade.
*/

SELECT
    c.cliente_nome AS cliente_nome,
    c.cliente_primeiro_nome AS name,
    c.cliente_person_id AS subscriberkey,
    c.cliente_email AS email,
    c.cliente_genero,
    c.sigla_unidade,
    'Ex-cliente' AS flag_status,
    c.plan_name AS plan_name,
    c.dt_expiracao_contrato AS dt_expiracao_contrato,
    '[DE_CLIENTES_EXCLIENTES]' AS tabela_origem,
    c.flag_status_cliente AS status_cliente
FROM [DE_CLIENTES_EXCLIENTES] c

INNER JOIN _Subscribers x
    ON x.SubscriberKey = c.cliente_person_id

INNER JOIN [DE_UNIDADES_CAMPANHA] u
    ON c.sigla_unidade = u.sigla_unidade

LEFT JOIN (
    SELECT subscriberkey
    FROM [DE_ENGAJAMENTO_180D_EXCLIENTES]
    WHERE dt_ultima_abertura IS NULL
      AND qtde_emails > 20
) desengaj_cli
    ON desengaj_cli.subscriberkey = c.cliente_person_id

WHERE
    c.flag_status_cliente = 'Cancelado'
    AND c.dt_expiracao_contrato <= DATEADD(DAY, -90, GETDATE())
    AND c.dt_solicitacao_cancelamento >= DATEADD(MONTH, -18, GETDATE())
    AND c.pgto_status <> 'Inadimplente'
    AND c.cliente_permite_email = 'S'
    AND c.plan_name IN ('black', 'smart', 'fit')
    AND x.Status <> 'Unsubscribed'
    AND desengaj_cli.subscriberkey IS NULL


UNION


SELECT
    c.cliente_nome AS cliente_nome,
    c.cliente_primeiro_nome AS name,
    c.cliente_person_id AS subscriberkey,
    c.cliente_email AS email,
    c.cliente_genero,
    c.sigla_unidade,
    'Ex-cliente' AS flag_status,
    c.plan_name AS plan_name,
    c.dt_expiracao_contrato AS dt_expiracao_contrato,
    '[DE_CLIENTES_PLANO_ESPECIFICO_CANCELADO]' AS tabela_origem,
    dim.flag_status_cliente AS status_cliente
FROM [DE_CLIENTES_PLANO_ESPECIFICO_CANCELADO] c

INNER JOIN _Subscribers x
    ON x.SubscriberKey = c.cliente_person_id

INNER JOIN [DE_CLIENTES_EXCLIENTES] dim
    ON dim.cliente_person_id = c.cliente_person_id

INNER JOIN [DE_UNIDADES_CAMPANHA] u
    ON c.sigla_unidade = u.sigla_unidade

LEFT JOIN (
    SELECT subscriberkey
    FROM [DE_ENGAJAMENTO_180D_EXCLIENTES]
    WHERE dt_ultima_abertura IS NULL
      AND qtde_emails > 20
) desengaj_cli
    ON desengaj_cli.subscriberkey = c.cliente_person_id

WHERE
    dim.flag_status_cliente = 'Cancelado'
    AND dim.plan_name LIKE '%PLANO_ESPECIFICO%'
    AND c.data_saida IS NOT NULL
    AND c.pgto_status <> 'Inadimplente'
    AND c.cliente_permite_email = 'S'
    AND x.Status <> 'Unsubscribed'
    AND c.dt_expiracao_contrato <= DATEADD(DAY, -2, GETDATE())
    AND desengaj_cli.subscriberkey IS NULL


UNION


SELECT
    c.Nome AS cliente_nome,
    TRIM(SUBSTRING(c.Nome, 1, CHARINDEX(' ', c.Nome + ' ') - 1)) AS name,
    c.Email AS subscriberkey,
    c.Email AS email,
    '' AS cliente_genero,
    c.sigla_unidade,
    'Lead' AS flag_status,
    '' AS plan_name,
    NULL AS dt_expiracao_contrato,
    '[DE_LEADS_CHECKOUT]' AS tabela_origem,
    '' AS status_cliente
FROM [DE_LEADS_CHECKOUT] c

INNER JOIN _Subscribers a
    ON a.SubscriberKey = c.Email

INNER JOIN [DE_UNIDADES_CAMPANHA] u
    ON c.sigla_unidade = u.sigla_unidade

LEFT JOIN (
    SELECT subscriberkey
    FROM [DE_ENGAJAMENTO_180D_LEADS]
    WHERE dt_ultima_abertura IS NULL
      AND qtde_emails > 20
) desengaj_lead
    ON desengaj_lead.subscriberkey = c.Email

WHERE
    c.permissao_envio_email = 'S'
    AND c.data_acesso >= DATEADD(MONTH, -13, GETDATE())
    AND desengaj_lead.subscriberkey IS NULL
    AND a.Status <> 'Unsubscribed'
    AND NOT EXISTS (
        SELECT 1
        FROM [DE_CLIENTES_EXCLIENTES] ex
        WHERE ex.cliente_email = c.Email
    )


UNION


SELECT
    f.Nome AS cliente_nome,
    TRIM(SUBSTRING(f.Nome, 1, CHARINDEX(' ', f.Nome + ' ') - 1)) AS name,
    f.Email AS subscriberkey,
    f.Email AS email,
    '' AS cliente_genero,
    f.sigla_unidade,
    'Lead' AS flag_status,
    '' AS plan_name,
    NULL AS dt_expiracao_contrato,
    '[DE_LEADS_LOJA_FISICA]' AS tabela_origem,
    '' AS status_cliente
FROM [DE_LEADS_LOJA_FISICA] f

INNER JOIN _Subscribers a
    ON a.SubscriberKey = f.Email

INNER JOIN [DE_UNIDADES_CAMPANHA] u
    ON f.sigla_unidade = u.sigla_unidade

LEFT JOIN (
    SELECT subscriberkey
    FROM [DE_ENGAJAMENTO_180D_LEADS]
    WHERE dt_ultima_abertura IS NULL
      AND qtde_emails > 20
) desengaj_lead
    ON desengaj_lead.subscriberkey = f.Email

WHERE
    f.permissao_envio_email = 'S'
    AND f.data_acesso >= DATEADD(MONTH, -13, GETDATE())
    AND desengaj_lead.subscriberkey IS NULL
    AND a.Status <> 'Unsubscribed'
    AND NOT EXISTS (
        SELECT 1
        FROM [DE_CLIENTES_EXCLIENTES] ex
        WHERE ex.cliente_email = f.Email
    );
