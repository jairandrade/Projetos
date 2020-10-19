#INCLUDE 'protheus.ch'
#INCLUDE "rwmake.ch"

user function AFIN011()
	
	Local _lRet 	:= .T.
	Local lEnable 	:= GetMV("TCP_ALTSP",.F.)

	
	IF  ALTERA .AND. ALLTRIM(M->E2_XORIGEM) == 'SP'
		If !lEnable
			_lRet := .F.
		ENDIF
	EndIf

return( _lRet )