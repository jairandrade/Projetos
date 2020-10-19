#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±										 ±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»                  																					 ±±
±±ºPrograma  ³PE MT100GE2   º Autor ³ Alfred Andersen          º Data ³  01/02/12   º												 ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹																											 ±±
±±ºDescricao ³ Ponto de entrada após a inclusão do Doc de Entrada  e SE2                             º							 ±±
±±º          ³                                                            º																							 ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹																											 ±±
±±ºUso       ³ Gravar no campo Historico da SE2 as informação do campo Observação da SC7 º								 ±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼																											 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±										 ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MT100GE2()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                            																			  ³//
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cSerie  := ""
Local cNota   := ""  
Local cPedido := "" 
Local cMen    := ""
Local _cContra:= ""
Local _cOrigem:= "" 
Private nOpc  := ParaMixB[2]

//Chama a função para inserir no titulo (SE2) informação do Centro de Custo apenas se for inclusão
If nOpc == 1	//Inclusão
	//Grava área de trabalho corrente
	_AreaSE2 := SE2->(GetArea())
	_AreaSD1 := SD1->(GetArea())
	_AreaSF1 := SF1->(GetArea())
	
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	if SC7->(DbSeek(xFilial("SC7")+SD1->D1_PEDIDO))
		cMen := "PC - "+ALLTRIM(SD1->D1_PEDIDO)+" - "+trataDesc(SC7->C7_OBS)
		_cContra:= SC7->C7_CONTRA
	endif
	
	SE2->E2_HIST := cMen  
	//Grava centro de custo
	SE2->E2_CCUSTO := grvcc()
	SE2->E2_CC 	   := SE2->E2_CCUSTO 

	If !Empty(_cContra) 
		SE2->E2_XORIGEM := "CT"
	Else
		SE2->E2_XORIGEM := "PC"
	EndIf
	
	//Restaura área de trabalho corrente
	
	RestArea(_AreaSE2)
	RestArea(_AreaSD1)
	RestArea(_AreaSF1)
EndIf

RETURN
static function trataDesc(_cDesc)
	Local  _sRet:= _cDesc
	_sRet := StrTran (_sRet, "'", "")
   _sRet := StrTran (_sRet, '"', "")
//   _sRet := StrTran (_sRet, "º", ".")
//   _sRet := StrTran (_sRet, "ª", ".")
   _sRet := StrTran (_sRet, "&", "e")
   _sRet := StrTran (_sRet, "|", "-")
   _sRet := StrTran (_sRet, "\", " ")
   _sRet := StrTran (_sRet, "/", " ")
   _sRet := StrTran (_sRet, "<", " ")
   _sRet := StrTran (_sRet, ">", " ")
   _sRet := StrTran (_sRet, chr (9), " ") // TAB
//   _sRet := StrTran (_sRet, chr (32), " ") // TAB
   _sRet := StrTran (_sRet, Chr(13) + Chr(10), " -- ") // enter
   //Só para garantir
   _sRet := noAcento (_sRet) 

return ALLTRIM(_sRet)

/*/{Protheus.doc} grvrat
Grava os rateios vindo do SIGAGCT
@author Rodrigo Slisinski
@since 31/08/2017
@version 1.0
/*/
Static Function grvrat()

	cSql:=" SELECT D1_PEDIDO FROM "+RetSqlName('SD1')
	cSql+="	WHERE D1_DOC ='"+SF1->F1_DOC+"'"
	cSql+=" AND D1_SERIE = '"+SF1->F1_SERIE+"'"
	cSql+=" AND D1_FORNECE = '"+SF1->F1_FORNECE+"'"
	cSql+=" AND D1_LOJA = '"+SF1->F1_LOJA+"'"
	cSql+=" AND D_E_L_E_T_<>'*'"

	IF Select('TRD1')<>0
		TRD1->(DBCloseArea())
	EndIF
	TcQuery cSql New Alias 'TRD1'

	IF TRD1->(EOF())
		RETURN
	EndIf

	DBSelectArea('SC7')
	DBSetOrder(1)
	If SC7->(DBSeek(xFilial('SC7')+TRD1->D1_PEDIDO))

		If !Empty(Alltrim(SC7->C7_MEDICAO))


			cSql:=" select R_E_C_N_O_ REC from "+RETSQLNAME('SEV')
			cSql+=" WHERE EV_FILIAL = '"+SE2->E2_FILIAL+"'" 
			cSql+=" AND EV_PREFIXO ='"+SE2->E2_PREFIXO+"'"
			cSql+=" AND EV_NUM ='"+SE2->E2_NUM+"'"
			cSql+=" AND EV_PARCELA ='"+SE2->E2_PARCELA+"'"
			cSql+=" AND EV_TIPO ='"+SE2->E2_TIPO+"'"
			cSql+=" AND EV_CLIFOR ='"+SE2->E2_FORNECE+"'"
			cSql+=" AND EV_LOJA ='"+SE2->E2_LOJA+"'"
			cSql+=" AND D_E_L_E_T_<>'*'"
			
			IF Select('TREV')<>0
				TREV->(DBCloseArea())
			EndIF
			TcQuery cSql New Alias 'TREV'
			While !TREV->(eof())
				SEV->(dbSelectArea('SEV'))
				SEV->(DBGoto(TREV->REC))
				SEV->(reclock('SEV',.F.))
				SEV->(DBDELETE())
				SEV->(MSUnlock())
				TREV->(dBSkip())
			EndDo

			cQuery := " SELECT Z21_NATURE, SUM(Z21_VALOR) AS VALOR FROM "+RetSqlNAme('Z21')
			cQuery += "	WHERE Z21_FILIAL = '"+xFilial('Z21')+"' AND Z21_CONTRA = '"+SC7->C7_CONTRA+"' "
			cQuery += "	  AND Z21_NUMMED = '"+SC7->C7_MEDICAO+"' AND D_E_L_E_T_ != '*' "
			cQuery += " GROUP BY Z21_NATURE "

			If SELECT("TMPGSE2") > 0
				TMPGSE2->(dbCloseArea())
			EndIf

			TCQuery cQuery Alias 'TMPGSE2' NEW
			dbSelectArea('TMPGSE2')
			TMPGSE2->(DbGoTop())
			
			cId := '0'
			cId := Soma1(cId)
			While !TMPGSE2->(EOF())
			
				cQuery2 := " SELECT Z21_NATURE, Z21_CCUSTO,Z21_ITEMCT, SUM(Z21_VALOR) AS VALOR FROM "+RetSqlNAme('Z21')
				cQuery2 += "	WHERE Z21_FILIAL = '"+xFilial('Z21')+"' AND Z21_CONTRA = '"+SC7->C7_CONTRA+"' "
				cQuery2 += "	  AND Z21_NUMMED = '"+SC7->C7_MEDICAO+"' AND Z21_CCUSTO != ' ' AND D_E_L_E_T_ != '*' and Z21_NATURE ='"+TMPGSE2->Z21_NATURE+"'"
				cQuery2 += " GROUP BY Z21_NATURE,Z21_CCUSTO,Z21_ITEMCT "
				If SELECT("TMPSE2CC") > 0
					TMPSE2CC->(dbCloseArea())
				EndIf
	
				TCQuery cQuery2 Alias 'TMPSE2CC' NEW
				dbSelectArea('TMPSE2CC')
				TMPSE2CC->(DbGoTop())
				If !TMPSE2CC->(EOF())
					cRatCC := '1'
				Else
					cRatCC := '2'
				EndIf
				
				nPerc:=TMPGSE2->VALOR/SF1->F1_VALBRUT
				RecLock('SEV',.T.)
				SEV->EV_FILIAL 	:= SE2->E2_FILIAL
				SEV->EV_PREFIXO := SE2->E2_PREFIXO
				SEV->EV_NUM 	:= SE2->E2_NUM
				SEV->EV_PARCELA := SE2->E2_PARCELA
				SEV->EV_CLIFOR 	:= SE2->E2_FORNECE
				SEV->EV_LOJA	:= SE2->E2_LOJA
				SEV->EV_TIPO	:= SE2->E2_TIPO
				SEV->EV_VALOR 	:= TMPGSE2->VALOR
				SEV->EV_NATUREZ := TMPGSE2->Z21_NATURE
				SEV->EV_RECPAG 	:= "P"
				SEV->EV_PERC 	:= round(nPerc*100,tamsx3('EV_PERC')[2])
				SEV->EV_RATEICC := cRatCC
				SEV->EV_IDENT 	:= cId
				SEV->(MsUnlock())				
				if cRatCC=='1'
					//cId := '0'
					While !TMPSE2CC->(EOF())
						//cId := Soma1(cId)
				  /*		RecLock('SEZ',.T.)
						SEZ->EZ_FILIAL 	:= SE2->E2_FILIAL
						SEZ->EZ_PREFIXO := SE2->E2_PREFIXO
						SEZ->EZ_NUM 	:= SE2->E2_NUM
						SEZ->EZ_PARCELA := SE2->E2_PARCELA
						SEZ->EZ_CLIFOR 	:= SE2->E2_FORNECE
						SEZ->EZ_LOJA	:= SE2->E2_LOJA
						SEZ->EZ_TIPO	:= SE2->E2_TIPO
						SEZ->EZ_VALOR 	:= TMPSE2CC->VALOR
						SEZ->EZ_NATUREZ := TMPSE2CC->Z21_NATURE
						SEZ->EZ_ITEMCTA := TMPSE2CC->Z21_ITEMCT
						SEZ->EZ_CCUSTO 	:= TMPSE2CC->Z21_CCUSTO
						SEZ->EZ_RECPAG 	:= "P"
						SEZ->EZ_PERC 	:= round(TMPSE2CC->VALOR/SE2->E2_VALOR*100,tamsx3('EZ_PERC')[2])
						SEZ->EZ_IDENT 	:= cId
						SEZ->(MsUnlock())   */
						TMPSE2CC->(DbSkip())
					EndDo				
				endif				
				TMPGSE2->(DbSkip())			
			EndDo
		EndIf
	ENDif
Return    



Return

/*
+-----------------------------------------------------------------------------+
! Função     ! grvcc        ! Autor ! Marcos Feijó IT UP ! Data !  20/12/2018 !
+------------+--------------+-------+--------------------+------+-------------+
! Parâmetros !                                                                !
+------------+----------------------------------------------------------------+
! Descricao  ! Inserir no titulo (SE2) informação do Centro de Custo da Nota  !
!            ! Fiscal, considerar sempre o Centro de Custo com maior          !
!            ! percentual se houver rateio ou mais documentos.                !
+------------+----------------------------------------------------------------+
*/

Static Function grvcc()
Local _cSql := ""

//Valida nos itens do documento de entrada o item com o maior valor (campo D1_TOTAL)
_cSql += "Select Top 1 D1_ITEM, D1_CC, D1_RATEIO, Max(D1_TOTAL) D1_TOTAL "
_cSql += "From " + RetSqlName('SD1') + " "
_cSql += "Where D1_FILIAL   = '" + SF1->F1_FILIAL  + "' And "
_cSql += "      D1_DOC      = '" + SF1->F1_DOC     + "' And "
_cSql += "      D1_SERIE    = '" + SF1->F1_SERIE   + "' And "
_cSql += "      D1_FORNECE  = '" + SF1->F1_FORNECE + "' And "
_cSql += "      D1_LOJA     = '" + SF1->F1_LOJA    + "' And "
_cSql += "      D_E_L_E_T_ <> '*'
_cSql += "Group By D1_ITEM, D1_CC, D1_RATEIO "
_cSql += "Order By D1_TOTAL DESC "

IF Select('TMPSD1') <> 0
	TMPSD1->(DBCloseArea())
EndIF

TcQuery _cSql New Alias 'TMPSD1'

//Verifica se o campo Rateio (D1_RATEIO) for igual a 1-Sim
If TMPSD1->D1_RATEIO == "1"  
	//Valida na tabela SDE o item com o maior percentual (campo DE_PERC) 
	_cSql := "Select Top 1 DE_CC, Max(DE_PERC) DE_PERC "
	_cSql += "From " + RetSqlName('SDE') + " "
	_cSql += "Where DE_FILIAL   = '" + SF1->F1_FILIAL  + "' And "
	_cSql += "      DE_DOC      = '" + SF1->F1_DOC     + "' And "
	_cSql += "      DE_SERIE    = '" + SF1->F1_SERIE   + "' And "
	_cSql += "      DE_FORNECE  = '" + SF1->F1_FORNECE + "' And "
	_cSql += "      DE_LOJA     = '" + SF1->F1_LOJA    + "' And "
	_cSql += "      DE_ITEMNF   = '" + TMPSD1->D1_ITEM + "' And "
	_cSql += "      D_E_L_E_T_ <> '*'
	_cSql += "Group By DE_CC "
	_cSql += "Order By DE_PERC DESC "

	IF Select('TMPSDE') <> 0
		TMPSDE->(DBCloseArea())
	EndIF

	TcQuery _cSql New Alias 'TMPSDE'

	_cc := TMPSDE->DE_CC

	TMPSDE->(DBCloseArea())
Else	//Se o campo Rateio (D1_RATEIO) for diferente de 1-Sim
 	//Envia para o título o Centro de Custo (campo D1_CC)
	_cc := TMPSD1->D1_CC
EndIf

TMPSD1->(DBCloseArea())

//Envia para o título o Centro de Custo
/*_cSql := "UpDate " + RetSqlName("SE2") + " SE2 " 
_cSql += "  Set E2_CCUSTO   = '" + _cc + "' "
_cSql += "Where E2_FILIAL   = '" + SF1->F1_FILIAL  + "' And "
_cSql += "      E2_NUM      = '" + SF1->F1_DOC     + "' And "
_cSql += "      E2_PREFIXO  = '" + SF1->F1_SERIE   + "' And "
_cSql += "      E2_FORNECE  = '" + SF1->F1_FORNECE + "' And "
_cSql += "      E2_LOJA     = '" + SF1->F1_LOJA    + "' And "
_cSql += "      D_E_L_E_T_ <> '*'

TcSqlExec(_cSql)*/

Return _cc