# Rotinas, erros por camada e performance

> **Como usar este arquivo.** Reúne (1) rotinas/fontes por módulo e suas
> ExecAuto, (2) roteiro de diagnóstico de erros por camada e (3) roteiro de
> análise de performance/bloqueio em banco. Nomes de rotina (MATAxxx, FINAxxx,
> CTBAxxx) são estáveis no núcleo, mas funções automáticas e parâmetros de
> ExecAuto **variam por release** — confirme a assinatura no TDN antes de gerar
> código de ExecAuto definitivo. Mensagens e códigos de erro (HELPCODE) também
> evoluem; trate os exemplos abaixo como padrões de causa, não como texto literal
> garantido.

## Índice
- [Rotinas por módulo](#rotinas-por-módulo)
- [ExecAuto (MSExecAuto)](#execauto-msexecauto)
- [Diagnóstico de erros por camada](#diagnóstico-de-erros-por-camada)
- [Performance e bloqueios em banco](#performance-e-bloqueios-em-banco)

---

## Rotinas por módulo

Confirme o nome exato e o módulo no ambiente; abaixo o núcleo estável.

Faturamento / Estoque (SIGAFAT / SIGAEST):
| Rotina | Descrição |
|--------|-----------|
| MATA410 | Pedido de venda |
| MATA460 / MATA461 | Preparação e geração do documento de saída (faturamento) |
| MATA103 | Documento de entrada (NF de entrada) |
| MATA240 | Movimentações internas de estoque |
| MATA242 | Transferências entre armazéns |

Compras (SIGACOM):
| Rotina | Descrição |
|--------|-----------|
| MATA110 | Solicitação de compras |
| MATA120 | Pedido de compra |
| MATA121 | Atualização/autorização de pedido de compra (confirmar na release) |

Financeiro (SIGAFIN):
| Rotina | Descrição |
|--------|-----------|
| FINA040 | Contas a receber (inclusão/manutenção de títulos) |
| FINA050 | Contas a pagar (inclusão/manutenção de títulos) |
| FINA070 | Baixa de contas a receber |
| FINA080 | Baixa de contas a pagar |
| FINA100 | Movimentações bancárias (confirmar na release) |

Contábil (SIGACTB):
| Rotina | Descrição |
|--------|-----------|
| CTBA102 | Lançamento contábil manual (confirmar nome/número na release) |

> Para rotinas que você não tem certeza do número, diga isso e confirme no TDN.
> Citar "MATAxxx" errado faz o analista abrir a tela errada.

---

## ExecAuto (MSExecAuto)

A automação de processos via `MSExecAuto` reaproveita a regra de negócio da
rotina padrão — preferível a UPDATE direto em banco. Princípios:

- Monte o array de campos conforme o layout esperado pela rotina (o conteúdo do
  array varia por release — confirme no TDN ou no fonte da rotina).
- Defina o tipo de operação (inclusão/alteração/exclusão) conforme a rotina.
- Trate `lMsErroAuto` e capture o log de erro (`GetAutoGRLog()` ou equivalente).
- Controle transação com `Begin/EndTransaction` quando o processo exigir
  atomicidade.

Esqueleto (objetivo: incluir título a pagar via ExecAuto, com guarda de área e
tratamento de erro — confirme os campos do aCabec/aItens no TDN da sua release):

```advpl
#Include "Protheus.ch"

User Function IncTitPag()
    Local aArea     := GetArea()
    Local aTitulo   := {}
    Local lOk       := .T.

    Private lMsErroAuto := .F.   // exigido pelo MSExecAuto

    // Campos do título — CONFIRMAR layout no TDN para a release alvo
    aAdd( aTitulo, { "E2_PREFIXO", "PAG",        Nil } )
    aAdd( aTitulo, { "E2_NUM",     "000000123",  Nil } )
    aAdd( aTitulo, { "E2_PARCELA", " ",          Nil } )
    aAdd( aTitulo, { "E2_TIPO",    "NF",         Nil } )
    aAdd( aTitulo, { "E2_FORNECE", "000001",     Nil } )
    aAdd( aTitulo, { "E2_LOJA",    "01",         Nil } )
    aAdd( aTitulo, { "E2_VALOR",   1000,         Nil } )
    aAdd( aTitulo, { "E2_VENCTO",  dDataBase,    Nil } )
    aAdd( aTitulo, { "E2_NATUREZ", "100001",     Nil } )

    Begin Transaction
        MSExecAuto( {|x,y| FINA050(x,y)}, aTitulo, 3 )  // 3 = inclusão

        If lMsErroAuto
            lOk := .F.
            MostraErro()        // em rotina interativa; em batch use GetAutoGRLog()
            DisarmTransaction()
        EndIf
    End Transaction

    RestArea(aArea)
Return lOk
```

> Impacto: ExecAuto executa a regra de negócio completa (gatilhos, validações,
> integrações). É seguro do ponto de vista de consistência, mas valide em
> ambiente de homologação antes de rodar em lote — um array mal montado pode
> gerar registros inconsistentes em escala.

---

## Diagnóstico de erros por camada

Roteiro: (1) leia a mensagem literal, (2) classifique a camada, (3) liste causas
da mais provável à menos, (4) valide, (5) corrija.

### ADVPL / Framework (HELPCODE, erros de execução)
Sintomas: tela de erro com pilha de chamada (stack), nome de função/fonte e
linha. Causas comuns: variável não inicializada/inexistente, índice de array
fora do limite, tipo incompatível, função não encontrada (RPO desatualizado),
área de trabalho não posicionada.
Validar: o fonte/RPO está atualizado? O Ponto de Entrada customizado quebra o
fluxo? Há `GetArea/RestArea` faltando? Reproduzir com log de console
(`conout`/`MsgRun`) ajuda a isolar a linha.

### Banco / DBAccess (TopConnect/DBAccess)
Sintomas: erro de conexão com o DBAccess, "tabela/coluna não encontrada",
deadlock, timeout. Causas comuns: DBAccess fora do ar ou versão incompatível com
o AppServer; tabela física com sufixo diferente do esperado; campo no dicionário
(SX3) mas não no banco (faltou atualizar a estrutura — `UPDDISTR`/compatibilizador);
bloqueio/lock de longa duração.
Validar: serviço do DBAccess ativo; versão DBAccess x AppServer compatível;
estrutura física = dicionário (rodar compatibilizador de base); checar locks
(ver seção de performance).

### AppServer
Sintomas: "Source not found"/"Could not find function", serviço não sobe,
threads travadas, consumo anômalo de memória/CPU. Causas comuns: RPO
desatualizado ou incompatível com o binário; `appserver.ini` mal configurado
(porta, ambiente, conexão DBAccess); build do AppServer incompatível com o RPO.
Validar: recompilar/atualizar RPO; conferir build do AppServer x release do RPO;
revisar `appserver.ini`; checar logs do console do AppServer.

### SmartClient
Sintomas: não conecta, versão incompatível, tela em branco/erro de renderização.
Causas comuns: versão do SmartClient diferente da do AppServer; `.ini` apontando
para servidor/porta errados; bloqueio de rede/firewall.
Validar: alinhar versão SmartClient ↔ AppServer; conferir conexão no `.ini`;
testar conectividade de rede até a porta do AppServer.

### TSS (integração fiscal eletrônica)
Sintomas: falha ao transmitir NF-e/NFC-e/CT-e, erro de schema XML, certificado,
ou comunicação com a SEFAZ. Causas comuns: certificado digital vencido/inválido;
schema/versão de layout desatualizada; indisponibilidade da SEFAZ; configuração
do TSS x Protheus divergente; build do TSS desatualizado.
Validar: **pesquisar no TDN/SEFAZ** a nota técnica/layout vigente (regra de
pesquisa externa); validar certificado e ambiente (produção/homologação); checar
status do webservice da SEFAZ; conferir versão do TSS.

> Em integração fiscal, **não responda de memória**: layouts e regras mudam com
> frequência. Pesquise e cite a fonte.

---

## Performance e bloqueios em banco

Quando o chamado for lentidão/travamento:

1. Identifique a rotina e o momento (importação, fechamento, relatório, gravação).
2. Peça o plano de execução da query crítica.
3. Verifique índices: a chave de busca da rotina tem índice (SIX) que a atenda?
   Índice ausente/seletividade ruim é a causa nº 1 de full scan.
4. Verifique bloqueios/locks: transação longa segurando registro trava as demais.

Confirmar índices de uma tabela pelo dicionário (objetivo: ver as chaves de
índice cadastradas para a tabela):

```sql
-- Objetivo: listar índices (ordens) cadastrados no dicionário para a SE1
SELECT INDICE, ORDEM, CHAVE, DESCRICAO, NICKNAME
FROM SIX010
WHERE INDICE = 'SE1'
  AND D_E_L_E_T_ = ' '
ORDER BY ORDEM
```

Investigar bloqueios — SQL Server (objetivo: ver sessões bloqueadas e o
bloqueador):

```sql
-- Objetivo (SQL Server): identificar quem está bloqueando quem
SELECT
    r.session_id        AS sessao_bloqueada,
    r.blocking_session_id AS sessao_bloqueadora,
    r.wait_type,
    r.wait_time         AS espera_ms,
    t.text              AS sql_em_execucao
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.blocking_session_id <> 0
```

> Riscos: não mate sessões (`KILL`) sem confirmar o impacto — pode deixar
> transação parcial. Prefira identificar a causa (índice/transação longa) e
> tratar a origem. Criação de índice em produção é alteração de estrutura:
> avalie janela de manutenção e impacto de escrita.

> **Antes de qualquer UPDATE/DELETE direto**: backup, validação do filtro em um
> `SELECT` equivalente, e preferência por correção via rotina/ExecAuto. Manipular
> SE1/SE2/SB2/SD2 na mão sem entender os gatilhos gera inconsistência fiscal,
> contábil e de saldo difícil de reverter.
