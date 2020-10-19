#include "totvs.ch"

/*/{Protheus.doc} TCCTW002
    Função executado no ponto de entrada CT102BUT
    @type  Function
    @author Willian Kaneta
    @since 23/06/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function TCCTW002()
    Local cNumDoc       := CT2->(DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC)
    Local cUsrIncLc     := FWLeUserlg("CT2_USERGI",1)

    U_TCCOA01(cNumDoc,'LC',cUsrIncLc,"U_TCCTWF01(1)")

Return Nil
