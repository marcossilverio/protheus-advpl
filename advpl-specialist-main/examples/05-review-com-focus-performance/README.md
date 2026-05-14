# 05 — Revisar código focando em performance

## Contexto

Uma rotina batch de reprocessamento está levando 45 minutos para rodar com 10k registros. O desenvolvedor original saiu da empresa. Você precisa identificar gargalos sem reescrever tudo — prioridade é achar os 2-3 pontos mais caros.

O arquivo [`exemplo-lento.prw`](exemplo-lento.prw) simula problemas típicos: queries em loop, `DbSeek` sem índice, processamento sem `BeginSQL`.

## Prompt exato

```
/advpl-specialist:review examples/05-review-com-focus-performance/exemplo-lento.prw --focus performance
```

## O que o plugin faz

1. **Lê o arquivo** e aplica as 6 regras da skill `advpl-code-review/rules-performance`:
   - `RP-001` — N+1 queries (SELECT dentro de loop)
   - `RP-002` — `DbSeek` sem índice dedicado
   - `RP-003` — Concatenação de string em loop (`cTexto += ...`)
   - `RP-004` — `MsExecAuto` em batch (usar `FWMVCRotAuto`)
   - `RP-005` — Falta de `BeginSQL` em consultas parametrizáveis
   - `RP-006` — `GetArea/RestArea` sem `DbSelectArea` específico em hot paths
2. **Classifica cada finding** por severidade (crítica, alta, média) e custo estimado de correção
3. **Apresenta relatório** com:
   - Top 3 findings por impacto (geralmente `RP-001` + `RP-002` dominam)
   - Código antes/depois para cada finding
   - Estimativa de ganho (% ou ordem de grandeza)
4. **Sugere ordem de correção:** atacar primeiro o que dá mais ganho por menos esforço

## Output esperado

Relatório estruturado tipo:

```
=== Review performance: exemplo-lento.prw ===

[CRITICAL] RP-001 N+1 queries - linha 28
  Loop com TcQuery dentro de While; 10k iteracoes = 10k queries.
  Ganho estimado: 100x (reduzir para 1 query com JOIN + INDEX).
  Fix sugerido: reescrever com BeginSQL e processar com DbUseArea("TMP").

[HIGH] RP-002 DbSeek sem indice - linha 45
  DbSetOrder(2) em SB1 por B1_DESC nao tem indice customizado.
  Ganho estimado: 10x em producao (usa TableScan hoje).
  Fix sugerido: criar indice SB1 com chave B1_DESC ou usar DbSetOrder(1) + filtro.

[MEDIUM] RP-003 Concatenacao de string em loop - linha 62
  cLog := cLog + cLinha repete alocacao a cada iteracao.
  Ganho estimado: 2x no loop de log (baixo ganho absoluto).
  Fix sugerido: usar array e fazer FWArrayToString() no final.

Ordem sugerida: 1 (RP-001) -> 2 (RP-002) -> ignorar RP-003 por enquanto.
```

## Arquivo de apoio

- [`exemplo-lento.prw`](exemplo-lento.prw) — rotina batch com os 3 problemas principais

## Variações

- `--focus security` — troca regras de performance por regras de segurança (SQL injection, macro injection)
- `--focus best-practices` — regras gerais (naming, error handling, documentação)
- `--focus modernization` — sugestões de refatoração para TLPP

## Próximos passos sugeridos

1. `/advpl-specialist:refactor exemplo-lento.prw` — aplicar as correções sugeridas automaticamente
2. Após correção, rodar `/advpl-specialist:test exemplo-lento.prw` para garantir que o comportamento não mudou
