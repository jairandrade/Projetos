#include 'protheus.ch'
#include 'parmtype.ch'

//==================================================================================================//
//	Programa: FA060TRF 	|	Autor: Luis Paulo									|	Data: 09/07/2018//
//==================================================================================================//
//	Descrição: Permite ou não o cancelamento do titulo no bordero	  								//
//																									//
//==================================================================================================//
User Function FA060TRF()
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cUser 	:= GetMv("KP_MNTBORR",,"000000")

If !(__CUserId $ cUser)
	MsgAlert("Você não tem permissão para transferir titulo!")
	lRet	:= .F.
EndIf

RestArea(aArea)	
Return(lRet)