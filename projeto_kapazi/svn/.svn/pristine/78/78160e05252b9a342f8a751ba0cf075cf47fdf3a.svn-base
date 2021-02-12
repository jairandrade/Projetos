#include 'protheus.ch'
#include 'parmtype.ch'
//==================================================================================================//
//	Programa: MTA416PV		|	Autor: Luis Paulo								|	Data: 23/05/2018//
//==================================================================================================//
//	Descrição: Executado apos o preenchimento do aCols na Baixa do Orcamento de Vendas.				//
//	Usar as variaveis _aCols e _aHeader																//
//																									//
//==================================================================================================//
User Function MTA416PV()

	Local aArea := GetArea()

	local nChave    := aScan(_aHeader,{|X| ALLTRIM(X[2]) == "C6_NUMORC"})
	local nLarg    := aScan(_aHeader,{|X| ALLTRIM(X[2]) == "C6_XLARG"})
	local nCompri    := aScan(_aHeader,{|X| ALLTRIM(X[2]) == "C6_XCOMPRI"})
	local nQTD    := aScan(_aHeader,{|X| ALLTRIM(X[2]) == "C6_XQTDPC"})
	Local nAux := PARAMIXB
	local nI := 0

	M->C5_NOMECLI  	:= POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI ,"A1_NOME")
	M->C5_CGCCLI  	:= POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI ,"A1_CGC")
	M->C5_K_TPCL  	:= POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI ,"A1_GRPVEN")

	//M->C5_NUMORC  	:= SCJ->CJ_NUM

	for nI:= 1 to nAux
		DbSelectArea("SCK")
		SCK->(DbSetOrder(1))
		If SCK->(DbSeek(xFilial("SCK")+_aCols[nI,nChave] ))
			_aCols[nI,nLarg]   := SCK->CK_XLARG
			_aCols[nI,nCompri] := SCK->CK_XCOMPRI
			_aCols[nI,nQTD]    := SCK->CK_XQTDPC
		EndIf
	next nI

	RestArea(aArea)
Return()

