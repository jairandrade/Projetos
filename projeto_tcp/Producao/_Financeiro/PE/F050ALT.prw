#include 'totvs.ch'

/*/{Protheus.doc} F050ALT
    Ponto de entrada executado na validação da Tudo Ok na alteração dos dados do contas a pagar.
    @type  Function
    @author Willian Kaneta
    @since 29/07/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function F050ALT()
    Local nOpca     := PARAMIXB[1]
    Local aAreaSE2  := SE2->(GetArea())

    If nOpca == 1
        If !Empty(SE2->E2_HIST)
            //Remove Pipe, Enter, Tab
            //User Function TRATAHIS declarada no Fonte FA050GRV.prw
            If RecLock("SE2",.F.)
                SE2->E2_HIST := U_TRATAHIS(SE2->E2_HIST)
                SE2->(MsUnlock())
            EndIf
        EndIf
    EndIf

    RestArea(aAreaSE2)
Return Nil
