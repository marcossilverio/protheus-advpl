# 03 — Diagnosticar erro de lock infinito em `RecLock`

## Contexto

Usuários relatam que a rotina `MATA410` (Pedido de Venda) está travando em produção. O log do AppServer mostra várias entradas:

```
USER THREAD ERROR: Record in use by another process (SC5, record 123456)
RecLock failed after 30 attempts
```

Você precisa entender:
1. Por que o lock está acontecendo
2. Se é competição legítima entre usuários ou bug de código
3. Qual a correção adequada

## Prompt exato

```
/advpl-specialist:diagnose

Estou vendo erros intermitentes de lock em producao na rotina MATA410.
Log do AppServer:

USER THREAD ERROR: Record in use by another process (SC5, record 123456)
RecLock failed after 30 attempts
at MATA410:FA410Grv (line 127)
at FATXA1:U_RotinaCustom (line 45)

Release: 12.1.2310
Ambiente: producao com 200 usuarios simultaneos
A rotina tem um ponto de entrada MT410GRV customizado que tambem faz gravacao.
```

## O que o plugin faz

1. **Classifica o erro** — usando a skill `advpl-debugging/common-errors.md`:
   - Categoria: concorrência / lock
   - Severidade: alta (impacta produção)
2. **Investiga causas prováveis:**
   - Dois `RecLock` simultâneos no mesmo registro (competição usuário × PE)
   - `MsUnlock` não chamado em branch de erro (lock vazado)
   - Transação longa segurando lock (`BEGIN TRANSACTION` sem commit rápido)
   - Índice ausente forçando lock de tabela em vez de linha
3. **Pergunta** para refinar diagnóstico:
   - O PE `MT410GRV` chama `RecLock` na SC5?
   - Há `BEGIN TRANSACTION` no PE ou só em MATA410?
   - O erro ocorre em horário específico (pico de uso)?
4. **Propõe correções prioritárias:**
   - Remover `RecLock` duplicado no PE se a rotina pai já está gravando
   - Substituir por `PutSx8Num` se for apenas geração de número
   - Adicionar `RECOVER` com `MsUnlock` em caso de erro
   - Reduzir escopo do `BEGIN TRANSACTION`

## Output esperado

Relatório estruturado com:

- **Root cause (mais provável):** descrição do problema com evidência do log
- **Root cause (alternativas):** 2-3 hipóteses secundárias a investigar
- **Correções sugeridas:** código antes/depois para cada hipótese
- **Próximos passos:** comandos `/review`, `/refactor` ou consultas a rodar para validar a hipótese

## Variações

- **Lock em batch:** se ocorre só em jobs noturnos, plugin foca em `BEGIN SEQUENCE` e isolamento
- **Lock em impressão:** pode ser `DbSkip` sem fechar tabela; plugin sugere `DbCloseArea`
- **Lock em integração REST:** provavelmente falta `RECOVER` em erro HTTP

## Próximos passos sugeridos

1. Rodar `/advpl-specialist:review MT410GRV.prw --focus best-practices` para auditar o PE
2. Rodar `/advpl-specialist:refactor MT410GRV.prw` se a correção envolver reestruturar transações
3. Consultar `/advpl-specialist:docs RecLock` para ver exemplos corretos na documentação
