#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: DesGeral		|	Autor: Luis Paulo							|	Data: 14/11/2019	//
//==================================================================================================//
//	Descrição: Rotina para bloqueios das entidades após confirmar ou cancela						//
//                                                                                                  //
//==================================================================================================//
User Function DesGeral(cIdUser,cRotina)
// variaveis auxiliares
Local cQr := ""
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaCTT	:= CTT->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())

// recupera os dados dos bloqueios
cQr := " SELECT R_E_C_N_O_ AS RECORECO,*
cQr += " FROM ZBL040
cQr += " WHERE D_E_L_E_T_ = ''
cQr += " AND ZBL_IDUSER = '"+ cIdUser +"'
cQr += " AND ZBL_FILIAL = '"+ xFilial("SF1") +"'
cQr += " AND ZBL_ROTINA	= '"+cRotina+"' "

// abre a query
TcQuery cQr new alias "QZBL"

While !QZBL->(Eof())
	
	//Valida e desbloqueia centro de custo
	If Alltrim(QZBL->ZBL_PROCES) == 'CTT'
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
		
	EndIf
	
	//Valida e desbloqueia produto
	If Alltrim(QZBL->ZBL_PROCES) == 'SB1'
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
	
	
	////Valida e desbloqueia fornecedor
	If Alltrim(QZBL->ZBL_PROCES) == 'SA2'
		// localiza o fornecedor
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		SA2->(DbGoTop())
		If SA2->(DbSeek(XFilial("SA2") + QZBL->ZBL_CLIENT + QZBL->ZBL_LOJA))
	
			//bloqueia o cliente
			RecLock("SA2", .F.)
			SA2->A2_MSBLQL := "1"
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

RestArea(aAreaSB1)
RestArea(aAreaSA2)
RestArea(aAreaCTT)
RestArea(aAreaSA1)
RestArea(aArea)
Return()