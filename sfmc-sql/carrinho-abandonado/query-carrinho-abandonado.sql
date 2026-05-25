/* 
  Projeto: Carrinho Abandonado — Salesforce Marketing Cloud
  Objetivo: Unificar leads de loja física e carrinho abandonado, aplicar filtros de consentimento,
  remover bounces/clientes ativos e deduplicar a base por SubscriberKey.

  Observação:
  Os nomes das Data Extensions foram anonimizados para preservar confidencialidade.
*/

SELECT
    x.SubscriberKey,
    x.Nome,
    x.Primeiro_Nome,
    x.Email,
    x.data_acesso,
    x.origem
FROM (
    SELECT
        base.SubscriberKey,
        base.Nome,
        base.Primeiro_Nome,
        base.Email,
        base.data_acesso,
        base.origem,
        ROW_NUMBER() OVER (
            PARTITION BY base.SubscriberKey
            ORDER BY base.data_acesso DESC
        ) AS rn
    FROM (

        /* Leads captados em loja física */
        SELECT
            lead.Email AS SubscriberKey,
            lead.Nome AS Nome,
            LEFT(lead.Nome, CHARINDEX(' ', lead.Nome + ' ') - 1) AS Primeiro_Nome,
            lead.Email AS Email,
            lead.data_acesso AS data_acesso,
            lead.id_unidade AS Unidade,
            'Lead Loja Fisica' AS origem
        FROM [DE_LEADS_LOJA_FISICA] lead
        LEFT JOIN [DE_CLIENTES] clientes
            ON lead.Email = clientes.Email
        LEFT JOIN _Bounce b
            ON b.SubscriberKey = lead.Email
        LEFT JOIN _Subscribers s
            ON s.SubscriberKey = lead.Email
        WHERE
            lead.permissao_envio_email = 'S'
            AND clientes.Email IS NULL
            AND b.SubscriberKey IS NULL
            AND (s.Status = 'Active' OR s.SubscriberKey IS NULL)
            AND lead.id_unidade IN ([LISTA_DE_UNIDADES])
            AND lead.data_acesso >= DATEADD(MONTH, -2, GETDATE())

        UNION ALL

        /* Leads com abandono de checkout */
        SELECT
            cart.Email AS SubscriberKey,
            cart.Nome AS Nome,
            LEFT(cart.Nome, CHARINDEX(' ', cart.Nome + ' ') - 1) AS Primeiro_Nome,
            cart.Email AS Email,
            cart.data_acesso AS data_acesso,
            cart.id_unidade AS Unidade,
            'Carrinho Abandonado' AS origem
        FROM [DE_CARRINHO_ABANDONADO] cart
        LEFT JOIN [DE_CLIENTES] clientes
            ON cart.Email = clientes.Email
        LEFT JOIN _Bounce b
            ON b.SubscriberKey = cart.Email
        LEFT JOIN _Subscribers s
            ON s.SubscriberKey = cart.Email
        WHERE
            cart.permissao_envio_email = 'S'
            AND clientes.Email IS NULL
            AND b.SubscriberKey IS NULL
            AND (s.Status = 'Active' OR s.SubscriberKey IS NULL)
            AND cart.id_unidade IN ([LISTA_DE_UNIDADES])
            AND cart.data_acesso >= DATEADD(MONTH, -2, GETDATE())

    ) base
) x
WHERE x.rn = 1;
