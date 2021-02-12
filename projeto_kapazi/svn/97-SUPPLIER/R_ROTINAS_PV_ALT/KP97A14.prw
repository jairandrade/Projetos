#include "tbiconn.ch"
#include "TbiCode.ch"
#Include 'ap5mail.ch'
#include "TopConn.ch"
#include "Totvs.ch"
//==================================================================================================//
//	Programa: KP97A14		|	Autor: Luis Paulo							|	Data: 25/08/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por integrar PV para Supplier na alt pedidos						//
//																									//
//==================================================================================================//
User Function KP97A14()
Local lRet		:= .T.
Local cMark		:= oMark:Mark()
Private nNLim	:= 0

If ValCliSe() 			//Valida se tem itens selecionados
	If ValClIMU() 		//Verifica se tem mais de uma raiz de CNPJ selecionada
		If ValCliSPP()	//Valida se o cliente pertence a Supplier
			Processa({||ApuraPDV()} ,"Processando pedidos de vendas","Aguarde...")  
		EndIf
	EndIf

EndIf
ClearOk(cMark)
oMark:Refresh()
Return()

//Valida se tem itens selecionados
Static Function ValCliSe()
Local cMarkKP	:= oMark:Mark()
Local lRet		:= .T.
Local nRegs		:= 0
Local cAliaSC5	:= GetNextAlias()

If Select("cAliaSC5")<>0
	DbSelectArea("cAliaSC5")
	DbCloseArea()
Endif

cQr := " SELECT *
cQr += " FROM "+ RetSqlName("SC5") +" "
cQr += " WHERE D_E_L_E_T_ = ''

If IsInCallStack("U_KP97B08")
		cQr += "	AND	C5_FLAGSP5 = '"+cMarkKP+"'"
	Else
		cQr += "	AND	C5_FLAGSP6 = '"+cMarkKP+"'"
EndIf
// abre a query
TcQuery cQr new alias "cAliaSC5"

DbSelectArea("cAliaSC5")
cAliaSC5->(DbGoTop())
If cAliaSC5->(EOF())
	lRet		:= .F.
	MsgInfo("Nenhum Registro selecionado!!!","KAPAZI - PEDIDOS DE VENDAS SUPPLIER")
EndIf

cAliaSC5->(DbCloseArea())
Return(lRet)

//Verifica se tem mais de uma raiz de CNPJ selecionada
Static Function ValClIMU()
Local cQr 		:= ""
Local cAliaSC5	:= GetNextAlias()
Local lRet		:= .T.
Local nRegs		:= 0
Local cMarkKP	:= oMark:Mark()

If Select("cAliaSC5")<>0
	DbSelectArea("cAliaSC5")
	DbCloseArea()
Endif

cQr += " SELECT DISTINCT SUBSTRING(SA1.A1_CGC,1,8) AS RAIZCNPJ
cQr += " FROM "+ RetSqlName("SC5") +" SC5 " 
cQr += " INNER JOIN "+ RetSqlName("SA1") +" SA1 ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ''
cQr += " WHERE SC5.D_E_L_E_T_ = ''

If IsInCallStack("U_KP97B08")
		cQr += "	AND SC5.C5_FLAGSP5 = '"+cMarkKP+"' "+cCRLF
	Else
		cQr += "	AND SC5.C5_FLAGSP6 = '"+cMarkKP+"' "+cCRLF
EndIf

cQr += " ORDER BY RAIZCNPJ

// abre a query
TcQuery cQr new alias "cAliaSC5"
Count To nRegs

If nRegs > 1
	MsgInfo("Existe mais de uma Raiz de CNPJ selecionada, Deseja continuar???","KAPAZI - PEDIDOS DE VENDAS SUPPLIER")
	lRet	:= .F.
EndIf

cAliaSC5->(DbCloseArea())
Return(lRet)


Static Function ApuraPDV()
Local cQr 		:= ""
Local cAliaSC5	:= GetNextAlias()
Local cID		:= ""
Local nTan		:= 0
Local cMarkKP	:= oMark:Mark()
Local nCount	:= 0
Local nRegs		:= 0
Local cItem		:= ""
Local lContinu	:= .T.
Local aEmp		:= {}
Local aFil		:= {}
Local cTxCli	:= SUPERGETMV("KP_TXSPCLI", .F., "2") //"2 = 2%"
Local cTxAdPar	:= SUPERGETMV("KP_TXSPAPA", .F., "6")	//"6 = 6%"
Local cTxPar	:= SUPERGETMV("KP_TXSPPAR", .F., "3")	//"3 = 3%"
Local cCondPGK 	:= ""	
Local aParcelas	:= {}
Local cDiaPPar	
Local cCodSol	:= ""

If Select("cAliaSC5")<>0
	DbSelectArea("cAliaSC5")
	cAliaSC5->(DbCloseArea())
Endif

cQr += " SELECT	SC5.R_E_C_N_O_ AS RECOC5,*"+cCRLF
cQr += " FROM "+ RetSqlName("SC5")+" SC5 WITH (NOLOCK) "+cCRLF
cQr += " LEFT JOIN SA1010 SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '' AND SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = '' "+cCRLF
cQr += " WHERE SC5.D_E_L_E_T_ = '' "+cCRLF


If IsInCallStack("U_KP97B08")
		cQr += "	AND SC5.C5_FLAGSP5 = '"+cMarkKP+"' "+cCRLF
	Else
		cQr += "	AND SC5.C5_FLAGSP6 = '"+cMarkKP+"' "+cCRLF
EndIf


Conout(cQr)

// abre a query
TcQuery cQr new alias "cAliaSC5"
Count to nRegs

DbSelectArea("cAliaSC5")
cAliaSC5->(DbGoTop())

ProcRegua(nRegs)
While !cAliaSC5->(EOF())
	
	nCount++
	IncProc('Processando.....  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	
	If !Empty(cAliaSC5->C5_XSTSSPP) //C5_FLENVSP - Enviado para supplier
			//C5_FLRECSU - Processado e em posse de supplier
	
			cID		:= SUBSTR(cAliaSC5->A1_COD,1,4) +cEmpAnt + cAliaSC5->C5_FILIAL + cAliaSC5->C5_NUM //Definir depois o formato de parcelas
			
			cItem	:= GETSXENUM("ZS7","ZS7_ITEM")
			ConfirmSx8()
			
			aFil	:= FWArrFilAtu(cEmpAnt,cAliaSC5->C5_FILIAL)
			
			aParcelas	:= {}
			aParcelas	:=	Condicao(cAliaSC5->C5_XTOTMER,cAliaSC5->C5_CONDPAG,,dDataBase)
			For nZ:=1 to Len(aParcelas)
				If nZ == 1
					cDiaPPar	:= aParcelas[1,1] - dDatabase
					//aParcelas[nZ,1]	//Data boa
					//aParcelas[nZ,2] //Valor do cheque/titulo
				EndIf
			Next nZ
			
			If IsInCallStack("U_KP97B08")
					cCodSol	:= "17"
				Else
					cCodSol	:= "25"
			EndIf
			
			DbSelectArea("ZS7")
			ZS7->(DbSetOrder(5))
			ZS7->(DbGoTop())
			If ZS7->(DbSeek(xFilial("ZS7") + Space(15) + cID) ) //Valida se o registro já foi para tabela de integracao
					RecLock("ZS7",.F.)
					Conout("Registro Duplicado->"+cID)
				Else
					RecLock("ZS7",.T.)
			EndIf
			
			ZS7->ZS7_FILIAL	:= ""
			ZS7->ZS7_ITEM	:= cItem
			ZS7->ZS7_XIDINT	:= ""
			ZS7->ZS7_STATUS	:= "1"
			ZS7->ZS7_FILORI	:= cEmpAnt+cAliaSC5->C5_FILIAL
			ZS7->ZS7_DATAIN	:= Date() 
			ZS7->ZS7_HORAII	:= Time()
			ZS7->ZS7_NMARQI	:= ""
			ZS7->ZS7_RECSC5	:= cAliaSC5->RECOC5
			ZS7->ZS7_CODSOL	:= cCodSol
			ZS7->ZS7_CGCCLI	:= cAliaSC5->A1_CGC
			ZS7->ZS7_CODPVC	:= cID
			ZS7->ZS7_CODPAU	:= cAliaSC5->C5_XCODPAU
			ZS7->ZS7_TPTRAN	:= "0"
			ZS7->ZS7_VLRPVS	:= cAliaSC5->C5_XTOTMER
			ZS7->ZS7_QTDPAR	:= cValTochar(Len(aParcelas))
			ZS7->ZS7_DIASPV	:= cValToChar(cDiaPPar)
			ZS7->ZS7_CONDIC	:=  "1"
			ZS7->ZS7_QTDDEP	:=  ""
			ZS7->ZS7_TXCLIE	:= cTxCli
			ZS7->ZS7_TXAPAR	:= cTxAdPar
			ZS7->ZS7_TXADMP	:= cTxPar
			ZS7->ZS7_FORRPA	:= "3"
			ZS7->ZS7_PRAZOR	:= "D+1"
			ZS7->(MsUnlock())
			XANREGA()
		Else
			MsgInfo("Pedido já integrado com a Supplier -> " + cAliaSC5->C5_FILIAL + "-" +cAliaSC5->C5_NUM,"KAPAZI - PEDIDOS DE VENDAS SUPPLIER")
			Conout("Pedido já integrado com a Supplier -> " + cAliaSC5->C5_FILIAL + "-" +cAliaSC5->C5_NUM)
	EndIf
	cAliaSC5->(DbSkip())
EndDo

cAliaSC5->(DbCloseArea())
Return()

/*
+--------------------------------------------------------------------------+
! Função    ! ClearOk    ! Autor !                    ! Data ! 30/09/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Limpa o campo C5_FLAGSP5.                                         !
+-----------+--------------------------------------------------------------+
*/
Static Function ClearOK(cMark)
Local cSql := ""

If IsInCallStack("U_KP97B08") //cancelamento
		cSql += " UPDATE " + RetSqlName("SC5") "
		cSql += " SET C5_FLAGSP5 = ''"
		cSql += " WHERE D_E_L_E_T_ <> '*' "
		cSql += " AND C5_FLAGSP5 	= '"+cMark+"'"
	Else //Alteracao
		cSql += " UPDATE " + RetSqlName("SC5") "
		cSql += " SET C5_FLAGSP6 = '' "
		cSql += " WHERE D_E_L_E_T_ <> '*' "
		cSql += " AND C5_FLAGSP6 	= '"+cMark+"'"
EndIf



If TcSqlExec(cSql) < 0
	Help( ,, 'Clear',, 'Não é possível limpar os registros!!!', 1, 0 )
	Conout("Nao limpouuu")
EndIf

Return(.T.)

//Atualiza o status
Static Function XANREGA()
Local aAreaZ2	:= ZS7->(GetArea())
Local cCmpObA	:= "ZS7_CODSOL/ZS7_CGCCLI/ZS7_CODPVC/ZS7_TPTRAN/ZS7_VLRPVS/ZS7_QTDPAR/ZS7_DIASPV/ZS7_CONDIC/ZS7_TXCLIE/ZS7_TXAPAR/ZS7_TXADMP/ZS7_FORRPA/ZS7_PRAZOR/"
Local lStatusL	:= .T.
Local cCmp		:= ""


If lStatusL //Valida campos obrigatorios normais
	// faz o loop sobre os campos
	For nI := 1 to ZS7->(FCount())
		If Alltrim(Field(nI)) $ cCmpObA
			
			cCmp	:= "ZS7->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS7->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS7")
	RecLock("ZS7",.F.)
	If lStatusL //Atualiza o status da linha
			ZS7->ZS7_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS7->ZS7_STATUS := "1"
	EndIf
	ZS7->(MsUnlock())
EndIf

//Valida campos obrigatorios em caso de historico de compras
/*
If lStatusL .And. Alltrim(ZS7->ZS7_HISTCP) == "S" 
	// faz o loop sobre os campos
	For nI := 1 to ZS7->(FCount())
		If Alltrim(Field(nI)) $ cCmpObB //Campos obrigatorios em caso de movimentos
			
			cCmp	:= "ZS7->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS7->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS7")
	RecLock("ZS7",.F.)
	If lStatusL //Atualiza o status da linha
			ZS7->ZS7_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS7->ZS7_STATUS := "1"
	EndIf
	ZS7->(MsUnlock())
EndIf
*/	
RestArea(aAreaZ2)
Return()

//Valida se o cliente pertence a Supplier
Static Function ValCliSPP()
Local lRet	:= .T.
Local cQr 		:= ""
Local cAliasEA	:= GetNextAlias()
Local nRegs		:= 0
Local cMarkKP	:= oMark:Mark()

If Select("cAliasEA")<>0
	DbSelectArea("cAliasEA")
	DbCloseArea()
EndIf


cQr += " SELECT	DISTINCT SA1.A1_COD,SA1.A1_LOJA
cQr += " FROM "+ RetSqlName("SC5") +" SC5 WITH (NOLOCK) 
cQr += " INNER JOIN "+ RetSqlName("SA1") +" SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '' AND SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = '' AND SA1.A1_FLAGSPC = 'S'
cQr += " WHERE SC5.D_E_L_E_T_ = '' 
If IsInCallStack("U_KP97B08")
		cQr += "	AND SC5.C5_FLAGSP5 = '"+cMarkKP+"' "+cCRLF
	Else
		cQr += "	AND SC5.C5_FLAGSP6 = '"+cMarkKP+"' "+cCRLF
EndIf

// abre a query
TcQuery cQr new alias "cAliasEA"

DbSelectArea("cAliasEA")
cAliasEA->(DbGoTop())

If cAliasEA->(EOF())
	lRet	:= .F.
	MsgInfo("Este cliente nao pertence a Supplier, favor verificar", "KAPAZI - PEDIDOS DE VENDAS SUPPLIER CARD")
EndIf

cAliasEA->(DbCloseArea())
Return(lRet)