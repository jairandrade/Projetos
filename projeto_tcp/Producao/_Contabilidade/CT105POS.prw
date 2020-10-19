#include 'totvs.ch'

/*/{Protheus.doc} CT105POS
    Ponto de Entrada que permite incluir novas validações de lançamento contábil.
    @type  Function
    @author Willian Kaneta
    @since 10/08/2020
    @version 1.0
    @return .T. - Lançamento Ok .F. - Lançamento inconsistente
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function CT105POS()
    Local _lRet := PARAMIXB[1]

    //Permite alterar quando é partida simples em 
    //execauto CTBA102 pela função TCWFCTRET - Aprovação Pré Lançamento CT2
    If IsBlind() .AND. IsIncallStack("U_TCWFCTRET")
        _lRet := .T.
    EndIf
    
Return _lRet 
