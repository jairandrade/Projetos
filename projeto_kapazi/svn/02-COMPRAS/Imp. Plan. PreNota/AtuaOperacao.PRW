#include "PROTHEUS.CH"
#include "topconn.ch"
/*
+ ---------------------------------------------------------------------------------------------------------------------------------------+
| Compras                                                                                                                                |
| Autor: Andre Roberto Ramos                                                                                                             |
| RSAC Solucoes                                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------------------------- |
| Data: 06.02.2018                                                                                                                       |
| Descricao: P.E na entrada para informar tipo de operação                                                                               |
| Empresa: Kapazi                                                                                                                        |
+----------------------------------------------------------------------------------------------------------------------------------------+
*/

User Function MT103NFE()
Local aArea			:= GetArea()
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaCTT		:= CTT->(GetArea())
Local aAreaSA2		:= SA2->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local lAtvDesb		:= SuperGetMv("KP_DESBDEV",.F.,.T.)

Local cOper1    	:= Space(2)
Local lContinua    	:= .F.
Local lFlagDev		:= SuperGetMv("MV_FLAGDEV",.F.,.F.) 

Local Nx

Private _dDataInc	:= Date()
Private _cHrInc		:= Time()

if l103Class .and. SF1->F1_EST == "EX"

	DEFINE MSDIALOG oDlg1 TITLE OemToAnsi("Tipo de operação") From 000,000 to 180,260 of oMainWnd PIXEL
	//coluna x linha     //altura x largura
	@ 005,005 To 70,130 of oDlg1 Pixel
	
	@ 017,015 Say "Informe a Operação: " of oDlg1 Pixel
	@ 019,075 Msget cOper1 Size 050,11  Pixel F3 "DJ" PICTURE "@!" VALID !Empty(M->cOper1) //Valid ExistCpo("SX5","DJ"+cOper1)
	
	@ 075,050 BUTTON "&Confirma" of oDlg1 pixel SIZE 40,12 ACTION (lContinua := .T.,oDlg1:End() )
	
	ACTIVATE MSDIALOG oDlg1 CENTERED
	
	
	If lContinua
		If Select("QSD1")<>0
			DbSelectArea("QSD1")
			dbCloseArea()
		Endif
	
		cQry := " SELECT *
		cQry += " FROM "+RetSqlName("SF1") + " F1 "
		cQry += " INNER JOIN " +RetSqlName("SD1") + " D1 ON
		cQry += " D1.D1_DOC = F1.F1_DOC AND
		cQry += " D1.D1_SERIE = F1.F1_SERIE AND
		cQry += " D1.D1_FORNECE = F1.F1_FORNECE AND
		cQry += " D1.D1_LOJA = F1.F1_LOJA AND
		cQry += " D1.D1_FILIAL = F1.F1_FILIAL
		cQry += " WHERE
		cQry += " 	  D1.D1_DOC = '"+SF1->F1_DOC+"' "
		cQry += " AND D1.D1_SERIE = '"+SF1->F1_SERIE+"' "
		cQry += " AND D1.D1_FORNECE = '"+SF1->F1_FORNECE+"' "
		cQry += " AND D1.D1_LOJA = '"+SF1->F1_LOJA+"' "
		cQry += " AND D1.D1_FILIAL = '"+xFilial("SD1")+"'"
		cQry += " AND D1.D_E_L_E_T_ <> '*'
		cQry += " AND F1.D_E_L_E_T_ <> '*'
	
		TCQUERY cQry NEW ALIAS "QSD1"
	
		Begin Transaction
		cUPD := " UPDATE "+RetSqlName("SD1") 
		cUPD += " SET D1_X_OPER = '"+cOper1+"'
		cUPD += " FROM "+RetSqlName("SF1") + " F1 "
		cUPD += " INNER JOIN " +RetSqlName("SD1") + " D1  ON	
		cUPD += " D1.D1_DOC = F1.F1_DOC AND
		cUPD += " D1.D1_SERIE = F1.F1_SERIE AND
		cUPD += " D1.D1_FORNECE = F1.F1_FORNECE AND
		cUPD += " D1.D1_LOJA = F1.F1_LOJA AND
		cUPD += " D1.D1_FILIAL = F1.F1_FILIAL
		cUPD += " WHERE
		cUPD += " 	  D1.D1_DOC = '"+SF1->F1_DOC+"' "
		cUPD += " AND D1.D1_SERIE = '"+SF1->F1_SERIE+"' "
		cUPD += " AND D1.D1_FORNECE = '"+SF1->F1_FORNECE+"' "
		cUPD += " AND D1.D1_LOJA = '"+SF1->F1_LOJA+"' "
		cUPD += " AND D1.D1_FILIAL = '"+xFilial("SD1")+"'"
		cUPD += " AND D1.D_E_L_E_T_ <> '*'                             
		cUPD += " AND F1.D_E_L_E_T_ <> '*'
		TcSqlExec(cUPD)
		End Transaction
	
	endif

endif

If !lFlagDev .And. lAtvDesb .And. cEmpAnt == "04"//Nao tem flag de retorno
	If IsInCallStack("SA103Devol") //é uma devolucao
		
		//Faz a verificacao do cliente e grava os itens
		If Len(_aATItDV) > 0
			//aAdd(_aATItDV,{	(aVetPar)->D2_FILIAL,(aVetPar)->D2_DOC,(aVetPar)->D2_SERIE,(aVetPar)->D2_CLIENTE,(aVetPar)->D2_LOJA,(aVetPar)->D2_ITEM,
			//					(aVetPar)->D2_COD,(aVetPar)->D2_PEDIDO,(aVetPar)->D2_ITEMPV,(aVetPar)->D2_EMISSAO,(aVetPar)->D2_CCUSTO}) 
			//DbSelectArea("ZBL")
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			SA1->(DbGoTop())
			If SA1->(DbSeek(xFilial("SA1") + _aATItDV[1][4] + _aATItDV[1][5] ))
				If Alltrim(SA1->A1_MSBLQL) == '1'
					DbSelectArea("ZBL")
					Reclock("ZBL",.T.)
					ZBL->ZBL_FILIAL	:= _aATItDV[1][1]
					ZBL->ZBL_DOC	:= _aATItDV[1][2]
					ZBL->ZBL_SERIE	:= _aATItDV[1][3]
					ZBL->ZBL_CLIENT	:= _aATItDV[1][4]
					ZBL->ZBL_LOJA	:= _aATItDV[1][5]
					ZBL->ZBL_ITEM	:= _aATItDV[1][6]
					ZBL->ZBL_COD	:= _aATItDV[1][7]
					ZBL->ZBL_PEDIDO	:= _aATItDV[1][8]
					ZBL->ZBL_EMISSA	:= _aATItDV[1][10]
					ZBL->ZBL_CCUSTO	:= ""
					ZBL->ZBL_PROCES	:= "SA1"
					ZBL->ZBL_IDUSER	:= __cUserId
					ZBL->ZBL_DSUSER	:= UsrFullName(__cUserID)
					ZBL->ZBL_XID	:= ""
					ZBL->ZBL_ROTINA	:= "MATA103"
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
			
		EndIf
		
		
		For nX := 1 To Len(_aATItDV) //Itens da devolucao para desbloquear
			
			//Faz a verificacao do centro de custo
			If !Empty(_aATItDV[nX][11])
				
				DbSelectArea("CTT")
				CTT->(DbSetOrder(1)) //CTT_FILIAL, CTT_CUSTO, R_E_C_N_O_, D_E_L_E_T_
				CTT->(DbGoTop())
				If CTT->(DbSeek(xFilial("CTT") + _aATItDV[nX][11]))
					
					If Alltrim(CTT->CTT_BLOQ) == '1' //Bloqueado
						DbSelectArea("ZBL")
						Reclock("ZBL",.T.)
						ZBL->ZBL_FILIAL	:= _aATItDV[nX][1]
						ZBL->ZBL_DOC	:= _aATItDV[nX][2]
						ZBL->ZBL_SERIE	:= _aATItDV[nX][3]
						ZBL->ZBL_CLIENT	:= _aATItDV[nX][4]
						ZBL->ZBL_LOJA	:= _aATItDV[nX][5]
						ZBL->ZBL_ITEM	:= _aATItDV[nX][6]
						ZBL->ZBL_COD	:= ""//_aATItDV[nX][7]
						ZBL->ZBL_PEDIDO	:= _aATItDV[nX][8]
						ZBL->ZBL_EMISSA	:= _aATItDV[nX][10]
						ZBL->ZBL_CCUSTO	:= _aATItDV[nX][11]
						ZBL->ZBL_PROCES	:= "CTT"
						ZBL->ZBL_IDUSER	:= __cUserId
						ZBL->ZBL_DSUSER	:= UsrFullName(__cUserID)
						ZBL->ZBL_XID	:= ""
						ZBL->ZBL_ROTINA	:= "MATA103"
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
			
			//Faz a verificacao dos produtos e grava os itens
			//DbSelectArea("ZBL")
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())
			If SB1->(DbSeek(xFilial("SB1") + _aATItDV[nX][7]))
				If Alltrim(SB1->B1_MSBLQL) == '1'

					DbSelectArea("ZBL")
					Reclock("ZBL",.T.)
					ZBL->ZBL_FILIAL	:= _aATItDV[nX][1]
					ZBL->ZBL_DOC	:= _aATItDV[nX][2]
					ZBL->ZBL_SERIE	:= _aATItDV[nX][3]
					ZBL->ZBL_CLIENT	:= _aATItDV[nX][4]
					ZBL->ZBL_LOJA	:= _aATItDV[nX][5]
					ZBL->ZBL_ITEM	:= _aATItDV[nX][6]
					ZBL->ZBL_COD	:= _aATItDV[nX][7]
					ZBL->ZBL_PEDIDO	:= _aATItDV[nX][8]
					ZBL->ZBL_EMISSA	:= _aATItDV[nX][10]
					ZBL->ZBL_CCUSTO	:= ""
					ZBL->ZBL_PROCES	:= "SB1"
					ZBL->ZBL_IDUSER	:= __cUserId
					ZBL->ZBL_DSUSER	:= UsrFullName(__cUserID)
					ZBL->ZBL_XID	:= ""
					ZBL->ZBL_ROTINA	:= "MATA103"
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
			
		Next
	EndIf	 
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSA2)
RestArea(aAreaCTT)
RestArea(aAreaSA1)
RestArea(aArea)
Return()



