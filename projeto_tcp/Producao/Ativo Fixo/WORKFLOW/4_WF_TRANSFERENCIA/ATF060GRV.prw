#include "totvs.ch"

/*/{Protheus.doc} ATF060GRV
    Ponto de entrada após a gravação de dados rotina de transferência ativo - ATFA060
    @type  Function
    @author Willian Kaneta
    @since 01/09/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function ATF060GRV()
    Local aArea     := GetArea()
    Local aAreaFNR  := FNR->(GetArea())
    Local aAreaSN4  := SN4->(GetArea())

    //Envia WF Transferência Ativo
    U_TCAT04WK()

    RestArea(aAreaSN4)
    RestArea(aAreaFNR)
    RestArea(aArea)
Return Nil
