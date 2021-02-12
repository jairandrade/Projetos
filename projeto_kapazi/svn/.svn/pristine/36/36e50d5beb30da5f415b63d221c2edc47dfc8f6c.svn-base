#include "tbiconn.ch"
#include "TbiCode.ch"
#Include 'ap5mail.ch'
#include "TopConn.ch"
#include "Totvs.ch"
//==================================================================================================//
//	Programa: KP97A11		|	Autor: Luis Paulo							|	Data: 02/09/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por integrar PV Ren Pre autorizacao								//
//																									//
//==================================================================================================//
User Function KP97A11()
Local lRet		:= .T.
Local cMark		:= oMark:Mark()
Private nNLim	:= 0

If ValCliSe() 			//Valida se tem itens selecionados
	If ValClIMU() 		//Verifica se tem mais de uma raiz de CNPJ selecionada
		Processa({||ApuraPDV()} ,"Processando pedidos de vendas","Aguarde...")  
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
cQr += "	AND	C5_FLAGSP4 = '"+cMarkKP+"'

// abre a query
TcQuery cQr new alias "cAliaSC5"
Count To nRegs

If nRegs == 0
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
cQr += "	AND	SC5.C5_FLAGSP4 = '"+cMarkKP+"'
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

If Select("cAliaSC5")<>0
	DbSelectArea("cAliaSC5")
	cAliaSC5->(DbCloseArea())
Endif

cQr += " SELECT	SC5.R_E_C_N_O_ AS RECOC5,*"+cCRLF
cQr += " FROM "+ RetSqlName("SC5")+" SC5 WITH (NOLOCK) "+cCRLF
cQr += " LEFT JOIN SA1010 SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '' AND SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = '' "+cCRLF
cQr += " WHERE SC5.D_E_L_E_T_ = '' "+cCRLF
cQr += "	AND SC5.C5_FLAGSP4 = '"+cMarkKP+"' "+cCRLF

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
	
	If !(cAliaSC5->C5_XSTSSPP == "1") //C5_FLENVSP - Enviado para supplier
			//C5_FLRECSU - Processado e em posse de supplier
	
			cID		:= SUBSTR(cAliaSC5->A1_COD,1,4) +cEmpAnt + cAliaSC5->C5_FILIAL + cAliaSC5->C5_NUM //Definir depois o formato de parcelas
			
			cItem	:= GETSXENUM("ZS5","ZS5_ITEM")
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
			
			DbSelectArea("ZS5")
			ZS5->(DbSetOrder(3))
			ZS5->(DbGoTop())
			If ZS5->(DbSeek(xFilial("ZS5") + Space(15) + cID) ) //Valida se o registro já foi para tabela de integracao
					RecLock("ZS5",.F.)
					Conout("Registro Duplicado->"+cID)
				Else
					RecLock("ZS5",.T.)
			EndIf	
			ZS5->ZS5_FILIAL	:= ""
			ZS5->ZS5_FILORI	:= cEmpAnt+cAliaSC5->C5_FILIAL
			ZS5->ZS5_ITEM	:= cItem
			ZS5->ZS5_STATUS	:= "1"
			ZS5->ZS5_XIDINT	:= ""
			ZS5->ZS5_DATAIN := Date()
			ZS5->ZS5_HORAII	:= Time()
			ZS5->ZS5_NMARQ	:= ""
			ZS5->ZS5_CODSO	:= "16"
			ZS5->ZS5_CGC	:= cAliaSC5->A1_CGC
			ZS5->ZS5_TIPOTR	:= "0" 			//Tipo de transacao - Preencher com o código descrito no item 8 do MAPA DE PARÂMETROS
			ZS5->ZS5_CODPV	:= cID	
			ZS5->ZS5_VLRPAU	:= cAliaSC5->C5_XTOTMER
			ZS5->ZS5_RECSC5	:= cAliaSC5->RECOC5
			ZS5->(MsUnlock())
			XANREGA()
		Else
			MsgInfo("Pedido ja enviado com a pre-autorizacao -> " + cAliaSC5->C5_FILIAL + "-" +cAliaSC5->C5_NUM,"KAPAZI - PRE AUTORIZACAO SUPPLIER")
			Conout("Pedido ja enviado com a pre-autorizacao -> " + cAliaSC5->C5_FILIAL + "-" +cAliaSC5->C5_NUM)
	EndIf
	cAliaSC5->(DbSkip())
EndDo

cAliaSC5->(DbCloseArea())
Return()

/*
+--------------------------------------------------------------------------+
! Função    ! ClearOk    ! Autor !                    ! Data ! 30/09/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Limpa o campo C5_FLAGSP4.                                         !
+-----------+--------------------------------------------------------------+
*/
Static Function ClearOK(cMark)
Local cSql := ""

cSql += " UPDATE " + RetSqlName("SC5") "
cSql += " SET C5_FLAGSP4 = ''"
cSql += " WHERE D_E_L_E_T_ <> '*' "
cSql += " AND C5_FLAGSP4 	= '"+cMark+"'"

If TcSqlExec(cSql) < 0
	Help( ,, 'Clear',, 'Não é possível limpar os registros!!!', 1, 0 )
	Conout("Nao limpouuu")
EndIf

Return(.T.)

//Atualiza o status
Static Function XANREGA()
Local aAreaZ2	:= ZS5->(GetArea())
Local cCmpObA	:= "ZS5_CODSO/ZS5_CGC/ZS5_TIPOTR/ZS5_CODPV/ZS5_VLRPAU"
//Local cCmpObB	:= "ZS5_DTFAT/ZS5_VLRTOT/ZS5_VENCPA/ZS5_VLRPAC/" //ZS5_DTPPAR/ZS5_VPPARC"
Local lStatusL	:= .T.
Local cCmp		:= ""

If lStatusL //Valida campos obrigatorios normais
	// faz o loop sobre os campos
	For nI := 1 to ZS5->(FCount())
		If Alltrim(Field(nI)) $ cCmpObA
			
			cCmp	:= "ZS5->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS5->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS5")
	RecLock("ZS5",.F.)
	If lStatusL //Atualiza o status da linha
			ZS5->ZS5_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS5->ZS5_STATUS := "1"
	EndIf
	ZS5->(MsUnlock())
EndIf

//Valida campos obrigatorios em caso de historico de compras
/*
If lStatusL .And. Alltrim(ZS5->ZS5_HISTCP) == "S" 
	// faz o loop sobre os campos
	For nI := 1 to ZS5->(FCount())
		If Alltrim(Field(nI)) $ cCmpObB //Campos obrigatorios em caso de movimentos
			
			cCmp	:= "ZS5->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS5->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS5")
	RecLock("ZS5",.F.)
	If lStatusL //Atualiza o status da linha
			ZS5->ZS5_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS5->ZS5_STATUS := "1"
	EndIf
	ZS5->(MsUnlock())
EndIf
*/	
RestArea(aAreaZ2)
Return()