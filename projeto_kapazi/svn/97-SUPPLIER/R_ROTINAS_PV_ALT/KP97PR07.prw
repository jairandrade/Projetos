#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97PR07		|	Autor: Luis Paulo							|	Data: 07/09/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel pelo reenvio de email com planilha para supplier					//
//																									//
//==================================================================================================//
User Function KP97PR07()
Private cNmArq	:= Alltrim(ZS7->ZS7_NMARQI)

If !Empty(ZS7->ZS7_XIDINT)
		U_KP97PRPA()
		//MsgInfo("Processo finalizado!!","KAPAZI - PEDIDOS DE VENDA SUPPLIER CARD")
	Else
		MsgInfo("Arquivo nao gerado anteriormente, favor verificar!!","KAPAZI - AUT PEDIDOS SUPPLIER CARD")
EndIf

Return()
