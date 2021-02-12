#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: FA460con 		|	Autor: ??????									|	Data: 22/01/2018//
//==================================================================================================//
//	Descrição: O ponto de entrada FA460CON permite a validação do aCols e aHeader na rotina de 		//
//	Liquidação (FINA460), inclusive para a rotina automática. 										//
//																									//
//==================================================================================================//
User Function FA460con()

//MsgAlert("Teste")

If Len(_ACMC7_) >0
	nPos:=ascan(aHeader,{|x|alltrim(x[2])=="EF_CODCHEQ"})
	
	for ni:=1 to len(aCols)
		aCols[ni][nPos]:=_ACMC7_[ni]
	next
	
	oGet:ForceRefresh()
EndIf

Return(.T.)