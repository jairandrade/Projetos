#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ TCGP03KM  ³ Autor ³ Kaique Mathias       ³ Data ³ 10.06.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio Faltas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TCGP03KM(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC          ³  Motivo da Alteracao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Flavio Corr ³10/06/16³ RHRH001-105  ³Criação do relatório de faltas    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function TCGP03KM()

Local	oReport   
Local	aArea 		:= GetArea()
Private nColPro	:= 0
Private cPerg		:= "TCGP03KM"

CriaSX1(cPerg)
Pergunte(cPerg,.F.)

oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Totvs IP RH           ³ Data ³12/04/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio para Abono                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TCGP03KM                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TCGP03KM - Generico                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oReport 
Local oSection1 
Local oSection2 
Local bBlkFil 	:= { || If ( cCodFilial != (cAliasQry)->RA_FILIAL, Eval( { || fInfo(@aInfo,(cAliasQry)->RA_FILIAL), aInfo[3] } ), aInfo[1] ) }
Local aOrd 		:= {"Filial" ,"Centro de Custo" ,"Departamento" } 

Private cTitulo	:= OemToAnsi("Relatorio de Faltas")// "Relatorio de Faltas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao dos componentes de impressao                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE REPORT oReport NAME "TCGP03KM" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| TGP03Imp(oReport)} DESCRIPTION OemtoAnsi("Contabilização de faltas") TOTAL IN COLUMN // "Contabilização de faltas"

	oSection1 := TRSection():New( oReport, OemToAnsi("Funcionarios"), {"SRA","SPH"}, aOrd,,,,) // "Funcionarios"


		TRCell():New(oSection1,"RA_FILIAL","SRA",,/*Picture*/,8,/*lPixel*/,{|| 	If(!Empty((cAliasQry)->RA_FILIAL),;
																								cCodFilial:= (cAliasQry)->RA_FILIAL,;
																								NIL),;
																								cCodFilial}	)
		TRCell():New(oSection1,"FILIAL","",OemToAnsi("Desc.Filial"),/*Picture*/,20,/*lPixel*/,{|| Eval( bBlkFil ) })	// "Desc.Filial"

		TRCell():New(oSection1,"RA_MAT"		,"SRA",,,6)
		TRCell():New(oSection1,"RA_NOME"	,"SRA",,,30,,,,.T.)
		TRCell():New(oSection1,"RA_CC"		,"SRA",OemToAnsi("C.Custo"),,10)	// "C.Custo"
		TRCell():New(oSection1,"RA_DEPTO"	,"SRA",,,23,,,,.T.)
		TRCell():New(oSection1,"RA_HRSMES"	,"SRA",OemToAnsi("Hrs Mes"),,5)	// "Tno"
		TRCell():New(oSection1,"DATA"	,""  ,"Data",,12,,,,)//"Data"
		TRCell():New(oSection1,"NAOAUT"		,""  ,OemToAnsi("Não Autorizadas"),'999999.99',13,,,,.T.)//"Não Autorizadas"
		TRCell():New(oSection1,"AUT"		,""  ,"Autorizadas",'999999.99',13,,,,.T.)//"Autorizadas"
		TRCell():New(oSection1,"ABONADAS"	,""  ,"Abonadas",'999999.99',13,/*lPixel*/,/*{||  }*/,,.T.,)//"Abonadas"
		TRCell():New(oSection1,"SUSPENSAO"	,""  ,OemToAnsi("Suspensão"),'999999.99',13,/*lPixel*/,/*{||  }*/,,.T.,)//"Suspensão"
		TRCell():New(oSection1,"DESCONTO"	,""  ,OemToAnsi("Desconto"),'999999.99',13,/*lPixel*/,/*{||  }*/,,.T.,)//"Suspensão"
		TRCell():New(oSection1,"REEMBOLSO"	,""  ,OemToAnsi("Reembolso"),'999999.99',13,/*lPixel*/,/*{||  }*/,,.T.,)//"Suspensão"
Return(oReport)

Static Function TGP03Imp(oReport)

Local cAcessaSRA	:= &( " { || " + ChkRH( "TCGP03KM" , "SRA" , "2" ) + " } " )
Local oSection  	:= oReport:Section(1)
Local cSitQuery		:= ""    
Local cCatQuery		:= ""  
Local nReg			:= 0
Local nOrdem		:= 1
Local cOrdem	 	:= ""
Local cFilSPHSP9	:= ""
Local cFilSPCSP9	:= ""
Local cFiltroSPH 	:= ""
Local cFiltroSPC 	:= ""
Local cFiltroSRA	:= ""
Local cSit     		:= ""
Local cCat     		:= ""
Local cCmpSPH		:= "%%"
Local cCmpSPC		:= "%%"
Local nTipo	 		:= 1
Local oBreakCc
Local oBreakFil
Local cAliasMarc	
Local nVal1 := 0
Local nVal2 := 0
Local nVal3 := 0
Local nVal4	:= 0
Local aDet := {}
Local nI	:= 1
Local lSexaCent := 1

Private aInfo		:= {}
Private cCodFilial	:= "##"
Private cAliasQry 	:= GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ MV_PAR01        //  Filial                                   ³
//³ MV_PAR02        //  Centro de Custo                          ³
//³ MV_PAR03        //  Departamento                             ³
//³ MV_PAR04        //  Matricula                                ³
//³ MV_PAR05        //  Relatorio 1=Analitico;2=Sintetico        ³
//³ MV_PAR06        //  Data de ate                              ³
//³ MV_PAR12        //  Categoria   
//³ MV_PAR13        //  Situacao                                 ³
//³ MV_PAR14        //  Horas em                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


nTipo   	 	:= mv_par09
lSexaCent  		:= MV_PAR14
cCat     		:= MV_PAR12
cSit     		:= MV_PAR13

SRA->(dbSetOrder(1))

//-- Modifica variaveis para a Query
For nReg:=1 to Len(cSit)
	cSitQuery += "'"+Subs(cSit,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSit)
		cSitQuery += "," 
	Endif
Next nReg        
cSitQuery := "%" + cSitQuery + "%"

cCatQuery := ""
For nReg:=1 to Len(cCat)
	cCatQuery += "'"+Subs(cCat,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCat)
		cCatQuery += "," 
	Endif
Next nReg        

cCatQuery := "%" + cCatQuery + "%"

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

cFiltroSPH 	:= ""
cFiltroSRC	:= ""
cFiltroSRD	:= ""

cFiltroSRA += " AND RA_FILIAL >= '" + MV_PAR01 + "'"
cFiltroSRA += 	" AND RA_FILIAL <= '" + MV_PAR02 + "'"
cFiltroSRA += 	" AND RA_CC >= '" + MV_PAR03 + "'"
cFiltroSRA += 	" AND RA_CC <= '" + MV_PAR04 + "'"
cFiltroSRA += 	" AND RA_DEPTO >= '" + MV_PAR05 + "'"
cFiltroSRA += 	" AND RA_DEPTO <= '" + MV_PAR06 + "'"
cFiltroSRA += 	" AND RA_MAT >= '" + MV_PAR07 + "'"
cFiltroSRA += 	" AND RA_MAT <= '" + MV_PAR08 + "'"

cFiltroSPH += 	" AND PH_DATA >= '" + DTOS(MV_PAR10) + "'"
cFiltroSPC += 	" AND PC_DATA >= '" + DTOS(MV_PAR10) + "'"
cFiltroSPH += 	" AND PH_DATA <= '" + DTOS(MV_PAR11) + "'"
cFiltroSPC += 	" AND PC_DATA <= '" + DTOS(MV_PAR11) + "'" 

cFiltroSRC += " AND SUBSTRING(RC_DTREF,1,6) >= '" + SUBSTR(DTOS(MV_PAR10),1,6) + "'"
cFiltroSRD += " AND SUBSTRING(RD_DTREF,1,6) >= '" + SUBSTR(DTOS(MV_PAR10),1,6) + "'"
cFiltroSRC += " AND SUBSTRING(RC_DTREF,1,6) <= '" + SUBSTR(DTOS(MV_PAR11),1,6) + "'"
cFiltroSRD += " AND SUBSTRING(RD_DTREF,1,6) <= '" + SUBSTR(DTOS(MV_PAR11),1,6) + "'"

If !Empty(cFiltroSPH)
	cFiltroSPH := "%" + cFiltroSPH + "%" 
Else
	cFiltroSPH := "%%"
EndIf

If !Empty(cFiltroSPC)
	cFiltroSPC := "%" + cFiltroSPC + "%"
Else
	cFiltroSPC := "%%"
EndIf

If !Empty(cFiltroSRC)
	cFiltroSRC := "%" + cFiltroSRC + "%"
Else
	cFiltroSRC := "%%"
EndIf

If !Empty(cFiltroSRD)
	cFiltroSRD := "%" + cFiltroSRD + "%"
Else
	cFiltroSRD := "%%"
EndIf

If !Empty(cFiltroSRA)
	cFiltroSRA := "%" + cFiltroSRA + "%"
Else
	cFiltroSRA := "%%"
EndIf

BEGIN REPORT QUERY oSection

cFilSPHSP9	:= "%" + FWJoinFilial("SPH", "SP9") + "%"
cFilSPCSP9	:= "%" + FWJoinFilial("SPC", "SP9") + "%"
cFilSRCSRV  := "%" + FWJoinFilial("SRC", "SRV") + "%"
cFilSRDSRV  := "%" + FWJoinFilial("SRD", "SRV") + "%"

nOrdem		:= oSection:GetOrder()

If nOrdem == 1
	cOrdem := "%SRA.RA_FILIAL,SRA.RA_MAT%"
ElseIf nOrdem == 2
	cOrdem := "%SRA.RA_FILIAL,SRA.RA_CC,SRA.RA_MAT%"
ElseIf nOrdem == 3
	cOrdem := "%SRA.RA_FILIAL,SRA.RA_DEPTO,SRA.RA_MAT%"
Endif

If nTipo == 1
	oSection:Cell( "DATA"):Enable()
	oSection:Cell( "NAOAUT"):Enable()
	oSection:Cell( "AUT"):Enable()
	oSection:Cell( "ABONADAS"):Enable()
	oSection:Cell( "SUSPENSAO"):Enable()
	oSection:Cell( "DESCONTO"):Disable()
	oSection:Cell( "REEMBOLSO"):Disable()
Else
	oSection:Cell( "DATA"):Disable()
	oSection:Cell( "NAOAUT"):Disable()
	oSection:Cell( "AUT"):Disable()
	oSection:Cell( "ABONADAS"):Disable()
	oSection:Cell( "SUSPENSAO"):Disable()
	oSection:Cell( "DESCONTO"):Enable()
	oSection:Cell( "REEMBOLSO"):Enable()
EndIf

BeginSql alias cAliasQry
	SELECT SRA.RA_FILIAL,SRA.RA_NOME,RA_HRSMES,RA_DEPTO,RA_CC,RA_MAT
	FROM %table:SRA% SRA
	WHERE SRA.D_E_L_E_T_ =' '
	%exp:cFiltroSRA% 
	AND SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%) 	
    AND SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	
    ORDER BY %exp:cOrdem%
EndSql
	
END REPORT QUERY oSection 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quebra de pagina C.Custo                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nOrdem = 2 ) 
	DEFINE BREAK oBreakCc OF oSection WHEN {|| (cAliasQry)->RA_CC } TITLE OemToansi("Centro de Custo") //Centro de Custo
	DEFINE FUNCTION FROM oSection:Cell("NAOAUT") 	FUNCTION TIMESUM BREAK oBreakCc NO END SECTION NO END REPORT 
	DEFINE FUNCTION FROM oSection:Cell("AUT") 		FUNCTION TIMESUM BREAK oBreakCc NO END SECTION NO END REPORT 
	DEFINE FUNCTION FROM oSection:Cell("ABONADAS") 	FUNCTION TIMESUM BREAK oBreakCc NO END SECTION NO END REPORT
	DEFINE FUNCTION FROM oSection:Cell("SUSPENSAO") FUNCTION TIMESUM BREAK oBreakCc NO END SECTION NO END REPORT
	oBreakCc:SetPageBreak(.F.) 
	oBreakCc:SetHeaderBreak(.F.) 
ElseIf (nOrdem = 3)
	DEFINE BREAK oBreakCc OF oSection WHEN {|| (cAliasQry)->RA_DEPTO } TITLE OemToansi("Departamento") //"Departamento"
	DEFINE FUNCTION FROM oSection:Cell("NAOAUT") 	FUNCTION TIMESUM BREAK oBreakCc NO END SECTION NO END REPORT 
	DEFINE FUNCTION FROM oSection:Cell("AUT") 		FUNCTION TIMESUM BREAK oBreakCc NO END SECTION NO END REPORT 
	DEFINE FUNCTION FROM oSection:Cell("ABONADAS") 	FUNCTION TIMESUM BREAK oBreakCc NO END SECTION NO END REPORT
	DEFINE FUNCTION FROM oSection:Cell("SUSPENSAO")	FUNCTION TIMESUM BREAK oBreakCc NO END SECTION NO END REPORT
	oBreakCc:SetPageBreak(.F.) 
	oBreakCc:SetHeaderBreak(.F.) 
Endif 

DEFINE BREAK oBreakFil OF oSection WHEN {|| (cAliasQry)->RA_FILIAL }  TITLE OemToansi("Total Filial") //"Total Filial"
DEFINE FUNCTION FROM oSection:Cell("NAOAUT") 	FUNCTION TIMESUM BREAK oBreakFil //NO END SECTION  
DEFINE FUNCTION FROM oSection:Cell("AUT") 		FUNCTION TIMESUM BREAK oBreakFil //NO END SECTION
DEFINE FUNCTION FROM oSection:Cell("ABONADAS") 	FUNCTION TIMESUM BREAK oBreakFil //NO END SECTION
DEFINE FUNCTION FROM oSection:Cell("SUSPENSAO") FUNCTION TIMESUM BREAK oBreakFil //NO END SECTION
oBreakFil:SetHeaderBreak(.F.) 
oBreakFil:SetPageBreak(.F.)

oSection:SetHeaderSection(.T.)
oSection:SetHeaderBreak(.F.) 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a variavel aInfo com a filial Logada              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fInfo(@aInfo,(cAliasQry)->RA_FILIAL)

//-- Define o total da regua da tela de processamento do relatorio
oReport:SetMeter( 100 )  
oSection:Init(.F.)        
While !(cAliasQry)->( EOF() ) 

	oReport:IncMeter( 1 )   

	//-- Verifica se o usuário cancelou a impressão do relatorio
	If oReport:Cancel()
		Exit
	EndIf               

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Consiste Filiais e Acessos                                             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF !( (cAliasQry)->RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA )
		(cAliasQry)->(DbSkip())
	   	Loop
	EndIF
	
	cAliasMarc := GetNextAlias()

	If nTipo == 1 //Analitico
		BeginSql alias cAliasMarc
			SELECT PC_FILIAL,PC_MAT MATRICULA,PC_CC, PC_DEPTO,PC_DATA DATA,PC_QUANTC , PC_QUANTI ,PC_QTABONO ,PC_PD ,PC_PDI ,P9_IDPON
			FROM %table:SPC%  SPC
			INNER JOIN %table:SP9%  SP9 ON %exp:cFilSPCSP9% AND P9_CODIGO = PC_PD AND SP9.D_E_L_E_T_ = ' ' AND P9_IDPON IN('008A','010A','032A','034A','007N','009N','033N','035N','043A')
			WHERE SPC.D_E_L_E_T_ =' '
			%exp:cFiltroSPC% 
			AND PC_MAT = %exp:(cAliasQry)->RA_MAT% 
			AND PC_FILIAL = %exp:(cAliasQry)->RA_FILIAL% 
			UNION ALL
			SELECT PH_FILIAL,PH_MAT,PH_CC, PH_DEPTO,PH_DATA,PH_QUANTC , PH_QUANTI ,PH_QTABONO ,PH_PD ,PH_PDI ,P9_IDPON
			FROM %table:SPH%  SPH
			INNER JOIN %table:SP9%  SP9 ON %exp:cFilSPHSP9% AND P9_CODIGO = PH_PD AND SP9.D_E_L_E_T_ = ' ' AND P9_IDPON IN('008A','010A','032A','034A','007N','009N','033N','035N','043A')
			WHERE SPH.D_E_L_E_T_ =' '
			%exp:cFiltroSPH% 
			AND PH_MAT = %exp:(cAliasQry)->RA_MAT% 
			AND PH_FILIAL = %exp:(cAliasQry)->RA_FILIAL% 
			ORDER BY PC_FILIAL,PC_MAT,PC_CC, PC_DEPTO,PC_DATA
		EndSql
	Else
		BeginSql alias cAliasMarc
			SELECT RC_FILIAL,RC_MAT MATRICULA,RC_CC,RC_DEPTO,RC_DTREF DATA,RC_HORAS,RV_COD
			FROM %Table:SRC% SRC
			INNER JOIN %table:SRV% SRV ON RV_FILIAL=%xFilial:SRV% AND RV_COD = RC_PD AND SRV.%NotDel% AND RV_COD IN ("425","274")
			WHERE SRC.%NotDel%
			%exp:cFiltroSRC%
			AND RC_MAT = %exp:(cAliasQry)->RA_MAT% 
			AND RC_FILIAL = %exp:(cAliasQry)->RA_FILIAL% 
			UNION ALL
			SELECT RD_FILIAL,RD_MAT,RD_CC,RD_DEPTO,RD_DTREF,RD_HORAS,RV_COD
			FROM %Table:SRD% SRD
			INNER JOIN %table:SRV% SRV ON RV_FILIAL=%xFilial:SRV% AND RV_COD = RD_PD AND SRV.%NotDel% AND RV_COD IN ("425","274")
			WHERE SRD.%NotDel%
			%exp:cFiltroSRD%
			AND RD_MAT = %exp:(cAliasQry)->RA_MAT%
			AND RD_FILIAL = %exp:(cAliasQry)->RA_FILIAL%
			ORDER BY RC_FILIAL,RC_MAT,RC_CC, RC_DEPTO,RC_DTREF
		EndSql
	EndIf

	(cAliasMarc)->(dbgotop())

	aDet := {}
	
	While !(cAliasMarc)->( EOF() ) 
		
		nVal1 := 0
		nVal2 := 0
		nVal3 := 0
		nVal4 := 0
		
		If nTipo == 1 //Analitico
			If (cAliasMarc)->P9_IDPON == "043A"
				nVal4 := If(Empty((cAliasMarc)->PC_PDI),(cAliasMarc)->PC_QUANTC,PC_QUANTI)
			ElseIf Right((cAliasMarc)->P9_IDPON,1) == "N"
				nVal1 := If(Empty((cAliasMarc)->PC_PDI),(cAliasMarc)->PC_QUANTC,PC_QUANTI)
			ElseIf Right((cAliasMarc)->P9_IDPON,1) == "A"
				nVal2 := If(Empty((cAliasMarc)->PC_PDI),(cAliasMarc)->PC_QUANTC,PC_QUANTI)
			EndIf
			nVal3 := (cAliasMarc)->PC_QTABONO
		Else
			If (cAliasMarc)->RV_COD = "425"
				nVal1 := (cAliasMarc)->RC_HORAS
			ElseIf (cAliasMarc)->RV_COD = "274"
				nVal2 := (cAliasMarc)->RC_HORAS
			EndIf
		EndIf
		
		If nTipo == 1 //Analitico
			nRet  := aScan( aDet,{|X| x[1] == (cAliasMarc)->DATA} )
		Else
			nRet  := aScan( aDet,{|X| x[1] == (cAliasMarc)->MATRICULA} )
		EndIf
		
		If nRet == 0
		    If nTipo == 1 //Analitico
		   		Aadd (aDet,{(cAliasMarc)->DATA,nVal1,nVal2,nVal3,nVal4})  // se nao cria elemento
		   	ELse
		   		Aadd (aDet,{(cAliasMarc)->MATRICULA,nVal1,nVal2,nVal3,nVal4})  // se nao cria elemento
		   	EndIf
		Else                                        
		    aDet[nRet,2] := SomaHoras(aDet[nRet,2],nVal1)
		    aDet[nRet,3] := SomaHoras(aDet[nRet,3],nVal2)
		    aDet[nRet,4] := SomaHoras(aDet[nRet,4],nVal3)
		    aDet[nRet,5] := SomaHoras(aDet[nRet,5],nVal4)
		Endif
		(cAliasMarc)->( dbSkip() ) 
	EndDo
	
	(cAliasMarc)->(dbCloseArea())
	
	For nI := 1 To Len(aDet)
		If nTipo == 1 //Analitico
			oSection:Cell( "DATA"):SetValue(dtoc(stod(aDet[nI][1])))		
			oSection:Cell( "NAOAUT"):SetValue(If( lSexaCent==2, fConvHr(aDet[nI][2],'D'), aDet[nI][2] ))				
			oSection:Cell( "AUT"):SetValue(If( lSexaCent==2, fConvHr(aDet[nI][3],'D'), aDet[nI][3] ))				
			oSection:Cell( "ABONADAS"):SetValue(If( lSexaCent==2, fConvHr(aDet[nI][4],'D'), aDet[nI][4] ))	
			oSection:Cell( "SUSPENSAO"):SetValue(If( lSexaCent==2, fConvHr(aDet[nI][5],'D'), aDet[nI][5] ))	
		Else
			//Sintetico
			oSection:Cell("DESCONTO"):SetValue(If( lSexaCent==2, fConvHr(aDet[nI][2],'D'), aDet[nI][2] ))					
			oSection:Cell("REEMBOLSO"):SetValue(If( lSexaCent==2, fConvHr(aDet[nI][3],'D'), aDet[nI][3] ))				
		EndIf
		
		oSection:PrintLine()
	Next nI
	(cAliasQry)->( dbSkip() ) 
EndDo

If Select(cAliasQry) > 0
	(cAliasQry)->(dbCloseArea())
Endif

Return

Static Function CriaSX1(cPerg)

    u_xPutSx1(cPerg,"01","Filial de ?"             	,"Filial de?"       			,"Filial de?"          		,"mv_ch1"  ,"C" ,2,0,0,"G","","XM0","","","mv_par01","","","","","","","","","","","","","","","","",{"Filial inicio."   ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"02","Filial até ?"            	,"Filial até?"      			,"Filial até?"         		,"mv_ch2"  ,"C" ,2,0,0,"G","","XM0","","","mv_par02","","","","","","","","","","","","","","","","",{"Filial fim."      ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"03","Centro de ?"             	,"Centro de?"       			,"Centro de?"          		,"mv_ch3"  ,"C" ,9,0,0,"G","","CTT","","","mv_par03","","","","","","","","","","","","","","","","",{"Centro de."       ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"04","Centro até ?"            	,"Centro até?"      			,"Centro até?"         		,"mv_ch4"  ,"C" ,9,0,0,"G","","CTT","","","mv_par04","","","","","","","","","","","","","","","","",{"Centro até."      ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"05","Departamento de ?"       	,"Matricula de?"    			,"Matricula de?"       		,"mv_ch5"  ,"C" ,6,0,0,"G","","SQB","","","mv_par05","","","","","","","","","","","","","","","","",{"Matricula de."    ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"06","Departamento até ?"      	,"Matricula até?"   			,"Matricula até?"      		,"mv_ch6"  ,"C" ,6,0,0,"G","","SQB","","","mv_par06","","","","","","","","","","","","","","","","",{"Matricula até."   ,"","",""},{"","","",""},{"","",""},"")
	u_xPutSx1(cPerg,"07","Matricula de ?"          	,"Matricula de?"    			,"Matricula de?"       		,"mv_ch7"  ,"C" ,6,0,0,"G","","SRA","","","mv_par07","","","","","","","","","","","","","","","","",{"Matricula de."    ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"08","Matricula até ?"         	,"Matricula até?"   			,"Matricula até?"      		,"mv_ch8"  ,"C" ,6,0,0,"G","","SRA","","","mv_par08","","","","","","","","","","","","","","","","",{"Matricula até."   ,"","",""},{"","","",""},{"","",""},"")
	u_xPutSx1(cPerg,"09","Tipo relatório ?"        	,"Matricula até?"   			,"Matricula até?"      		,"mv_ch9"  ,"N" ,1,0,0,"C","","   ","","","mv_par09","1=Analítico","","","","2=Sintético","","","","","","","","","","","",{"Matricula até."   ,"","",""},{"","","",""},{"","",""},"")
	u_xPutSx1(cPerg,"10","Periodo de ?"            	,"Data de?"         			,"Data de?"            		,"mv_cha"  ,"D" ,8,0,0,"G","Naovazio()","   ","","","mv_par10","","","","","","","","","","","","","","","","",{"Centro de."       ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"11","Periodo até ?"           	,"Data até?"        			,"Data até?"           		,"mv_chb"  ,"D" ,8,0,0,"G","Naovazio()","   ","","","mv_par11","","","","","","","","","","","","","","","","",{"Centro até."      ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"12","Categorias a Imprimir ?"	,"Categorias a Imprimir ?"   	,"Categorias a Imprimir ?"  ,"mv_chc"  ,"C" ,15,0,0,"G","fCategoria()","","","","mv_par12","","","","","","","","","","","","","","","","",{"Matricula até."   ,"","",""},{"","","",""},{"","",""},"")
	u_xPutSx1(cPerg,"13","Situação ?"         		,"Matricula até?"   			,"Matricula até?"      		,"mv_chd"  ,"C" ,5 ,0,0,"G","fSituacao()","  ","","","mv_par13","","","","","","","","","","","","","","","","",{"Matricula até."   ,"","",""},{"","","",""},{"","",""},"")
	u_xPutSx1(cPerg,"14","Horas em ?"         		,"Matricula até?"   			,"Matricula até?"      		,"mv_che"  ,"C" ,1,0,0,"C","","   ","","","mv_par14","Sexagesimal","","","","Centesimal","","","","","","","","","","","",{"","","",""},{"","","",""},{"","",""},"")

Return( Nil )