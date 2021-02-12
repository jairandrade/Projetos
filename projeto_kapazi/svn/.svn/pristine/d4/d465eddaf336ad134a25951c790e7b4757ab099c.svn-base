#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
#Include "tbiconn.ch"
//==================================================================================================//
//	Programa: M410STTS	|	Autor: Luis Paulo								|	Data: 02/01/2018	//
//==================================================================================================//
//	Descrição: Este PE Está em todas as rotinas de alteração, inclusão, exclusão e devolução de 	//
// compras. Executado após todas as alterações no arquivo de pedidos terem sido feitas.				//
//																									//
//==================================================================================================//
//Criar o indice XIDNFSE na SC5
/*
Serve também para movimentar a atividade no Fluig.
@author Reinaldo Santos
@since 13/04/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
User Function M410STTS()
	Local aArea			:= GetArea()
	Local lContinua		:= .F.
	Local aCabPed		:= {}
	Local aLinhaPed		:= {}
	Local aItensPed		:= {}
	Local lAtvNFM		:= GetMV("KP_ATVNFM",.F.,.F.) //GetMV( <cValor>, <lConsulta>, <xDefault> ) GetMv("KP_ATVNFM") //Verifica se a NF mista esta ativa
	// ativa a rotina que blqoueia a venda de produto no app caso não tenha saldo em estoque
	Local lBlqProdApp	:= GetMV("KP_BLQPRAP",,.F.)
	Local lRet 			:= .T.
	Local nOper			:= PARAMIXB[1]

	Private cAliasPV
	Private lIncPNF		:= .F.
	Private lMsErroAuto	:= .F.

	If IsInCallStack("A410Inclui") .or. IsInCallStack("A410PCopia")

		If SC5->( FieldPos("C5_XJUSTIF")) > 0
			RecLock("SC5",.F.)
			SC5->C5_XJUSTIF := ""
			MsUnLock("SC5")
		Endif

		If ExistBlock("KFATR15")
			U_KFATR15("01",SC5->C5_NUM)
		Endif
	Endif

	/* Processo Fluig */
	//Verifica se é inclusão e foi chamado pela tela de orçamentos
	If  ISINCALLSTACK('MATA416') .and. IsInCallStack("A410Inclui")
		DBSelectArea('SCJ') //Orçamento
		SCJ->(DBSetOrder(1))//CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA
		SCJ->(DbSeek(xFilial("SCJ") + SUBSTR(SC6->C6_NUMORC,1,TamSX3('CJ_NUM')[1])))
		If !Empty(SCJ->CJ_XNUMFLU)
			Reclock('ZA1',.T.)
				ZA1->ZA1_FILIAL:=xFilial('ZA1')
				ZA1->ZA1_TIPO  :='PEDIDO'
				ZA1->ZA1_NUM   :=SC5->C5_NUM
				ZA1->ZA1_STATUS:='1' //Aguardando
				ZA1->ZA1_DTCRIA:=Date()
				ZA1->ZA1_HRCRIA:=Time()
			MsUnlock()

			//Inicia o JOB que irá integrar com o Fluig
			//Dessa forma, libera o APP mais rapidamente e evita o  TimeOut
			//u_ProcPed('PEDIDO', SC5->C5_NUM)
			StartJob('U_KAPJOB',GetEnvServer(),.F., 'PEDIDO', SC5->C5_NUM, CEMPANT, CFILANT)
		endif
	EndIf

	/* Processo Fluig */
	If !IsInCallStack("MATA416") //Se não veio de orcamento
		If (IsInCallStack("A410Inclui") .OR. IsInCallStack("A410PCopia")) .And. !l410Auto .And. cEmpAnt == "04" .And. cFilAnt == "01" .And. SC5->C5_K_OPER == "01" //.And. SC5->C5_XGERASV == "S"
			lContinua		:= .T.

			If (IsInCallStack("A410Inclui") .OR. IsInCallStack("A410PCopia")) .And. !l410Auto .And. lAtvNFM
				RecLock("SC5",.F.)
					SC5->C5_XIDVNFK	:= SPACE(15)
				SC5->(MsUnlock())
			Endif

		EndIf
	EndIf

	If (IsInCallStack("A410Inclui") .OR. IsInCallStack("A410Altera") .OR. IsInCallStack("A410PCopia")) .And. !(IsInCallStack("MATA521A"))

		If IsInCallStack("A410Altera")
			U_GRVDTUS() //ROTINA PARA GRAVAR DATA E USUARIO
		EndIf

		//ROTINA PARA ENVIAR EMAIL DO PEDIDO DE VENDA POR EMAIL
		If UPPER((Alltrim(GetEnvServer()))) $ "KAPAZI\KAPAZI2\KAPAZI3\REST" .And. Alltrim(SC5->C5_XTIPONF) <> "2" //Somente ambientes de producao e diferente pedido de serviço
			U_EMAPDV()
		EndIf

	EndIf

	If cEmpAnt == '04' .And. IsInCallStack("A410Altera") .And. !IsInCallStack("MATA416") .And. !IsInCallStack("U_M410PVNF") .And. !(IsInCallStack("MATA521A"))
		If (SC5->C5_XPVSPC  == 'S') .And. Empty(SC5->C5_NOTA) .And. ((SC5->C5_XSTSSPP >= '2' .And. SC5->C5_XSTSSPP <= '5') .OR. SC5->C5_XSTSSPP == 'A')  .And. !IsInCallStack("U_M410PVNF")
			If !ValAltSP() //Verifica se tem envio do pedido para supplier e se o vlr é diferente
				AtvlrZS7() //Caso ja tenha sido enviado para uma pré apuracao,
				RecLock("SC5",.F.)
					SC5->C5_XSTSSPP	:= 'A'
				SC5->(MsUnlock())
			Else
				ValJaAlt() //Verifica se alguma alteracao já foi enviada para supplier e tem valor diferente
				AtvlrZS7() //Caso ja tenha sido enviado para uma pré apuracao,
			EndIf
		EndIf
	EndIf

	If cEmpAnt == '04' .And. IsInCallStack("A410Altera") .And. !IsInCallStack("MATA416") .And. !IsInCallStack("U_M410PVNF") .And. !(IsInCallStack("MATA521A"))
		If SC5->C5_XPVSPC  != 'S'
			VerSPVFS() //Valida se o pedido já foi supplier
		EndIf

		If SC5->C5_XPVSPC  == 'S'
			VerSPLim() //Valida se o pedido já foi supplier
		EndIf
	EndIf

	If IsInCallStack("A410Devol") .And. cEmpAnt == "04"//é uma devolucao
		//Faz o desbloqueio geral: Centro de custo, cliente e produto das devolucoes
		u_DesGeral(__cUserId,"MATA410")
	EndIf

	If lBlqProdApp .and. ExistBlock("KFATR24")
		U_KFATR24(SC5->C5_NUM,nOper)
	Endif
		
	RestArea(aArea)
Return()

//Valida a alteracao
Static Function ValAltSP()
	Local cQr 		:= ""

	If Select("cAliaZS3")<>0
		DbSelectArea("cAliaZS3")
		cAliaZS3->(DbCloseArea())
	Endif

	cQr += " SELECT ZS3.ZS3_RECSC5,SC5.R_E_C_N_O_,ZS3.ZS3_VALPV,SC5.C5_XTOTMER
	cQr += " FROM "+ RetSqlName("ZS3") +" ZS3
	cQr += " INNER JOIN "+ RetSqlName("SC5") +" SC5 ON ZS3.ZS3_RECSC5 = SC5.R_E_C_N_O_ AND SC5.D_E_L_E_T_ = '' AND ZS3.ZS3_VALPV <> SC5.C5_XTOTMER
	cQr += " WHERE ZS3.D_E_L_E_T_ = ''
	cQr += "		AND ZS3.ZS3_RECSC5 = "+cValtoChar((SC5->(RECNO())))+""

	// abre a query
	TcQuery cQr new alias "cAliaZS3"
	Count to nRegs

	DbSelectArea("cAliaZS3")
	cAliaZS3->(DbGoTop())

Return(cAliaZS3->(EOF()))

Static Function AtvlrZS7()
	Local cQry	:= ""

	cQry	:= " UPDATE ZS7040 SET ZS7_VLRPVS = "+ Alltrim(STR(SC5->C5_XTOTMER,12,2)) +" WHERE ZS7_RECSC5 = "+ cValTochar((SC5->(RECNO()))) +" AND D_E_L_E_T_ = '' AND ZS7_XIDINT = ''

	If TcSqlExec(cQry) < 0
		Conout("")
		MsgInfo("TCSQLError() " + TCSQLError())
		Conout("")
	EndIf

Return(.T.)

Static Function ValJaAlt()
	Local cQr 		:= ""

	If Select("cAliaZS7")<>0
		DbSelectArea("cAliaZS7")
		cAliaZS7->(DbCloseArea())
	Endif

	cQr += " SELECT TOP 1 ZS7.ZS7_RECSC5,SC5.R_E_C_N_O_,ZS7.ZS7_VLRPVS,SC5.C5_XTOTMER
	cQr += " FROM "+ RetSqlName("ZS7") +" ZS7
	cQr += " INNER JOIN "+ RetSqlName("SC5") +" SC5 ON ZS7.ZS7_RECSC5 = SC5.R_E_C_N_O_ AND SC5.D_E_L_E_T_ = ''
	cQr += " WHERE ZS7.D_E_L_E_T_ = ''
	cQr += "		AND ZS7.ZS7_RECSC5 = "+cValtoChar((SC5->(RECNO())))+""
	cQr += " ORDER BY ZS7.R_E_C_N_O_ DESC"

	// abre a query
	TcQuery cQr new alias "cAliaZS7"

	DbSelectArea("cAliaZS7")
	cAliaZS7->(DbGoTop())

	If cAliaZS7->ZS7_VLRPVS != cAliaZS7->C5_XTOTMER
		RecLock("SC5",.F.)
		SC5->C5_XSTSSPP	:= 'A'
		SC5->(MsUnlock())
	EndIf

Return()

//Funcao para verificar
Static Function VerSPVFS()
	Local cQry := ""
	Local cSeq := ""
	Local nNew := 0

	cQry:=" SELECT  TOP 1 ZCL_FILINC,ZCL_PEDIDO,ZCL_SEQ,ZCL_VALOR,ZCL_RECSC5,ZCL_CDUSER,ZCL_NMUSER,ZCL_DTALT,ZCL_HRALT,ZCL_OFF,R_E_C_N_O_ AS RECOZCL FROM "+ RETSQLNAME('ZCL')
	cQry+=" WHERE D_E_L_E_T_<>'*'"
	cQry+=" AND ZCL_PEDIDO = '"+ SC5->C5_NUM +"'"
	cQry+=" AND ZCL_FILINC = '"+ xFilial("SC5") +"'"
	cQry+=" ORDER BY ZCL_SEQ DESC"

	IF Select('TRZCL')<>0
		TRZCL->(DBCloseArea())
	EndIF

	TcQuery cQry New Alias 'TRZCL'

	If !TRZCL->(EOF()) .And. TRZCL->ZCL_OFF <> 'X'

		DbSelectArea("ZCL")
		Reclock("ZCL",.T.)
			ZCL->ZCL_FILINC	:= xFilial("SC5")
			ZCL->ZCL_PEDIDO	:= SC5->C5_NUM
			ZCL->ZCL_SEQ	:= PegaSeq()
			ZCL->ZCL_VALOR	:= SC5->C5_XTOTMER
			ZCL->ZCL_RECSC5	:= SC5->(RECNO())
			ZCL->ZCL_CDUSER	:= __cUserId
			ZCL->ZCL_NMUSER	:= UsrFullName(__cUserID)
			ZCL->ZCL_DTALT	:= Date()
			ZCL->ZCL_HRALT	:= Time()
			ZCL->ZCL_OFF `	:= "X"
		ZCL->(MsUnLock())

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbGoTOp())
		If SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

			nNew := SA1->A1_SALPEDL + TRZCL->ZCL_VALOR

			RecLock("SA1",.F.)
			SA1->A1_SALPEDL := nNew
			SA1->(MsUnlock())
		EndIf

	EndIf

	TRZCL->(DBCloseArea())
Return()

//Pega o proximo sequencial
Static Function PegaSeq()
	Local cQry := ""
	Local cSeq := ""

	cQry:=" SELECT  TOP 1 ZCL_SEQ FROM "+ RETSQLNAME('ZCL')
	cQry+=" WHERE D_E_L_E_T_<>'*'"
	cQry+=" AND ZCL_PEDIDO = '"+ SC5->C5_NUM +"'"
	cQry+=" AND ZCL_FILINC = '"+ xFilial("SC5") +"'"
	cQry+=" ORDER BY ZCL_SEQ DESC"

	IF Select('TRZCLS')<>0
		TRZCLS->(DBCloseArea())
	EndIF

	TcQuery cQry New Alias 'TRZCLS'

	If TRZCLS->(eof())
		cSeq := '001'
	Else
		cSeq := Soma1(TRZCLS->ZCL_SEQ)
	EndIf

	TRZCLS->(DBCloseArea())
Return(cSeq)

//Ajusta o limite de acordo com alguma liberacao anterior
Static Function VerSPLim()
	Local cQry 	:= ""
	Local cSeq 	:= ""
	Local nNew 	:= 0
	Local nValPV := 0

	cQry:=" SELECT  TOP 1 ZCL_FILINC,ZCL_PEDIDO,ZCL_SEQ,ZCL_VALOR,ZCL_RECSC5,ZCL_CDUSER,ZCL_NMUSER,ZCL_DTALT,ZCL_HRALT,ZCL_OFF,R_E_C_N_O_ AS RECOZCL
	cQry+=" FROM "+ RETSQLNAME('ZCL')
	cQry+=" WHERE D_E_L_E_T_<>'*'"
	cQry+=" AND ZCL_PEDIDO = '"+ SC5->C5_NUM +"'"
	cQry+=" AND ZCL_FILINC = '"+ xFilial("SC5") +"'"
	cQry+=" ORDER BY ZCL_SEQ DESC"

	IF Select('TRZCL')<>0
		TRZCL->(DBCloseArea())
	EndIF

	TcQuery cQry New Alias 'TRZCL'

	If !TRZCL->(EOF()) .And. TRZCL->ZCL_OFF <> 'X'

		nValPV := TRZCL->ZCL_VALOR

		DbSelectArea("ZCL")
		Reclock("ZCL",.T.)
			ZCL->ZCL_FILINC	:= xFilial("SC5")
			ZCL->ZCL_PEDIDO	:= SC5->C5_NUM
			ZCL->ZCL_SEQ	:= PegaSeq()
			ZCL->ZCL_VALOR	:= SC5->C5_XTOTMER
			ZCL->ZCL_RECSC5	:= SC5->(RECNO())
			ZCL->ZCL_CDUSER	:= __cUserId
			ZCL->ZCL_NMUSER	:= UsrFullName(__cUserID)
			ZCL->ZCL_DTALT	:= Date()
			ZCL->ZCL_HRALT	:= Time()
			ZCL->ZCL_OFF 	:= "X"
		ZCL->(MsUnLock())

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbGoTOp())
		If SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

			nNew := nValPV + SA1->A1_SALPEDL

			RecLock("SA1",.F.)
				SA1->A1_SALPEDL := nNew
			SA1->(MsUnlock())
		EndIf
	EndIf

	TRZCL->(DBCloseArea())

Return()
