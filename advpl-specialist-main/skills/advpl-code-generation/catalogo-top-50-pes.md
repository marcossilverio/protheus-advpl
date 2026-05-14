# Catálogo Top 50 Pontos de Entrada

Índice rápido dos pontos de entrada (PE) mais usados em customizações Protheus. Este arquivo funciona como **Tier 1 (cache local)** da estratégia de lookup documentada em [`skills/tdn-lookup/reference.md`](../tdn-lookup/reference.md).

**Cobertura atual:** 20 PEs (COM, FAT, EST, FIN — 5 cada).
**Meta:** 50 PEs. A expansão é incremental — contribua via PR adicionando PEs novos mantendo o formato abaixo.

## Como usar

1. `/advpl-specialist:generate ponto-entrada NOME` primeiro procura aqui
2. Se o PE estiver listado: extrai PARAMIXB, momento, retorno e rotina chamadora direto deste arquivo (sem TDN)
3. Se não estiver: cai para `skills/tdn-lookup/reference.md` (Tier 2 em diante)

## Formato de cada entrada

```
### NOME_PE
- **Rotina:** ROTINA_PADRAO - descrição curta
- **Módulo:** COM | FAT | EST | FIN | CTB | FIS | MNT | PCP
- **Momento:** Pré-validação | Pós-validação | Pré-gravação | Pós-gravação | Cancelamento
- **PARAMIXB:** descrição das posições ou "nenhum"
- **Retorno:** tipo e significado
- **TDN:** URL oficial
```

---

## COM — Compras

### MT100TOK
- **Rotina:** MATA100 — Pedido de Compras
- **Módulo:** COM
- **Momento:** Pré-gravação (validação do TudoOk antes de persistir)
- **PARAMIXB:** nenhum (usa variáveis públicas `aCols`, `aHeader`)
- **Retorno:** `.T.` continua gravação, `.F.` aborta com mensagem
- **TDN:** https://tdn.totvs.com/display/public/PROT/MT100TOK

### MT100GRV
- **Rotina:** MATA100 — Pedido de Compras
- **Módulo:** COM
- **Momento:** Após gravação do cabeçalho, antes dos itens
- **PARAMIXB:** `[1]=cFilOri (caractere), [2]=nOpcAuto (numérico)`
- **Retorno:** `.T.` continua, `.F.` aborta gravação dos itens
- **TDN:** https://tdn.totvs.com/display/public/PROT/MT100GRV

### MT103FIM
- **Rotina:** MATA103 — Documento de Entrada
- **Módulo:** COM
- **Momento:** Após gravação completa (cabeçalho + itens + impostos)
- **PARAMIXB:** nenhum (usa `aCols`, `aHeader`, variáveis públicas)
- **Retorno:** ignorado
- **TDN:** https://tdn.totvs.com/display/public/PROT/MT103FIM

### MA103OK
- **Rotina:** MATA103 — Documento de Entrada
- **Módulo:** COM
- **Momento:** Pré-validação do TudoOk (antes de abrir transação)
- **PARAMIXB:** nenhum
- **Retorno:** `.T.` libera gravação, `.F.` bloqueia
- **TDN:** https://tdn.totvs.com/display/public/PROT/MA103OK

### MT097APR
- **Rotina:** MATA097 — Liberação de Documentos
- **Módulo:** COM
- **Momento:** Durante aprovação de documento (antes de liberar)
- **PARAMIXB:** `[1]=cAlias (caractere: SC7, SCR, etc.), [2]=nRecno (numérico)`
- **Retorno:** `.T.` aprova, `.F.` rejeita aprovação
- **TDN:** https://tdn.totvs.com/display/public/PROT/MT097APR

---

## FAT — Faturamento

### M410CMPL
- **Rotina:** MATA410 — Pedido de Venda
- **Módulo:** FAT
- **Momento:** Complemento da tela antes de ser exibida (customização visual)
- **PARAMIXB:** nenhum
- **Retorno:** array adicional para compor enchoice (pode ser `{}`)
- **TDN:** https://tdn.totvs.com/display/public/PROT/M410CMPL

### M410STTS
- **Rotina:** MATA410 — Pedido de Venda
- **Módulo:** FAT
- **Momento:** Após alteração de status do pedido (bloqueio, liberação, etc.)
- **PARAMIXB:** `[1]=cNumPed (caractere), [2]=cStatus (caractere 1)`
- **Retorno:** ignorado
- **TDN:** https://tdn.totvs.com/display/public/PROT/M410STTS

### MA440GRV
- **Rotina:** MATA440 — Documento de Saída (Nota Fiscal)
- **Módulo:** FAT
- **Momento:** Após gravação da NF (antes da impressão)
- **PARAMIXB:** `[1]=cFilOri, [2]=nOpcAuto, [3]=cDocNF (número da NF)`
- **Retorno:** `.T.` continua, `.F.` estorna gravação
- **TDN:** https://tdn.totvs.com/display/public/PROT/MA440GRV

### M460FIM
- **Rotina:** MATA460 — Preparação de Documentos de Saída
- **Módulo:** FAT
- **Momento:** Ao final da preparação de cada NF
- **PARAMIXB:** `[1]=cNFSaida (caractere), [2]=cSerieNF (caractere)`
- **Retorno:** ignorado
- **TDN:** https://tdn.totvs.com/display/public/PROT/M460FIM

### MT460A
- **Rotina:** MATA460A — Preparação de Documento de Saída (tela)
- **Módulo:** FAT
- **Momento:** Antes de exibir a tela de preparação (filtro de pedidos)
- **PARAMIXB:** nenhum
- **Retorno:** filtro adicional para query de pedidos (caractere com cláusula SQL)
- **TDN:** https://tdn.totvs.com/display/public/PROT/MT460A

---

## EST — Estoque

### MA030TOK
- **Rotina:** MATA030 — Cadastro de Clientes
- **Módulo:** EST (compartilhado com FAT)
- **Momento:** Pré-gravação (validação do TudoOk)
- **PARAMIXB:** nenhum
- **Retorno:** `.T.` grava, `.F.` aborta
- **TDN:** https://tdn.totvs.com/display/public/PROT/MA030TOK

### MT240PRO
- **Rotina:** MATA240 — Movimentos Internos
- **Módulo:** EST
- **Momento:** Processamento do movimento (antes de atualizar SB2)
- **PARAMIXB:** `[1]=cProduto, [2]=cLocal, [3]=nQuant, [4]=cTM (tipo de movimento)`
- **Retorno:** `.T.` processa, `.F.` aborta movimento
- **TDN:** https://tdn.totvs.com/display/public/PROT/MT240PRO

### MT116NT
- **Rotina:** MATA116 — Inventário
- **Módulo:** EST
- **Momento:** Ao confirmar contagem de inventário
- **PARAMIXB:** `[1]=cProduto, [2]=cLocal, [3]=nQtdContada`
- **Retorno:** `.T.` confirma contagem, `.F.` exige recontagem
- **TDN:** https://tdn.totvs.com/display/public/PROT/MT116NT

### MT250GRV
- **Rotina:** MATA250 — Produção
- **Módulo:** EST (compartilhado com PCP)
- **Momento:** Após gravação de apontamento de produção
- **PARAMIXB:** `[1]=cOPN (ordem de produção), [2]=nQuant`
- **Retorno:** ignorado
- **TDN:** https://tdn.totvs.com/display/public/PROT/MT250GRV

### MA030GRV
- **Rotina:** MATA030 — Cadastro de Clientes
- **Módulo:** EST (compartilhado com FAT)
- **Momento:** Após gravação do registro (inclusão ou alteração)
- **PARAMIXB:** `[1]=cFilOri, [2]=nOpcAuto`
- **Retorno:** ignorado
- **TDN:** https://tdn.totvs.com/display/public/PROT/MA030GRV

---

## FIN — Financeiro

### F050TIT
- **Rotina:** FINA050 — Contas a Pagar
- **Módulo:** FIN
- **Momento:** Gravação de título a pagar (inclusão)
- **PARAMIXB:** `[1]=cAlias (SE2), [2]=nRecno, [3]=nOpcAuto`
- **Retorno:** `.T.` grava, `.F.` aborta
- **TDN:** https://tdn.totvs.com/display/public/PROT/F050TIT

### F080FIL
- **Rotina:** FINA080 — Contas a Receber
- **Módulo:** FIN
- **Momento:** Filtro da consulta de títulos a receber
- **PARAMIXB:** nenhum
- **Retorno:** filtro adicional (caractere SQL)
- **TDN:** https://tdn.totvs.com/display/public/PROT/F080FIL

### M460MVF
- **Rotina:** MATA460 — Preparação + Movimentação Financeira
- **Módulo:** FIN (chamado pela FAT)
- **Momento:** Geração dos títulos a receber durante faturamento
- **PARAMIXB:** `[1]=cFilOri, [2]=cNumNota, [3]=cSerie, [4]=cCliente`
- **Retorno:** `.T.` gera título, `.F.` pula geração
- **TDN:** https://tdn.totvs.com/display/public/PROT/M460MVF

### MF370FIL
- **Rotina:** FINA370 — Baixa a Receber
- **Módulo:** FIN
- **Momento:** Filtro dos títulos exibidos na tela de baixa
- **PARAMIXB:** nenhum
- **Retorno:** filtro adicional (caractere SQL)
- **TDN:** https://tdn.totvs.com/display/public/PROT/MF370FIL

### F240FIL
- **Rotina:** FINA240 — Conciliação Bancária
- **Módulo:** FIN
- **Momento:** Filtro de movimentos bancários na tela de conciliação
- **PARAMIXB:** nenhum
- **Retorno:** filtro adicional (caractere SQL)
- **TDN:** https://tdn.totvs.com/display/public/PROT/F240FIL

---

## Próximas adições sugeridas (roadmap para chegar a 50)

- **COM:** MT110FIL, MT120VLD, M100INC, MT103IF, MT097GRV
- **FAT:** M410VLD, MA440CAN, M460CAN, M460MVR, MT450GRV
- **EST:** MA010GRV, MT161GRV, MA030CPL, MT240GRV, MA010TOK
- **FIN:** F090GRV, F040TOK, MF320BX, F190GRV, F550GRV
- **CTB:** CTBA102I, CTBA100F, CT100TOK, CT040TOK
- **FIS:** NFEClassFis, LIVR1000, MT100GRD

Cada PE novo deve incluir PARAMIXB real validado contra o TDN (não inventado).
