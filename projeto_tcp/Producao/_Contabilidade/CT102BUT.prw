#include "totvs.ch"

/*/{Protheus.doc} CT102BUT
    Ponto de entrada para adicionar fun��es no aRotina CTBA102
    @type  Function
    @author Willian Kaneta
    @since 23/06/2020
    @version 1.0
    @return aRet
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function CT102BUT()
    Local aRet      := {}
    
    //TCCOA01(cNumDoc,cTipoDoc,cCodUser,cFuncWf)
    aAdd(aRet, {'Aprova��o Pr� lan�amento',"U_TCCTW002",   0 , 4    })

Return aRet
