#include 'protheus.ch'
#include 'parmtype.ch'
#Include "Totvs.ch"
#Include "FwMvcDef.ch"
//==================================================================================================//
//	Programa: GTCLIZPV		|	Autor: Luis Paulo								|	Data: 22/01/2018//
//==================================================================================================//
//	Descrição: GATILHO PARA RETORNAR O CONTEUDO DE UM CAMPO											//
//																									//
//==================================================================================================//
User Function GTCLIZPV()
Local oMdlAct 		:= FwModelActive()
Local oVwAct 			:= FwViewActive()
Local cCodCL			:= oMdlAct:GetValue( 'Enchoice_ZPV', 'ZPV_CLIENT' )
Local cCodLJ			:= oMdlAct:GetValue( 'Enchoice_ZPV', 'ZPV_CLILOJ' )
Local cDescCli		
Local cRet

cDescCli	:= Posicione("SA1",1,xFilial("SA1")+cCodCL+cCodLJ,"A1_NOME")

If oVwAct != Nil .And. oVwAct:LACTIVATE
	oVwAct:lModify := .T.
	oVwAct:Refresh()
EndIf
	
Return(cRet)
