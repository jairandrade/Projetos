/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Funcoes relacionadas a geracao de ordens de producao de produtos personalizados.                                             **/
/** Autor: luiz henrique jacinto                                                                                                 **/
/** RSAC Soluções                                                                                                                **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/                          
/** 14/05/2018 | Luiz Henrique Jacinto          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"

#Define ENTER CHR(13)+CHR(10)

/**********************************************************************************************************************************/
/** user function KFATA13()                                                                                                      **/
/** processa o pedido                                                                                                            **/
/**********************************************************************************************************************************/
User Function KFATA13(cPedido,cCampo)
	Local 	aArea	:= GetArea()
	Local	cTemp	:= GetNextAlias()
	Local	nCount	:= 0
	Local	nModBkp	:= nModulo
	Local 	aOps	:= {}
	Local	cOp		:= ""
	Local	lRet	:= .T.
	Local	nX		:= 0

	Default	cPedido	:= ""
	Default cCampo	:= "B1_XOPFLU"
	
	If Empty(AllTrim(cPedido))
		Return
	Endif
	
	nModulo := 10
	
	nCount := qryItensPV(cPedido,cTemp,cCampo)
	
	If nCount >0
		ProcRegua(0)
		IncProc()
		IncProc()
		ProcRegua(nCount)
	Endif
	
	
	While !(cTemp)->( EOF() )  
		IncProc()
			If !gerarOrdem(cTemp,@cOp)
				lRet := .F.
			Endif
		If !lRet
			exit
		Endif
		aadd(aOps,cOp)
		(cTemp)->( DbSkip() )
	Enddo
	
	
	If Select(cTemp) > 0
		(cTemp)->( DBCloseArea() )
	Endif
	
	If lRet .and. Len(aOps) > 0
		For nX := 1 to len(aOps)
			// atualiza o retorno
			StartJob("U_KFATA13C",GetEnvServer(),.T.,cEmpAnt,cFilant,aOps[nX])
		Next
	Endif
	
	nModulo := nModBkp
	
	RestArea(aArea)
Return lRet

/**********************************************************************************************************************************/
/** static function qryItensPV()                                                                                                 **/
/** obtem os produtos a serem produzidos                                                                                         **/
/**********************************************************************************************************************************/
Static function qryItensPV(cPedido,cTemp,cCampo)
	Local cQuery:= ""
	Local aArea	:= GetArea()
	Local nCount:= 0
	
	cQuery += "SELECT "+ENTER
	cQuery += "	SC6.R_E_C_N_O_ SC6REGNO "+ENTER
	cQuery += "	,C6_FILIAL "+ENTER
	cQuery += "	,C6_NUM "+ENTER
	cQuery += "	,C6_ITEM "+ENTER
	cQuery += "	,C6_PRODUTO "+ENTER
	cQuery += "	,C6_ENTREG "+ENTER
	cQuery += "	,C6_LOCAL "+ENTER
	cQuery += "	,C6_TPOP "+ENTER
	cQuery += "	,C6_REVISAO "+ENTER
	cQuery += "	,C6_QTDVEN "+ENTER
	cQuery += "	,C6_QTDENT "+ENTER
	cQuery += "	,C6_QTDVEN - C6_QTDENT SALDO "+ENTER
	cQuery += "	,C6_QTDEMP "+ENTER
	cQuery += "	,B1_CC "+ENTER
	cQuery += "	,B1_UM "+ENTER
	cQuery += "	 "+ENTER
	cQuery += "FROM "+RetSqlName("SC6")+" SC6 "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND B1_FILIAL ='"+xFilial("SB1")+"' "+ENTER
	cQuery += "		AND B1_COD = C6_PRODUTO "+ENTER
	cQuery += "		AND "+cCampo+" = 'S' "+ENTER
	cQuery += "	"+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.D_E_L_E_T_<>'*'  "+ENTER
	cQuery += "		AND F4_FILIAL = C6_FILIAL "+ENTER
	cQuery += "		AND F4_CODIGO = C6_TES "+ENTER
	cQuery += "		AND F4_ESTOQUE = 'S' "+ENTER
	cQuery += "	LEFT OUTER JOIN "+RetSqlName("SC2")+" SC2 ON SC2.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND C2_FILIAL = C6_FILIAL "+ENTER
	cQuery += "		AND C2_PEDIDO = C6_NUM "+ENTER
	cQuery += "		AND C2_ITEMPV = C6_ITEM "+ENTER
	cQuery += "		AND C2_PRODUTO = C6_PRODUTO "+ENTER

	cQuery += "	"+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "		SC6.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND C6_FILIAL = '"+xFilial("SC6")+"' "+ENTER
	cQuery += "	AND C6_NUM    = '"+cPedido+"' "+ENTER
	cQuery += "	AND C6_BLQ   <> 'R' "+ENTER
	cQuery += "	AND C6_QTDVEN > C6_QTDENT "+ENTER
	cQuery += "	AND C6_QTDEMP > 0 "+ENTER
	If AllTrim(cCampo) == "B1_XOPFLU"
		cQuery += "	AND C6_NUMORC<>'' "+ENTER
	Endif
	cQuery += "	AND C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD IS NULL "+ENTER
	
	cQuery += "ORDER BY  "+ENTER
	cQuery += "	C6_FILIAL "+ENTER
	cQuery += "	,C6_NUM "+ENTER
	cQuery += "	,C6_ITEM "+ENTER

	If Select(cTemp) > 0
		(cTemp)->( DBCloseArea() )
	Endif
	
	TcQuery cQuery new Alias (cTemp)
	Count to nCount
	
	TcSetField(cTemp,"C6_ENTREG","D")
	
	(cTemp)->( DbGoTop() )
	
Return nCount

/**********************************************************************************************************************************/
/** static function gerarOrdem()                                                                                                 **/
/** gera a ordem de producao a partir do pedido                                                                                  **/
/**********************************************************************************************************************************/
Static Function gerarOrdem(cTemp,cOp)
	Local aInclui	:= {}
	Local lRet		:= .T.
	Local cNum		:= 'A'+StrZero(0,5)
	Local cItem		:= (cTemp)->C6_ITEM
	Local cSequen	:= StrZero(1,TamSx3("C2_SEQUEN")[1] )
	Local cObs		:= "KFAT13 - ORDEM PERSONALIZADO A PARTIR DO PEDIDO "+cNum+", ITEM "+cItem
	Local cDestina	:= CriaVar("C2_DESTINA")
	Local cCC		:= (cTemp)->B1_CC
	Local nQtde		:= (cTemp)->SALDO
	Local cItemGrd	:= CriaVar("C2_ITEMGRD")
	Local dDtFim	:= (cTemp)->C6_ENTREG + GetMv("KA_PERSPRZ",,180)
	Local dDtIni	:= (cTemp)->C6_ENTREG + 7
	
	Default cOp		:= ""
	
	cNum := getNumero(cNum,(cTemp)->C6_NUM)
	
	nModulo := 10
	
	If dDtFim < dDataBase
		dDtFim	:= dDataBase + 1
	endif
	
	If Empty(AllTrim(cCC))
		cCC := AllTrim(GetMv("KA_PERSCC",,"423010001"))
	Endif
	
	// array de inclusao
	aadd(aInclui,{'C2_FILIAL'	,xFilial("SC2")		,NIL} )
	aadd(aInclui,{'C2_ITEMGRD'	,cItemGrd			,NIL} )
	aadd(aInclui,{'C2_SEQUEN'	,cSequen			,NIL} )
	aadd(aInclui,{'C2_ITEM'		,cItem				,NIL} )
	aadd(aInclui,{'C2_NUM'		,cNum				,NIL} )
	aadd(aInclui,{'C2_PRODUTO'	,(cTemp)->C6_PRODUTO,NIL} )
	aadd(aInclui,{'C2_DATPRI'	,dDtIni				,NIL} )
	aadd(aInclui,{'C2_DATPRF'	,dDtFim				,NIL} )
	aadd(aInclui,{'C2_LOCAL'	,(cTemp)->C6_LOCAL	,NIL} )
	aadd(aInclui,{'C2_CC' 		,cCC		 		,NIL} )
	aadd(aInclui,{'C2_UM'		,(cTemp)->B1_UM		,NIL} )
	aadd(aInclui,{'C2_QUANT'	,nQtde				,NIL} )
	aadd(aInclui,{'C2_OBS'		,cObs				,NIL} )
	aadd(aInclui,{'C2_PEDIDO'	,(cTemp)->C6_NUM	,NIL} )
	aadd(aInclui,{'C2_ITEMPV'	,cItem				,NIL} )
	aadd(aInclui,{'C2_TPOP'		,(cTemp)->C6_TPOP	,NIL} )
	aadd(aInclui,{'C2_EMISSAO'	,dDataBase			,NIL} )
	aadd(aInclui,{'C2_DESTINA'	,cDestina			,NIL} )

	// inicia transacao
	Begin Transaction
	
		// flag de erro do execauto
		lMsErroAuto	:= .F.
		// array de exclusao possui itens
		If !Empty(aInclui)
			// exclui a ordem de producao na filial do pedido
			MsExecAuto({|x,Y| Mata650(x,Y)},aInclui,3)
			
			// flag problema
			If lMsErroAuto
				// altera o retorno
				lRet := .F.
				// mostra erro
				MostraErro()
				// desfaz transacao
				DisarmTransactions()
			Else
				cOp := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD

				If IsInCallStack("U_KESTR15")
					U_KFATR15("21",cPedido,cItem,,,"OP: "+cOp)
				Endif
			Endif
		Endif
	
	// fim da transacao
	End Transaction
	
Return lRet 

Static Function getNumero(_cNum,_cPed)
	Local cRet 		:= ""
	Local cTemp		:= GetNextAlias()
	Local cQuery	:= ""
	
	
	cQuery += "SELECT TOP 1 isnull(C2_NUM,'') C2_NUM "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SC2")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND C2_FILIAL='"+xFilial("SC2")+"' "+ENTER
	cQuery += "AND C2_PEDIDO='"+_cPed+"' "+ENTER
	
	If Select(cTemp)>0
		(cTemp)->( DbCloseArea())
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	If !(cTemp)->( EOF() ) .and. !Empty( AllTrim( (cTemp)->C2_NUM ) )
		cRet := (cTemp)->C2_NUM 
	Endif
	
	If Empty(AllTrim(cRet))
		cQuery := "SELECT ISNULL(MAX(C2_NUM),'') C2_NUM "+ENTER
		cQuery += " "+ENTER
		cQuery += "FROM "+RetSqlName("SC2")+" "+ENTER
		cQuery += " "+ENTER
		cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
		cQuery += "AND C2_FILIAL='"+xFilial("SC2")+"' "+ENTER
		cQuery += "AND C2_NUM>='"+_cNum+"' "+ENTER
		
		If Select(cTemp)>0
			(cTemp)->( DbCloseArea())
		Endif
		
		TcQuery cQuery New Alias (cTemp)
		
		If !(cTemp)->( EOF() ) .and. !Empty( AllTrim( (cTemp)->C2_NUM ) )
			cRet := Soma1( (cTemp)->C2_NUM )
		Endif
	Endif
	
	If Select(cTemp)>0
		(cTemp)->( DbCloseArea())
	Endif
	
Return cRet

User Function KFATA13A()
	Local nRet		:= 1
	Local cTemp		:= GetNextAlias()
	Local cGrp		:= GetMv("KA_PERSGRP",,"")
	Local lRet		:= .T.
	Local cMsg		:= ""
	
	If Empty(AllTrim(cGrp))
		Return nRet
	Endif
	
	// !todos os produtos dos grupos informados estao liberados no credito somente no grupo
	lRet := !qryLiberados(cTemp,cGrp,"B")
	
	// se existem bloqueados no credito
	If !lRet
		cMsg := "Não é permitido liberar estoque de pedidos personalizados (FLUIG) com bloqueio de crédito:"+ENTER
		cMsg += "Pedido - Item - Produto "+ENTER
		While !(cTemp)->( EOF() )
			cMsg += AllTrim( (cTemp)->C9_PEDIDO )+" - "
			cMsg += AllTrim( (cTemp)->C9_ITEM 	)+" - "
			cMsg += AllTrim( (cTemp)->C9_PRODUTO)+ENTER
			(cTemp)->( DbSkip() )
		Enddo
		
		MsgStop(cMsg)
		
	Endif
	
	// fecha a area
	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif
	
	// se nao existem bloqueados no credito
	If lRet
		// obtem os pedidos sem bloqueio de credito somente do grupo informado
		qryLiberados(cTemp,cGrp)
		// inicia a transacao
		Begin Transaction
			// faz loop nos pedidos
			While !(cTemp)->( EOF() )
				// aponta o produto
				lRet := StartJob("U_KFATA13B",GetEnvServer(),.T.,cEmpAnt,cFilant,(cTemp)->C9_PEDIDO,(cTemp)->C9_ITEM,(cTemp)->C9_PRODUTO)
				//lRet := U_KFATA13B(cEmpAnt,cFilant,(cTemp)->C9_PEDIDO,(cTemp)->C9_ITEM,(cTemp)->C9_PRODUTO)
				// se nao conseguiu apontar
				If !lRet
					// desfaz as transacoes
					DisarmTransactions()
					// sai do loop
					Exit
				Endif
				// proximo registro
				(cTemp)->( DbSkip() )
			Enddo
		// termina a transacao
		End Transaction
	Endif
	
	// se deu erro
	If !lRet
		// altera para cancelar
		nRet := 2
	Endif

	// retorna
Return nRet 

Static Function qryLiberados(cTemp,cCampo,cTipo)
	Local 	cQuery	:= ""
	Local 	lRet 	:= .T.
	Local 	cPedIni := MV_PAR01
	Local 	cPedFim	:= MV_PAR02
	Local 	cCliIni	:= MV_PAR03
	Local 	cCliFim	:= MV_PAR04
	Local 	dDtIni	:= MV_PAR05
	Local 	dDtFim	:= MV_PAR06

	Default cTipo 	:= ""
	Default cCampo	:= "B1_XOPFLU"

	// atribui duas vezes para o compilador nao reclamar
	cPedIni := MV_PAR01
	cPedFim	:= MV_PAR02
	cCliIni	:= MV_PAR03
	cCliFim	:= MV_PAR04
	dDtIni	:= MV_PAR05
	dDtFim	:= MV_PAR06
	
	cQuery += "SELECT DISTINCT "+ENTER
	cQuery += "	C9_FILIAL "+ENTER
	cQuery += "	,C9_PEDIDO "+ENTER
	cQuery += "	,C9_ITEM "+ENTER
	cQuery += "	,C9_PRODUTO "+ENTER
	cQuery += "	,B1_GRUPO "+ENTER
	cQuery += "	,C9_BLCRED "+ENTER
	cQuery += "FROM "+RetSqlName("SC9")+" SC9 "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SC6")+" SC6 ON SC6.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND C6_FILIAL  = C9_FILIAL "+ENTER
	cQuery += "		AND C6_NUM     = C9_PEDIDO "+ENTER
	cQuery += "		AND C6_ITEM    = C9_ITEM "+ENTER
	cQuery += "		AND C6_PRODUTO = C9_PRODUTO "+ENTER
	cQuery += "		AND C6_ENTREG >= '"+DtoS(dDtIni)+"' "+ENTER
	cQuery += "		AND C6_ENTREG <= '"+Dtos(dDtFim)+"' "+ENTER

	If AllTrim(cCampo) == "B1_XOPFLU"
		cQuery += "		AND C6_NUMORC <> '' "+ENTER
	Endif

	cQuery += "	INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND B1_FILIAL='"+xFilial("SB1")+"' "+ENTER
	cQuery += "		AND B1_COD = C9_PRODUTO "+ENTER
	cQuery += "		AND "+cCampo+" = 'S' "+ENTER
	// SOMENTE ITENS DO PEDIDO QUE POSSUEM ORDEM DE PRODUCAO
	cQuery += "	INNER JOIN "+RetSqlName("SC2")+" SC2 ON SC2.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND C2_FILIAL = C9_FILIAL "+ENTER
	cQuery += "		AND C2_PEDIDO = C9_PEDIDO "+ENTER
	cQuery += "		AND C2_ITEMPV = C9_ITEM "+ENTER
	cQuery += "		AND C2_PRODUTO = C9_PRODUTO "+ENTER
	// SOMENTE ORDEM DE PRODUCAO ABERTA
	cQuery += "		AND C2_QUANT > C2_QUJE "+ENTER
	cQuery += "		AND C2_DATRF ='' "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "		SC9.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND C9_FILIAL   = '"+xFilial("SC9")+"' "+ENTER
	cQuery += "	AND C9_PEDIDO  >= '"+cPedIni+"' "+ENTER
	cQuery += "	AND C9_PEDIDO  <= '"+cPedFim+"' "+ENTER
	cQuery += "	AND C9_CLIENTE >= '"+cCliIni+"' "+ENTER
	cQuery += "	AND C9_CLIENTE <= '"+cCliFim+"' "+ENTER
	cQuery += "	AND C9_NFISCAL  = '' "+ENTER
	
	If cTipo == "B"
		cQuery += "	AND C9_BLCRED   = '04' "+ENTER
	Endif 
	
	If Select(cTemp) > 0
		(cTemp)->( DbCloseArea() )
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	lRet := !(cTemp)->( EOF() )
	
Return lRet

User Function KFATA13B(_cEmp,_cFil,_cPedido,_cItem,_cProduto,_lLog)
	// criou ambiente
	Local	lEnv 	:= StaticCall(KAP_WF03,environmentActions,1,_cEmp,_cFil,,,"10",{"SC2"})
	Local	lRet	:= apontarPedido(_cPedido,_cItem,_cProduto,_lLog)
		
	IF lEnv
		StaticCall(KAP_WF03,environmentActions,2)
	Endif
	
Return lRet 

User Function KFATA13C(_cEmp,_cFil,_cOp)
	// criou ambiente
	Local	lEnv 	:= StaticCall(KAP_WF03,environmentActions,1,_cEmp,_cFil,,,"10",{"SC2"})
	Local	lRet	:= GeraSD4(_cOp)
		
	IF lEnv
		StaticCall(KAP_WF03,environmentActions,2)
	Endif
	
Return lRet 

Static Function ordemPAberta(_cPedido)
	Local	aArea 	:= GetArea()
	Local	cQuery	:= ""
	Local	cTemp	:= GetNextAlias()
	Local	lRet	:= .F.
	
	cQuery += "SELECT "+ENTER
	cQuery += "count(*) CONTA "+ENTER
	cQuery += "FROM "+RetSqlName("SC2")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND C2_FILIAL='"+xFilial("SC2")+"' "+ENTER
	cQuery += "AND C2_PEDIDO='"+_cPedido+"' "+ENTER
	// se ja produziu algo
	cQuery += "AND (C2_QUJE > 0 "+ENTER
	// ou encerrada
	cQuery += "		OR C2_DATRF <> '' ) "+ENTER
	
	If Select(cTemp)
		(cTemp)->( DbCloseArea() )
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	If !(cTemp)->( EOF() )
		lRet := (cTemp)->CONTA == 0
	Endif
	
	If Select(cTemp)
		(cTemp)->( DbCloseArea() )
	Endif
	
	RestArea(aArea)
Return lRet	


Static function apontarPedido(_cPedido,_cItem,_cProduto,_lLog)
	Local	aArea 	:= GetArea()
	Local	cQuery	:= ""
	Local	cTemp	:= GetNextAlias()
	Local	lRet	:= .F.
	Local	aMata250:= {}
	Local	cOp		:= ""
	Local	nModBkp	:= nModulo
	Local	cErro	:= ""

	Default _lLog	:= .T.
	
	cQuery += "SELECT "+ENTER
	cQuery += "R_E_C_N_O_ SC2REGNO "+ENTER
	cQuery += "FROM "+RetSqlName("SC2")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND C2_FILIAL='"+xFilial("SC2")+"' "+ENTER
	cQuery += "AND C2_PEDIDO='"+_cPedido+"' "+ENTER
	cQuery += "AND C2_ITEMPV='"+_cItem+"' "+ENTER
	cQuery += "AND C2_PRODUTO='"+_cProduto+"' "+ENTER
	
	If Select(cTemp)
		(cTemp)->( DbCloseArea() )
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	If !(cTemp)->( EOF() )
		dbSelectArea("SC2")
		SC2->( DbSetOrder(1) )
		SC2->( DbGoTo( (cTemp)->SC2REGNO ))
		lRet := SC2->(Recno() ) == (cTemp)->SC2REGNO
	Endif
	
	If Select(cTemp)
		(cTemp)->( DbCloseArea() )
	Endif
	
	If lRet
		nModulo := 10
		cOp 	:= SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
		nSaldo 	:= SC2->C2_QUANT - SC2->C2_QUJE
		If nSaldo > 0  
			SB1->( DbSetOrder(1) )
			If SB1->( MsSeek(xFilial("SB1")+SC2->C2_PRODUTO))
				aMata250 :={{"D3_OP"	  	, cOp						,Nil},;
							{"D3_COD"	  	, SC2->C2_PRODUTO			,Nil},;
							{"D3_LOCAL"		, SC2->C2_LOCAL				,Nil},;
							{"D3_EMISSAO"	, dDataBase					,Nil},;
							{"D3_PARCTOT"	, "T"			  			,Nil},;
							{"D3_TM"		, "020"						,Nil},;
							{"D3_QUANT"		, nSaldo					,Nil} }
				aMata250 := FWVetByDic( aMata250, "SD3" )
				Pergunte("MTA250",.F.)
				lMsErroAuto := .F.
				
				MSExecAuto({|x,y| mata250(x,y)},aMata250,3)
				If lMsErroAuto
					DisarmTransactions()
					If !isBlind()
						MostraErro()
					Else
						cErro := MostraErro("\")
						MemoWrite("\logs\kfata13\"+AllTrim(cOp)+"_"+AllTrim(SC2->C2_PRODUTO)+".log",cErro)
					Endif
					lRet := .F.
				Else
					lRet := enderecar()
					SC5->( DbSetOrder(1) )
					If SC5->(MsSeeks(xFilial("SC5")+_cPedido))
						RecLock("SC5",.F.)
							SC5->C5_XSITLIB := "6"
						MsUnLock("SC5")
					Endif
				Endif
			Endif
		Endif
	Endif
	
	nModulo := nModBkp 
	
	If lRet .and. _lLog
		U_KFATR15("22",SC2->C2_PEDIDO,SC2->C2_ITEM,,,"OP: "+ SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD)
	Endif

	RestArea(aArea)
	
Return lRet


Static Function GeraSD4(pOP)
	local 	nSC2Ord 	:= SC2->(IndexOrd())
	local 	nSC2Reg 	:= SC2->(Recno())
	Local 	nI			:= 0
	// area local
	local 	aArea 		:= GetArea()
	// flag para geração das op's em batch
	local 	lGerar 		:= .F.
	// total de op's a gerar
	local 	nOps 		:= 0
	// total de op's a gerar
	local 	nOpc 		:= 0
	local 	lRet 		:= .F.
	Local 	lA650GEF  	:= If(SuperGetMV("MV_A650GEF",.F.,"N")=="S",.T.,.F.)
	Local 	aFilial   	:= {}
	Local 	lUsaSemaf 	:= (SUPERGETMV("MV_SEMAFGE", .T., "N") == "S")

	Private aSav650 	:= Array(20)
	Private cTmpPPI   	:= ""
	Private aIntegPPI 	:= {}
	Private cBkpFilial	:= cFilAnt

	LMATA712 	:= .F.
	LPCPA107	:= .F.
	L650AUTO	:= .F.
	
	lZrHeader 	:= If(l650Auto,.T.,.F.)

	// atribui duas vezes para o compilador nao reclamar
	LMATA712 	:= .F.
	LPCPA107	:= .F.
	L650AUTO	:= .F.
	
	lZrHeader 	:= If(l650Auto,.T.,.F.)
	
	CONOUT("gerasd4 inicio")
	
	Pergunte("MTA650",.F.)
	mv_par13 := 2
	mv_par13 := 2
	//Salvar variaveis existentes
	For ni := 1 to 20
		aSav650[ni] := &("mv_par"+StrZero(ni,2))
	Next ni

	lConsNPT  := (aSav650[14] == 1)
	lConsTerc := !(aSav650[15] == 1)

	lConsNPT  := (aSav650[14] == 1)
	lConsTerc := !(aSav650[15] == 1)
	
	//Pega as filiais do grupo de empresas.
	If lA650GEF
		aFiliais := FWAllFilial(,,cEmpAnt,.F.) 
		For nI := 1 To Len(aFiliais)
		   aAdd(aFilial,{aFiliais[nI],0})
		Next nI
	Else
		aAdd(aFilial,{cFilAnt,0})
	EndIf
	
	aOPC1     :={}
	aOPC7     :={}
	aDataOPC1 :={}
	aDataOPC7 :={}

	aOPC1     :={}
	aOPC7     :={}
	aDataOPC1 :={}
	aDataOPC7 :={}
	
	DbSelectArea("SC2")
	a650RegOPI(@lGerar, @nOps,,@aFilial)
	If lGerar
		If l650Auto
			nPos := aScan(aRotProd,{|x| x[1] == "AUTEXPLODE"})
			If ( nPos > 0 .and. aRotProd[nPos,2] == "S" )
				nOpc := 1
			Else
				nOpc := 2
			EndIf
		Else
			//MTA650OK(@nOpc)
			nOpc := 1
		EndIf
		If nOpc == 1
		
			For nI := 1 To Len(aFilial)
				If aFilial[nI,2] < 1
					Loop
				EndIf
				cFilAnt := aFilial[nI,1]
			
				DbSelectArea("SC2")
				//If lMult650 .And. !lProj711
				//	StartJob("MA650JProc",GetEnvServer(),.F.,@lEnd, cEmpAnt,cFilAnt, nOps, RetCodUsr())
				//Else
					If ( l650Auto )
						CONOUT("process")
						MA650Process(@lEnd,nOps)
					Else
					    If Len(aFilial) > 1
							cTitle := AllTrim("Geração de OPs Intermediarias e SCs. Filial: 01") + ". " + AllTrim("") + aFilial[nI,1] //
						Else
							cTitle := AllTrim("Geração de OPs Intermediarias e SCs. Filial: 01") //"Gera‡„o de OPs Intermediarias e SCs"
						EndIf
						CONOUT("process")
						Processa({|lEnd| MA650Process(@lEnd,nOps)},"Geração de OPs Intermediarias e SCs. Filial: 01",OemToAnsi("Gerando OPs Intermediarias e SCs..."),.F.) 	//"Gera‡„o de OPs Intermediarias e SCs"###"Gerando OPs Intermediarias e SCs..."
						If Len(aIntegPPI) > 0
							cMsg := "Atenção! Ocorreram erros na integração com o PCFactory. Erro: " + CHR(10) //
							For ni := 1 To Len(aIntegPPI)
								cMsg += "OP: " + AllTrim(aIntegPPI[ni,1]) + " - " + AllTrim(aIntegPPI[ni,2]) + CHR(10)
							Next ni
							Aviso("",cMsg,{"Ok"},3)
						EndIf
					EndIf
	                //EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada executado apos o processamento da inclusao  ³
				//³ da Op e os pedidos de compras.                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ExistTemplate("A650PROC"))
					ExecTemplate('A650PROC',.F.,.F.)
				EndIf
	
				If (ExistBlock("A650PROC"))
					ExecBlock('A650PROC',.F.,.F.)
				EndIf
			Next nI
			cFilAnt := cBkpFilial				
		EndIf
	EndIf
	If !Empty(cTmpPPI)
       TCDelFile(cTmpPPI)
    EndIf

	If lUsaSemaf
		UnLockByName("650USOGOP",.T.,.T.)
	EndIf

	SC2->(DbSetOrder(nSC2Ord))
	SC2->(DbGoTo(nSC2Reg))
	CONOUT("fim")
return lRet

// StaticCall(KFATA13,enderecar)
Static function enderecar()
	Local	lRet		:= .T.
	Local	aCab		:= {}
	Local	aItens		:= {}
	Local	cEndereco	:= Padr( GetMv("KA_PERSEND",,"EXPEDICAO"),TamSx3("DB_LOCALIZ")[1]  )
	Local	nModBkp		:= nModulo
	Local	cItemEnd	:= ""
	Local	cItemAnt	:= ""
	
	nModulo := 4
	
	//SD3->( DbGoTo(1525719) )
	
	If temSaldo()
		
		// recupera o item de endereçamento
		cItemEnd := GetItemEnd( SDA->DA_PRODUTO, SDA->DA_LOCAL, SDA->DA_DOC, SDA->DA_ORIGEM, SDA->DA_LOTECTL, SDA->DA_NUMSEQ )
		cItemAnt := StrZero( Val(cItemEnd) - 1, TamSx3("DB_ITEM")[01] )
		
		aCab := {}
		AAdd( aCab, {"DA_PRODUTO", SDA->DA_PRODUTO	, nil} )
		AAdd( aCab, {"DA_NUMSEQ" , SDA->DA_NUMSEQ	, nil} )

		aItens := {}
		AAdd( aItens, {"DB_ITEM"   , cItemAnt						, nil} )
		AAdd( aItens, {"DB_ESTORNO", " "							, nil} )
		AAdd( aItens, {"DB_LOCALIZ", Padr(cEndereco, 15)			, nil} )
		AAdd( aItens, {"DB_QUANT"  , SDA->DA_SALDO					, nil} )
		AAdd( aItens, {"DB_NUMSERI", Space(TamSx3("DB_NUMSERI")[01]), nil} )
		AAdd( aItens, {"DB_DATA"   , Date()							, nil} )
		
		lMsErroAuto	:= .F.

		MsExecAuto( {|x, y, z| mata265(x, y, z)}, aCab, {aItens}, 3 )
		
		If lMsErroAuto
			DisarmTransactions()
			mostraerro()
			lRet := .F.
		Endif
	Endif
	
	nModulo := nModBkp
	
Return lRet

Static Function temSaldo()
	Local lRet	:= .F.
	Local cQuery:= ""
	Local cTemp	:= GetNextAlias()
	
	cQuery += "SELECT "+ENTER
	cQuery += "	DA_SALDO "+ENTER
	cQuery += "	,R_E_C_N_O_ SDAREGNO "+ENTER
	cQuery += "FROM "+RetSqlName("SDA")+" "+ENTER
	cQuery += " "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "	D_E_L_E_T_ <> '*' "+ENTER
	cQuery += "AND DA_FILIAL   = '"+SD3->D3_FILIAL	+"' "+ENTER
	cQuery += "AND DA_NUMSEQ   = '"+SD3->D3_NUMSEQ	+"' "+ENTER
	cQuery += "AND DA_PRODUTO  = '"+SD3->D3_COD		+"' "+ENTER
	cQuery += "AND DA_DOC      = '"+SD3->D3_DOC		+"' "+ENTER
	
	If Select(cTemp)>0
		(cTemp)->( DbCloseArea() )
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	If !(cTemp)->( EOF() )
		lRet := (cTemp)->DA_SALDO > 0
		If lRet
			SDA->( DbGoTo( (cTemp)->SDAREGNO ))
		Endif
	Endif
	
	If Select(cTemp)>0
		(cTemp)->( DbCloseArea() )
	Endif
	
Return lRet

/**********************************************************************************************************************************/
/** static function GetItemEnd( cCodProd, cLocal, cDoc, cOrigem, cContain, cNumSeq )                                             **/
/** Recupera o proximo item a endereçar                                                                                          **/
/**********************************************************************************************************************************/
static function GetItemEnd( cCodProd, cLocal, cDoc, cOrigem, cContain, cNumSeq )
	// retorno da função
	local cRet := ""
	// query
	local cQr := ""
	// area
	local aArea := GetArea()
	
	
	// monta a query para recuperar o proximo item
	cQr := " select max(SDB.DB_ITEM) DB_ITEM
	cQr += "   from " + RetSqlName("SDB") + " SDB
	cQr += "  where SDB.D_E_L_E_T_ = ' '
	cQr += "    and SDB.DB_FILIAL  = '" + XFilial("SDB") + "'
	cQr += "    and SDB.DB_PRODUTO = '" + cCodProd + "'
	cQr += "    and SDB.DB_LOCAL   = '" + cLocal + "'
	cQr += "    and SDB.DB_DOC     = '" + cDoc + "'
	cQr += "    and SDB.DB_ORIGEM  = '" + cOrigem + "'
	cQr += "    and SDB.DB_LOTECTL = '" + cContain + "'
	cQr += "    and SDB.DB_NUMSEQ  = '" + cNumSeq + "'
	
	TcQuery cQr new alias "QITE"
	RestArea(aArea)
	
	// busca o proximo item
	if ( Empty(QITE->DB_ITEM) )
		cRet := StrZero( 1, TamSx3("DB_ITEM")[01] )
	else
		cRet := StrZero( Val(QITE->DB_ITEM) + 1, TamSx3("DB_ITEM")[01] )
	endIf
	
	// fecha a query
	QITE->(dbCloseArea())

return cRet

Static Function fromFluig(cPedido)
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local lRet		:= .F.
	Local cTemp		:= GetNextAlias()
	
	cQuery += "SELECT COUNT(*) CONTA "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SC6")+" SC6 "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND B1_FILIAL='"+xFilial("SB1")+"' "+ENTER
	cQuery += "	AND B1_COD = C6_PRODUTO "+ENTER
	cQuery += "	AND B1_XOPFLU = 'S'" +ENTER"
	cQuery += " "+ENTER
	cQuery += "WHERE SC6.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND C6_FILIAL='"+xFilial("SC6")+"' "+ENTER
	cQuery += "AND C6_NUM='"+cPedido+"' "+ENTER
	cQuery += "AND C6_NUMORC<>'' "+ENTER
	
	If Select( cTemp ) > 0
		(cTemp)->( DbCloseArea() )
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	lRet := (cTemp)->CONTA > 0
	
	If Select( cTemp ) > 0
		(cTemp)->( DbCloseArea() )
	Endif
	
	RestArea(aArea)
Return lRet

Static Function fromPersonalizado(cPedido)
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local lRet		:= .F.
	Local cTemp		:= GetNextAlias()
	
	cQuery += "SELECT COUNT(*) CONTA "+ENTER
	cQuery += " "+ENTER
	cQuery += "FROM "+RetSqlName("SC6")+" "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND B1_FILIAL='"+xFilial("SB1")+"' "+ENTER
	cQuery += "	AND B1_COD = C6_PRODUTO "+ENTER
	cQuery += "	AND B1_XOPKAP = 'S' "+ENTER"
	cQuery += " "+ENTER
	cQuery += "WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "AND C6_FILIAL='"+xFilial("SC6")+"' "+ENTER
	cQuery += "AND C6_NUM='"+cPedido+"' "+ENTER
	
	If Select( cTemp ) > 0
		(cTemp)->( DbCloseArea() )
	Endif
	
	TcQuery cQuery New Alias (cTemp)
	
	lRet := (cTemp)->CONTA > 0
	
	If Select( cTemp ) > 0
		(cTemp)->( DbCloseArea() )
	Endif
	
	RestArea(aArea)
Return lRet


// funcao de teste
User Function KFATA13T()
	Local lRet := U_KFATA13B("04","01","318075","01","01052001")
	
	// chama static functions pro compilador nao reclamar
	// usada em validacoes fora
	ordemPAberta()
	// usada em validacoes fora
	fromFluig()
	// usada em validacoes fora
	fromPersonalizado()

Return



