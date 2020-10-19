#include 'totvs.ch'

/*/{Protheus.doc} ATFA036
    (long_description)
    @type  Function
    @author user
    @since 26/08/2020
    @version 1.0
    @return xRet
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function ATFA036()
	Local _cIdPonto := ""
	Local _cIdModel := ""    
    Local xRet 		:= .T.
    Local _lCancel  := .F.

    If PARAMIXB <> Nil
        _cIdPonto  := PARAMIXB[2]    
        _cIdModel  := PARAMIXB[3]    
        If _cIdPonto == 'FORMPOS'
            _lCancel := At("CANCELAR",CCADASTRO) != 0
            //Cancelamento
            If _lCancel .AND. _cIdModel == "FN7VALOR"
                U_TCAT03WK(5)
            EndIf
        EndIf
    EndIf

Return xRet
