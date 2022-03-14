#include "tbiconn.ch"
#include "protheus.ch"

/*/{Protheus.doc} ATUMOEDAS
Função que atualiza a MOEDA2 na tabela SM2
@author Jair Andrade
@since 24/03/2021
@version 1.0
@type function
Alterações: 
Alterado 30-03-2021 - incluir moedas UFIR / EURO / IENE / 
/*/
User Function ATUMOEDAS()
	Local cFile		:=""
	Local cTexto 	:=""
	Local nLinhas	:= 0
	Local nY 		:= 0
	Local lAuto 	:= .F.
	Local lAchou 	:= .F.
	Local nValUSD	:= 0
	Local nValEUR	:= 0
	Local nValIEN	:= 0

	If Select("SX2")==0 // Testa se está sendo rodado do menu
		//RPCSETENV("99","01",,,,"nYOB",{"SM2"})
		Prepare Environment Empresa "04" Filial "01"
		Qout("nYOB - Atualizacao do Dolar...")
		lAuto := .T.
	EndIf

	dDataRef := dDataBase -1

	If Dow(dDataRef) == 1    // Se for domingo
		cFile := DTOS(dDataRef - 2)+".csv"
	ElseIf Dow(dDataBase) == 7            // Se for sábado
		cFile := DTOS(dDataRef - 1)+".csv"
	Else                                   // Se for dia normal
		cFile := DTOS(dDataRef)+".csv"
	EndIf

	cTexto := HTTPGET('https://www4.bcb.gov.br/download/fechamento/'+cFile)
	nLinhas := MLCount(cTexto, 81)
	dData := date()
	For nY := 1 to nLinhas
		lAchou:=.T.
		cLinha := Memoline(cTexto,81,nY)
		//cData := Substr(cLinha,1,10)
		cCompra := StrTran(Substr(cLinha,22,10),",",".")
		cVenda := StrTran(Substr(cLinha,33,10),",",".")
		If Subst(cLinha,12,3)=="220" // Dolar Americano
			nValUSD := Val(cVenda)
		EndIf

		If Subst(cLinha,12,3)=="978" // EURO
			nValEUR		:= Val(cVenda)
		EndIf

		If Subst(cLinha,12,3)=="470" // IENE
			nValIEN		:= Val(cVenda)
		EndIf
	Next
	dbSelectArea("SM2")
	dbSetorder(1)

	If dData != Nil

		If SM2->(dbSeek(DtoS(dData)))
			Reclock("SM2", .F.)
		Else
			Reclock("SM2", .T.)
			SM2->M2_DATA	:= dData
		EndIf
		SM2->M2_MOEDA2	:= nValUSD//dolar
		SM2->M2_MOEDA3  := 0.8287 //ufir
		SM2->M2_MOEDA4  := nValEUR//euro
		SM2->M2_MOEDA5  := nValIEN//iene
		SM2->M2_INFORM	:= "S"
		MsUnLock("SM2")
	EndIf

	if lAchou
		conout("Atualizacao efetuada com sucesso")
	else
		conout(" Falha no processamento, verifique conexao com internet ou tente mais tarde !")
	EndIf

	If lAuto
		//RpcClearEnv()
		RESET ENVIRONMENT
		conout("FIM - nYOB - Atualizacao do Dolar.")
	EndIf

Return
