#include "tbiconn.ch"
#include "TbiCode.ch"
#Include 'ap5mail.ch'
#include "TopConn.ch"
#include "Totvs.ch"
//==================================================================================================//
//	Programa: KP97A13		|	Autor: Luis Paulo							|	Data: 19/09/2018	//
//==================================================================================================//
//	Descrição: Funcao responsavel por integrar NF JÁ AUTORIZADOS pela Supplier						//
//																									//
//==================================================================================================//
User Function KP97A13()
Local lRet		:= .T.
Local cMark		:= oMark:Mark()
Private nNLim	:= 0

If ValCliSe() 			//Valida se tem itens selecionados
	If ValClIMU() 		//Verifica se tem mais de uma raiz de CNPJ selecionada
		Processa({||ApuraNF()} ,"Processando NF","Aguarde...")  
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
Local cAliaSF2	:= GetNextAlias()

If Select("cAliaSF2")<>0
	DbSelectArea("cAliaSF2")
	DbCloseArea()
Endif

cQr := " SELECT *
cQr += " FROM "+ RetSqlName("SF2") +" "
cQr += " WHERE D_E_L_E_T_ = ''
cQr += "	AND	F2_MARKSP = '"+cMarkKP+"'

// abre a query
TcQuery cQr New Alias "cAliaSF2"

DbSelectArea("cAliaSF2")
cAliaSF2->(DbGoTop())

If cAliaSF2->(EOF())
	lRet		:= .F.
	MsgInfo("Nenhum Registro selecionado!!!","KAPAZI - NF SUPPLIER")
EndIf

cAliaSF2->(DbCloseArea())
Return(lRet)

//Verifica se tem mais de uma raiz de CNPJ selecionada
Static Function ValClIMU()
Local cQr 		:= ""
Local cAliaSF2	:= GetNextAlias()
Local lRet		:= .T.
Local nRegs		:= 0
Local cMarkKP	:= oMark:Mark()

If Select("cAliaSF2")<>0
	DbSelectArea("cAliaSF2")
	DbCloseArea()
Endif

cQr += " SELECT DISTINCT SUBSTRING(SA1.A1_CGC,1,8) AS RAIZCNPJ
cQr += " FROM "+ RetSqlName("SF2") +" SF2 " 
cQr += " INNER JOIN "+ RetSqlName("SA1") +" SA1 ON SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ''
cQr += " WHERE SF2.D_E_L_E_T_ = ''
cQr += "	AND	SF2.F2_MARKSP = '"+cMarkKP+"'
cQr += " ORDER BY RAIZCNPJ

// abre a query
TcQuery cQr new alias "cAliaSF2"
Count To nRegs

If nRegs > 1
	//MsgInfo("Existe mais de uma Raiz de CNPJ selecionada, Deseja continuar???","KAPAZI - NF SUPPLIER")
	//lRet	:= .F.
EndIf

cAliaSF2->(DbCloseArea())
Return(lRet)


Static Function ApuraNF()
Local cQr 		:= ""
Local cAliaSF2	:= GetNextAlias()
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

If Select("cAliaSF2")<>0
	DbSelectArea("cAliaSF2")
	cAliaSF2->(DbCloseArea())
Endif

cQr += " SELECT	SF2.R_E_C_N_O_ AS RECOF2,SC5.R_E_C_N_O_ AS RECOC5,SC5.C5_NUM,(SELECT TOP 1 C5_NUM FROM SC5040 WHERE D_E_L_E_T_ = '' AND C5_XIDVNFK = SC5.C5_XIDVNFK AND C5_XTIPONF = '1') AS PEDIDO,* "+cCRLF
cQr += " FROM "+ RetSqlName("SF2")+" SF2 WITH (NOLOCK) "+cCRLF
cQr += " INNER JOIN SA1010 SA1 WITH (NOLOCK) ON SA1.A1_FILIAL = '' AND SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = '' "+cCRLF
cQr += " INNER JOIN "+ RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON SF2.F2_FILIAL = SC5.C5_FILIAL AND SC5.C5_NOTA = SF2.F2_DOC AND SF2.F2_SERIE = SC5.C5_SERIE AND SC5.D_E_L_E_T_ = '' "+cCRLF
cQr += " WHERE SF2.D_E_L_E_T_ = '' "+cCRLF
cQr += "	AND SF2.F2_MARKSP = '"+cMarkKP+"' "+cCRLF

Conout(cQr)

// abre a query
TcQuery cQr new alias "cAliaSF2"
Count to nRegs

DbSelectArea("cAliaSF2")
cAliaSF2->(DbGoTop())

ProcRegua(nRegs)
While !cAliaSF2->(EOF())
	
	nCount++
	IncProc('Processando.....  ' + Alltrim(Str(nCount)) + " de " + Alltrim(Str(Int(nRegs))) )
	
	If !(cAliaSF2->F2_XSTSSPP == "S") //F2_FLENVSP - Enviado para supplier
			
			If Empty(cAliaSF2->F2_XIDVNFK)
					cID		:= SUBSTR(cAliaSF2->A1_COD,1,4) +cEmpAnt + cAliaSF2->F2_FILIAL + cAliaSF2->C5_NUM //Definir depois o formato de parcelas
				Else
					cID		:= SUBSTR(cAliaSF2->A1_COD,1,4) +cEmpAnt + cAliaSF2->F2_FILIAL + cAliaSF2->PEDIDO
			EndIf
			
			cItem	:= GETSXENUM("ZS6","ZS6_ITEM")
			ConfirmSx8()
			
			DbSelectArea("ZS6")
			ZS6->(DbSetOrder(6))
			ZS6->(DbGoTop())
			If ZS6->(DbSeek(xFilial("ZS6") + Space(15) + cID + cValTochar(cAliaSF2->RECOC5) ) ) //Valida se o registro já foi para tabela de integracao
					RecLock("ZS6",.F.)
					Conout("Registro Duplicado->"+cID)
				Else
					RecLock("ZS6",.T.)
			EndIf
			
			
			ZS6->ZS6_FILIAL	:= ""
			ZS6->ZS6_FILORI	:= cEmpAnt+cAliaSF2->F2_FILIAL
			ZS6->ZS6_ITEM	:= cItem
			ZS6->ZS6_STATUS	:= "1"
			ZS6->ZS6_XIDINT	:= ""
			ZS6->ZS6_DATAIN := Date()
			ZS6->ZS6_HORAII	:= Time()
			ZS6->ZS6_NMARQI	:= ""
			ZS6->ZS6_CODSOL	:= "16"
			ZS6->ZS6_CGC	:= cAliaSF2->A1_CGC
			ZS6->ZS6_TPTRAN	:= "0" 			//Tipo de transacao - Preencher com o código descrito no item 8 do MAPA DE PARÂMETROS
			ZS6->ZS6_CODPVS	:= cID	
			ZS6->ZS6_CODPAU	:= cAliaSF2->C5_XCODPAU
			ZS6->ZS6_VLRFAT	:= cAliaSF2->F2_VALBRUT
			ZS6->ZS6_NOTAF	:= cAliaSF2->F2_DOC
			ZS6->ZS6_RECSF2	:= cAliaSF2->RECOF2
			ZS6->ZS6_RECSC5	:= cAliaSF2->RECOC5
			ZS6->(MsUnlock())
			XANREGA()
		Else
			MsgInfo("NF ja enviado com a pre-autorizacao -> " + cAliaSF2->F2_FILIAL + "-" +cAliaSF2->F2_DOC,"KAPAZI - NF SUPPLIER")
			Conout("NF ja enviado com a pre-autorizacao -> " + cAliaSF2->F2_FILIAL + "-" +cAliaSF2->F2_DOC)
	EndIf
	cAliaSF2->(DbSkip())
EndDo

cAliaSF2->(DbCloseArea())
Return()

/*
+--------------------------------------------------------------------------+
! Função    ! ClearOk    ! Autor !                    ! Data ! 30/09/2017  !
+-----------+------------+-------+--------------------+------+-------------+
! Descricao ! Limpa o campo F2_XPVSPP.                                         !
+-----------+--------------------------------------------------------------+
*/
Static Function ClearOK(cMark)
Local cSql := ""

cSql += " UPDATE " + RetSqlName("SF2") "
cSql += " SET F2_MARKSP = ''"
cSql += " WHERE D_E_L_E_T_ <> '*' "
cSql += " AND F2_MARKSP 	= '"+cMark+"'"

If TcSqlExec(cSql) < 0
	Help( ,, 'Clear',, 'Não é possível limpar os registros!!!', 1, 0 )
	Conout("Nao limpouuu")
EndIf

Return(.T.)

//Atualiza o status
Static Function XANREGA()
Local aAreaZ2	:= ZS6->(GetArea())
Local cCmpObA	:= "ZS6_CODSOL/ZS6_CGC/ZS6_TPTRAN/ZS6_CODPVS/ZS6_CODPAU/ZS6_NOTAF"
Local lStatusL	:= .T.
Local cCmp		:= ""

If lStatusL //Valida campos obrigatorios normais
	// faz o loop sobre os campos
	For nI := 1 to ZS6->(FCount())
		If Alltrim(Field(nI)) $ cCmpObA
			
			cCmp	:= "ZS6->" +(Field(nI))
			cCmp	:= &(cCmp)
			
			If	Empty(cCmp) //"ZS6->" +(Field(nI))
				lStatusL	:= .F.
				Exit	
			EndIf
			
		EndIf
	Next nI
	
	DbSelectArea("ZS6")
	RecLock("ZS6",.F.)
	If lStatusL //Atualiza o status da linha
			ZS6->ZS6_STATUS := "2"
		Else
			lStatusG	:= .F.
			ZS6->ZS6_STATUS := "1"
	EndIf
	ZS6->(MsUnlock())
EndIf

RestArea(aAreaZ2)
Return()