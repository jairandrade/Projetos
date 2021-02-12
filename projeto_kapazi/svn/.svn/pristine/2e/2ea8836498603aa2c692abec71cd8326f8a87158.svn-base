#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97PR04		|	Autor: Luis Paulo							|	Data: 07/09/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel pelo reenvio de email com planilha para supplier					//
//																									//
//==================================================================================================//
User Function KP97PR04()
Private cNmArq	:= Alltrim(ZS5->ZS5_NMARQ)

If !Empty(ZS5->ZS5_XIDINT)
		U_KP97PRRA()
	Else
		MsgInfo("Arquivo nao gerado anteriormente, favor verificar!!","KAPAZI - AUT PEDIDOS SUPPLIER CARD")
EndIf

Return()
