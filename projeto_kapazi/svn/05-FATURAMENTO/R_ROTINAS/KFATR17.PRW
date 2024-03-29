#Include "protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"

#Define ENTER chr(13)+chr(10)

/*
Funcao que faz a transferencia / estorno do pedido de venda
*/
User Function KFATR17(cPedido,cOper)
Local aArea 	:= GetArea()
Local lContinua	:= .T.

// Default cPedido := "284962"
Default cPedido := ""
Default cOper	:= "TRANSFERENCIA"

While lContinua

	lContinua := TelaPedido(cPedido,cOper)

Enddo

RestArea(aArea)
Return

/*
Funcao que faz o estorno da transferencia do pedido de venda
*/
User function KFATR17E(cPedido)
Local 	aArea 	:= GetArea()
Default cPedido := ""
// Default cPedido := "284962"

U_KFATR17(cPedido,"ESTORNAR")

RestArea(aArea)
Return

Static Function TelaPedido(_cPedido,_cOper)
// retorno
Local lRet		:= .T.
// posicao dos objetos
Local nLinha	:= 30
// funcao botao ok
Local bOkb	 	:= {|| iif(VldPedido(cPedido),Close(oDlgPedido),nil)}
// funcao cancelar
Local bCancel 	:= {|| lRet := .F.,Close(oDlgPedido) }
// msg ao deletar
Local lMsgDel	:= .F.
// botoes
Local aButtons	:= {}
// registro
Local nRecno 	:= Nil
// alias
Local cAlias	:= Nil
// exibe mashups
Local lMashups	:= .F.
// imprime padrao
Local lImpCad	:= .F.
// botoes padra
Local lPadrao	:= .F.
// exibe botao ok
Local lHasOk	:= .F.
// exibe walk
Local lWalkThru	:= .F.
// objeto da tela
Local oDlgPedido
Local cMsg		:= "Transfer�ncia"
// objeto pedido
Private oPedido
Private oFil

// pedido
Private _cPed 	:= Space(TamSx3("C5_NUM")[1]) 
Private _cFil 	:= Space(TamSx3("C5_FILIAL")[1]) 

Default _cPedido := ""
Default _cOper 	 := "TRANSFERENCIA"

If !Empty(AllTrim(_cPedido))
	_cPed := _cPedido
Endif

If _cOper <> "TRANSFERENCIA"
	cMsg := "Estorno de transfer�ncia"
Endif

Aadd(aButtons, {"", {|| U_KFATR18() }, "Corre��o Picking"})

DEFINE MSDIALOG oDlgPedido TITLE cMsg+" de Pedidos Separados" FROM 000, 000  TO 300, 425 PIXEL
	
	nLinha += 5
	@ nLinha, 004 GROUP TO 098, 161 PROMPT "" OF oDlgPedido PIXEL

	nLinha += 10
	
	//@ nLinha	, 007 SAY "Filial:" SIZE 025, 007 OF oDlgPedido PIXEL 
	//@ nLinha -1	, 032 MSGET oFil VAR _cFil SIZE 060, 010 OF oDlgPedido PIXEL
	//nLinha += 20

	@ nLinha	, 007 SAY "Pedido:" SIZE 025, 007 OF oDlgPedido PIXEL 
	@ nLinha -1	, 032 MSGET oPedido VAR _cPed SIZE 060, 010 OF oDlgPedido PIXEL valid VldPedido(_cPed,_cOper)

ACTIVATE MSDIALOG oDlgPedido CENTERED on init EnchoiceBar( oDlgPedido ,bOkb,bCancel,lMsgDel,aButtons,nRecno,cAlias,lMashups,lImpCad,lPadrao,lHasOk,lWalkThru)

Return lRet 

/*
VALIDA SE O PEDIDO FOI LIBERADO E N�O FOI FATURADO 
*/
Static Function VldPedido(cPedido,cOper)
Local aArea := GetArea()
Local cQuery:= ""
Local cTemp := GetNextAlias()

If Empty(Alltrim(cPedido))
	Return .T.
Endif

If cOper == "TRANSFERENCIA"
	cQuery += "SELECT COUNT(*) CONTAGEM "+ENTER
	cQuery += "FROM "+RetSqlName("SC9")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "	D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND C9_FILIAL = '"+xFilial("SC9")+"' "+ENTER
	cQuery += "	and C9_PEDIDO = '"+cPedido+"' "+ENTER
	cQuery += "	and C9_NFISCAL = '' "+ENTER
	cQuery += "	and C9_BLCRED = '' "+ENTER	
Else
	cQuery += "SELECT COUNT(*) CONTAGEM "+ENTER
	cQuery += "FROM "+RetSqlName("SC5")+" "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND C5_FILIAL='"+xFilial("SC5")+"' "+ENTER
	cQuery += "	AND C5_NUM='"+cPedido+"' "+ENTER
Endif

If Select(cTemp) > 0
	(cTemp)->( DbCloseArea() )
Endif

TcQuery cQuery New Alias (cTemp)

lRet := (cTemp)->CONTAGEM > 0

If Select(cTemp) > 0
	(cTemp)->( DbCloseArea() )
Endif

If !lRet 
	If !isBlind()
		MsgStop("O pedido informado n�o est� dispon�vel para transfer�ncia. Verifique.")
	Endif
else
	// LibPed(cPedido)
	Processa({||PrepListbo(cPedido,cOper) },"Processando...","Aguarde...")
Endif

_cPed := Space(6)
oPedido:SetFocus()

RestArea(aArea)
Return lRet

Static Function PrepListbo(cPedido,_cOper)
Local aArea 	:= GetArea()
Local aDados	:= {} 
Local cTitulo	:= "Produtos a serem transferidos do pedido: "+cPedido+"."
Local lHasMark	:= .F.
Local lMax		:= .T.
Local aRet		:= {}
Local nCount	:= 0
Local aCampos	:= GetCab(_cOper,lHasMark)
Local nPMark	:= aScan(aCampos,{|x| AllTrim(x[1])== "MARK"		})
Local nPQuant	:= aScan(aCampos,{|x| AllTrim(x[1])== "BF_QUANT"	})
Local cMsg		:= ""
Local nX		:= 0

ProcRegua(0)
IncProc()
IncProc()

If _cOper <> "TRANSFERENCIA"
	cTitulo := "Produtos que ser�o devolvidos do pedido: "+cPedido+".'"
	cMsg	:= "devolver da "
	aDados	:= GetEstor(cPedido,lHasMark)
Else
	aDados	:= GetProds(cPedido,lHasMark)
Endif

if !Empty(aDados)
	
	aRet := StaticCall(LISTBOX,dialogListBox,cTitulo,nil,"","",lHasMark,aDados,aCampos,nil,lMax,.T.)
	
	If !Empty(aRet)
		If nPMark > 0 .and. lHasMark
			
			if nCount == 0
				MsgStop("Nenhum registro com saldo foi selecionado para "+cMsg+"transfer�ncia.")
				RestArea(aArea)
				Return
			Endif
		Endif

		If _cOper <> "TRANSFERENCIA"
			aScan(aRet,{|x| iif(x[nPQuant] > 0 ,nCount++,nil)})
			if nCount == 0
				MsgStop("Nenhum registro com saldo para "+cMsg+"transfer�ncia.")
				RestArea(aArea)
				Return
			Endif
		Else
			for nX := 1 to Len(aRet)
				if aRet[nX][nPQuant] <= 0
					MsgStop("Existem itens sem saldo, a transfer�ncia n�o ser� executada.")
					RestArea(aArea)
					Return
				Endif
			Next
		Endif
		
		SD3Pro(cPedido,aCampos,aRet,_cOper)
		MsgInfo("Processo finalizado.")
	Endif
Else
	MsgInfo("N�o foram encontrados itens dispon�veis para "+cMsg+"transfer�ncia do pedido.")
Endif

RestArea(aArea)
Return

Static Function GetEstor(cPedido,lHasMark)
Local aArea		:= GetArea()
Local aRet		:= {}
Local aItem		:= {}
Local cQuery	:= ""
Local cTemp		:= GetNextAlias()

cQuery += " SELECT  "+ENTER
cQuery += "		C6_NUM  "+ENTER
cQuery += "		,C6_ITEM   "+ENTER
cQuery += "		,C6_PRODUTO   "+ENTER
cQuery += "		,RTRIM(B1_DESC) B1_DESC   "+ENTER
cQuery += "		,MAX(CASE WHEN D3_TM < '500' THEN D3_LOCAL ELSE '' END) BF_LOCAL "+ENTER
cQuery += "		,MAX(CASE WHEN D3_TM < '500' THEN D3_LOCALIZ ELSE '' END) BF_LOCALIZ "+ENTER
cQuery += "		,MAX(CASE WHEN D3_TM >= '500' THEN D3_LOCAL ELSE '' END) D3_LOCAL "+ENTER
cQuery += "		,MAX(CASE WHEN D3_TM >= '500' THEN D3_LOCALIZ ELSE '' END) D3_LOCALIZ "+ENTER
cQuery += "		,C6_QTDVEN "+ENTER
cQuery += "		,D3_QUANT BF_QUANT "+ENTER
cQuery += "		,B1_UM "+ENTER
cQuery += "		,D3_OBSERVA "+ENTER
cQuery += "		,SC6.R_E_C_N_O_ SC6REGNO "+ENTER
cQuery += "		,D3_DOC "+ENTER
cQuery += "		,D3_EMISSAO "+ENTER
cQuery += " 				"+ENTER
cQuery += " FROM "+RetSqlName("SC6")+" SC6   "+ENTER
cQuery += "	INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_<>'*' AND B1_FILIAL='"+xFilial("SB1")+"' AND B1_COD = C6_PRODUTO   "+ENTER

If cEmpAnt == "04" .And. cFilAnt == "08"  //Ajuste 0408
		cQuery += "	INNER JOIN "+RetSqlName("SD3")+" SD3 ON SD3.D_E_L_E_T_<>'*' AND D3_FILIAL = '01' AND D3_COD = C6_PRODUTO AND D3_ESTORNO<>'S' AND D3_OBSERVA = 'KFATR17'+'"+xFilial("SC9")+"'+RTRIM(C6_NUM)+RTRIM(C6_ITEM)  "+ENTER
		cQuery += "											AND SUBSTRING(D3_OBSERVA,18,1) = ' ' "+ENTER
	Else
		cQuery += "	INNER JOIN "+RetSqlName("SD3")+" SD3 ON SD3.D_E_L_E_T_<>'*' AND D3_FILIAL = C6_FILIAL AND D3_COD = C6_PRODUTO AND D3_ESTORNO<>'S' AND D3_OBSERVA = 'KFATR17'+'"+xFilial("SC9")+"'+RTRIM(C6_NUM)+RTRIM(C6_ITEM)  "+ENTER
		cQuery += "											AND SUBSTRING(D3_OBSERVA,18,1) = ' ' "+ENTER
Endif

cQuery += " WHERE    "+ENTER
cQuery += "		SC6.D_E_L_E_T_<>'*'   "+ENTER
cQuery += "		AND C6_FILIAL = '"+xFilial("SC6")+"'   "+ENTER
cQuery += "		AND C6_NUM = '"+cPedido+"'   "+ENTER
cQuery += "		AND C6_NOTA = ''  "+ENTER
cQuery += " 		"+ENTER
cQuery += "GROUP BY "+ENTER
cQuery += "			C6_NUM  "+ENTER
cQuery += "			,C6_ITEM   "+ENTER
cQuery += "			,C6_PRODUTO   "+ENTER
cQuery += "			,RTRIM(B1_DESC)  "+ENTER
cQuery += "			,C6_QTDVEN "+ENTER
cQuery += "			,D3_QUANT  "+ENTER
cQuery += "			,B1_UM "+ENTER
cQuery += "			,D3_OBSERVA "+ENTER
cQuery += "			,B1_COD "+ENTER
cQuery += "			,SC6.R_E_C_N_O_  "+ENTER
cQuery += "			,D3_DOC "+ENTER
cQuery += "			,D3_EMISSAO "+ENTER
cQuery += " "+ENTER
cQuery += "ORDER BY B1_COD,C6_ITEM  "+ENTER

MemoWrite("\logs\querys\kfatr17.sql",cQuery)

If Select(cTemp) > 0
	(cTemp)->(DbCloseArea())
Endif

TcQuery cQuery New Alias (cTemp)

While !(cTemp)->( EOF() )
	aItem := {}

	if lHasMark
		aadd(aItem,.T.)
	Endif
	aadd(aItem,(cTemp)->C6_NUM	)
	aadd(aItem,(cTemp)->C6_ITEM		)
	aadd(aItem,(cTemp)->C6_PRODUTO	)
	aadd(aItem,(cTemp)->B1_DESC		)
	aadd(aItem,(cTemp)->BF_LOCAL	)
	aadd(aItem,(cTemp)->BF_LOCALIZ	)
	aadd(aItem,(cTemp)->C6_QTDVEN	)
	aadd(aItem,(cTemp)->BF_QUANT	)
	aadd(aItem,(cTemp)->B1_UM		)
	aadd(aItem,(cTemp)->D3_OBSERVA	)
	aadd(aItem,(cTemp)->D3_LOCAL	)
	aadd(aItem,(cTemp)->D3_LOCALIZ	)
	aadd(aItem,Stod((cTemp)->D3_EMISSAO	))
	aadd(aItem,(cTemp)->D3_DOC		)
	aadd(aRet,aItem)

	(cTemp)->(DbSkip())
Enddo

If Select(cTemp) > 0
	(cTemp)->(DbCloseArea())
Endif

RestArea(aArea)
Return aRet

Static Function GetProds(cPedido,lHasMark)
Local aArea		:= GetArea()
Local aRet		:= {}
Local aItem		:= {}
Local cQuery	:= ""
Local cTemp		:= GetNextAlias()
Local cArmOrig	:= StaticCall(M521CART,TGetMv,cFilAnt,"KA_PICKARM","C","01"		,"KFATR17 - Armazem de origem da transferencia do picking list.")
Local cEndOrig	:= StaticCall(M521CART,TGetMv,cFilAnt,"KA_PICKEND","C","PICKING","KFATR17 - Endereco de origem da transferencia do picking list.")

/*
cQuery += "SELECT   "+ENTER
cQuery += "	C9_PEDIDO "+ENTER
cQuery += "	,C9_ITEM  "+ENTER
cQuery += "	,C9_PRODUTO  "+ENTER
cQuery += "	,RTRIM(B1_DESC) B1_DESC  "+ENTER
cQuery += "	,ISNULL(BF_LOCAL,'') BF_LOCAL "+ENTER
cQuery += "	,ISNULL(	(CASE   "+ENTER
cQuery += "					WHEN BZ_XPICKIN IS NULL OR BZ_XPICKIN ='' THEN BF_LOCALIZ   "+ENTER
cQuery += "					ELSE BZ_XPICKIN   "+ENTER
cQuery += "				END) "+ENTER
cQuery += "			,'') BF_LOCALIZ  "+ENTER
cQuery += "	,C9_LOCAL D3_LOCAL  "+ENTER
cQuery += "	,'EXPEDICAO' D3_LOCALIZ  "+ENTER
cQuery += "	,C9_QTDLIB  "+ENTER
cQuery += "	,ISNULL(BF_QUANT ,0) BF_QUANT "+ENTER
cQuery += "	,B1_UM  "+ENTER
cQuery += "	,CASE "+ENTER
cQuery += "		WHEN ISNULL(BF_QUANT,0) = 0 THEN 'SEM SALDO'  "+ENTER
cQuery += "		ELSE ''  "+ENTER
cQuery += "	END D3_OBSERVA "+ENTER
cQuery += "	,CASE  "+ENTER
cQuery += "		WHEN ISNULL(BF_QUANT,0) = 0 THEN 0  "+ENTER
cQuery += "		ELSE SC9.R_E_C_N_O_  "+ENTER
cQuery += "	END SC9REGNO  "+ENTER
cQuery += "	,C9_BLEST  "+ENTER
cQuery += "	  "+ENTER
cQuery += "FROM "+RetSqlName("SC9")+" SC9  "+ENTER
cQuery += "	INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_<>'*'  "+ENTER
cQuery += "		AND B1_FILIAL='"+xFilial("SB1")+"'  "+ENTER
cQuery += "		AND B1_COD = C9_PRODUTO  "+ENTER
cQuery += "	LEFT OUTER JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.D_E_L_E_T_<>'*'  "+ENTER
cQuery += "		AND BZ_FILIAL = C9_FILIAL  "+ENTER
cQuery += "		AND BZ_COD = C9_PRODUTO  "+ENTER
cQuery += "	LEFT OUTER JOIN	( "+ENTER
cQuery += "						SELECT  "+ENTER
cQuery += "							BF_FILIAL "+ENTER
cQuery += "							,BF_LOCAL "+ENTER
cQuery += "							,BF_PRODUTO "+ENTER
cQuery += "							,BF_LOCALIZ "+ENTER
cQuery += "							,BF_QUANT - BF_EMPENHO BF_QUANT "+ENTER
// cQuery += "							,ROW_NUMBER () OVER(PARTITION BY BF_FILIAL,BF_LOCAL,BF_PRODUTO ORDER BY BF_QUANT - BF_EMPENHO,BF_LOCALIZ ) ROWID "+ENTER
cQuery += "						FROM "+RetSqlName("SBF")+"  "+ENTER
cQuery += "						WHERE  "+ENTER
cQuery += "							D_E_L_E_T_<>'*'  "+ENTER
cQuery += "							AND BF_FILIAL = '"+xFilial("SBF")+"' "+ENTER
cQuery += "							AND BF_LOCAL = '"+cArmOrig+"'  "+ENTER
cQuery += "					) SBF ON SBF.BF_FILIAL = C9_FILIAL "+ENTER
cQuery += "						AND BF_PRODUTO = C9_PRODUTO "+ENTER
cQuery += "						AND BF_QUANT > C9_QTDLIB "+ENTER
// cQuery += "						AND SBF.ROWID = 1 "+ENTER
cQuery += "						AND BF_LOCALIZ =CASE  "+ENTER
cQuery += "											WHEN ISNULL(BZ_XPICKIN,'') <> '' THEN BZ_XPICKIN  "+ENTER

If Empty(AllTrim(cEndOrig))
	cQuery += "											ELSE BF_LOCALIZ  "+ENTER
Else
	cQuery += "											ELSE '"+cEndOrig+"'  "+ENTER
Endif

cQuery += "										END "+ENTER
cQuery += "						 "+ENTER
cQuery += "WHERE   "+ENTER
cQuery += "	SC9.D_E_L_E_T_<>'*'  "+ENTER
cQuery += "	AND C9_FILIAL = '"+xFilial("SC9")+"'  "+ENTER
cQuery += "	and C9_PEDIDO = '"+cPedido+"'  "+ENTER
cQuery += "	and C9_NFISCAL = '' "+ENTER
cQuery += "	and C9_BLCRED = '' "+ENTER
cQuery += "	and 0 = ( 	SELECT COUNT(*) "+ENTER
cQuery += "				FROM "+RetSqlName("SD3")+" "+ENTER
cQuery += "				WHERE D_E_L_E_T_<>'*' "+ENTER
cQuery += "				AND D3_FILIAL='"+xFilial("SD3")+"' "+ENTER
cQuery += "				AND D3_ESTORNO<>'S' "+ENTER
cQuery += "	  			AND D3_OBSERVA = 'KFATR17'+RTRIM(C9_PEDIDO)+RTRIM(C9_ITEM) "+ENTER
cQuery += "	  			AND SUBSTRING(D3_OBSERVA,16,1) = ' ' ) "+ENTER
cQuery += "ORDER BY BF_LOCALIZ,B1_COD,C9_ITEM "+ENTER
*/

cQuery += "SELECT " +ENTER
cQuery += "			C9_PEDIDO " +ENTER
cQuery += "			,C9_ITEM " +ENTER
cQuery += "			,C9_PRODUTO " +ENTER
cQuery += "			,RTRIM(B1_DESC) B1_DESC " +ENTER
cQuery += "			,ISNULL(BF_LOCAL,'') BF_LOCAL " +ENTER
cQuery += "			,ISNULL(	(CASE " +ENTER
cQuery += "							WHEN ISNULL(BZ_XPICKIN,'') = '' THEN BF_LOCALIZ " +ENTER
cQuery += "							ELSE BZ_XPICKIN " +ENTER
cQuery += "						END) ,'') BF_LOCALIZ " +ENTER
cQuery += "			,C9_LOCAL D3_LOCAL " +ENTER
cQuery += "			,'EXPEDICAO' D3_LOCALIZ " +ENTER
cQuery += "			,C9_QTDLIB " +ENTER
cQuery += "			,ISNULL(BF_QUANT ,0) BF_QUANT " +ENTER
cQuery += "			,B1_UM " +ENTER
cQuery += "			,CASE " +ENTER
cQuery += "				WHEN ISNULL(BF_QUANT,0) = 0 THEN 'SEM SALDO' " +ENTER
cQuery += "				ELSE '' " +ENTER
cQuery += "			END D3_OBSERVA " +ENTER
cQuery += "			,CASE " +ENTER
cQuery += "				WHEN ISNULL(BF_QUANT,0) = 0 THEN 0 " +ENTER
cQuery += "					ELSE SC9.R_E_C_N_O_  " +ENTER
cQuery += "				END SC9REGNO " +ENTER
cQuery += "			,C9_BLEST " +ENTER
cQuery += "	  				  " +ENTER
cQuery += " FROM "+RetSqlName("SC9")+" SC9 WITH(NOLOCK) " +ENTER
cQuery += "	INNER JOIN "+RetSqlName("SB1")+" SB1 WITH(NOLOCK) ON SB1.D_E_L_E_T_<>'*' AND B1_FILIAL='"+xFilial("SB1")+"' AND B1_COD = C9_PRODUTO " +ENTER

If cEmpAnt == "04" .And. cFilAnt == "08"  //Ajuste 0408
		cQuery += "	LEFT OUTER JOIN "+RetSqlName("SBZ")+" SBZ WITH(NOLOCK) ON SBZ.D_E_L_E_T_<>'*' AND BZ_FILIAL = '01' AND BZ_COD = C9_PRODUTO " +ENTER
		cQuery += "	LEFT OUTER JOIN "+RetSqlName("SBF")+" SBF WITH(NOLOCK) ON 	SBF.D_E_L_E_T_<>'*' AND BF_FILIAL = '01' AND BF_LOCAL = '"+cArmOrig+"' AND BF_PRODUTO = C9_PRODUTO AND BF_QUANT >= C9_QTDLIB " +ENTER
		cQuery += "													AND BF_LOCALIZ = CASE " +ENTER
		cQuery += "																		WHEN ISNULL(BZ_XPICKIN,'') <> '' THEN BZ_XPICKIN " +ENTER
		cQuery += "																			ELSE '"+cEndOrig+"' " +ENTER
		cQuery += "																		END " +ENTER

	Else
		cQuery += "	LEFT OUTER JOIN "+RetSqlName("SBZ")+" SBZ WITH(NOLOCK) ON SBZ.D_E_L_E_T_<>'*' AND BZ_FILIAL = C9_FILIAL AND BZ_COD = C9_PRODUTO " +ENTER
		cQuery += "	LEFT OUTER JOIN "+RetSqlName("SBF")+" SBF WITH(NOLOCK) ON 	SBF.D_E_L_E_T_<>'*' AND BF_FILIAL = C9_FILIAL AND BF_LOCAL = '"+cArmOrig+"' AND BF_PRODUTO = C9_PRODUTO AND BF_QUANT >= C9_QTDLIB " +ENTER
		cQuery += "													AND BF_LOCALIZ = CASE " +ENTER
		cQuery += "																		WHEN ISNULL(BZ_XPICKIN,'') <> '' THEN BZ_XPICKIN " +ENTER
		cQuery += "																			ELSE '"+cEndOrig+"' " +ENTER
		cQuery += "																		END " +ENTER
EndIf

cQuery += "WHERE " +ENTER
cQuery += "			SC9.D_E_L_E_T_<>'*' " +ENTER
cQuery += "			AND C9_FILIAL = '"+xFilial("SC9")+"' " +ENTER
cQuery += "			AND C9_PEDIDO = '"+cPedido+"' " +ENTER
cQuery += "			AND C9_NFISCAL = '' " +ENTER
cQuery += "			AND C9_BLCRED = '' " +ENTER
cQuery += "			AND 0 = ( 	SELECT COUNT(*) " +ENTER
cQuery += "						FROM "+RetSqlName("SD3")+" WITH(NOLOCK)" +ENTER
cQuery += "						WHERE D_E_L_E_T_<>'*' " +ENTER

If cEmpAnt == "04" .And. cFilAnt == "08"  //Ajuste 0408
		cQuery += "						AND D3_FILIAL = '01' " +ENTER
	Else
		cQuery += "						AND D3_FILIAL='"+xFilial("SD3")+"' " +ENTER
EndIf

cQuery += "						AND D3_ESTORNO<>'S' " +ENTER
cQuery += "	  					AND D3_OBSERVA = 'KFATR17'+'"+xFilial("SC9")+"'+RTRIM(C9_PEDIDO)+RTRIM(C9_ITEM) " +ENTER //Ajuste 0408
cQuery += "	  					AND SUBSTRING(D3_OBSERVA,18,1) = ' ' ) " +ENTER
cQuery += " " +ENTER
cQuery += "ORDER BY BF_LOCALIZ,B1_COD,C9_ITEM " +ENTER

If Select(cTemp) > 0
	(cTemp)->(DbCloseArea())
Endif

TcQuery cQuery New Alias (cTemp)

While !(cTemp)->( EOF() )
	aItem := {}

	if lHasMark
		If (cTemp)->BF_QUANT > 0
			aadd(aItem,.T.)
		Else
			aadd(aItem,.F.)
		Endif
	Endif

	aadd(aItem,(cTemp)->C9_PEDIDO	)
	aadd(aItem,(cTemp)->C9_ITEM		)
	aadd(aItem,(cTemp)->C9_PRODUTO	)
	aadd(aItem,(cTemp)->B1_DESC		)
	aadd(aItem,(cTemp)->BF_LOCAL	)
	aadd(aItem,(cTemp)->BF_LOCALIZ	)
	aadd(aItem,(cTemp)->C9_QTDLIB	)
	aadd(aItem,(cTemp)->BF_QUANT	)
	aadd(aItem,(cTemp)->B1_UM		)
	aadd(aItem,(cTemp)->D3_OBSERVA	)
	aadd(aItem,(cTemp)->D3_LOCAL	)
	aadd(aItem,(cTemp)->D3_LOCALIZ	)
	aadd(aItem,(cTemp)->SC9REGNO	)
	aadd(aRet,aItem)

	(cTemp)->(DbSkip())
Enddo

If Select(cTemp) > 0
	(cTemp)->(DbCloseArea())
Endif

RestArea(aArea)
Return aRet

Static Function GetCab(_cOper,lHasMark)
Local aRet	:= {}
Local aItem	:= {}
Local aTam	:= {}
Local cCampo:= ""

if lHasMark
	aItem 	:= {}
	aadd(aItem,"MARK"		) // 1 campo
	aadd(aItem," "			) // 2 titulo
	aadd(aItem,10			) // 3 tamanho
	aadd(aItem,1			) // 4 decimal
	aadd(aItem,"L"			) // 5 tipo
	aadd(aRet,aItem)
Endif

aItem 	:= {}
aTam 	:= TamSx3("C9_PEDIDO")
aadd(aItem,"C9_PEDIDO"				) // 1 campo
aadd(aItem,"Pedido"					) // 2 titulo
aadd(aItem,fieldSize("C9_PEDIDO")	) // 3 tamanho
aadd(aItem,aTam[2]					) // 4 decimal
aadd(aItem,aTam[3]					) // 5 tipo
aadd(aRet,aItem)

aItem 	:= {}
aTam 	:= TamSx3("C9_ITEM")
aadd(aItem,"C9_ITEM"				) // 1 campo
aadd(aItem,"Item Pedido"			) // 2 titulo
aadd(aItem,fieldSize("C9_ITEM")		) // 3 tamanho
aadd(aItem,aTam[2]					) // 4 decimal
aadd(aItem,aTam[3]					) // 5 tipo
aadd(aRet,aItem)

aItem 	:= {}
aTam 	:= TamSx3("C9_PRODUTO")
aadd(aItem,"C9_PRODUTO"				) // 1 campo
aadd(aItem,"Produto"				) // 2 titulo
aadd(aItem,fieldSize("C9_PRODUTO")	) // 3 tamanho
aadd(aItem,aTam[2]					) // 4 decimal
aadd(aItem,aTam[3]					) // 5 tipo
aadd(aRet,aItem)

aItem 	:= {}
aTam 	:= TamSx3("B1_DESC")
aadd(aItem,"B1_DESC"				) // 1 campo
aadd(aItem,"Descri��o"				) // 2 titulo
aadd(aItem,fieldSize("B1_DESC")/3*2	) // 3 tamanho
aadd(aItem,aTam[2]					) // 4 decimal
aadd(aItem,aTam[3]					) // 5 tipo
aadd(aRet,aItem)

aItem 	:= {}
aTam 	:= TamSx3("BF_LOCAL")
aadd(aItem,"BF_LOCAL"				) // 1 campo
aadd(aItem,"Arm. Origem"			) // 2 titulo
aadd(aItem,fieldSize("BF_LOCAL")	) // 3 tamanho
aadd(aItem,aTam[2]					) // 4 decimal
aadd(aItem,aTam[3]					) // 5 tipo
aadd(aRet,aItem)

aItem 	:= {}
aTam 	:= TamSx3("BF_LOCALIZ")
aadd(aItem,"BF_LOCALIZ"				) // 1 campo
aadd(aItem,"End. Origem"			) // 2 titulo
aadd(aItem,fieldSize("BF_LOCALIZ")	) // 3 tamanho
aadd(aItem,aTam[2]					) // 4 decimal
aadd(aItem,aTam[3]					) // 5 tipo
aadd(aRet,aItem)

aItem 	:= {}
aTam 	:= TamSx3("C9_QTDLIB")
aadd(aItem,"C9_QTDLIB"				) // 1 campo
aadd(aItem,"Qtde. Pedido"			) // 2 titulo
aadd(aItem,fieldSize("C9_QTDLIB")	) // 3 tamanho
aadd(aItem,aTam[2]					) // 4 decimal
aadd(aItem,aTam[3]					) // 5 tipo
aadd(aRet,aItem)

aItem 	:= {}
aTam 	:= TamSx3("BF_QUANT")
aadd(aItem,"BF_QUANT"				) // 1 campo
aadd(aItem,"Saldo End. Origem"		) // 2 titulo
aadd(aItem,fieldSize("BF_QUANT")	) // 3 tamanho
aadd(aItem,aTam[2]					) // 4 decimal
aadd(aItem,aTam[3]					) // 5 tipo
aadd(aRet,aItem)

aItem 	:= {}
aTam 	:= TamSx3("B1_UM")
aadd(aItem,"B1_UM"					) // 1 campo
aadd(aItem,"Uni. Medida"			) // 2 titulo
aadd(aItem,fieldSize("B1_UM")		) // 3 tamanho
aadd(aItem,aTam[2]					) // 4 decimal
aadd(aItem,aTam[3]					) // 5 tipo
aadd(aRet,aItem)

aItem 	:= {}
aTam 	:= TamSx3("D3_OBSERVA")
aadd(aItem,"D3_OBSERVA"				) // 1 campo
aadd(aItem,"Observa��o"				) // 2 titulo
aadd(aItem,fieldSize("D3_OBSERVA")/2) // 3 tamanho
aadd(aItem,aTam[2]					) // 4 decimal
aadd(aItem,aTam[3]					) // 5 tipo
aadd(aRet,aItem)

aItem 	:= {}
aTam 	:= TamSx3("D3_LOCAL")
aadd(aItem,"D3_LOCAL"				) // 1 campo
aadd(aItem,"Arm. Destino"			) // 2 titulo
aadd(aItem,fieldSize("D3_LOCAL")	) // 3 tamanho
aadd(aItem,aTam[2]					) // 4 decimal
aadd(aItem,aTam[3]					) // 5 tipo
aadd(aRet,aItem)

aItem 	:= {}
aTam 	:= TamSx3("D3_LOCALIZ")
aadd(aItem,"D3_LOCALIZ"				) // 1 campo
aadd(aItem,"End. Destino"			) // 2 titulo
aadd(aItem,fieldSize("D3_LOCALIZ")	) // 3 tamanho
aadd(aItem,aTam[2]					) // 4 decimal
aadd(aItem,aTam[3]					) // 5 tipo
aadd(aRet,aItem)

if _cOper == "TRANSFERENCIA"
	aItem 	:= {}
	aTam 	:= TamSx3("CV3_RECDES")
	aadd(aItem,"CV3_RECDES"				) // 1 campo
	aadd(aItem,"Registro SC9"			) // 2 titulo
	aadd(aItem,fieldSize("CV3_RECDES")/2) // 3 tamanho
	aadd(aItem,aTam[2]					) // 4 decimal
	aadd(aItem,aTam[3]					) // 5 tipo
	aadd(aRet,aItem)
Endif

if _cOper <> "TRANSFERENCIA"
	aItem 	:= {}
	aTam 	:= TamSx3("D3_EMISSAO")
	aadd(aItem,"D3_EMISSAO"				) // 1 campo
	aadd(aItem,"Dt. Transferencia"		) // 2 titulo
	aadd(aItem,fieldSize("D3_EMISSAO")	) // 3 tamanho
	aadd(aItem,aTam[2]					) // 4 decimal
	aadd(aItem,aTam[3]					) // 5 tipo
	aadd(aRet,aItem)

	aItem 	:= {}
	cCampo	:= "D3_DOC"
	aTam 	:= TamSx3(cCampo)
	aadd(aItem,cCampo				) // 1 campo
	aadd(aItem,"Documento"			) // 2 titulo
	aadd(aItem,fieldSize(cCampo)	) // 3 tamanho
	aadd(aItem,aTam[2]				) // 4 decimal
	aadd(aItem,aTam[3]				) // 5 tipo
	aadd(aRet,aItem)
Endif

Return aRet

Static Function fieldSize(cCampo)
Return StaticCall(LISTBOX,fieldSize,cCampo)

Static Function SD3Pro(cPedido,aCab,aDados,_cOper,lHasMark)
Local aArea 	:= GetArea()
Local nX		:= 0
Local aItem		:= {}
Local aTransf	:= {}
Local cLote		:= CriaVar("D3_LOTECTL")
Local dDtValid	:= CriaVar("D3_DTVALID")
Local nPProdOr	:= aScan(aCab,{|x| AllTrim(x[1])== "C9_PRODUTO"	})
Local nPProdDe	:= aScan(aCab,{|x| AllTrim(x[1])== "C9_PRODUTO"	})
Local nPArmOr	:= aScan(aCab,{|x| AllTrim(x[1])== "BF_LOCAL"	})
Local nPArmDe	:= aScan(aCab,{|x| AllTrim(x[1])== "D3_LOCAL"	})
Local nPQuant	:= aScan(aCab,{|x| AllTrim(x[1])== "C9_QTDLIB"	})
Local nPSaldo	:= aScan(aCab,{|x| AllTrim(x[1])== "BF_QUANT"	})
Local nPEndOr	:= aScan(aCab,{|x| AllTrim(x[1])== "BF_LOCALIZ"	})
Local nPEndDe	:= aScan(aCab,{|x| AllTrim(x[1])== "D3_LOCALIZ"	})
Local nPItem	:= aScan(aCab,{|x| AllTrim(x[1])== "C9_ITEM"	})
Local nPDtTran	:= aScan(aCab,{|x| AllTrim(x[1])== "D3_EMISSAO"	}) 
Local nPDoc		:= aScan(aCab,{|x| AllTrim(x[1])== "D3_DOC"		}) 
Local cObs		:= "KFATR17"+xFilial("SC9")+cPedido
Local cObserva	:= ""
Local _cFil		:= cFilAnt
Local _cEmp		:= cEmpAnt
Local dUlMed	:= GetMv("MV_ULMES")
Local nOpc		:= 3
Local cSeq		:= ""
Local cDoc		:= ""
Local lRet		:= .T.
Local lContinua := .T.
Local nPos		:= 0
Local cPesq		:= ""

Default _cOper	:= ""

If _cOper <> "TRANSFERENCIA"
	cDoc := aDados[1][nPDoc]
Else
	cSeq := GetSD3Seq(cPedido)
	cDoc := cPedido+cSeq
Endif

//aTransf[nX][ 1] cProdOrig
//aTransf[nX][ 2] cProdDest
//aTransf[nX][ 3] cArmOrig
//aTransf[nX][ 4] cArmDest
//aTransf[nX][ 5] nQuant
//aTransf[nX][ 6] cLoteOri
//aTransf[nX][ 7] cLoteDest
//aTransf[nX][ 8] cEndOri
//aTransf[nX][ 9] cEndDest
//aTransf[nX][10] dDtVlOri
//aTransf[nX][11] dDtVlDest
//aTransf[nX][12] observacao

If nPDtTran > 0 .and. _cOper <> "TRANSFERENCIA"
	nOpc := 6
	aScan(aDados,{|x| iif(x[nPDtTran] <= dUlMed,nOpc := 3,nil)})
Endif

For nX := 1 to Len(aDados)
	If lHasMark
		lContinua := aDados[nX][1] 
	Endif

	If lContinua
		if aDados[nX][nPSaldo] > 0
			If nOpc == 6
				cDoc := aDados[nX][nPDoc]
			Endif

			cObserva := cObs + aDados[nX][nPItem]

			cPesq := aDados[nX][nPProdOr	]+aDados[nX][nPProdDe	]
			cPesq += aDados[nX][nPArmOr	]+aDados[nX][nPArmDe	]
			cPesq += aDados[nX][nPEndOr	]+aDados[nX][nPEndDe	]

			nPos := aScan(aTransf,{|x| x[1]+x[2]+x[3]+x[4]+x[8]+x[9] == cPesq})
			If nPos == 0
				aItem := {}
				aadd(aItem,aDados[nX][nPProdOr]	) // 01 prod origem
				aadd(aItem,aDados[nX][nPProdDe]	) // 02 prod destino
				aadd(aItem,aDados[nX][nPArmOr]	) // 03 armazem origem
				aadd(aItem,aDados[nX][nPArmDe]	) // 04 armazem destino
				aadd(aItem,aDados[nX][nPQuant]	) // 05 quantidade
				aadd(aItem,cLote				) // 06 lote
				aadd(aItem,cLote				) // 07 lote
				aadd(aItem,aDados[nX][nPEndOr]	) // 08 endereco origem
				aadd(aItem,aDados[nX][nPEndDe]	) // 09 endereco destino
				aadd(aItem,dDtValid				) // 10 data validade lote
				aadd(aItem,dDtValid				) // 11 data validade lote
				aadd(aItem,cObserva				) // 12 observacao
				aadd(aTransf,aItem	)
			Else
				aTransf[nPos][05] += aDados[nX][nPQuant]
			Endif
		Endif
	Endif
Next

if !Empty(aTransf)
	If cEmpAnt == "04" .And. cFilAnt == "08"  //Ajuste 0408
			
			cFilant		:= 	"01"		//Seta a filial correta
			DbSelectArea("SM0")
			SM0->(DbGoTop())
			SM0->(DbSeek( "04" + "01" ) )//Seta SM0 correta
			Conout("")
			ConOut(SM0->M0_CODIGO+" - "+SM0->M0_CODFIL)
			Conout("")

			
			lRet := U_TRAIL03A(_cEmp,"01",nil,aTransf,nOpc,cDoc) //Efetua Transferencias
			If lRet .and. _cOper <> "TRANSFERENCIA" .and. nOpc <> 6
				MarkEsto(cPedido,cDoc)
			Endif

			cFilant		:= 	"08"		 //Seta a filial correta
			DbSelectArea("SM0")
			SM0->(DbGoTop())
			SM0->(DbSeek( "04" + "08" ) )//Seta SM0 correta
			Conout("")
			ConOut(SM0->M0_CODIGO+" - "+SM0->M0_CODFIL)
			Conout("")

		Else 
			lRet := U_TRAIL03A(_cEmp,_cFil,nil,aTransf,nOpc,cDoc) //Efetua Transferencias
			If lRet .and. _cOper <> "TRANSFERENCIA" .and. nOpc <> 6
				MarkEsto(cPedido,cDoc)
			Endif

	EndIf 
Endif

If lRet 
	If _cOper == "TRANSFEFENCIA"
		u_kfatr15("16",cPedido)  //Grava log do pedido de venda da tabela ZA
		// LibPed(cPedido)
	Else
		u_kfatr15("17",cPedido) // Grava log do pedido de venda da tabela ZA
	Endif
Endif

cEmpAnt := _cEmp
cFilAnt := _cFil

RestArea(aArea)
Return 

/*
Static Function LibPed(cPedido)
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cTemp		:= GetNextAlias()
Local cItem		:= ""

cQuery += "SELECT DISTINCT  "+ENTER
cQuery += "	C9_PEDIDO  "+ENTER
cQuery += "	,C9_ITEM   "+ENTER
cQuery += "	,C9_PRODUTO   "+ENTER
cQuery += "	,C9_LOCAL D3_LOCAL   "+ENTER
cQuery += "	,C9_QTDLIB   "+ENTER
cQuery += "	"+ENTER
cQuery += "FROM "+RetSqlName("SC9")+" SC9   "+ENTER
cQuery += "    INNER JOIN "+RetSqlName("SD3")+" SD3 ON SD3.D_E_L_E_T_<>'*' "+ENTER
cQuery += "        AND D3_FILIAL = C9_FILIAL "+ENTER
cQuery += "        AND D3_COD = C9_PRODUTO "+ENTER
cQuery += "        AND D3_ESTORNO<>'S' "+ENTER
cQuery += "        AND D3_OBSERVA = 'KFATR17'+RTRIM(C9_PEDIDO)+RTRIM(C9_ITEM) "+ENTER
cQuery += "        AND SUBSTRING(D3_OBSERVA,16,1)<>'S' "+ENTER
cQuery += "						  "+ENTER
cQuery += "WHERE "+ENTER
cQuery += "	SC9.D_E_L_E_T_<>'*'   "+ENTER
cQuery += "	AND C9_FILIAL = '"+xFilial("SC9")+"'   "+ENTER
cQuery += "	and C9_PEDIDO = '"+cPedido+"'   "+ENTER
cQuery += "	and C9_NFISCAL = ''  "+ENTER
cQuery += "	and C9_BLEST IN ('02','03') "+ENTER
cQuery += "ORDER BY C9_ITEM  "+ENTER

If Select(cTemp) > 0
	(cTemp)->( DbCloseArea() )
Endif

TcQuery cQuery New Alias (cTemp)

While !(cTemp)->( EOF() )
	cItem := (cTemp)->C9_ITEM

	LibEst(cPedido,cItem)

	(cTemp)->(DbSkip())
Enddo

If Select(cTemp) > 0
	(cTemp)->( DbCloseArea() )
Endif

RestArea(aArea)
Return

Static Function LibEst(cPedido,cItem,nQTransf)
Local aArea		:= GetArea()

SC9->( DbSetOrder(1) )
If SC9->(MsSeek(xFilial("SC9")+cPedido+cItem))
	Begin Transaction
		While !SC9->( EOF() ) .and. SC9->C9_FILIAL = xFilial("SC9") .and. SC9->C9_PEDIDO == cPedido .and. SC9->C9_ITEM == cItem
			If Empty(AllTrim(SC9->C9_NFISCAL)) .and. !Empty(AllTrim(SC9->C9_BLEST))
				SC6->( DbSetOrder(1) )
				If SC6->( MsSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))
					nOpc 	:= 1   // liberar
					lAtuCred:= .F. // nao altera liberacao de credito
					lAtuEst	:= .T. // libera estoque
					lHelp	:= .F. // nao exibe msg de help
					aSaldos	:= nil // nao informa saldos especificos
					lAvEst	:= .T. // avalia o estoque disponivel
					
					// Begin Transaction
						//a450Grava(nOpc,lAtuCred,lAtuEst,lHelp,aSaldos,lAvEst)
						a450Grava(1,.F.,.T.,.T.)
					// End Transaction
				Endif
			Endif
			SC9->( DbSkip())
		Enddo
	End Transaction
Endif

RestArea(aArea)
Return
*/

Static Function MarkEsto(cPedido,cDoc)
Local aArea := GetArea()
Local cTemp := GetNextAlias()
Local cQuery:= ""

cQuery += "SELECT "+ENTER
cQuery += "	RTRIM(D3_OBSERVA)D3_OBSERVA "+ENTER
cQuery += "	,D3_NUMSEQ "+ENTER
cQuery += "	,D3_EMISSAO "+ENTER
cQuery += "	,R_E_C_N_O_ SD3REGNO "+ENTER
cQuery += "	,D3_DOC "+ENTER
cQuery += "	,SUBSTRING(D3_OBSERVA,1,7) ROTINA "+ENTER

cQuery += "	,SUBSTRING(D3_OBSERVA,8,2) FILIAL "+ENTER 	//Ajustes 0408

cQuery += "	,SUBSTRING(D3_OBSERVA,10,6) PEDIDO "+ENTER 	//Ajustes 0408
cQuery += "	,SUBSTRING(D3_OBSERVA,16,2) ITEM "+ENTER 	//Ajustes 0408
cQuery += "	,SUBSTRING(D3_OBSERVA,18,1) ESTORNADO "+ENTER //Ajustes 0408
cQuery += " "+ENTER
cQuery += "FROM "+RetSqlName("SD3")+" WITH(NOLOCK)"+ENTER
cQuery += " "+ENTER
cQuery += "WHERE  "+ENTER
cQuery += "	D_E_L_E_T_<>'*' "+ENTER

If cEmpAnt == "04" .And. cFilAnt == "08"  //Ajuste 0408
		cQuery += "	AND D3_FILIAL='01' "+ENTER
	Else
		cQuery += "	AND D3_FILIAL='"+xFilial("SD3")+"' "+ENTER
EndIf
cQuery += "	AND D3_ESTORNO='' "+ENTER

If cEmpAnt == "04" .And. cFilAnt == "08"  //Ajuste 0408
		cQuery += "	AND SUBSTRING(D3_OBSERVA,1,15) = 'KFATR17'+ '01' +RTRIM('"+cPedido+"') "+ENTER //Ajuste 0408
	Else
		cQuery += "	AND SUBSTRING(D3_OBSERVA,1,15) = 'KFATR17'+'"+xFilial("SC9")+"'+RTRIM('"+cPedido+"') "+ENTER  //Ajuste 0408
EndIf

cQuery += "	AND SUBSTRING(D3_OBSERVA,18,1) = ' ' "+ENTER
cQuery += "	AND D3_DOC>='"+cDoc+"  ' "+ENTER
cQuery += " "+ENTER
cQuery += "ORDER BY 1,2,SD3REGNO "+ENTER

If Select(cTemp) > 0
	(cTemp)->( DbCloseArea())
Endif

TcQuery cQuery New Alias (cTemp)

While !(cTemp)->(EOF() )
	nRegno := (cTemp)->SD3REGNO
	SD3->( DbGoTo(nRegno))
	If SD3->(Recno()) == nRegno
		RecLock("SD3",.F.)
			SD3->D3_OBSERVA := AllTrim(SD3->D3_OBSERVA)+"S"
		MsUnLock("SD3")
	Endif
	(cTemp)->(DbSkip())
Enddo

If Select(cTemp) > 0
	(cTemp)->(DbCloseArea())
Endif

RestArea(aArea)
Return

Static Function GetSD3Seq(cPedido)
Local cRet 		:= "000"
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cTemp		:= GetNextAlias()

cQuery += "SELECT "+ENTER
cQuery += "	ISNULL(MAX(CONVERT(INT,REPLACE(D3_DOC,'"+cPedido+"',''))),0)+1 SEQ"+ENTER
cQuery += "FROM "+RetSqlName("SD3")+" WITH(NOLOCK) "+ENTER
cQuery += " "+ENTER
cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER

If cEmpAnt == "04" .And. cFilAnt == "08"  //Ajuste 0408
		cQuery += "AND D3_FILIAL = '01' "+ENTER
	Else
		cQuery += "AND D3_FILIAL = '"+xFilial("SD3")+"' "+ENTER	 
EndIf

cQuery += "AND SUBSTRING(D3_OBSERVA,1,15)= 'KFATR17'+ '"+xFilial("SC9")+"'+ RTRIM('"+cPedido+"') "+ENTER //Ajuste 0408
cQuery += "AND REPLACE(D3_DOC,'"+cPedido+"','') >= '000' "+ENTER
cQuery += "AND REPLACE(D3_DOC,'"+cPedido+"','') <= '999' "+ENTER

if Select(cTemp) > 0
	(cTemp)->(DbCloseArea())
Endif

TcQuery cQuery New Alias (cTemp)

If !(cTemp)->( EOF() )
	cRet := StrZero((cTemp)->SEQ,3)
Endif

if Select(cTemp) > 0
	(cTemp)->(DbCloseArea())
Endif

RestArea(aArea)
Return cRet
