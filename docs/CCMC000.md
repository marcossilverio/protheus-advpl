# CCMC000

## Objetivo

Classe ADVPL responsável por encapsular a conexão com uma base de dados externa via **DbAccess/TcLink**, fornecendo métodos para conectar, desconectar e gerenciar o handle de conexão. Permite que outras rotinas acessem bancos externos (ex: SQL Server, Oracle) configurados no DbAccess sem expor os detalhes de conexão.

---

## Tipo

`Class` — Classe ADVPL (não-TLPP)

## Módulo

Customização / Integração (`CC` — prefixo de customização da empresa)

---

## Propriedades da Classe

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `cBcoDados` | C | Nome da fonte de dados ODBC configurada no DbAccess |
| `cServer` | C | Endereço IP/hostname do servidor DbAccess |
| `nPorta` | N | Porta de conexão do DbAccess |
| `nHandle` | N | Handle retornado por `TcLink` (identificador da conexão ativa) |
| `cResult` | C | Mensagem de resultado da última operação |

---

## Parâmetros MV_* (SuperGetMV)

| Parâmetro | Padrão | Descrição |
|-----------|--------|-----------|
| `ZZ_DAXBCO` | `ODBC/base_auxiliar_ax` | Nome da conexão ODBC cadastrada no DbAccess |
| `ZZ_DAXSRV` | `localhost` | Servidor onde o DbAccess está sendo executado |
| `ZZ_DAXPOR` | `7891` | Porta de comunicação com o DbAccess |

> Esses parâmetros devem ser cadastrados no **Configurador > Parâmetros** antes do uso em produção.

---

## Métodos

### `NewConexaoDAX()` — Construtor

Inicializa a instância lendo as configurações de conexão via `SuperGetMV`. Se os parâmetros não estiverem cadastrados, usa os valores padrão.

```advpl
Local oConex := CCMC000():NewConexaoDAX()
```

---

### `Conecta()` → `lRet (L)`

Estabelece a conexão com o banco externo via `TcLink`. Retorna `.T.` se conectado com sucesso ou `.F.` em caso de falha, gravando a mensagem de erro em `cResult`.

| Retorno | Valor | Descrição |
|---------|-------|-----------|
| `.T.` | Handle >= 0 | Conexão estabelecida |
| `.F.` | Handle < 0 | Falha na conexão |

---

### `Desconecta()` → `lRet (L)`

Encerra a conexão ativa via `TCUnlink`. Retorna o resultado da operação.

---

### Getters / Setters

| Método | Direção | Propriedade |
|--------|---------|-------------|
| `GetBcoDados()` | Leitura | `cBcoDados` |
| `GetServer()` | Leitura | `cServer` |
| `GetPorta()` | Leitura | `nPorta` |
| `GetHandle()` | Leitura | `nHandle` |
| `GetResult()` | Leitura | `cResult` |
| `SetHandle(value)` | Escrita | `nHandle` |
| `SetResult(value)` | Escrita | `cResult` |

---

## Tabelas Protheus

Nenhuma tabela padrão do Protheus é acessada diretamente. A classe gerencia exclusivamente conexões com **bases externas via DbAccess**.

---

## Dependências

| Função/Include | Arquivo | Tipo |
|----------------|---------|------|
| `TcLink` | Protheus nativo | Conecta ao banco externo via DbAccess |
| `TCUnlink` | Protheus nativo | Desconecta do banco externo |
| `SuperGetMV` | Protheus nativo | Lê parâmetro MV com valor padrão |
| `PROTHEUS.CH` | Include | Definições padrão Protheus |
| `TOTVS.CH` | Include | Definições TOTVS |

---

## Exemplo de Uso

```advpl
// Instancia e conecta
Local oConex := CCMC000():NewConexaoDAX()
Local lConectado := oConex:Conecta()

If lConectado
    Local nHandle := oConex:GetHandle()
    // ... TCQuery, etc.
    oConex:Desconecta()
Else
    MsgAlert(oConex:GetResult(), "Erro de Conexão")
EndIf
```

---

## Observações

- O comentário do método `Conecta()` no código-fonte está incorreto — diz `"GravaLog()"` mas refere-se ao método `Conecta()`. Recomenda-se corrigir.
- Existe um bloco de código comentado no final do arquivo (`/* ... */`) com uma implementação procedural alternativa — pode ser removido com segurança.
- Os includes `APWIZARD.CH`, `FILEIO.CH` e `RPTDEF.CH` não parecem ser utilizados pela classe; avalie remover para manter o fonte limpo.

---

## Histórico

| Data | Autor | Descrição |
|------|-------|-----------|
| — | João Zabotto | Criação da classe e método `Conecta()` |
| — | Wellington Navasconi | Implementação do construtor `NewConexaoDAX()` e `SetHandle()` |
