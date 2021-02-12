#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "topconn.ch"
//==================================================================================================//
//	Programa: FA060Qry 	|	Autor: Luis Paulo									|	Data: 09/07/2018//
//==================================================================================================//
//	Descrição: Funcao filtrar os titulos															//
//																									//
//==================================================================================================//
User Function FA060Qry() 
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cUser 	:= GetMv("KP_MNTBORR",,"000000")
Local cFiltro := ""

If !(__CUserId $ cUser)
		MsgAlert("Você não tem permissão para criar bordero!")
		cFiltro := " E1_XIDVNFK = '999999999999999' "
	Else
		cFiltro := nil
EndIf

RestArea(aArea)	
Return(cFiltro)
