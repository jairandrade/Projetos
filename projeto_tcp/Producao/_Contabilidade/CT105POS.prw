#include 'totvs.ch'

/*/{Protheus.doc} CT105POS
    Ponto de Entrada que permite incluir novas valida��es de lan�amento cont�bil.
    @type  Function
    @author Willian Kaneta
    @since 10/08/2020
    @version 1.0
    @return .T. - Lan�amento Ok .F. - Lan�amento inconsistente
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function CT105POS()
    Local _lRet := PARAMIXB[1]

    //Permite alterar quando � partida simples em 
    //execauto CTBA102 pela fun��o TCWFCTRET - Aprova��o Pr� Lan�amento CT2
    If IsBlind() .AND. IsIncallStack("U_TCWFCTRET")
        _lRet := .T.
    EndIf
    
Return _lRet 
