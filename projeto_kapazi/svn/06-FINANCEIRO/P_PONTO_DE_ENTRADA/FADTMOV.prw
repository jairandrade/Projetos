#include 'protheus.ch'
#include 'parmtype.ch'

//==================================================================================================//
//	Programa: FADTMOV 	|	Autor: Luis Paulo									|	Data: 09/07/2018//
//==================================================================================================//
//	Descrição: Valida o cancelamento do bordero						  								//
//																									//
//==================================================================================================//
User Function FADTMOV()
Local aArea	:= GetArea()
Local lRet	:= .T.
Local cUser := GetMv("KP_MNTBORR",,"000000")

If Funname() == "FINA060" .And. (IsInCallStack( 'Fa060Canc' ) .OR. IsInCallStack( 'FA060Trans' ) .OR.  IsInCallStack( 'FA060Borde' ))
	If !(__CUserId $ cUser)
		MsgAlert("Você não tem permissão para acessar esta rotina!")
		lRet	:= .F.
	EndIf

EndIf

RestArea(aArea)	
Return(lRet)