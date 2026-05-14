# Exemplos de uso — advpl-specialist

Cada subpasta contém um cenário end-to-end com prompt exato, output esperado e explicação do que o plugin fez. Os exemplos são independentes — podem ser executados em qualquer ordem.

| # | Cenário | Comando principal |
|---|---------|-------------------|
| 01 | Gerar MVC completo para tabela customizada ZA1 | `/advpl-specialist:generate` |
| 02 | Migrar ADVPL procedural para TLPP com classes | `/advpl-specialist:migrate` |
| 03 | Diagnosticar erro de lock infinito em `RecLock` | `/advpl-specialist:diagnose` |
| 04 | Criar endpoint REST em TLPP com namespace | `/advpl-specialist:generate` |
| 05 | Revisar código focando em performance | `/advpl-specialist:review` |
| 06 | Gerar dicionário SX3 + SIX + SX1 para nova tabela | `/advpl-specialist:sxgen` |

## Como usar

1. Abra o Claude Code na raiz de um projeto Protheus (com arquivos `.prw` ou `.tlpp`)
2. Escolha o exemplo mais próximo do seu cenário
3. Copie o prompt exato do README do exemplo
4. Ajuste os parâmetros (nome da rotina, módulo, campos) conforme seu caso
5. Revise o plan mode antes de aprovar a geração/alteração

## Convenções

- Exemplos `01`, `04`, `06` começam do zero (apenas descrição de cenário)
- Exemplos `02`, `03`, `05` incluem arquivos `.prw` de apoio para servir de input
- Todos os prompts usam nomes de exemplo (ex: `ZA1`, `CadOrdemServico`) — substitua pelos seus

## Tem sugestão de novo exemplo?

Abra uma issue em https://github.com/thalysjuvenal/advpl-specialist/issues com o cenário e o prompt que você gostaria de ver documentado.
