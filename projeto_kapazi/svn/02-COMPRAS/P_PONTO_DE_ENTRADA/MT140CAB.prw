#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
#Include "tbiconn.ch"
//==================================================================================================//
//	Programa: MT140CAB		|	Autor: Luis Paulo							|	Data: 19/08/2020    //
//==================================================================================================//
//	Descrição: PE NA ALTERACAO DA PRE-NOTA                											//
//																									//
//==================================================================================================//
User Function MT140CAB()
Local lExecuta  := .T.

If Type("lAtualPr") == "U" 
        Public lAtualPr	:= .f.
    ElseIf Type("lAtualPr") == "L"
        lAtualPr	:= .f.
EndIf

Return( lExecuta )
