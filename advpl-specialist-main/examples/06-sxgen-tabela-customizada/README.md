# 06 — Gerar dicionário SX3 + SIX + SX1 para tabela customizada

## Contexto

Você vai criar a tabela **ZB1 (Controle de Visitas Técnicas)** no módulo de manutenção. Precisa do script completo de dicionário para importar no cliente:

- **SX3** — estrutura dos campos (tipo, tamanho, validação, help)
- **SIX** — índices (chave única + consulta por cliente + por data)
- **SX1** — perguntas do sistema (data inicial, data final, cliente)
- **SX5** — tabela genérica de tipos de visita (preventiva, corretiva, instalação)

Tudo em linguagem natural, sem montar cada registro manualmente.

## Prompt exato

```
/advpl-specialist:sxgen

Gerar dicionario completo para a tabela customizada ZB1:

Campos (SX3):
- ZB1_FILIAL (2 chars, chave)
- ZB1_NUMVIS (6 chars, numero da visita, chave)
- ZB1_DTVIS (data, data da visita)
- ZB1_CLIENT (6 chars, cliente - pipe para SA1)
- ZB1_LOJA (2 chars, loja do cliente)
- ZB1_TIPO (1 char, tipo de visita - pipe para SX5 tabela ZB)
- ZB1_TECNIC (6 chars, tecnico responsavel)
- ZB1_DESCR (100 chars, descricao da ocorrencia)
- ZB1_STATUS (1 char, status: 1=Pendente, 2=Em andamento, 3=Concluida, 4=Cancelada)

Indices (SIX):
- Indice 1: ZB1_FILIAL + ZB1_NUMVIS (unico)
- Indice 2: ZB1_FILIAL + ZB1_CLIENT + ZB1_LOJA + ZB1_DTVIS (consulta por cliente)
- Indice 3: ZB1_FILIAL + ZB1_DTVIS (consulta por periodo)

Perguntas (SX1 - grupo ZBR001):
- mv_par01 = data inicial
- mv_par02 = data final
- mv_par03 = cliente (F3 SA1, opcional)

Tabela generica (SX5 - tabela ZB):
- 1 = Preventiva
- 2 = Corretiva
- 3 = Instalacao
- 4 = Garantia
```

## O que o plugin faz

1. **Valida os campos:**
   - Convenção de nome (prefixo `ZB1_`, tipo apropriado, tamanho condizente)
   - Campos chave marcados como `Obrigatorio = .T.`
   - Campos com `pipe` para outras tabelas geram validação `F3` automática
2. **Plan mode** — apresenta:
   - Nome do arquivo gerado (`dicZB1.prw` ou formato de import preferido)
   - Cada registro SX3 com `PutSx3()` + help via `HlpByReg()`
   - Cada índice SIX com `PutSix()`
   - Perguntas SX1 com `PutSx1()`
   - SX5 com `PutSx5()`
3. **Aprovação** → gera o arquivo único com todas as seções separadas por comentário de bloco

## Output esperado

Arquivo `dicZB1.prw` com estrutura:

```advpl
#Include "TOTVS.CH"

User Function DicZB1()
    // === SX3 - Estrutura de Campos ===
    U_AtuSX3()

    // === SIX - Indices ===
    U_AtuSIX()

    // === SX1 - Perguntas ===
    U_AtuSX1()

    // === SX5 - Tabela Generica ===
    U_AtuSX5()

    MsgInfo("Dicionario ZB1 atualizado")
Return Nil

Static Function U_AtuSX3()
    // PutSx3() para cada campo com todos os atributos
    // ...
Return Nil

// ... e assim por diante para SIX, SX1, SX5
```

## Variações

- `--format excel` — exporta CSV para importar via SXImport (mais seguro em produção)
- `--format apo` — gera .prw executável (formato antigo, ainda suportado)
- `--include sx7` — adiciona gatilhos (SX7) para consistência entre campos
- Sem especificar tudo no prompt: plugin pergunta campo a campo em modo interativo

## Próximos passos sugeridos

1. `/advpl-specialist:generate mvc CadVisitasTec` — gerar o CRUD TLPP para a nova tabela
2. `/advpl-specialist:document dicZB1.prw` — documentar o script de dicionário
3. Testar a importação em ambiente de desenvolvimento antes de subir para homologação
