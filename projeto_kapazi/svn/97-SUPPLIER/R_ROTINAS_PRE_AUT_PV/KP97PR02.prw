#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97PR02		|	Autor: Luis Paulo							|	Data: 07/09/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel pelo reenvio de email com planilha para supplier					//
//																									//
//==================================================================================================//
User Function KP97PR02()
Private cNmArq	:= Alltrim(ZS4->ZS4_NMARQ)

If !Empty(ZS4->ZS4_XIDINT)
		U_KP97PRAU()
	Else
		MsgInfo("Arquivo nao gerado anteriormente, favor verificar!!","KAPAZI - AUT PEDIDOS SUPPLIER CARD")
EndIf

Return()
