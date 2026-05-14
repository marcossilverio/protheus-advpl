# 02 — Migrar ADVPL procedural (FATA001) para TLPP com classes

## Contexto

Você tem uma rotina legada `FATA001.prw` escrita em ADVPL procedural: variáveis `Private`, sem tratamento de erro, queries montadas em `cQuery` com concatenação. Quer modernizar para TLPP orientado a objetos com classe, namespace e `BEGIN SEQUENCE`.

O arquivo [`FATA001-antes.prw`](FATA001-antes.prw) deste exemplo serve de input.

## Prompt exato

```
/advpl-specialist:migrate examples/02-migrar-fata001/FATA001-antes.prw

Migre para TLPP com:
- Namespace: custom.fat.pedidovenda
- Classe principal: PedidoVendaService
- Usar BeginSQL/EndSQL no lugar de cQuery concatenado
- BEGIN SEQUENCE em todas as operacoes de banco
- Manter a funcao User Function FATA001 como entry point chamando a classe
```

## O que o plugin faz

1. **Lê o arquivo de origem** e analisa:
   - Variáveis `Private` — candidatas a atributos ou parâmetros
   - Queries em `cQuery` — candidatas a `BeginSQL/EndSQL` com macros (`%table%`, `%notDel%`, `%xfilial%`)
   - Chamadas a `RecLock`/`MsUnLock` — candidatas a `BEGIN SEQUENCE ... RECOVER ... END SEQUENCE`
   - Lógica de negócio — candidata a método público da classe
2. **Plan mode** — apresenta:
   - Nova estrutura de arquivos (uma classe por arquivo)
   - Mapeamento `funcao_antiga → metodo_novo`
   - Riscos (quebra de compatibilidade com chamadores externos, se houver)
3. **Aprovação** → gera os arquivos novos **sem apagar o original** (você decide depois)

## Output esperado

Dois arquivos:

- `PedidoVendaService.tlpp` — classe com métodos `Gravar()`, `Cancelar()`, `Consultar()`
- `FATA001.prw` (novo, substituindo o antigo) — `User Function FATA001()` que instancia e delega para a classe

## Arquivo de apoio

- [`FATA001-antes.prw`](FATA001-antes.prw) — código procedural típico (~60 linhas) usado como input

## Variações

- **Migração parcial:** peça para migrar apenas a parte de gravação, mantendo consulta em ADVPL
- **Cobertura de testes:** após migração, rode `/advpl-specialist:test PedidoVendaService.tlpp`
- **Revisão antes de commitar:** rode `/advpl-specialist:review PedidoVendaService.tlpp --focus best-practices`

## Cuidados

- Se a rotina original é chamada por outros PRW do projeto, o plugin destaca os pontos de integração e sugere manter a `User Function FATA001()` como fachada
- Macros (`&cMacro`) na rotina original exigem análise manual — o plugin sinaliza, não migra automaticamente
