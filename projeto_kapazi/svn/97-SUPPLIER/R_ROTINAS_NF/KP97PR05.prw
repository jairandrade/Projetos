#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97PR05		|	Autor: Luis Paulo							|	Data: 07/09/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel pelo reenvio de email com planilha para supplier					//
//																									//
//==================================================================================================//
User Function KP97PR05()
Private cNmArq	:= Alltrim(ZS6->ZS6_NMARQI)

If !Empty(ZS6->ZS6_XIDINT)
		U_KP97PRNF()
	Else
		MsgInfo("Arquivo nao gerado anteriormente, favor verificar!!","KAPAZI - AUT PEDIDOS SUPPLIER CARD")
EndIf

Return()
