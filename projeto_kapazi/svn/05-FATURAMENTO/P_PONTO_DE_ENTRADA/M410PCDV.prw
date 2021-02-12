#include 'protheus.ch'
#include 'parmtype.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#Include "topconn.ch"
//==================================================================================================//
//	Programa: M410PCDV		|	Autor: Luis Paulo							|	Data: 07/11/2019	//
//==================================================================================================//
//	Descrição: PE para desbloqueio das entidades envolvidas no retorno do PV						//
//																									//
//==================================================================================================//
//Este Pe valida caso selecionado fornecedor e é acionado em cada linha
User Function M410PCDV()
Local aArea			:= GetArea()
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaCTT		:= CTT->(GetArea())
Local aAreaSA2		:= SA2->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local lAtvDesb		:= SuperGetMv("KP_DESBDEV",.F.,.T.)
Local _cFornece		:= cFornece
Local _cLoja		:= cLoja
Private _dDataInc	:= Date()
Private _cHrInc		:= Time()
Private cAliasSD1	:= PARAMIXB[1] //Recebe o alias 

If IsInCallStack("A410Devol") .And. cEmpAnt == "04"//é uma devolucao
	
	If lAtvDesb //Se o processo de desbloqueio esta ativo
		If lForn //Se é fornecedor //Validar se usa cliente ou fornecedor	
				xDesblFor(_cFornece,_cLoja)
			Else //Cliente
				xDesblCli(_cFornece,_cLoja)
		EndIf
		
		xDesbCTT(_cFornece,_cLoja)	//Desbloqueia os centros de custos 
		xDesbPro(_cFornece,_cLoja) 	//Desbloqueia os produtos
	EndIf
	
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSA2)
RestArea(aAreaCTT)
RestArea(aAreaSA1)
RestArea(aArea)	
Return()

//Desbloqueia os produtos
Static Function xDesbPro(_cFornece,_cLoja)

DbSelectArea("SB1")
SB1->(DbSetOrder(1))
SB1->(DbGoTop())
If SB1->(DbSeek(xFilial("SB1") + (cAliasSD1)->D1_COD))
	If Alltrim(SB1->B1_MSBLQL) == '1'

		DbSelectArea("ZBL")
		Reclock("ZBL",.T.)
		ZBL->ZBL_FILIAL	:= xFilial("SC5")
		ZBL->ZBL_DOC	:= (cAliasSD1)->D1_DOC
		ZBL->ZBL_SERIE	:= (cAliasSD1)->D1_SERIE
		ZBL->ZBL_CLIENT	:= _cFornece
		ZBL->ZBL_LOJA	:= _cLoja
		ZBL->ZBL_ITEM	:= (cAliasSD1)->D1_ITEM
		ZBL->ZBL_COD	:= (cAliasSD1)->D1_COD
		ZBL->ZBL_PEDIDO	:= ""
		ZBL->ZBL_EMISSA	:= SF1->F1_EMISSAO //Pois esta posicionado
		ZBL->ZBL_CCUSTO	:= (cAliasSD1)->D1_CC
		ZBL->ZBL_PROCES	:= "SB1"
		ZBL->ZBL_IDUSER	:= __cUserId
		ZBL->ZBL_DSUSER	:= UsrFullName(__cUserID)
		ZBL->ZBL_XID	:= ""
		ZBL->ZBL_ROTINA	:= "MATA410"
		ZBL->ZBL_DTINC 	:= _dDataInc
		ZBL->ZBL_TIMEIN	:= _cHrInc
		ZBL->(MsUnlock())	

		//Efetua o desbloqueio
		DbSelectArea("SB1")
		Reclock("SB1",.F.)
		SB1->B1_MSBLQL := "2"
		SB1->(MsUnlock())
	EndIf
EndIf


Return()


//Desbloqueia os centros de custos
Static Function xDesbCTT(_cFornece,_cLoja) 

If !Empty((cAliasSD1)->D1_CC)

	DbSelectArea("CTT")
	CTT->(DbSetOrder(1)) //CTT_FILIAL, CTT_CUSTO, R_E_C_N_O_, D_E_L_E_T_
	CTT->(DbGoTop())
	If CTT->(DbSeek(xFilial("CTT") + (cAliasSD1)->D1_CC))
		
		If Alltrim(CTT->CTT_BLOQ) == '1' //Bloqueado
			DbSelectArea("ZBL")
			Reclock("ZBL",.T.)
			ZBL->ZBL_FILIAL	:= xFilial("SC5")
			ZBL->ZBL_DOC	:= (cAliasSD1)->D1_DOC
			ZBL->ZBL_SERIE	:= (cAliasSD1)->D1_SERIE
			ZBL->ZBL_CLIENT	:= _cFornece
			ZBL->ZBL_LOJA	:= _cLoja
			ZBL->ZBL_ITEM	:= (cAliasSD1)->D1_ITEM
			ZBL->ZBL_COD	:= (cAliasSD1)->D1_COD
			ZBL->ZBL_PEDIDO	:= ""
			ZBL->ZBL_EMISSA	:= SF1->F1_EMISSAO //Pois esta posicionado
			ZBL->ZBL_CCUSTO	:= (cAliasSD1)->D1_CC
			ZBL->ZBL_PROCES	:= "CTT"
			ZBL->ZBL_IDUSER	:= __cUserId
			ZBL->ZBL_DSUSER	:= UsrFullName(__cUserID)
			ZBL->ZBL_XID	:= ""
			ZBL->ZBL_ROTINA	:= "MATA410"
			ZBL->ZBL_DTINC 	:= _dDataInc
			ZBL->ZBL_TIMEIN	:= _cHrInc
			ZBL->(MsUnlock())	
			
			//Efetua o desbloqueio
			DbSelectArea("CTT")
			Reclock("CTT",.F.)
			CTT->CTT_BLOQ := "2"
			CTT->(MsUnlock())
		EndIf
		
	EndIf

EndIf

Return()

//Desbloqueia o fornecedor
Static Function xDesblFor(_cFornece,_cLoja)

//DbSelectArea("ZBL")
DbSelectArea("SA2")
SA2->(DbSetOrder(1))
SA2->(DbGoTop())
If SA2->(DbSeek(xFilial("SA2") + _cFornece + _cLoja ))
	If Alltrim(SA2->A2_MSBLQL) == '1'
		DbSelectArea("ZBL")
		Reclock("ZBL",.T.)
		ZBL->ZBL_FILIAL	:= xFilial("SC5")
		ZBL->ZBL_DOC	:= (cAliasSD1)->D1_DOC
		ZBL->ZBL_SERIE	:= (cAliasSD1)->D1_SERIE
		ZBL->ZBL_CLIENT	:= _cFornece
		ZBL->ZBL_LOJA	:= _cLoja
		ZBL->ZBL_ITEM	:= (cAliasSD1)->D1_ITEM
		ZBL->ZBL_COD	:= (cAliasSD1)->D1_COD
		ZBL->ZBL_PEDIDO	:= ""
		ZBL->ZBL_EMISSA	:= SF1->F1_EMISSAO //Pois esta posicionado
		ZBL->ZBL_CCUSTO	:= (cAliasSD1)->D1_CC
		ZBL->ZBL_PROCES	:= "SA2"
		ZBL->ZBL_IDUSER	:= __cUserId
		ZBL->ZBL_DSUSER	:= UsrFullName(__cUserID)
		ZBL->ZBL_XID	:= ""
		ZBL->ZBL_ROTINA	:= "MATA410"
		ZBL->ZBL_DTINC 	:= _dDataInc
		ZBL->ZBL_TIMEIN	:= _cHrInc
		ZBL->(MsUnlock())	

		//Efetua o desbloqueio
		DbSelectArea("SA2")
		Reclock("SA2",.F.)
		SA2->A2_MSBLQL := "2"
		SA2->(MsUnlock())
	EndIf
EndIf

Return()

//Desbloqueia o cliente
Static Function xDesblCli(_cFornece,_cLoja)

//DbSelectArea("ZBL")
DbSelectArea("SA1")
SA1->(DbSetOrder(1))
SA1->(DbGoTop())
If SA1->(DbSeek(xFilial("SA1") + _cFornece + _cLoja ))
	If Alltrim(SA1->A1_MSBLQL) == '1'
		DbSelectArea("ZBL")
		Reclock("ZBL",.T.)
		ZBL->ZBL_FILIAL	:= xFilial("SC5")
		ZBL->ZBL_DOC	:= (cAliasSD1)->D1_DOC
		ZBL->ZBL_SERIE	:= (cAliasSD1)->D1_SERIE
		ZBL->ZBL_CLIENT	:= _cFornece
		ZBL->ZBL_LOJA	:= _cLoja
		ZBL->ZBL_ITEM	:= (cAliasSD1)->D1_ITEM
		ZBL->ZBL_COD	:= (cAliasSD1)->D1_COD
		ZBL->ZBL_PEDIDO	:= ""
		ZBL->ZBL_EMISSA	:= SF1->F1_EMISSAO //Pois esta posicionado
		ZBL->ZBL_CCUSTO	:= (cAliasSD1)->D1_CC
		ZBL->ZBL_PROCES	:= "SA1"
		ZBL->ZBL_IDUSER	:= __cUserId
		ZBL->ZBL_DSUSER	:= UsrFullName(__cUserID)
		ZBL->ZBL_XID	:= ""
		ZBL->ZBL_ROTINA	:= "MATA410"
		ZBL->ZBL_DTINC 	:= _dDataInc
		ZBL->ZBL_TIMEIN	:= _cHrInc
		ZBL->(MsUnlock())	

		//Efetua o desbloqueio
		DbSelectArea("SA1")
		Reclock("SA1",.F.)
		SA1->A1_MSBLQL := "2"
		SA1->(MsUnlock())
	EndIf
EndIf
Return()
