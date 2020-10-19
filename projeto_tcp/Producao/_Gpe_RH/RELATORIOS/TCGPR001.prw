#INCLUDE 'TOTVS.CH'
#INCLUDE 'REPORT.CH'

/*/{Protheus.doc} TCGPR001
Função responsável pela impressão do relatório de Histórico de Funções
@author Kaique Mathias
@since 18/02/2020
@version P11
@return Nil, Valor Nulo
/*/

User Function TCGPR001()
	
	Local	aArea 	:= GetArea()
	Local	oReport:= Nil
	Private aTpsAltSal := {}
	
	oReport := ReportDef()
	
	if(oReport <> Nil)
		aTpsAltSal := gtTpAltSal()
	 
		oReport:PrintDialog()
	endIf
	
	oReport := Nil
	RestArea(aArea)	

Return( Nil )

/*/{Protheus.doc} ReportDef
Define o Objeto da Classe TReport utilizado na impressão do relatório
@author Kaique Mathias
@since 18/02/2020
@version P11
@return oReport, instância da classe TReport
/*/
Static Function ReportDef()	
	
	Local oReport	:= Nil
	Local oSecFil	:= Nil
	Local oSecCab	:= Nil
	Local oSecItems	:= Nil
	Local cRptTitle	:= OemToAnsi("Relatório de Histórico de Funções") //"Relatório de Histórico de Funções"
	Local cRptDescr	:= OemToAnsi("Este programa emite a Impressão do Relatório de Histórico de Funções.") //"Este programa emite a Impressão do Relatório de Histórico de Funções."
	Local aOrderBy	:= {}
	Local cNomePerg	:=	"TCGPR001"
	Local cMyAlias	:= GetNextAlias()	
	
	aAdd(aOrderBy, OemToAnsi('1 - Matrícula + Data')) //'1 - Matrícula + Data'
	aAdd(aOrderBy, OemToAnsi('2 - Data + Matrícula'	))//'2 - Data + Matrícula'	
	
	Pergunte(cNomePerg,.F.)
	
	DEFINE REPORT oReport NAME "TCGPR001" TITLE cRptTitle PARAMETER cNomePerg ACTION {|oReport| PrintReport(oReport,cNomePerg,cMyAlias)} DESCRIPTION cRptDescr	TOTAL IN COLUMN
	oReport:SetLandScape(.T.)
	
	DEFINE SECTION oSecFil OF oReport TITLE cRptTitle 	TABLES "SR7" TOTAL IN COLUMN ORDERS aOrderBy 
	DEFINE CELL NAME "R7_FILIAL" 	OF 	oSecFil ALIAS "SR7"		
	
	DEFINE SECTION oSecCab OF oSecFil 	TITLE '' TABLES "SR7","SRA" TOTAL IN COLUMN
	DEFINE CELL NAME "RA_CC" 		OF 	oSecCab ALIAS "SRA" SIZE 12
	//DEFINE CELL NAME "CCUSTO" 		OF 	oSecCab ALIAS "SR7" SIZE 12
	DEFINE CELL NAME "R7_MAT" 		OF 	oSecCab ALIAS "SR7" SIZE 12
	DEFINE CELL NAME "RA_NOME" 		OF 	oSecCab ALIAS "SRA" 
	DEFINE CELL NAME "RA_ADMISSA" 		OF 	oSecCab ALIAS "SRA"
	DEFINE CELL NAME "R7_FUNCAO" 		OF 	oSecCab ALIAS "SR7" SIZE 12
	DEFINE CELL NAME "R7_DESCFUN" 		OF 	oSecCab ALIAS "SR7" TITLE "" SIZE 35
	DEFINE CELL NAME "R7_DATA" 		OF 	oSecCab ALIAS "SR7"  SIZE 15
	DEFINE CELL NAME "R7_TIPO" 		OF 	oSecCab BLOCK {||GetDescTip((cMyAlias)->R7_TIPO)} ALIAS "SR7" SIZE 45
	//DEFINE CELL NAME "R7_CATFUNC"	OF 	oSecCab ALIAS "SR7" SIZE 4 TITLE "Cat."
	//DEFINE CELL NAME "VLRHR"			OF 	oSecCab BLOCK {||Transform((cMyAlias)->VLRHR,'@E 999.99')} TITLE OemToAnsi("Val. Hr")
	DEFINE CELL NAME "R7_CARGO" 	OF 	oSecCab ALIAS "SR7"
	DEFINE CELL NAME "R7_DESCCAR" 	OF 	oSecCab ALIAS "SR7" TITLE ""
	
	//DEFINE CELL NAME "RA_CBO" 		OF 	oSecCab ALIAS "SRA" TITLE "C.B.O."
		
Return( oReport )

/*/{Protheus.doc} PrintReport
Realiza a impressão do relatório
@author Kaique Mathias
@since 18/02/2020
@version P11
@param oReport, objeto, instância da classe TReport
@param cNomePerg, caractere, Nome do Pergunte
@param cMyAlias, caractere, Alias utilizado p/ consulta
@return nil, valor nulo
/*/
Static Function PrintReport(oReport, cNomePerg, cMyAlias)
	
	Local oSecFil		:= oReport:Section(1)
	Local oSecCab		:= oSecFil:Section(1)
	Local nOrderBy	:= oSecFil:GetOrder()
	Local cOrderBy	:= ''
	Local oBreakFil	:= Nil
	Local oBreakUni	:= Nil
	Local oBreakEmp	:= Nil
	Local cTitFil		:= ''
	Local cTitUniNeg	:= ''
	Local cTitEmp		:= ''
	Local cJoin		:= ""	
	Local lCorpManage	:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado
	Local cLayoutGC 	:= ''
	Local nStartEmp	:= 0
	Local nStartUnN	:= 0
	Local nEmpLength	:= 0
	Local nUnNLength	:= 0
	Local cDataDeAte	:= ''
	Local cInSitucao	:= ''
	Local cInCategor	:= ''
	Local cColumnSel	:= ""
	
	Default cMyAlias	:= GetNextAlias()
	
	If lCorpManage
		cLayoutGC 	:= FWSM0Layout(cEmpAnt)
		nStartEmp	:= At("E",cLayoutGC)
		nStartUnN	:= At("U",cLayoutGC)
		nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
		nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))	
	EndIf	
	
	//cJoin := "%" + FWJoinFilial("SR3", "SRA") + "%"
	
	if(nOrderBy == 1)
		cOrderBy := "%R7_FILIAL, R7_MAT, R7_DATA%"
	elseIf(nOrderBy == 2)
		cOrderBy := "%R7_FILIAL, R7_DATA, R7_MAT%"
	endIf
	
	If cPaisLoc == "BRA"
		cColumnSel := "%R7_FILIAL, RA_CC, R7_MAT, RA_NOME, RA_ADMISSA, R7_FUNCAO, R7_DESCFUN,R7_DATA, R7_TIPO, R7_CATFUNC, R7_CARGO, R7_DESCCAR%"
	Else
		cColumnSel := "%R7_FILIAL, RA_CC, R7_MAT, RA_NOME, RA_ADMISSA, R7_FUNCAO, R7_DESCFUN,R7_DATA, R7_TIPO, R7_CATFUNC, R7_CARGO, R7_DESCCAR%"
	EndIf	
	
	MakeSqlExpr(cNomePerg)
	
	cDataDeAte:= "(R7_DATA BETWEEN '"+ DtoS(MV_PAR03) +"' AND '"+ DtoS(MV_PAR04) +"')"
	
	if(Len(MV_PAR07) > 0)		
		cInSitucao := "(RA_SITFOLH IN (" + fSqlIn(MV_PAR07,1) + "))"		 
	endIf
	
	MV_PAR09 := StrTran(MV_PAR09, '*')
	MV_PAR09 := StrTran(MV_PAR09, "'")
	if(Len(MV_PAR09) > 0)		
		cInCategor := "(R7_CATFUNC IN (" + fSqlIn(MV_PAR09,1) + "))"		 
	endIf
	
	BEGIN REPORT QUERY oSecFil	
	
		BeginSql alias cMyAlias
			COLUMN R7_DATA AS DATE
			SELECT %exp:cColumnSel%
			FROM %table:SR7% SR7
			INNER JOIN %table:SRA% SRA ON(SRA.RA_FILIAL = R7_FILIAL AND SRA.%notDel% AND SRA.RA_MAT = R7_MAT)
			//INNER JOIN %table:SR3% SR3 ON(%exp:cJoin% AND SR3.%notDel% AND R3_MAT = R7_MAT AND R3_DATA = R7_DATA AND R3_SEQ = R7_SEQ)
			WHERE
			SR7.%notDel%
			ORDER BY %exp:cOrderBy%
		EndSql	
	
	END REPORT QUERY oSecFil PARAM MV_PAR01, MV_PAR02, MV_PAR05, MV_PAR06,cDataDeAte,cInSitucao,MV_PAR08,cInCategor
	
	if(lCorpManage)
		
		//QUEBRA FILIAL
		DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->R7_FILIAL }		
		oBreakFil:OnBreak({|x|cTitFil := OemToAnsi("Filial") +" " + x, oReport:ThinLine()})
		oBreakFil:SetTotalText({||cTitFil})
		oBreakFil:SetTotalInLine(.T.)			
		
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("R7_MAT")  FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT
		//DEFINE FUNCTION NAME "DB" FROM oSecCab:Cell("R3_VALOR")FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT		
		
		//QUEBRA UNIDADE DE NEGÓCIO
		DEFINE BREAK oBreakUni OF oReport WHEN {|| Substr((cMyAlias)->R7_FILIAL, nStartUnN, nUnNLength) }		
		oBreakUni:OnBreak({|x|cTitUniNeg := OemToAnsi("Unid. Neg.") +" " + x, oReport:ThinLine()})
		oBreakUni:SetTotalText({||cTitUniNeg})
		oBreakUni:SetTotalInLine(.T.)			
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("R7_MAT")  FUNCTION COUNT	BREAK oBreakUni NO END SECTION NO END REPORT
		//DEFINE FUNCTION NAME "DB" FROM oSecCab:Cell("R3_VALOR")FUNCTION SUM	BREAK oBreakUni NO END SECTION NO END REPORT
		
		//QUEBRA EMPRESA
		DEFINE BREAK oBreakEmp OF oReport WHEN {|| Substr((cMyAlias)->R7_FILIAL, nStartEmp, nEmpLength) }		
		oBreakEmp:OnBreak({|x|cTitEmp := OemToAnsi("Empresa") + " " + x, oReport:ThinLine()})
		oBreakEmp:SetTotalText({||cTitEmp})
		oBreakEmp:SetTotalInLine(.T.)			
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("R7_MAT")  FUNCTION COUNT	BREAK oBreakEmp NO END SECTION NO END REPORT
		//DEFINE FUNCTION NAME "DB" FROM oSecCab:Cell("R3_VALOR")FUNCTION SUM	BREAK oBreakEmp NO END SECTION NO END REPORT
			
	Else
		DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->R7_FILIAL }		
		oBreakFil:OnBreak({|x|cTitFil := OemToAnsi("Filial") +" " + x, oReport:ThinLine()})
		oBreakFil:SetTotalText({||cTitFil})
		oBreakFil:SetTotalInLine(.T.)			
		DEFINE FUNCTION NAME "DA" FROM oSecCab:Cell("R7_MAT")  FUNCTION COUNT	BREAK oBreakFil NO END SECTION NO END REPORT
		//DEFINE FUNCTION NAME "DB" FROM oSecCab:Cell("R3_VALOR")FUNCTION SUM	BREAK oBreakFil NO END SECTION NO END REPORT	
	endIf
	
	oSecCab:SetParentQuery()
	oSecCab:SetParentFilter({|cParam|(cMyAlias)->R7_FILIAL == cParam},{||(cMyAlias)->R7_FILIAL})
	oSecFil:Print()

Return( Nil )

/*/{Protheus.doc} gtTpAltSal
Retorna um vetor com os tipos de Alteração de Funções
@author Kaique Mathias
@since 18/02/2020
@version P11
@return aReturn, vetor, contém todos os tipos de Alteração de Funções
/*/
Static Function gtTpAltSal()
	
	Local aContent 	:= FwGetSX5("41")
	Local aResult	:= {}
	
	aEval(aContent,{ |x| AAdd(aResult, {x[3],x[4]}) })

Return( aResult )

/*/{Protheus.doc} GetDescTip
Retorna a descrição do Tipo de Aumento
@author Kaique Mathias
@since 18/02/2020
@version P11
@param cTipo, caractere, código
@return cResult, descrição
/*/
Static Function GetDescTip(cTipo)
	Local cResult := ""
	Local nPos		:= 0
	Default cTipo := ""
	
	nPos := aScan(aTpsAltSal,{|x|x[1] == cTipo})
	
	if(nPos > 0)
		cResult := AllTrim(cTipo) + " - " + aTpsAltSal[nPos,2]
	else
		cResult := cTipo
	endIf
	
Return cResult