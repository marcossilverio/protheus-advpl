#Include "TOTVS.CH"

/*/{Protheus.doc} FATA001
Gravacao de pedido de venda - versao procedural legada (input de exemplo para migracao).
Este arquivo ilustra padroes ADVPL antigos que serao modernizados para TLPP.
@author Exemplo
@since 2020
/*/
User Function FATA001()
    Local aArea    := GetArea()
    Local cQuery   := ""
    Local cNumPed  := ""
    Local cCliente := "000001"
    Local cLoja    := "01"
    Local nValor   := 0
    Private lOk    := .T.

    // Gera proximo numero de pedido - concatenacao manual, sem BeginSQL
    cQuery := "SELECT MAX(C5_NUM) AS ULTIMO FROM " + RetSqlName("SC5") + " "
    cQuery += "WHERE C5_FILIAL = '" + xFilial("SC5") + "' AND D_E_L_E_T_ = ' '"

    TcQuery cQuery New Alias "TMP"
    cNumPed := Soma1(TMP->ULTIMO)
    TMP->(DbCloseArea())

    // Gravacao sem BEGIN SEQUENCE, sem tratamento de erro
    DbSelectArea("SC5")
    SC5->(DbSetOrder(1))
    RecLock("SC5", .T.)
    SC5->C5_FILIAL := xFilial("SC5")
    SC5->C5_NUM    := cNumPed
    SC5->C5_CLIENT := cCliente
    SC5->C5_LOJACLI:= cLoja
    SC5->C5_EMISSAO:= dDataBase
    SC5->C5_TIPO   := "N"
    SC5->(MsUnlock())

    // Gravacao do item - query concatenada vulneravel
    cQuery := "INSERT INTO " + RetSqlName("SC6") + " "
    cQuery += "(C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, C6_QTDVEN, C6_PRCVEN) "
    cQuery += "VALUES ('" + xFilial("SC6") + "', '" + cNumPed + "', '01', "
    cQuery += "'PROD001', 10, 100.00)"
    TcSqlExec(cQuery)

    // Calculo sem isolamento, lOk pode ser alterado por outras rotinas
    nValor := 10 * 100.00
    If nValor > 0
        lOk := .T.
    EndIf

    If lOk
        MsgInfo("Pedido " + cNumPed + " gravado com sucesso")
    Else
        MsgStop("Erro na gravacao do pedido")
    EndIf

    RestArea(aArea)
Return Nil

/*/{Protheus.doc} F001Cons
Consulta de pedido - tambem procedural, candidata a metodo da classe.
@param cNumPed numero do pedido a consultar
/*/
Static Function F001Cons(cNumPed)
    Local aArea := GetArea()
    Local cSql  := ""

    cSql := "SELECT C5_NUM, C5_CLIENT, C5_EMISSAO FROM " + RetSqlName("SC5") + " "
    cSql += "WHERE C5_FILIAL = '" + xFilial("SC5") + "' AND C5_NUM = '" + cNumPed + "' "
    cSql += "AND D_E_L_E_T_ = ' '"

    TcQuery cSql New Alias "QRY"
    If !QRY->(Eof())
        MsgInfo("Pedido " + QRY->C5_NUM + " encontrado")
    EndIf
    QRY->(DbCloseArea())

    RestArea(aArea)
Return Nil
