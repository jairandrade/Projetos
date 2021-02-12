#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: FA60CAN1 	|	Autor: Luis Paulo									|	Data: 09/07/2018//
//==================================================================================================//
//	Descrição: Permite ou não o cancelamento do titulo no bordero	  								//
//																									//
//==================================================================================================//
User Function FA60CAN1()
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cUser 	:= GetMv("KP_MNTBORR",,"000000")

If !(__CUserId $ cUser)
	MsgAlert("Você não tem permissão para excluir titulo em bordero!")
	lRet	:= .F.
EndIf

RestArea(aArea)	
Return(lRet)