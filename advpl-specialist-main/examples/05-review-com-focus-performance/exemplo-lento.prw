#Include "TOTVS.CH"

/*/{Protheus.doc} BATCH001
Rotina batch de reprocessamento - versao com problemas de performance tipicos.
Usada como input para /advpl-specialist:review --focus performance.

Problemas ilustrados:
  - N+1 queries (RP-001) no loop principal
  - DbSeek sem indice dedicado (RP-002) na SB1
  - Concatenacao de string em loop (RP-003) na montagem do log
/*/
User Function BATCH001()
    Local aArea    := GetArea()
    Local cQuery   := ""
    Local cLog     := ""
    Local cLinha   := ""
    Local nTotal   := 0
    Local nSaldo   := 0
    Private nProc  := 0

    // Loop principal lendo todos os itens a processar
    cQuery := "SELECT C6_FILIAL, C6_NUM, C6_PRODUTO, C6_QTDVEN FROM " + RetSqlName("SC6") + " "
    cQuery += "WHERE C6_FILIAL = '" + xFilial("SC6") + "' AND D_E_L_E_T_ = ' ' "
    cQuery += "AND C6_NUM LIKE '2026%'"

    TcQuery cQuery New Alias "ITENS"
    ITENS->(DbGoTop())

    While !ITENS->(Eof())
        // RP-001: query dentro do loop - a cada iteracao, uma nova TcQuery na SB2
        // Com 10k iteracoes = 10k queries. Deveria ser um JOIN na query principal.
        cQuery := "SELECT B2_QATU FROM " + RetSqlName("SB2") + " "
        cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' "
        cQuery += "AND B2_COD = '" + ITENS->C6_PRODUTO + "' "
        cQuery += "AND B2_LOCAL = '01' AND D_E_L_E_T_ = ' '"

        TcQuery cQuery New Alias "SLD"
        nSaldo := SLD->B2_QATU
        SLD->(DbCloseArea())

        // RP-002: DbSeek na SB1 por B1_DESC (ordem 2) - indice customizado raramente existe
        // Resulta em TableScan em producao
        DbSelectArea("SB1")
        SB1->(DbSetOrder(2))
        If SB1->(DbSeek(xFilial("SB1") + Space(30), .F.))
            // Logica de consulta reversa por descricao
        EndIf

        // RP-003: concatenacao de string em loop realoca a cada iteracao
        cLinha := "Processado item " + ITENS->C6_NUM + " produto " + ITENS->C6_PRODUTO + CRLF
        cLog := cLog + cLinha  // <-- ponto caro com 10k iteracoes

        nTotal := nTotal + nSaldo
        nProc++
        ITENS->(DbSkip())
    EndDo

    ITENS->(DbCloseArea())

    // Gravacao do log - funciona, mas cLog ja esta inchado
    MemoWrite("\logs\batch001.log", cLog)

    MsgInfo("Processados " + cValToChar(nProc) + " itens. Saldo total: " + cValToChar(nTotal))

    RestArea(aArea)
Return Nil
