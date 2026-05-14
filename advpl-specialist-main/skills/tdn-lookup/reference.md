# TDN Lookup — Estratégia de Busca Online

## Overview

Estratégia padronizada para buscar documentação no TDN (tdn.totvs.com) quando a referência local não tem a informação. O TDN roda sobre Confluence Data Center 7.19 e expõe a API REST v1 publicamente sem autenticação.

## Quando usar

- Função nativa não encontrada em `native-functions.md`
- Entry point não coberto por `patterns-pontos-entrada.md`
- Erro desconhecido não listado em `common-errors.md`
- Processo de negócio não coberto pelos módulos locais
- Qualquer consulta que exija a documentação oficial da TOTVS

## Estratégia de busca (Tier 1 local + 4 tiers online)

Do mais econômico ao mais custoso em tokens. Sempre consultar Tier 1 antes de qualquer chamada online.

### Tier 1: Cache local por domínio

Antes de qualquer busca online, **consultar o catálogo local específico do domínio** — resposta instantânea, custo zero em tokens de rede.

| Domínio | Arquivo de cache local |
|---------|------------------------|
| Pontos de entrada | [`skills/advpl-code-generation/catalogo-top-50-pes.md`](../advpl-code-generation/catalogo-top-50-pes.md) |
| Funções nativas | [`skills/protheus-reference/native-functions.md`](../protheus-reference/native-functions.md) |
| Dicionário SX | [`skills/protheus-reference/sx-dictionary.md`](../protheus-reference/sx-dictionary.md) |
| Campos SX3 comuns | [`skills/protheus-reference/sx3-common-fields.md`](../protheus-reference/sx3-common-fields.md) |
| Erros conhecidos | [`skills/advpl-debugging/common-errors.md`](../advpl-debugging/common-errors.md) |
| Funções restritas | [`skills/protheus-reference/restricted-functions.md`](../protheus-reference/restricted-functions.md) |
| Processos de negócio | [`skills/protheus-business/modulo-*.md`](../protheus-business/) |

**Sucesso Tier 1:** termo encontrado no catálogo com metadados completos → usar diretamente, não avançar para tiers online.
**Falha Tier 1:** termo não listado, ou listado com informações parciais que exigem complemento → avançar para Tier 2.

### Tier 2: WebFetch direto na API REST do Confluence

1. Montar a URL:
   ```
   https://tdn.totvs.com/rest/api/search?cql=<CQL_ENCODADO>&expand=body.view&limit=3
   ```
2. Executar `WebFetch` na URL
3. Se retornar JSON válido com `size > 0`:
   - Extrair `results[0].content.title`, `results[0].excerpt`, `results[0].url`
   - Extrair `results[0].content.body.view.value` (HTML do conteúdo completo)
   - Parsear o HTML para extrair: Descrição, Sintaxe, Parâmetros, Retorno, Exemplo
   - **Usar diretamente** (fim)
4. Se `size == 0` → repetir com CQL fuzzy (ver tabela de CQL abaixo)
5. Se falhar (403 Cloudflare, timeout, HTML em vez de JSON) → Tier 3

### Tier 3: Playwright na API REST (JSON via navegador)

1. `browser_navigate` → mesma URL do Tier 2
2. `browser_snapshot` → extrair o JSON como texto
3. Parsear o JSON com mesmo processo do Tier 2
4. Se `size == 0` → repetir com CQL fuzzy
5. Se falhar (JSON inválido, API fora) → Tier 4

### Tier 4: WebSearch + Playwright na URL encontrada

O Google indexa o TDN de forma diferente do CQL — pode encontrar páginas que a busca via API não encontra.

1. Executar `WebSearch` com query: `site:tdn.totvs.com "<TERMO>" advpl`
2. Se retornar resultados com URL do TDN:
   - `browser_navigate` → URL retornada pelo WebSearch
   - `browser_snapshot` → extrair conteúdo textual da página
   - Se insuficiente → `browser_take_screenshot` para captura visual
   - **Usar diretamente** (fim)
3. Se WebSearch não retornar resultados → Tier 5

### Tier 5: Playwright busca visual no site TDN (último recurso)

Para quando nem a API REST nem o Google encontram — busca manual no site.

1. `browser_navigate` → `https://tdn.totvs.com`
2. `browser_fill_form` → preencher campo de busca com o termo
3. `browser_click` → disparar busca
4. `browser_snapshot` → ler resultados e navegar ao mais relevante
5. Se insuficiente → `browser_take_screenshot` para captura visual
6. Sintetizar resultados no formato da referência local

### Limpeza de recursos

- **Sempre** executar `browser_close` ao finalizar Tier 3, 4 ou 5, independentemente de sucesso ou falha.

## CQL Patterns por tipo de consulta

**Endpoint:** `GET https://tdn.totvs.com/rest/api/search?cql=<CQL>&expand=body.view&limit=3`

| Tipo | CQL título exato | CQL fuzzy (fallback) |
|------|------------------|----------------------|
| Função | `type=page AND title="{FunctionName}" AND space IN ("tec","framework")` | `type=page AND title~"{FunctionName}"` |
| Entry point | `type=page AND title="{EP_NAME}" AND space IN ("tec","framework")` | `type=page AND text~"{EP_NAME}"` |
| Parâmetro MV | `type=page AND title="{MV_PARAM}"` | `type=page AND title~"{MV_PARAM}"` |
| Tabela SX | `type=page AND title~"{TableAlias}" AND space="tec"` | `type=page AND text~"{TableAlias} dicionario"` |
| API REST | `type=page AND text~"rest api {endpoint}" AND space IN ("tec","framework")` | `type=page AND text~"rest api {endpoint}"` |
| Erro | `type=page AND text~"{erro}" AND space IN ("tec","framework")` | `type=page AND text~"{erro}"` |
| Rotina | `type=page AND title~"{MATA410}"` | `type=page AND text~"{MATA410} protheus"` |
| Processo | `type=page AND text~"{processo} protheus fluxo"` | `type=page AND text~"{processo}"` |
| Módulo | `type=page AND text~"{module} modulo protheus"` | `type=page AND text~"{module}"` |
| Integração | `type=page AND text~"{moduleA} {moduleB} integracao"` | `type=page AND text~"{moduleA} {moduleB}"` |
| Conceito | `type=page AND text~"{concept} protheus" AND space IN ("tec","framework")` | `type=page AND text~"{concept}"` |

## Extração de dados do JSON

```
results[i].content.title       → Título da página
results[i].excerpt             → Resumo em texto puro
results[i].url                 → Path relativo (para Tier 5: https://tdn.totvs.com{url})
results[i].content.body.view.value → HTML do conteúdo (Descrição, Sintaxe, Parâmetros, Retorno, Exemplo)
```

## Detecção de falha

| Tier | Sucesso | Falha → próximo tier |
|------|---------|---------------------|
| **1 (Cache local)** | Termo encontrado no arquivo de cache do domínio com metadados completos | Termo não catalogado ou informações insuficientes |
| **2 (WebFetch API)** | JSON com `"results"` e `size > 0` | HTTP 403, body com `"Attention Required"` ou `"cf-browser-verification"`, timeout, body vazio, JSON com `size: 0` após fuzzy |
| **3 (Playwright API)** | Snapshot parseável como JSON com `size > 0` | Snapshot é HTML em vez de JSON, snapshot vazio, JSON com `size: 0` após fuzzy |
| **4 (WebSearch + Playwright)** | WebSearch retorna URL do TDN e snapshot tem conteúdo relevante | WebSearch retorna 0 resultados ou nenhuma URL do TDN |
| **5 (Playwright busca visual)** | Snapshot com conteúdo textual relevante | Página de erro, "page not found", snapshot vazio |

## Informações técnicas do TDN

- **Plataforma:** Confluence Data Center 7.19
- **API:** REST v1 (`/rest/api/`) — v2 não existe em Data Center
- **Autenticação:** Acesso anônimo habilitado
- **Proteção:** Cloudflare managed challenge (bloqueia WebFetch ~80%, Playwright resolve)
- **Rate limit:** ~10 requests/min para anônimo
- **Spaces conhecidos:** `tec` (funções nativas), `framework` (framework MVC/REST)

## URL Encoding Reference

| Caractere | Encoded |
|-----------|---------|
| espaço | `%20` |
| `=` | `%3D` |
| `"` | `%22` |
| `(` | `%28` |
| `)` | `%29` |
| `,` | `%2C` |
| `~` | `%7E` |
