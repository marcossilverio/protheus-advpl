# 04 — Criar endpoint REST em TLPP com namespace

## Contexto

Você precisa expor uma consulta de saldo de produtos via REST para um frontend Angular/PO UI. Quer usar TLPP moderno com:

- Annotation `@Get` (não `WsRestFul` legado)
- Namespace organizado
- Resposta paginada no padrão PO UI (`{ items: [], hasNext: boolean }`)
- Validação de parâmetros e tratamento de erro HTTP

## Prompt exato

```
/advpl-specialist:generate

Criar endpoint REST em TLPP:
- Nome: SaldoProdutoAPI
- Rota: /api/v1/saldo/produtos
- Namespace: custom.est.api.saldo
- Metodo: GET
- Parametros query: pagina (int, default 1), tamanho (int, default 20), filial (string, obrigatorio)
- Retorno: array de { codigo, descricao, saldoAtual, saldoDisponivel } paginado padrao PO UI
- Consulta na SB2 (saldo atual por produto e filial)
- Release: 12.1.2410
```

## O que o plugin faz

1. **Plan mode** — apresenta:
   - Estrutura: `class SaldoProdutoAPI` com método anotado `@Get`
   - Includes: `tlpp-core.th`, `tlpp-rest.th`
   - Validação de parâmetros via `oRequest:getQueryParam()`
   - `BEGIN SEQUENCE` para proteger a leitura da SB2
   - Response com `oResponse:setBody(FWJsonSerialize(aRet))`
2. **Pergunta** sobre:
   - Autenticação (OAuth2 padrão TOTVS vs. token custom)
   - Limite de paginação máximo (evitar DOS)
   - Campos adicionais na resposta (B1_DESC, B1_TIPO, etc.)
3. **Aprovação** → gera `SaldoProdutoAPI.tlpp`

## Output esperado

```tlpp
#include "tlpp-core.th"
#include "tlpp-rest.th"

namespace custom.est.api.saldo

class SaldoProdutoAPI

    public method listarSaldos() as json
endclass

@Get("/api/v1/saldo/produtos")
method listarSaldos() as json class SaldoProdutoAPI
    local aRet     := {}
    local oResp    := JsonObject():new()
    local nPagina  := val(oRequest:getQueryParam("pagina"))
    local nTamanho := val(oRequest:getQueryParam("tamanho"))
    local cFilial  := oRequest:getQueryParam("filial")

    begin sequence
        // Validacao de parametros obrigatorios
        if empty(cFilial)
            oResponse:setStatusCode(400)
            oResp["error"] := "Parametro 'filial' e obrigatorio"
            return oResp
        endif

        // Consulta paginada na SB2
        aRet := ::consultarSB2(cFilial, nPagina, nTamanho)

        oResp["items"]   := aRet
        oResp["hasNext"] := len(aRet) == nTamanho
    recover
        oResponse:setStatusCode(500)
        oResp["error"] := "Erro interno ao consultar saldo"
    end sequence

return oResp
```

## Variações

- **Paginação cursor-based:** se a tabela é muito grande, peça `last_id` em vez de `pagina`
- **Cache de resposta:** plugin pode sugerir TTL com `oResponse:setHeader("Cache-Control", "max-age=60")`
- **WebService SOAP:** use `type: soap` em vez de REST para integração com sistemas legados

## Próximos passos sugeridos

1. `/advpl-specialist:review SaldoProdutoAPI.tlpp --focus security` — valida autenticação e sanitização
2. `/advpl-specialist:test SaldoProdutoAPI.tlpp` — gera testes ProBat com mock de request
3. `/advpl-specialist:document SaldoProdutoAPI.tlpp --format api` — gera documentação Swagger-like
