#include 'protheus.ch'
#include 'TOPCONN.ch'

User Function ACDA100I()
	Local lRetorno 	:= .T.
	Local lRet		:= .F.
	Local aEmpenhos := {}
	Local cAlias
	Local lTem := .F.
	Local _nQtdD4   := 0
	Local _nQtdDc   := 0
	
	Local aArea := GetArea()
	
	DbSelectArea('AKA')
	AKA->(DbSetOrder(1))
	AKA->(DbGoTop())               //ALGUM PROCESSO ESTÁ APAGANDO OS REGISTROS. RESTAURA ANTES DA UTILIZAÇÃO
	If !AKA->(DbSeek(xFilial('AKA')+'090001'))
		TcSqlExec("UPDATE "+RetSqlName('AKA')+" SET D_E_L_E_T_ = ' ' WHERE AKA_PROCES = '090001' AND D_E_L_E_T_ != ' ' ")
		TcSqlExec("UPDATE "+RetSqlName('AKB')+" SET D_E_L_E_T_ = ' ' WHERE AKB_PROCES = '090001' AND D_E_L_E_T_ != ' ' ")	
	EndIf
	
	lRet := PCOVldLan("090001","02","ACDA100",.T.)  
	If !lRet
		PcoDetLan("090001","02","ACDA100")
		Return .F.
	EndIf
	
	PcoIniLan("090001")


	IF IsInCallStack("GeraOSepProducao")

		SD4->( dbSetOrder(2) )
		SD4->( dbSeek( xFilial("SD4") + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) ) )

		While !SD4->( Eof() ) .And. SD4->(D4_FILIAL+D4_OP) == xFilial("SD4") + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)

			aAdd(aEmpenhos,{;
							SD4->D4_COD,;		//[01] - Produto
							SD4->D4_LOCAL,;		//[02] - BC10003376
							SD4->D4_TRT,;		//[03] - Sequencia na Estrutura
							SD4->D4_LOTECTL,;	//[04] - Lote
							SD4->D4_NUMLOTE,;	//[05] - Sub-Lote
							SD4->D4_QTDEORI,;	//[06] - Quantidade Empenhada
							SD4->D4_QUANT,;		//[07] - Saldo da Qtd. Empenhada
							0})					//[08] - Quantidade na CN8

			SD4->( dbSkip() )
		EndDO


		CB7->( dbSetOrder(5) )
		CB7->( dbSeek( xFilial("CB7") + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) ) )

		While !CB7->( Eof() ) .And. CB7->(CB7_FILIAL+CB7_OP) == xFilial("CB7") + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
			lTem := .T.
			IF CB7->CB7_STATUS != "9"
				lRetorno := .F.
				aAdd(aLogOS,{"2","OP",SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),"","","Existe uma Ordem de Separacao em aberto para esta Ordem de Producao","NAO_GEROU_OS"})
	//		Else
	//			CB8->( dbSetOrder(1) )
	//			CB8->( dbSeek( xFilial("CB8") + CB7->CB7_ORDSEP ) )
	//
	//			While !CB8->( Eof() ) .And. CB8->(CB8_FILIAL+CB8_ORDSEP) == CB7->(CB7_FILIAL+CB7_ORDSEP)
	//				nPos := aScan(aEmpenhos, {|x| x[1]+x[2]+x[3]+x[4]+x[5] == CB8->(CB8_PROD+CB8_LOCAL+CB8_TRT+CB8_LOTECT+CB8_NUMLOT)  })
	//				IF nPos != 0
	//					aEmpenhos[nPos][8] += CB8->CB8_QTDORI
	//				EndIF
	//				CB8->( dbSkip() )
	//			EndDO
			EndIF
			CB7->( dbSkip() )
		EndDO
  
		
	  	//Para tratar EPIs, caos contrário não separa
		/*
  		If SubStr(SC2->C2_PRODUTO,1,3) == 'EPI'
  			RecLock('SC2',.F.)   
  			SC2->C2_PRODUTO := "MANUTENCAO"
  			msUnlock()  
  		EndIf
		*/
		cAlias := getNextAlias()
				
		BeginSQL Alias cAlias

			SELECT SUM(D4_QUANT) AS D4QUANT
			FROM %TABLE:SC2% SC2
			LEFT JOIN %TABLE:SD4% SD4 ON C2_FILIAL = D4_FILIAL AND D4_OP = C2_NUM+C2_ITEM + C2_SEQUEN AND SD4.%NotDel% 
			WHERE SC2.%NotDel% AND C2_NUM+C2_ITEM + C2_SEQUEN = %EXP: SC2->(C2_NUM+C2_ITEM + C2_SEQUEN)%	

		EndSQL

		IF !(cAlias)->(Eof())
			_nQtdD4 := (cAlias)->D4QUANT
		ENDIF
		
		(cAlias)->(dbCloseArea())
		
		cAlias := getNextAlias()
				
		BeginSQL Alias cAlias

			SELECT SUM(DC_QUANT) AS DCQUANT  
			FROM %TABLE:SC2% SC2
			LEFT JOIN %TABLE:SDC% SDC ON C2_FILIAL = DC_FILIAL AND DC_OP = C2_NUM+C2_ITEM + C2_SEQUEN AND SDC.%NotDel% 
			WHERE SC2.%NotDel% AND C2_NUM+C2_ITEM + C2_SEQUEN = %EXP: SC2->(C2_NUM+C2_ITEM + C2_SEQUEN)%	

		EndSQL

		IF !(cAlias)->(Eof())
			_nQtdDc := (cAlias)->DCQUANT
		ENDIF
		
		(cAlias)->(dbCloseArea())
		
		
		IF _nQtdDc <= 0 .OR. _nQtdD4 <= 0 
			MSGALERT('Não foi possível gerar a Ordem de Separação, pois esta OP não possui empenhos.','Atenção '+PROCNAME())
			lRetorno := .F.
		ELSEIF _nQtdDc!= _nQtdD4
			MSGALERT('Não foi possível gerar a Ordem de Separação, pois os empenhos desta OP estão desbalanceados.','Atenção '+PROCNAME())
			lRetorno := .F.
		ENDIF
		
  
	EndIF


 //		IF lTem .And. lRetorno

//			For n1 := 1 to len(aEmpenhos)
//				IF !(( aEmpenhos[nPos][6] - aEmpenhos[nPos][7] ) >= aEmpenhos[nPos][8])
//					lRetorno := .F.
//				EndIF
//			Next n1
                                       

//[06] - Quantidade Empenhada
//[07] - Saldo da Qtd. Empenhada
//[08] - Quantidade na CN8

//			IF !lRetorno
//				lRetorno := Aviso("Atenção", "A ordem de produção "+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+" possui empenho para requisição em aberto referente ao ordem de serviço, Deseja continuar e gerar OS com o saldo em aberto de outra OS?", {"Continuar","Pular"}, 2) == 1
//			EndIF
			
//			IF !lRetorno
//				Aviso("Atenção", "A ordem de produção " + AllTrim(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)) +;
//								 " possui empenho para requisição em aberto referente a ordem de serviço.", {"Ok"}, 2)
//			EndIF
			
//		EndIF

                       
//PcoFinLan("090001")


	RestArea(aArea)

Return lRetorno


/*/{Protheus.doc} Acd100M
LOCALIZAÇÃO : Function ACDA100- Função responsável por gerar a ordem de separação.
 EM QUE PONTO : No início da Função, antes de montar a tela do browser, pode ser usado para adicionar opções na rotina.

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6090962
/*/
User Function Acd100M()

	//rotina para consulta da liberação
	aAdd(aRotina,{"Consulta Aprovacao"	    ,"u_AAcd010Consulta",0,3})
	//aAdd(aRotina,{"Dev.Material"		,"U_AACD013()"		,0,4})	//Rotina para deveolução de materiais
	aAdd(aRotina,{"Fechamento de Ordem"	    ,"U_AACD014()"		,0,6})	//Fechamento de Ordem	
	aAdd(aRotina,{"Recibo EPI (Biometria)"	,"MDTA333()"		,0,7})	//Recibo de Epi via Biometria	

Return


/*/{Protheus.doc} AcdA100F
Este ponto de entrada é utilizado para incluir validações em cada item considerado para gerar ordens de separação.
LOCALIZAÇÃO: Função GeraOSepPedido - Gera as ordens de separacao a partir dos itens da MarkBrowse.
EM QUE PONTO: No loop dos itens das ordens de separação.

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6091072
/*/
User Function AcdA100F()
Local aArea := CB8->(GetArea())
// 45010137     
	cSepara := ParamIxb[1]   
	DbSelectArea('CB8')
	CB8->(DbSetOrder(1))
	CB8->(DbGoTop())
	IF !CB8->(DbSeek(xFilial('CB8')+cSepara))
		cQuery := " SELECT * FROM "+RetSqlName('SD4')+" WHERE D4_FILIAL = '"+xFilial('CB8')+"' AND D4_OP = '"+CB7->CB7_OP+"' AND D4_QUANT > 0 AND D_E_L_E_T_ != '*' "
		If SELECT("TMPCB8") > 0
			TMPCB8->(dbCloseArea())
		EndIf
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMPCB8",.T.,.F.)	
		DbSelectArea('TMPCB8')
		nSeq := 0		
		While !TMPCB8->(EOF())   
			nSeq++
			RecLock('CB8',.T.)
			CB8->CB8_FILIAL := xFilial('CB8')
			CB8->CB8_ORDSEP := cSepara
			CB8->CB8_ITEM 	:= StrZero(nSeq,2)
			CB8->CB8_PROD 	:= TMPCB8->D4_COD
			CB8->CB8_LOCAL 	:= TMPCB8->D4_LOCAL
			CB8->CB8_QTDORI := TMPCB8->D4_QUANT
			CB8->CB8_SALDOS := TMPCB8->D4_QUANT
			CB8->CB8_LCALIZ := Posicione('SDC',2,xFilial('SDC')+TMPCB8->D4_COD+TMPCB8->D4_LOCAL+TMPCB8->D4_OP+TMPCB8->D4_TRT,"DC_LOCALIZ")
			CB8->CB8_CFLOTE := '1'
			CB8->CB8_OP 	:= TMPCB8->D4_OP
			CB8->CB8_TRT 	:= TMPCB8->D4_TRT
			SB2->( dbSetOrder(1) )
			SB2->( dbSeek( xFilial("SB2") + CB8->(CB8_PROD+CB8_LOCAL) ) )
			//salva o custo medio os itens da ordem de separação
			CB8->CB8_CUSTOL := SB2->B2_CM1		
			MsUnlock()      
			
		   	TMPCB8->(DbSkip())
		EndDo
		TMPCB8->(dbCloseArea())
	EndIf
	
	//se for Ordem de Produção
	IF CB7->CB7_ORIGEM == '3'

		//aqui vai enviar/gerar os niveis de bloqueios
		u_AAcd010Gera()
		
		SC2->(DbSetOrder(1))
		If SC2->(DbSeek(xFilial("SC2")+CB7->CB7_OP))
			RecLock("SC2",.F.)
			SC2->C2_OK := " " // Limpa o OK para não correr risco de repetir
			SC2->(MsUnlock())
		EndIf
		
	EndIF
RestArea(aArea)
Return



/*/{Protheus.doc} Acd100Et
LOCALIZAÇÃO: Function ACDA100Et -  Programa de estorno da Ordem de Separacao.
 EM QUE PONTO: Após confirmação do estorno do documento, permite efetuar tratamentos específicos do usuário.

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6091156
/*/
User Function Acd100Et()

	//aqui vai enviar excluir os niveis de bloqueios
	u_AAcd010Estorna()
	
	//Atualiza o status da Reserva no manusis
	If SUPERGETMV( 'TCP_MANUSI', .f., .F. ) .AND. !EMPTY(CB7->CB7_XOM)
		DbSelectArea('ZZF')
		ZZF->(DbSetOrder(2))
		//ZZF->(DbGOTOP())
		//ZZF->(DBOrderNickname( 'NUMEROOP'))
		//ZZF->(DbGOTOP())
		IF ZZF->(DbSeek(xFilial('ZZF')+CB7->CB7_OP))
			oManusis  := ClassIntManusis():newIntManusis()    
			oManusis:cFilZze    := xFilial('ZZE')
			oManusis:cChave     := CB7->CB7_FILIAL+CB7->CB7_OP
			oManusis:cTipo	    := 'E'
			oManusis:cStatus    := 'P'
			oManusis:cErro      := ''
			oManusis:cEntidade  := 'AWF'
			oManusis:cOperacao  := 'I'
			oManusis:cRotina    := FunName()
			oManusis:cErroValid := ''
			oManusis:cTxtStat   := 'Separação estornada.'
			
			IF oManusis:gravaLog()  
				U_MNSINT03(oManusis:cChaveZZE)              
			ELSE
				ALERT(oManusis:cErroValid)
			ENDIF  
			
			While !ZZF->(EOF()) .AND. ALLTRIM(ZZF->ZZF_OP) == ALLTRIM(CB7->CB7_OP)
			
				nRecZzf := ZZF->(RECNO())
				
				oManusis  := ClassIntManusis():newIntManusis()    
				oManusis:cFilZze    := xFilial('ZZE')
				oManusis:cChave     := ZZF->ZZF_FILIAL+ZZF->ZZF_OP+ZZF->ZZF_RESERV
				oManusis:cTipo	    := 'E'
				oManusis:cStatus    := 'P'
				oManusis:cErro      := ''
				oManusis:cEntidade  := 'SOP'
				oManusis:cOperacao  := 'I'
				oManusis:cRotina    :=  FunName()
				//
				oManusis:cStatOp 	:= '1'
			
				IF oManusis:gravaLog()  
					U_MNSINT03(oManusis:cChaveZZE)              
				ELSE
					ALERT(oManusis:cErroValid)
				ENDIF 
				
				
				ZZF->(DbSetOrder(2))
				ZZF->(dbGoTo(nRecZzf))
				
				ZZF->(DbSkip())
			EndDo
		ENDIF			
					
	ENDIF
Return


/*/{Protheus.doc} Acd100Gi
LOCALIZAÇÃO: FUNCTION - GeraOSepPedido()- Gera as ordens de separação por pedido de vendas, a partir dos itens da MarkBrowse.
			 FUNCTION - GeraOSepNota()- Gera as ordens de separação pela nota fiscal de saída, a partir dos itens da MarkBrowse.
			 FUNCTION - GeraOSepProducao() - Gera as ordens de separação pela ordem de produção a partir dos itens da MarkBrowse.
 EM QUE PONTO: No momento da gravação dos itens da ordem de separação, permitindo gravar campos

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@see http://tdn.totvs.com/pages/releaseview.action?pageId=6090961
/*/
User Function Acd100Gi()

	Local aSaveArea := SaveArea1({"SB2"})
	Local lRetorno 	:= .T.
	Local aEmpenhos := {}
	Local lTem 		:= .F.
	Local cQuery	:= ""
	Local cAliasD4	:= ""
	Local cAliasCB	:= ""
	Local nQtdOri	:= 0
	Local nSaldos	:= 0

	SB2->( dbSetOrder(1) )
	SB2->( dbSeek( xFilial("SB2") + CB8->(CB8_PROD+CB8_LOCAL) ) )

	//salva o custo medio os itens da ordem de separação
	CB8->CB8_CUSTOL := SB2->B2_CM1

	IF IsInCallStack("GeraOSepProducao") .And. CB8->( FieldPos("CB8_TRT") ) != 0
		CB8->CB8_TRT := SD4->D4_TRT
	EndIF
/*		
	cQuery := "	SELECT D4_COD, D4_LOCAL, D4_TRT, D4_LOTECTL, D4_NUMLOTE, D4_QTDEORI, D4_QUANT " + CRLF
	cQuery += "	FROM " + RetSqlName("SD4") + " " + CRLF
	cQuery += "	WHERE " + CRLF	
	cQuery += "			D4_FILIAL =  " + xFilial("SD4") + " " + CRLF
	cQuery += "		AND	D4_OP = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + "' " + CRLF
	cQuery += "		AND D_E_L_E_T_ = ' ' " + CRLF
	
	Memowrite("C:\TEMP\ACDA100_01.TXT",cQuery)
	If SELECT("cAliasD4") > 0
		(cAliasD4)->(dbCloseArea())
	EndIf
	cAliasD4 := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasD4,.T.,.F.)		
	
	While !(cAliasD4)->(Eof())
*/	
		cQuery := "	SELECT CB8_ITEM, CB8_PROD, CB8_LCALIZ, CB8_QTDORI, CB8_SALDOS " + CRLF
		cQuery += "	FROM " + RetSqlName("CB7") + " CB7 " + CRLF
		cQuery += "	INNER JOIN " + RetSqlName("CB8") + " CB8 ON " + CRLF
		cQuery += "			CB8_FILIAL = CB7_FILIAL " + CRLF
		cQuery += "		AND CB8_ORDSEP = CB7_ORDSEP " + CRLF
		cQuery += "		AND CB8.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "	WHERE " + CRLF
		cQuery += "			CB7_FILIAL = " + xFilial("CB7") + " " + CRLF
		cQuery += "		AND CB7_OP = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + "' " + CRLF
		cQuery += "		AND CB7_STATUS = 9 " + CRLF
		cQuery += "		AND CB7.D_E_L_E_T_ = ' ' " + CRLF	

		Memowrite("C:\TEMP\ACDA100_02.TXT",cQuery)
		If SELECT("cAliasCB") > 0
			(cAliasCB)->(dbCloseArea())
		EndIf
		cAliasCB := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasCB,.T.,.F.)	

		If (cAliasCB)->(Eof())
			nQtdOri := CB8->CB8_QTDORI
			nSaldos := CB8->CB8_SALDOS
		Else
			nQtdOri := CB8->CB8_QTDORI
			nSaldos := CB8->CB8_SALDOS
		EndIf	
				
		(cAliasCB)->(dbCloseArea())	
/*		
		(cAliasD4)->(dbSkip())
	
	EndDo

	(cAliasD4)->(dbCloseArea())
*/	
	CB8->CB8_QTDORI := nQtdOri
	CB8->CB8_SALDOS := nSaldos
	
/*
	CB7->( dbSetOrder(5) )
	CB7->( dbSeek( xFilial("CB7") + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) ) )

	//Verifica se todas as Ordens de separação da OP estão finalizadas 
	While !CB7->( Eof() ) .And. CB7->(CB7_FILIAL+CB7_OP) == xFilial("CB7") + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)

		IF CB7->CB7_STATUS == "9"

			CB8->( dbSetOrder(1) )
			CB8->( dbSeek( xFilial("CB8") + CB7->CB7_ORDSEP ) )

			While !CB8->( Eof() ) .And. CB8->(CB8_FILIAL+CB8_ORDSEP) == CB7->(CB7_FILIAL+CB7_ORDSEP)
				nPos := aScan(aEmpenhos, {|x| x[1]+x[2]+x[3]+x[4]+x[5] == CB8->(CB8_PROD+CB8_LOCAL+CB8_TRT+CB8_LOTECT+CB8_NUMLOT)  })
				IF nPos != 0
					aEmpenhos[nPos][8] += CB8->CB8_QTDORI
				EndIF
				CB8->( dbSkip() )
			EndDO

		EndIF

		CB7->( dbSkip() )
	EndDO

	RestArea1(aSaveArea)

//	CB8->(DbGoTo(nRegnoSB8))
*/


Return


/* {Protheus.doc} Acd100Cr
O ponto de entrada ACD100CR manipula as regras padrões ou adiciona novas condições, após montagem do array com as regras para apresentação das cores dos status na mBrowse.
 Localização: Function ACDA100 - Ordem de Separação

@author Rafael Ricardo Vieceli
@since 07/2015
@version 1.0
@return aCores, array, Legendas
@see http://tdn.totvs.com/display/public/mp/ACD100CR+-+Manipula+regras+de+cores+de+status+na+mBrowse
 */
User Function Acd100Cr()

	Local aCoresPadrao := ParamIXB[1]
	Local aCores := {}
	Local n1

	//adiciona por primeiro a legenda bloqueado
	aAdd( aCores, { "CB7->CB7_ORIGEM == '3' .And. CB7->CB7_LIBOK == 'B'", "BR_PINK"  } )
	//depos as padrões
	For n1 := 1 to len(aCoresPadrao)
		aAdd(aCores, aCoresPadrao[n1])
	Next n1

Return aCores



/*/{Protheus.doc} Acd100Lg
O ponto de entrada ACD100LG manipula o array com as regras para apresentação das cores dos status na mBrowse, após a montagem do Array contendo as legendas da tabela CB7 e antes da execução da função Brwlegenda que monta a dialog com as legendas, utilizado para adicionar legendas na dialog.
 LOCALIZAÇÃO : Function ACDA100Lg - Função da dialog de legendas da mBrowse da rotina Ordem de Separação.

@author Rafael Ricardo Vieclei
@since 07/2015
@version 1.0
@return aCorDesc, array, Legendas
@see http://tdn.totvs.com/pages/releaseview.action?pageId=88900209
/*/
User Function Acd100Lg()

	Local aCorDescPadrao := ParamIXB[1]
	Local aCorDesc := {}
	Local n1

	//adiciona por primeiro a legenda bloqueado
	aAdd( aCorDesc, { "BR_PINK"   , "- Pendente Liberação" } )
	//depos as padrões
	For n1 := 1 to len(aCorDescPadrao)
		aAdd(aCorDesc, aCorDescPadrao[n1])
	Next n1

Return aCorDesc




User Function A100CABE()    

	//Atualiza o status da Reserva no manusis
	If SUPERGETMV( 'TCP_MANUSI', .f., .F. )
		DbSelectArea('ZZF')
		ZZF->(DbSetOrder(2))
		//ZZF->(DBOrderNickname( 'NUMEROOP'))
		IF ZZF->(DbSeek(xFilial('ZZF')+CB7->CB7_OP))
			
			CB7->CB7_XOM := ZZF->ZZF_OM
			
			if EMPTY(ZZF->ZZF_OM)
				WHILE CB7->CB7_OP == ZZF->ZZF_OP
					if !EMPTY(ZZF->ZZF_OM)
						CB7->CB7_XOM := ZZF->ZZF_OM
					endif
					ZZF->(DBSKIP())
				ENDDO
			ENDIF
				
		ENDIF			
					
	ENDIF
Return	

/*
USER FUNCTION ACDA100I 
Local lRet := .T. // Customizações do cliente. O exemplo abaixo, para opcao por Ordem de Produção, ao retornar .F. (falso), é para não gerar OS se já foi efetuada anteriormente a separação para a OP.
     
Return lRet

*/


