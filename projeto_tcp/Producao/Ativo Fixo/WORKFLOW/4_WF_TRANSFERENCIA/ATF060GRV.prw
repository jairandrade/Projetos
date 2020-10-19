#include "totvs.ch"

/*/{Protheus.doc} ATF060GRV
    Ponto de entrada ap�s a grava��o de dados rotina de transfer�ncia ativo - ATFA060
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

    //Envia WF Transfer�ncia Ativo
    U_TCAT04WK()

    RestArea(aAreaSN4)
    RestArea(aAreaFNR)
    RestArea(aArea)
Return Nil
