#include 'totvs.ch'

/*/{Protheus.doc} User Function MT450END
    Ponto de Entrada pertencente à rotina "Liberação de Crédito" (MATA450). 
    Está localizado no processamento da avaliação automática de crédito por pedidos, MA450PROCES(). 
    É executado ao final do processamento de cada item.
    @type  Function
    @author Willian Kaneta
    @since 13/05/2020
    @version 1.0
    /*/
User Function MT450END()
    Local aArea := GetArea()
    Local aAreaSC9 := SC9->(GetArea())
    Local aAreaSC5 := SC5->(GetArea())
    Local aAreaSC6 := SC6->(GetArea())
    Local aAreaSUA := SUA->(GetArea())
    Local cEstoCIC := ""
    Local cNumTlvX := ""
    Local cNumSC5X := SC5->C5_NUM
    Local _cFilBKPJV := cFilAnt

    DbSelectArea("SC9")
    SC9->(DbSetOrder(1))

    If SC9->(MsSeek(xFilial("SUA")+SC5->C5_NUM))
        cNumTlvX := POSICIONE("SUA",8,xFilial("SUA")+SC9->C9_PEDIDO,"UA_NUM")
        cEstoCIC := POSICIONE("SUA",8,xFilial("SUA")+SC9->C9_PEDIDO,"UA_XESTOQU")
        If Alltrim(cEstoCIC) == "2" .AND. (!IsBlind()) .AND. SC5->C5_XFLAGJV != "S" .AND. FunName() == "MATA450" .AND. Empty(SC9->C9_BLCRED)

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
    EndIf

    RestArea(aAreaSUA)
    RestArea(aAreaSC6)
    RestArea(aAreaSC5)
    RestArea(aAreaSC9)
    RestArea(aArea)
Return Nil
