
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} EXTGD02
(Extrator de dados gooddata DRE Produto)
@type function
@author Fernando Nonato
@since 10/08/2018
@version 1.0
/*/
User Function EXTGD02()

	Local bProcess
	Local oProcess

	bProcess := {|oSelf| EXTGD02A(oSelf) }

	oProcess := tNewProcess():New("GDEXT02","Extrator GoodData",bProcess,"Rotina para extração de dados para o DRE de produtos especifica para o MADERO.",,,.F.,,,.T.,.F.)
	
Return

/*/{Protheus.doc} APCP201E
(Chamada para execução das Rotinas)
@type function
@author Fernando Nonato
@since 10/08/2018
@version 1.0
/*/
Static Function EXTGD02A(oProc)
	Local dDtFech 	:= GETMV("MV_ULMES")
	
	
	cSql := " SELECT D2_COD, SUM(D2_QUANT) D2_QUANT, SUM(D2_TOTAL) D2_TOTAL, SUM(D2_VALFRE) D2_VALFRE, SUM(D2_ICMSRET) D2_ICMSRET, "
	cSql += " SUM(D2_VALICM) D2_VALICM, SUM(D2_VALIMP5) D2_VALCOF, SUM(D2_VALIMP6) D2_VALPIS, SUM(D2_CUSTO1) D2_CUSTO1  " 
	cSql += " FROM " + RetSqlName('SD2') + " SD2 "
	cSql += " WHERE D2_FILIAL = '" + xFilial('SD2') + "' AND D2_EMISSAO BETWEEN '" + dtos(FirstDate(dDtFech)) +"' AND " 
	cSql += " '" + dtos(dDtFech) +"' AND SD2.D_E_L_E_T_ = ' ' "
	cSql += " GROUP BY D2_COD "
	cSql := ChangeQuery(cSql)
	
	TcQuery cSql NEW ALIAS "QRY"
	
	
	nTotalLinhas := 0 
	QRY->(DbGotop())
	While QRY->(!EOF())
		nTotalLinhas++
		QRY->(dBSkip())
	EndDo
	oProc:SetRegua1( nTotalLinhas ) //Seta Regua 1
	oProc:IncRegua1("Processando registros da Tabela de Faturamento (SD2)... " ) // Descrição Regua
	
	QRY->(DbGotop())
	n := 0
	While QRY->(!EOF()) 
		n++
		oProc:IncRegua1("Processando produto " + Alltrim(QRY->D2_COD) + " registro " + alltrim(str(n)) + " de " + alltrim(str(nTotalLinhas))  ) // Descrição Regua 2
		oProc:SetRegua2( 3 ) //Seta Regua 2
		
		DbSelectArea("Z50")
		DbSetOrder(1) // MATERIA PRIMA
		
			
		If Z51->(DbSeek(xFilial("Z50") + dtos(dDtFech) + QRY->D2_COD))
			RecLock("Z50",.F.)
		Else
			RecLock("Z50",.T.)
			Z50->Z50_DTREF 	:= dDtFech
			Z50->Z50_COD	:= QRY->D2_COD
		Endif
			
		SB1->(dbSetOrder(1))
		SB1->(dbSeek( xFilial("SB1") + QRY->D2_COD ))

		cSql := " SELECT SUM(D3_CUSTO1) D3_CUSTO1, SUM(D3_QUANT) D3_QUANT "
		cSql += " FROM " + RetSqlName('SD3') + " SD3 "
		cSql += " WHERE D3_FILIAL = '" + xFilial('SD3') + "' AND D3_EMISSAO BETWEEN '" + dtos(FirstDate(dDtFech)) +"' AND " 
		cSql += " '" + dtos(dDtFech) +"' AND SD3.D_E_L_E_T_ = ' ' AND D3_CF = 'PR0' "
		cSql += " AND D3_COD = '" + QRY->D2_COD + "' "
		cSql := ChangeQuery(cSql)
	
		TcQuery cSql NEW ALIAS "QRY_D3"
		nCustProd 	:= 0
		nQtdProd 	:= 0
		
		if QRY_D3->(!EOF())
			nCustProd 	:= QRY_D3->D3_CUSTO1
			nQtdProd 	:= QRY_D3->D3_QUANT
		endif
		QRY_D3->(DbCloseArea())
		
		
		cSql := " SELECT SUM(D1_TOTAL) D1_TOTAL "
		cSql += " FROM " + RetSqlName('SF1') + " SF1 "
		cSql += " LEFT JOIN " + RetSqlName('SD1') + " SD1 ON D1_FILIAL = '" + xFilial('SF1') + "' "
		cSql += " AND D1_COD = '" + QRY->D2_COD + "' "
		cSql += " WHERE F1_FILIAL = '" + xFilial('SF1') + "' AND F1_EMISSAO BETWEEN '" + dtos(FirstDate(dDtFech)) +"' AND " 
		cSql += " '" + dtos(dDtFech) +"' AND SF1.D_E_L_E_T_ = ' ' AND F1_TIPO = 'D' "
		cSql := ChangeQuery(cSql)
	
		TcQuery cSql NEW ALIAS "QRY_D1"
		nTotDev := 0
		
		if QRY_D1->(!EOF())
			nTotDev 	:=  QRY_D1->D1_TOTAL
		endif
		QRY_D1->(DbCloseArea())
		
		// 32020010002 - Energia Eletrica
		// 32020010004 - Gas
		// 32020010005 - Seguros
		// 32020400004 - Manutenção de Máquinas e Equipamentos
		// 32020300002 - Combustiveis e Lubrificantes
		// 32020700002 - Despesas de Viagem - Logistica
		// 32020750006 - IPVA e Licenciamentos
		
		cSql := " SELECT CT2_DEBITO, SUM(CT2_VALOR) CT2_VALOR "
		cSql += " FROM " + RetSqlName('CT2') + " CT2 " 
		cSql += " WHERE CT2_FILIAL = '" + xFilial('CT2') + "' AND D_E_L_E_T_ = ' ' " 
		cSql += " AND CT2_DEBITO IN  ('32020010002','32020010004','32020010005','32020400004','32020300002','32020700002','32020750006') "
		cSql += " GROUP BY CT2_DEBITO "
		cSql := ChangeQuery(cSql)
		
		TcQuery cSql NEW ALIAS "QRY_CT2"
		QRY_CT2->(DbGotop())            
			
		Do While QRY_CT2->(!Eof())
			if alltrim(QRY->CT2_DEBITO) = '32020010002'
				nEneEle := QRY->CT2_VALOR
			elseif alltrim(QRY->CT2_DEBITO) = '32020010004'
				nGas := QRY->CT2_VALOR
			elseif alltrim(QRY->CT2_DEBITO) = '32020010005'
				nSeguro := QRY->CT2_VALOR
			elseif alltrim(QRY->CT2_DEBITO) = '32020400004'
				nManMaq := QRY->CT2_VALOR
			elseif alltrim(QRY->CT2_DEBITO) = '32020300002'
				nCombLub := QRY->CT2_VALOR
			elseif alltrim(QRY->CT2_DEBITO) = '32020700002'
				nDespVia := QRY->CT2_VALOR
			elseif alltrim(QRY->CT2_DEBITO) = '32020750006'
				nIPVA := QRY->CT2_VALOR
			endif
			
			
			QRY_CT2->(dbSkip())
		EndDo
	            
		QRY_CT2->(DbCloseArea())
		
		Z50->Z50_FILIAL	:= xFilial("Z50")
		Z50->Z50_TIPO	:= SB1->B1_TIPO
		Z50->Z50_GRUPO	:= SB1->B1_GRUPO
		Z50->Z50_COD	:= SB1->B1_COD
		Z50->Z50_DESC	:= SB1->B1_DESC
		Z50->Z50_QTDVEN	:= QRY->D2_QUANT
		Z50->Z50_QTDPRO	:= nQtdProd
		Z50->Z50_VLUNIT	:= QRY->D2_TOTAL / QRY->D2_QUANT
		Z50->Z50_VLTOT	:= QRY->D2_TOTAL
		Z50->Z50_VLFRET	:= QRY->D2_VALFRE
		Z50->Z50_ICMSST	:= QRY->D2_ICMSRET
		Z50->Z50_ICMS	:= QRY->D2_VALICM
		Z50->Z50_VLPIS	:= QRY->D2_VALPIS
		Z50->Z50_VLCOF	:= QRY->D2_VALCOF
		Z50->Z50_VLST	:= QRY->D2_ICMSRET
		Z50->Z50_VLDEV	:= nTotDev
		Z50->Z50_CUSVDA	:= QRY->D2_CUSTO1
		Z50->Z50_CUSINV	:= 0 
		Z50->Z50_CUSMOV	:= 0
		Z50->Z50_CUSMED	:= 0
		Z50->Z50_ESICMS	:= 0
		Z50->Z50_ESST	:= 0
		Z50->Z50_MNTFRE	:= 0
		Z50->Z50_SEGFRE	:= 0
		Z50->Z50_IPVFRE	:= nIPVA
		Z50->Z50_DTREF	:= dDtFech	
			
		Z50->Z50_MODFRE	:= 0
		Z50->Z50_COMFRE	:= nCombLub
		Z50->Z50_DVFRE	:= nDespVia
		Z50->Z50_DEPFRE	:= 0
		Z50->Z50_VLMOD	:= 0
		Z50->Z50_VLENE	:= nEneEle
		Z50->Z50_VLGAS	:= nGas
		Z50->Z50_VLSEG	:= nSeguro
		Z50->Z50_VLMNT	:= nManMaq
		Z50->Z50_VLMOI	:= 0
		Z50->Z50_DESPI	:= 0
		Z50->Z50_VLDEPR	:= 0
				
		Z50->( MsUnLock())
		
		
		
		QRY->(dbSkip())
	EndDo
            
	QRY->(DbCloseArea())
				
Return
