#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: MTSELEOP		|	Autor: Luis Paulo							|	Data: 14/09/2020	//
//==================================================================================================//
//	Descrição: Responsável pela exibição e retorno da seleção de opcionais de acordo com os         //
//  parâmetros recebidos.EM QUE PONTO : É executado somente quando o parâmetro MV_SELEOPC estiver   //
//  habilitado. Tem como objetivo inibir (.F.) ou exibir (.T.) a tela de seleção de opcionais do    //
//  produto.																                        //
//																									//
//==================================================================================================//
User Function MTSELEOP()
Local cRet 	    := ParamIxb[1]
Local cProd     := ParamIxb[2]
Local cProg     := ParamIxb[3]
Local lRet      := .T.

If IsInCallStack("MATA410")
    lRet := .f.
EndIf

Return lRet
