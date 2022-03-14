/*/{Protheus.doc} User Function MTA450LIB
    Ponto de entrada para Validar item na liberação manual
    @type  Function
    @author user
    @since 23/04/2020
    @version 1.0
    @return lRet(logico) .T. processar o item/ .F. não processar o item.
    /*/
User Function MTA450LIB()
    Local lRet          := .T.
    Local aArea         := GetArea()
    Local aAreaSC9      := SC9->(GetArea())
    Local aAreaSC5      := SC5->(GetArea())
    Local aAreaSC6      := SC6->(GetArea())
    Local aAreaSUA      := SUA->(GetArea())
    Local cEstoCIC      := ""
    Local cNumTlvX      := ""
    Local cNumSC5X      := SC9->C9_PEDIDO
    Local _cFilBKPJV    := cFilAnt

    cNumTlvX := POSICIONE("SUA",8,xFilial("SUA")+SC9->C9_PEDIDO,"UA_NUM")
    cEstoCIC := POSICIONE("SUA",8,xFilial("SUA")+SC9->C9_PEDIDO,"UA_XESTOQU")

    If Alltrim(cEstoCIC) == "2" .AND. (!IsBlind()) .AND. SC5->C5_XFLAGJV != "S" .AND. FunName() == "MATA450"
        //Grava flag que já foi gerado o pedido de venda na filial CIC
        If RecLock("SC5",.F.)
            SC5->C5_XFLAGJV := "S"
            SC5->(MsUnlock())
        EndIf   
        _cFilBKPJV := cFilAnt
        U_CTFAT04WK(cNumTlvX,cNumSC5X)
        cFilAnt := _cFilBKPJV
        POSICIONE("SM0",1,cEmpAnt+cFilAnt,"M0_CGC")
    EndIf

    RestArea(aAreaSUA)
    RestArea(aAreaSC6)
    RestArea(aAreaSC5)
    RestArea(aAreaSC9)
    RestArea(aArea)  
Return lRet
