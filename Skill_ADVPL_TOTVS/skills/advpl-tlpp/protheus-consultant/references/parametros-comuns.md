# Parâmetros (MV_*) comuns do Protheus

> **Como usar este arquivo — leia antes de citar qualquer parâmetro.**
> Parâmetros são o ponto de maior risco de alucinação: nome, tipo, conteúdo
> padrão e até a *existência* de um MV_* variam por release, por módulo
> habilitado e por customização do cliente. Este arquivo lista um núcleo de
> parâmetros amplamente usados e estáveis. **A fonte da verdade é o SX6 do
> ambiente** — o conteúdo real do cliente pode divergir do padrão. Sempre que
> houver dúvida sobre nome ou comportamento, confirme via consulta ao SX6
> (query ao final deste arquivo) ou no TDN, em vez de afirmar de memória.
>
> Regra prática: ao citar um parâmetro num diagnóstico, diga "confirme o
> conteúdo atual em Configurador → Parâmetros (SX6)" antes de instruir alteração.

## Índice
- [Estoque / Custos](#estoque--custos)
- [Faturamento / Vendas](#faturamento--vendas)
- [Financeiro](#financeiro)
- [Fiscal](#fiscal)
- [Ambiente / sistema](#ambiente--sistema)
- [Consultando o SX6 no ambiente](#consultando-o-sx6-no-ambiente)

---

## Estoque / Custos

| Parâmetro | Função | Impacto |
|-----------|--------|---------|
| MV_ESTNEG | Permite (ou não) saldo de estoque negativo | `.T.` permite faturar/movimentar abaixo do saldo; `.F.` bloqueia. Causa frequente de chamado "não consigo faturar / saldo insuficiente". |
| MV_RASTRO | Controle de rastreabilidade por lote/sublote | Define se o sistema exige lote nas movimentações. Afeta SB8 e telas de movimentação. |
| MV_LOCALIZ | Controla uso de endereçamento físico (WMS simples) | `S` exige endereço (SB8/SBE) nas movimentações. |
| MV_ATUSB2 | Atualização do saldo em estoque (SB2) online x posterior | Confirme o comportamento da sua release no SX6 antes de alterar — impacta consistência de saldo. |

---

## Faturamento / Vendas

| Parâmetro | Função | Impacto |
|-----------|--------|---------|
| MV_TPNRNFS | Tipo de numeração da NF de saída | Controla origem do número do documento de saída. Confirme conteúdo no ambiente. |
| MV_2DUPREF | Regra de prefixo/numeração de duplicata gerada no faturamento | Afeta o financeiro gerado pela NF. Validar no SX6 — varia por release. |

> Vários parâmetros de faturamento controlam numeração, bloqueio de crédito e
> liberação. Por variarem bastante, **não os cite de memória**: confirme no SX6
> do cliente e/ou no TDN qual parâmetro rege o comportamento específico.

---

## Financeiro

| Parâmetro | Função | Impacto |
|-----------|--------|---------|
| MV_JUROS | Percentual de juros padrão | Usado em cálculos de juros de títulos quando não há taxa específica. |
| MV_MULTA | Percentual de multa padrão | Aplicado em atraso conforme regra da rotina. |
| MV_1DUP | Prefixo/série padrão de títulos a receber gerados | Confirme conteúdo e uso na sua release antes de alterar. |

> Parâmetros de baixa, abatimento, moeda e portador são numerosos e variam por
> release. Para um diagnóstico de baixa/saldo, identifique o parâmetro pelo SX6
> do ambiente em vez de assumir o nome.

---

## Fiscal

| Parâmetro | Função | Impacto |
|-----------|--------|---------|
| MV_ESTADO | UF da empresa/filial | Base para cálculo de ICMS interestadual e validações fiscais. |
| MV_PAISLOC | Localização do país (ex.: `BRA`) | Define o pacote de localização fiscal aplicado. |

> **Tudo que toca NF-e/NFC-e/CT-e/MDF-e, TSS, SPED/EFD e Reforma Tributária
> muda rápido.** Não cite parâmetros fiscais recentes de memória — pesquise no
> TDN/SEFAZ e confirme no SX6 (regra de pesquisa externa do SKILL.md).

---

## Ambiente / sistema

| Parâmetro | Função | Impacto |
|-----------|--------|---------|
| MV_DISPREL | Diretório/controle de relatórios | Operacional, ligado à geração de relatórios. |
| MV_MULMOED / multimoeda | Habilita controle multimoeda | Quando ativo, várias rotinas passam a tratar moeda. Confirme o nome exato no SX6. |

---

## Consultando o SX6 no ambiente

Sempre prefira confirmar o conteúdo real a assumir o padrão. Exemplo (objetivo:
ver o conteúdo atual e a descrição de um parâmetro específico):

```sql
-- Objetivo: conferir conteúdo, tipo e descrição de um parâmetro no ambiente
SELECT X6_VAR, X6_TIPO, X6_CONTEUD, X6_DESCRIC
FROM SX6010
WHERE X6_VAR = 'MV_ESTNEG'
  AND D_E_L_E_T_ = ' '
```

Para localizar parâmetros por palavra na descrição (objetivo: achar o parâmetro
certo quando não se sabe o nome):

```sql
-- Objetivo: localizar parâmetros relacionados a um tema pela descrição
SELECT X6_VAR, X6_CONTEUD, X6_DESCRIC
FROM SX6010
WHERE X6_DESCRIC LIKE '%estoque negativo%'
  AND D_E_L_E_T_ = ' '
```

> Alteração de parâmetro tem efeito sistêmico. Antes de orientar mudança:
> registre o valor anterior, confirme o impacto nas rotinas afetadas e prefira
> alterar pelo Configurador (não por UPDATE direto na SX6).
