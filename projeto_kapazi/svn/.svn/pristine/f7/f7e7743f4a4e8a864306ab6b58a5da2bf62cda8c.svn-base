#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: MT103CAN		|	Autor: Luis Paulo							|	Data: 17/10/2019	//
//==================================================================================================//
//	Descrição: Este Ponto de Entrada tem por objetivo verificar se o usuário clicou no botão 		//
//	Cancelar no Documento de Entrada.																//
//																									//
//==================================================================================================//
User Function MT103CAN()
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaCTT	:= CTT->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local lFlagDev	:= SuperGetMv("MV_FLAGDEV",.F.,.F.) 
Local lAtvDesb	:= SuperGetMv("KP_DESBDEV",.F.,.T.)
//Local aParam	:= PARAMIXB[1]	//ExecBlock("MT103CAN",.F.,.F.)

If !lFlagDev .And. lAtvDesb .And. cEmpAnt == "04"//Nao tem flag de retorno
	If IsInCallStack("SA103Devol") //é uma devolucao
		//Volta bloqueios
		_aATItDV	:= {} //Zera variavel
		
		/*
		//Volta o bloqueio Clientes 
		xDesbCli(__cUserId)
		
		//Volta os bloqueios dos produtos
		xDesbPro(__cUserId)
		
		//Volta os bloqueios dos centros de custos
		xDesbCTT(__cUserId)
		
		//xDesGeral(__cUserId)
		*/
		//Faz o desbloqueio geral: Centro de custo, cliente e produto
		u_DesGeral(__cUserId,"MATA103")
		
	EndIf	 
EndIf	

RestArea(aAreaSB1)
RestArea(aAreaSA2)
RestArea(aAreaCTT)
RestArea(aAreaSA1)
RestArea(aArea)
Return()

/*
//Faz o desbloqueio geral das entidades 
Static Function xDesGeral(cIdUser)
// variaveis auxiliares
local cQr := ""
local aArea := GetArea()

// recupera os dados dos bloqueios
cQr := " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM ZBL040
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZBL_IDUSER = '"+ cIdUser +"'
cQr += " AND ZBL_FILIAL = '"+ xFilial("SF1") +"'
cQr += " AND ZBL_ROTINA	= 'MATA103' "

// abre a query
TcQuery cQr new alias "QZBL"

While !QZBL->(Eof())
	
	//Valida e desbloqueia centro de custo
	If Alltrim(QZBL->ZBL_PROCES) == 'CTT'
		//localiza o centro de custo
		DbSelectArea("CTT")
		CTT->(DbSetOrder(1)) //CTT_FILIAL, CTT_CUSTO, R_E_C_N_O_, D_E_L_E_T_
		CTT->(DbGoTop())
		If CTT->(DbSeek(xFilial("CTT") + QZBL->ZBL_CCUSTO))
	
			//bloqueia o centro de custo
			RecLock("CTT", .F.)
			CTT->CTT_BLOQ := "1"
			MsUnlock()
			
			DbSelectArea("ZBL")
			ZBL->(DbGoTo(QZBL->RECORECO))
			RecLock("ZBL",.F.)
			DbDelete()
			ZBL->(MsUnlock())
		EndIf
		
	EndIf
	
	//Valida e desbloqueia produto
	If Alltrim(QZBL->ZBL_PROCES) == 'SB1'
		// localiza o cliente
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbGoTop())
		If SB1->(DbSeek(XFilial("SB1") + QZBL->ZBL_COD))
	
			//bloqueia o produto
			RecLock("SB1", .F.)
			SB1->B1_MSBLQL := "1"
			MsUnlock()
			
			DbSelectArea("ZBL")
			ZBL->(DbGoTo(QZBL->RECORECO))
			RecLock("ZBL",.F.)
			DbDelete()
			ZBL->(MsUnlock())
		EndIf
	EndIf
	
	////Valida e desbloqueia cliente
	If Alltrim(QZBL->ZBL_PROCES) == 'SA1'
		// localiza o cliente
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())
		If SA1->(DbSeek(XFilial("SA1") + QZBL->ZBL_CLIENT + QZBL->ZBL_LOJA))
	
			//bloqueia o cliente
			RecLock("SA1", .F.)
			SA1->A1_MSBLQL := "1"
			MsUnlock()
			
			DbSelectArea("ZBL")
			ZBL->(DbGoTo(QZBL->RECORECO))
			RecLock("ZBL",.F.)
			DbDelete()
			ZBL->(MsUnlock())
		EndIf
	EndIf
	
	// proximo registro
	QZBL->(DbSkip())

EndDo

QZBL->(DbCloseArea())
RestArea(aArea)

Return()

//Funcao responsavel por bloqueio novamente o centro de custo
Static Function xDesbCTT(cIdUser)

// variaveis auxiliares
local cQr := ""
local aArea := GetArea()

// recupera os dados dos bloqueios
cQr := " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM ZBL040
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZBL_IDUSER = '"+ cIdUser +"'
cQr += " AND ZBL_FILIAL = '"+ xFilial("SF1") +"'
cQr += " AND ZBL_PROCES = 'CTT'

// abre a query
TcQuery cQr new alias "QZBL"

While !QZBL->(Eof())

	//localiza o cliente
	DbSelectArea("CTT")
	CTT->(DbSetOrder(1)) //CTT_FILIAL, CTT_CUSTO, R_E_C_N_O_, D_E_L_E_T_
	CTT->(DbGoTop())
	If CTT->(DbSeek(xFilial("CTT") + QZBL->ZBL_CCUSTO))

		//bloqueia o centro de custo
		RecLock("CTT", .F.)
		CTT->CTT_BLOQ := "1"
		MsUnlock()
		
		DbSelectArea("ZBL")
		ZBL->(DbGoTo(QZBL->RECORECO))
		RecLock("ZBL",.F.)
		DbDelete()
		ZBL->(MsUnlock())
	EndIf

	// proximo registro
	QZBL->(DbSkip())

EndDo

QZBL->(DbCloseArea())
RestArea(aArea)
Return()


//Funcao responsavel por bloqueio novamente do cliente
Static Function xDesbCli(cIdUser)
// variaveis auxiliares
local cQr := ""
local aArea := GetArea()

// recupera os dados dos bloqueios
cQr := " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM ZBL040
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZBL_IDUSER = '"+ cIdUser +"'
cQr += " AND ZBL_FILIAL = '"+ xFilial("SF1") +"'
cQr += " AND ZBL_PROCES = 'SA1'

// abre a query
TcQuery cQr new alias "QZBL"

While !QZBL->(Eof())

	// localiza o cliente
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	If SA1->(DbSeek(XFilial("SA1") + QZBL->ZBL_CLIENT + QZBL->ZBL_LOJA))

		//bloqueia o cliente
		RecLock("SA1", .F.)
		SA1->A1_MSBLQL := "1"
		MsUnlock()
		
		DbSelectArea("ZBL")
		ZBL->(DbGoTo(QZBL->RECORECO))
		RecLock("ZBL",.F.)
		DbDelete()
		ZBL->(MsUnlock())
	EndIf

	// proximo registro
	QZBL->(DbSkip())

EndDo

QZBL->(DbCloseArea())
RestArea(aArea)
Return()

//Funcao responsavel por bloqueio dos produtos
Static Function xDesbPro(cIdUser)
// variaveis auxiliares
local cQr := ""
local aArea := GetArea()

// recupera os dados dos bloqueios
cQr := " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM ZBL040
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZBL_IDUSER = '"+ cIdUser +"'
cQr += " AND ZBL_FILIAL = '"+ xFilial("SF1") +"'
cQr += " AND ZBL_PROCES = 'SB1'

// abre a query
TcQuery cQr new alias "QZBL"

While !QZBL->(Eof())

	// localiza o cliente
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())
	If SB1->(DbSeek(XFilial("SB1") + QZBL->ZBL_COD))

		//bloqueia o cliente
		RecLock("SB1", .F.)
		SB1->B1_MSBLQL := "1"
		MsUnlock()
		
		DbSelectArea("ZBL")
		ZBL->(DbGoTo(QZBL->RECORECO))
		RecLock("ZBL",.F.)
		DbDelete()
		ZBL->(MsUnlock())
	EndIf

	// proximo registro
	QZBL->(DbSkip())

EndDo

QZBL->(DbCloseArea())
RestArea(aArea)
Return()
*/