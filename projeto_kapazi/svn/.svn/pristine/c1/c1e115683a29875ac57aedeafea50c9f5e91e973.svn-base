#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: KP97PR03		|	Autor: Luis Paulo							|	Data: 07/09/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel pelo reenvio de email com planilha para supplier					//
//																									//
//==================================================================================================//
User Function KP97PR03()
Private cNmArq	:= Alltrim(ZS3->ZS3_NMARQI)

If !Empty(ZS3->ZS3_XIDINT)
		U_KP97PRPV()
		//MsgInfo("Processo finalizado!!","KAPAZI - PEDIDOS DE VENDA SUPPLIER CARD")
	Else
		MsgInfo("Arquivo nao gerado anteriormente, favor verificar!!","KAPAZI - AUT PEDIDOS SUPPLIER CARD")
EndIf

Return()
