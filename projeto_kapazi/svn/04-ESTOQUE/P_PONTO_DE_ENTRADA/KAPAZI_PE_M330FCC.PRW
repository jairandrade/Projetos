#include "rwmake.ch"
#include "protheus.ch"

/*
	O ponto e chamado no momento que o sistema filtra as contas contabeis para o calculo de valor nos centros de custo que resultarão no valor da MOD.
*/
User Function M330FCC()
	// area atual
	Local aArea := GetArea()
	//-- (.T.) - Processa registro da tabela / (.F.) -- Não processa registro
	Local xRet 	:= .T.
	// tabela de processamento
	Local cTab	:= ""

	If ValType(PARAMIXB) == "A"
		cTab := PARAMIXB[1]
	ElseIf ValType(PARAMIXB) == "C"
		cTab := PARAMIXB
	EndIf

	//-- Validações adicionais do Cliente
	If cTab == "CT1"
		xRet := Substr(CT1->CT1_CONTA,1,6) == '410102'
	ElseIf cTab == "CQ1"
		xRet := Substr(CQ1->CQ1_CONTA,1,6) == '410102'
	ElseIF cTab == "CQ3"
		if IsInCallStack("MovMesCT3")
			xRet := Substr(CQ3->CQ3_CONTA,1,6) == '410102'
		Else
			xRet := " SUBSTRING(CQ3_CONTA,1,6) = '410102' "
			xRet += " AND '1' <> (select CTT_K_CTIN FROM "+RetSqlName("CTT")+" WHERE D_E_L_E_T_<>'*' AND CTT_FILIAL ='"+xFilial("CTT")+"' "
			xRet += " AND CTT_CUSTO = CQ3_CCUSTO)"
		Endif
	EndIf

	// restaura a area
	RestArea(aArea)
	// retorna
Return xRet
