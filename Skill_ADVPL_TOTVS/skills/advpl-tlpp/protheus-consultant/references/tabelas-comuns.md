# Tabelas comuns do Protheus por módulo

> **Como usar este arquivo.** Este é um catálogo de referência das tabelas e
> campos-chave mais estáveis do Protheus. Convenções e tabelas centrais (SA1,
> SE1, SC5, SD2...) são consistentes entre releases, mas **a lista de campos de
> cada tabela varia por release, por customização e por país**. O dicionário do
> ambiente é a fonte da verdade: confirme em `SX3` (campos), `SX2` (mapa de
> tabelas) e `SIX` (índices) antes de afirmar que um campo existe ou tem
> determinado nome. Se um campo não estiver aqui, não o invente — consulte o
> SX3 do cliente.

## Índice
- [Convenções de nomenclatura](#convenções-de-nomenclatura)
- [Dicionário de dados (metadados)](#dicionário-de-dados-metadados)
- [Cadastros gerais](#cadastros-gerais)
- [Faturamento / Vendas (SIGAFAT)](#faturamento--vendas-sigafat)
- [Compras (SIGACOM)](#compras-sigacom)
- [Estoque / Custos (SIGAEST)](#estoque--custos-sigaest)
- [Financeiro (SIGAFIN)](#financeiro-sigafin)
- [Fiscal (SIGAFIS)](#fiscal-sigafis)
- [Contábil (SIGACTB)](#contábil-sigactb)
- [Como descobrir campos no ambiente](#como-descobrir-campos-no-ambiente)

---

## Convenções de nomenclatura

A tabela lógica usa 3 caracteres (ex.: `SE1`). A tabela **física** no banco leva
o sufixo da empresa/grupo de compartilhamento (ex.: `SE1010`, `SA1010`). Sempre
confirme o sufixo do ambiente — não assuma `010`.

O prefixo dos campos deriva da própria tabela: `SA1` → campos `A1_*`; `SE1` →
`E1_*`; `SC5` → `C5_*`; `SD2` → `D2_*`. Toda tabela carrega campos de controle
do framework: `R_E_C_N_O_`, `D_E_L_E_T_` (registro logicamente excluído quando
≠ ' '), e geralmente os campos de filial `XX_FILIAL`.

`D_E_L_E_T_ = ' '` em **todo** filtro de query é obrigatório para ignorar
registros logicamente excluídos.

---

## Dicionário de dados (metadados)

Estas são as tabelas que descrevem o próprio dicionário. São a fonte para
confirmar campos/parâmetros antes de citá-los.

| Tabela | Descrição | Campos-chave |
|--------|-----------|--------------|
| SX2 | Mapa de tabelas (lógico → físico, path, modo de abertura) | X2_CHAVE, X2_ARQUIVO, X2_NOME, X2_PATH, X2_MODO |
| SX3 | Campos das tabelas (definição de cada campo do dicionário) | X3_ARQUIVO, X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_TITULO, X3_DESCRIC, X3_USADO, X3_CONTEXT (R=Real/V=Virtual), X3_PICTURE, X3_RELACAO, X3_VALID |
| SX6 | Parâmetros (MV_*) | X6_VAR, X6_TIPO, X6_CONTEUD, X6_DESCRIC, X6_DSCSPA, X6_DSCENG, X6_PROPRI |
| SX7 | Gatilhos de campo | X7_CAMPO, X7_SEQUENC, X7_REGRA, X7_CDOMIN, X7_TIPO, X7_PROPRI |
| SX1 | Perguntas (pergunte) das rotinas | X1_GRUPO, X1_ORDEM, X1_PERGUNT, X1_VARIAVL, X1_VAR01, X1_TIPO |
| SX5 | Tabelas genéricas (domínios cadastrais) | X5_TABELA, X5_CHAVE, X5_DESCRI |
| SIX | Índices das tabelas | INDICE, ORDEM, CHAVE, DESCRICAO, NICKNAME |

---

## Cadastros gerais

| Tabela | Descrição | Campos-chave |
|--------|-----------|--------------|
| SA1 | Clientes | A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ, A1_CGC, A1_END, A1_EST, A1_MUN, A1_COD_MUN, A1_INSCR, A1_MSBLQL (bloqueio) |
| SA2 | Fornecedores | A2_COD, A2_LOJA, A2_NOME, A2_NREDUZ, A2_CGC, A2_EST, A2_MUN, A2_INSCR, A2_BANCO, A2_AGENCIA, A2_NUMCON |
| SA3 | Vendedores | A3_COD, A3_NOME, A3_COMIS, A3_EMAIL |
| SA6 | Bancos | A6_COD, A6_AGENCIA, A6_NUMCON, A6_NOME |
| SED | Naturezas (financeiras) | ED_CODIGO, ED_DESCRIC, ED_TIPO |
| SYA | Países / regiões fiscais | YA_CODGI, YA_DESCR |

---

## Faturamento / Vendas (SIGAFAT)

| Tabela | Descrição | Campos-chave |
|--------|-----------|--------------|
| SB1 | Produtos (cadastro / dados genéricos) | B1_COD, B1_DESC, B1_TIPO, B1_UM, B1_GRUPO, B1_LOCPAD, B1_POSIPI (NCM), B1_ORIGEM, B1_RASTRO, B1_LOCALIZ |
| SC5 | Pedido de venda — cabeçalho | C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_CONDPAG, C5_TPFRETE, C5_TIPO, C5_NOTA, C5_SERIE, C5_EMISSAO, C5_LIBEROK, C5_BLQ |
| SC6 | Pedido de venda — itens | C6_NUM, C6_ITEM, C6_PRODUTO, C6_QTDVEN, C6_QTDENT (entregue), C6_PRCVEN, C6_VALOR, C6_TES, C6_LOCAL, C6_NOTA, C6_BLQ |
| SC9 | Pedidos liberados (liberação de estoque/crédito) | C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_QTDLIB, C9_BLEST (bloq. estoque), C9_BLCRED (bloq. crédito), C9_NFISCAL |
| SF2 | Documento de saída — cabeçalho (NF de saída) | F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_TIPO, F2_VALMERC, F2_VALBRUT, F2_VALICM, F2_EST |
| SD2 | Documento de saída — itens | D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD (produto), D2_ITEM, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_TES, D2_CF (CFOP), D2_LOCAL, D2_PEDIDO, D2_ITEMPV, D2_EMISSAO |
| SF4 | TES — Tipos de Entrada/Saída | F4_CODIGO, F4_TIPO, F4_TES, F4_ESTOQUE (atualiza estoque S/N), F4_CREDICM, F4_DEBITO, F4_DUPLIC (gera financeiro), F4_CF, F4_PODER3 (poder de terceiros) |

A relação SC5/SC6 → SC9 → SF2/SD2 é o coração do faturamento. Pedido liberado
(SC9) com bloqueios zerados é o pré-requisito para gerar o documento de saída.

---

## Compras (SIGACOM)

| Tabela | Descrição | Campos-chave |
|--------|-----------|--------------|
| SC1 | Solicitação de compras (SC) | C1_NUM, C1_ITEM, C1_PRODUTO, C1_QUANT, C1_LOCAL, C1_APROV, C1_PEDIDO |
| SC7 | Pedido de compra | C7_NUM, C7_ITEM, C7_PRODUTO, C7_FORNECE, C7_LOJA, C7_QUANT, C7_QUJE (qtd já recebida), C7_PRECO, C7_TOTAL, C7_TES, C7_LOCAL, C7_ENCer (encerrado) |
| SC8 | Cotações | C8_NUM, C8_ITEM, C8_PRODUTO, C8_FORNECE, C8_PRECO |

A entrada física da mercadoria recai sobre o documento de entrada (SF1/SD1, no
Estoque/Faturamento), abatendo C7_QUJE.

---

## Estoque / Custos (SIGAEST)

| Tabela | Descrição | Campos-chave |
|--------|-----------|--------------|
| SB2 | Saldos em estoque (físico/financeiro por produto+armazém) | B2_COD, B2_LOCAL, B2_QATU (qtd atual), B2_QEMP (empenhada), B2_RESERVA, B2_QPEDVEN, B2_VATU1 (valor custo 1) |
| SB5 | Dados complementares do produto | B5_COD, B5_CEME, B5_FABR |
| SBM | Grupos de produtos | BM_GRUPO, BM_DESC |
| SD1 | Documento de entrada — itens (NF entrada) | D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD (produto), D1_ITEM, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_TES, D1_CF (CFOP), D1_LOCAL, D1_PEDIDO, D1_ITEMPC |
| SF1 | Documento de entrada — cabeçalho | F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, F1_EMISSAO, F1_DTDIGIT, F1_VALMERC |
| SD3 | Movimentações internas de estoque | D3_TM (tipo movimento), D3_COD, D3_LOCAL, D3_QUANT, D3_CUSTO1, D3_DOC, D3_EMISSAO, D3_CF |
| NNR | Locais / Armazéns | NNR_CODIGO, NNR_DESCRI, NNR_TPLOC |

`B2_QATU` é o saldo físico. Quando "o saldo não bate", a investigação costuma
cruzar SB2 com a soma das movimentações (SD1 entrada, SD2 saída, SD3 internas)
do produto+armazém, validando se a TES (SF4.F4_ESTOQUE) movimenta estoque.

---

## Financeiro (SIGAFIN)

| Tabela | Descrição | Campos-chave |
|--------|-----------|--------------|
| SE1 | Contas a receber (títulos) | E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_EMISSAO, E1_VENCTO, E1_VENCREA (venc. real), E1_VALOR, E1_SALDO, E1_BAIXA, E1_NATUREZ, E1_PORTADO, E1_SITUACA, E1_MOVIMEN |
| SE2 | Contas a pagar (títulos) | E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_EMISSAO, E2_VENCTO, E2_VENCREA, E2_VALOR, E2_SALDO, E2_BAIXA, E2_NATUREZ |
| SE5 | Movimento bancário (baixas, recebimentos, pagamentos) | E5_DATA, E5_VALOR, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_RECPAG (R/P), E5_NATUREZ, E5_SITUACA |

`E1_SALDO`/`E2_SALDO` = saldo em aberto do título. Baixa não atualizar saldo é
um dos chamados financeiros mais comuns — investigação tipicamente cruza SE1/SE2
com os movimentos de SE5 e valida se a baixa foi via rotina (FINA070/FINA080) ou
manipulação direta.

---

## Fiscal (SIGAFIS)

| Tabela | Descrição | Campos-chave |
|--------|-----------|--------------|
| SF3 | Livros fiscais (registro de apuração) | F3_NFISCAL, F3_SERIE, F3_CLIEFOR, F3_CFO (CFOP), F3_BASEICM, F3_VALICM, F3_ENTRADA, F3_SAIDA |
| CFO | Cadastro de CFOP (em alguns releases via SX5 tabela de CFOP) | confirmar no ambiente |

Conteúdo fiscal (NF-e, SPED, EFD, notas técnicas SEFAZ) **muda rápido** — para
qualquer dúvida fiscal/legislativa, pesquisar no TDN/SEFAZ antes de responder,
conforme regra de "Pesquisa externa obrigatória" no SKILL.md.

---

## Contábil (SIGACTB)

| Tabela | Descrição | Campos-chave |
|--------|-----------|--------------|
| CT1 | Plano de contas | CT1_CONTA, CT1_DESC01, CT1_CLASSE, CT1_NORMAL |
| CT2 | Lançamentos contábeis | CT2_DATA, CT2_LOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO (conta), CT2_CREDIT (conta), CT2_VALOR, CT2_HIST, CT2_CCD (centro custo débito), CT2_CCC |
| CTT | Centros de custo | CTT_CUSTO, CTT_DESC01, CTT_CLASSE, CTT_NORMAL |
| CTD | Itens contábeis | CTD_ITEM, CTD_DESC01 |
| CTH | Classes de valor | CTH_CLVL, CTH_DESC01 |
| CTO | Lançamentos padronizados | confirmar campos no ambiente |

---

## Como descobrir campos no ambiente

Quando precisar confirmar a existência/nome de um campo sem assumir, oriente o
usuário a consultar o dicionário direto no banco. Exemplo (objetivo: listar
todos os campos reais de uma tabela com tipo e título):

```sql
-- Objetivo: listar a estrutura de campos da SE1 conforme o dicionário do ambiente
SELECT X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_TITULO, X3_CONTEXT
FROM SX3010
WHERE X3_ARQUIVO = 'SE1'
  AND D_E_L_E_T_ = ' '
ORDER BY X3_ORDEM
```

Para confirmar o nome físico (sufixo) de uma tabela lógica:

```sql
-- Objetivo: descobrir o arquivo físico e path de uma tabela lógica
SELECT X2_CHAVE, X2_ARQUIVO, X2_NOME, X2_PATH, X2_MODO
FROM SX2010
WHERE X2_CHAVE = 'SE1'
  AND D_E_L_E_T_ = ' '
```
