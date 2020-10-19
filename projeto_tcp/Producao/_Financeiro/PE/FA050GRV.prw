#include 'totvs.ch'

/*/{Protheus.doc} FA050GRV
    Ponto de entrada apos a gravacao da SE2, antes da contabilização.
    @type  Function
    @author Willian Kaneta
    @since 16/07/2020
    @version 1.0
    @return Nil
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function FA050GRV()

    If !Empty(SE2->E2_HIST)
        //Remove Pipe, Enter, Tab
        If RecLock("SE2",.F.)
            SE2->E2_HIST := U_TRATAHIS(SE2->E2_HIST)
            SE2->(MsUnlock())
        EndIf
    EndIf

Return Nil

/*/{Protheus.doc} TRATAHIS
    Tratamento caracteres campo E2_HIST
/*/
User Function TRATAHIS(_cDesc)
	Local  _sRet:= _cDesc
    _sRet := StrTran (_sRet, "'", "" )
    _sRet := StrTran (_sRet, '"', "" )
    _sRet := StrTran (_sRet, "&", "e")
    _sRet := StrTran (_sRet, "|", "-")
    _sRet := StrTran (_sRet, "\", "-")
    _sRet := StrTran (_sRet, "/", "-")
    _sRet := StrTran (_sRet, "<", " ")
    _sRet := StrTran (_sRet, ">", " ")
    _sRet := StrTran (_sRet, chr(9)," ") // TAB
    _sRet := StrTran (_sRet, CRLF, " -- ") // enter
    _sRet := StrTran (_sRet,"  "," " )
    _sRet := StrTran (_sRet,"   "," ")
   
   //Só para garantir
   _sRet := noAcento (_sRet) 

return ALLTRIM(_sRet)
