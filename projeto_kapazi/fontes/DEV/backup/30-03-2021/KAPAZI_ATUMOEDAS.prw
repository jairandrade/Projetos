#include "tbiconn.ch"
#include "protheus.ch"

/*/{Protheus.doc} ATUMOEDAS
Função que atualiza a MOEDA2 na tabela SM2
@author Jair Andrade
@since 24/03/2021
@version 1.0
@type function
/*/
User Function ATUMOEDAS()
	Local cFile		:=""
	Local cTexto 	:=""
	Local nLinhas	:= 0
	Local nY 		:= 0
	Local lAuto 	:= .F.
	Local lAchou 	:= .F.

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
	For nY := 1 to nLinhas
		lAchou:=.T.
		cLinha := Memoline(cTexto,81,nY)
		//cData := Substr(cLinha,1,10)
		cCompra := StrTran(Substr(cLinha,22,10),",",".")
		cVenda := StrTran(Substr(cLinha,33,10),",",".")
		If Subst(cLinha,12,3)=="220" // Dolar Americano
			DbSelectArea("SM2")
			DbSetOrder(1)

			dData := date()

			If DbSeek(DTOS(dData))
				Reclock("SM2",.F.)
			Else
				Reclock("SM2",.T.)
				Replace M2_DATA   With dData
			EndIf
			Replace M2_MOEDA2 With Val(cVenda)
			Replace M2_INFORM With "S"
			MsUnlock("SM2")
		EndIf
	Next

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
