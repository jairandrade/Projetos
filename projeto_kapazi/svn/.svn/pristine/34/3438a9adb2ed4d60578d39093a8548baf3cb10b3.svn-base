#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: F590COK 	|	Autor: Luis Paulo									|	Data: 08/07/2018//
//==================================================================================================//
//	Descrição: Permite ou não o cancelamento do titulo no bordero	  								//
//																									//
//==================================================================================================//
User Function F590COK()
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cUserr 	:= GetMv("KP_MNTBORR",,"000000")
Local cUserp 	:= GetMv("KP_MNTBORP",,"000000")
Local cUser		:= ""
Local lReceber	:= ( Type("lRecTrue") != "U" ) //Variavel private da rotina

If lReceber
		If !(__CUserId $ cUserr)
			MsgAlert("Você não tem permissão para incluir titulo em bordero!")
			lRet	:= .F.
		EndIf
	
	Else
		If !(__CUserId $ cUserp)
			MsgAlert("Você não tem permissão para incluir titulo em bordero!")
			lRet	:= .F.
		EndIf	
EndIf

RestArea(aArea)	
Return(lRet)