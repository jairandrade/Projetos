#include 'totvs.ch'

/*/{Protheus.doc} AF050FIM
    Ponto de entrada executado no final da rotina Depreciação Ativo Fixo - ATFA050
    @type  Function
    @author Willian Kaneta
    @since 25/08/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function AF050FIM()
    
    //Envia WF Ativo - Depreciação
    U_TCAT01WK()
Return Nil
