# 01 — Gerar MVC completo para tabela ZA1

## Contexto

Você precisa criar o CRUD completo (MenuDef, ModelDef, ViewDef) para a tabela customizada **ZA1 (Ordens de Serviço)** no módulo de manutenção. O projeto está em release `12.1.2410+`, então você quer gerar em **TLPP** (não ADVPL procedural).

## Prompt exato

```
/advpl-specialist:generate

Preciso de um MVC completo para a tabela ZA1 (Ordens de Servico).
- Modulo: MNT (manutencao)
- Nome da rotina: CadOrdemServico
- Namespace: custom.mnt.cadordemservico
- Campos: ZA1_FILIAL, ZA1_NUMOS, ZA1_DTEMIS, ZA1_STATUS, ZA1_DESCR
- Gerar em TLPP (release 12.1.2410)
```

## O que o plugin faz

1. **Plan mode** — apresenta:
   - Tipo inferido: `mvc`
   - Linguagem: TLPP (por causa do release informado ≥ 12.1.2410)
   - Estrutura proposta: `MenuDef()`, `ModelDef()`, `ViewDef()` + `FWMVCRotAuto()`
   - Includes: `tlpp-core.th`
   - Validações a aplicar nos campos obrigatórios
2. **Pergunta** se você quer:
   - Adicionar mais campos
   - Incluir validações customizadas (campo único, range de datas, etc.)
   - Gerar também a entrada de menu (SX2/SXB)
3. **Aprovação** → gera o arquivo `CadOrdemServico.tlpp`

## Output esperado

Arquivo `CadOrdemServico.tlpp` contendo:

```tlpp
#include "tlpp-core.th"

namespace custom.mnt.cadordemservico

static function MenuDef()
    // Rotinas 1 a 5 padrao
end function

static function ModelDef()
    // Modelo com campos obrigatorios e validacoes
end function

static function ViewDef()
    // View com folder padrao
end function

user function CadOrdemServico()
    // Entry point com FWMVCRotAuto()
return
```

## Variações

- **Sem release configurado:** o plugin pergunta qual linguagem você prefere (ADVPL ou TLPP)
- **Release < 12.1.2410:** plugin força ADVPL e avisa o motivo
- **Gerar também o dicionário:** rode depois `/advpl-specialist:sxgen` para criar os SX3/SIX
- **Campos customizados com `X_*`:** plugin valida se a convenção (`X_` como primeira letra após o prefixo da tabela) está sendo respeitada

## Próximos passos sugeridos

1. Rodar `/advpl-specialist:review CadOrdemServico.tlpp` para validação de best practices
2. Rodar `/advpl-specialist:test CadOrdemServico.tlpp` para gerar testes ProBat
3. Rodar `/advpl-specialist:sxgen ZA1` para gerar o dicionário da tabela
