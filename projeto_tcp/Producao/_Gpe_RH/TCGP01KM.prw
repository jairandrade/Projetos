#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'REPORT.CH'

/*/{Protheus.doc} TCGP01KM
Função responsável pela impressão do relatório de historico de afastamento
@author Kaique Mathias
@since 19/08/2016
@version P11
@return Nil, Valor Nulo
/*/
User Function TCGP01KM()

Local	aArea 	:= GetArea()
Local	oReport	:= Nil 

oReport := ReportDef()

oReport:PrintDialog()

RestArea(aArea)	 

Return( Nil )

/*/{Protheus.doc} ReportDef
Define o Objeto da Classe TReport utilizado na impressão do relatório
@author Kaique Mathias
@since 19/08/2016
@version P11
@return oReport, instância da classe TReport
/*/
Static Function ReportDef()	
Local oReport	:= Nil
Local oSecFil	:= Nil
//Local oSecCab	:= Nil
Local cRptTitle	:= OemToAnsi("Relatório de Histórico de Afastamentos") //"Relatório de Histórico de Afastamentos"
Local cRptDescr	:= OemToAnsi("Este programa emite a Impressão do Relatório de Histórico de Afastamentos.") //"Este programa emite a Impressão do Relatório de Histórico de Afastamentos."
Local aOrderBy	:= {}
Local cNomePerg	:=	"TCGP01KM"
Local cMyAlias	:= GetNextAlias()	

aAdd(aOrderBy, OemToAnsi('1 - Filial + Matrícula'))//'1 - Filial + Matrícula'
aAdd(aOrderBy, OemToAnsi('2 - Filial + Nome'))//'2 - Filial + Nome'
aAdd(aOrderBy, OemToAnsi('3 - Filial + Centro de Custo'))//'3 - Filial + Centro de Custo'

CriaSX1(cNomePerg)

//--Verifica se o grupo de perguntas existe na base
dbSelectarea("SX1")
DbSetOrder(1)

If ! dbSeek(cNomePerg)
	Help(" ",1,"NOPERG")
	Return 
EndIf

Pergunte(cNomePerg,.F.)

DEFINE REPORT oReport NAME "TCGP01KM" TITLE cRptTitle PARAMETER cNomePerg ACTION {|oReport| PrintReport(oReport,cNomePerg,cMyAlias)} DESCRIPTION cRptDescr	TOTAL IN COLUMN

DEFINE SECTION oSecFil OF oReport TITLE "Cabeçalho" 	TABLES "SRA" TOTAL IN COLUMN ORDERS aOrderBy
	DEFINE CELL NAME "RA_FILIAL" OF 	oSecFil ALIAS "SRA" SIZE Max(6,Len(xFilial("SRA")))
	DEFINE CELL NAME "RA_MAT" 	 OF 	oSecFil ALIAS "SRA" SIZE 9
	DEFINE CELL NAME "RA_NOME" 	 OF 	oSecFil ALIAS "SRA" SIZE 30
	DEFINE CELL NAME "R8_DATAINI"OF 	oSecFil ALIAS "SR8" SIZE 12
	DEFINE CELL NAME "R8_DATAFIM"OF 	oSecFil ALIAS "SR8" SIZE 12
	DEFINE CELL NAME "MOTIVO"	 OF 	oSecFil BLOCK {|| (cMyAlias)->MOTIVO + " " + FDesc("RCM",(cMyAlias)->MOTIVO,"RCM_DESCRI",60)} SIZE 65 TITLE "Motivo de Afastamento"//"Motivo de Afastamento"	
	DEFINE CELL NAME "RA_CC" 	 OF 	oSecFil BLOCK {|| (cMyAlias)->RA_CC + " " + (cMyAlias)->CTT_DESC01 } SIZE 40
	DEFINE CELL NAME "R8_DURACAO"OF 	oSecFil ALIAS "SR8" SIZE 5

/*DEFINE SECTION oSecCab OF oSecFil 	TITLE 'Itens' TABLES "SRA","SR8" TOTAL IN COLUMN
	DEFINE CELL NAME "RA_FILIAL" 	OF 	oSecCab ALIAS "SRA" TITLE "" SIZE Max(6,Len(xFilial("SRA")))
	DEFINE CELL NAME "RA_MAT" 	 	OF 	oSecCab ALIAS "SRA" TITLE "" SIZE 9
	DEFINE CELL NAME "RA_NOME" 	 	OF 	oSecCab ALIAS "SRA" TITLE "" SIZE 30
	DEFINE CELL NAME "R8_DATAINI" 	OF 	oSecCab ALIAS "SR8" TITLE "" SIZE 12
	DEFINE CELL NAME "R8_DATAFIM"	OF 	oSecCab ALIAS "SR8" TITLE "" SIZE 12
	DEFINE CELL NAME "MOTIVO"		OF 	oSecCab BLOCK {|| (cMyAlias)->MOTIVO + " " + FDesc("RCM",(cMyAlias)->MOTIVO,"RCM_DESCRI",60)} SIZE 65 TITLE ""//"Motivo de Afastamento"
	DEFINE CELL NAME "RA_CC" 	 	OF 	oSecCab BLOCK {|| (cMyAlias)->RA_CC + " " + (cMyAlias)->CTT_DESC01 } SIZE 40  TITLE ""
    DEFINE CELL NAME "R8_DURACAO"   OF 	oSecCab ALIAS "SR8" SIZE 5*/

Return( oReport )

/*/{Protheus.doc} PrintReport
Realiza a impressão do relatório
@author Kaique Mathias
@since 18/08/2016
@version P11
@param oReport, objeto, instância da classe TReport
@param cNomePerg, caractere, Nome do Pergunte
@param cMyAlias, caractere, Alias utilizado p/ consulta
@return nil, valor nulo
/*/
Static Function PrintReport(oReport, cNomePerg, cMyAlias)
Local oSecFil		:= oReport:Section(1)
//Local oSecCab		:= oSecFil:Section(1)
Local oBreakFil		:= Nil
Local oBreakUni		:= Nil
Local oBreakEmp		:= Nil
Local oBreakCC		:= Nil
Local cTitFil		:= ""
Local cTitUniNeg	:= ""
Local cTitEmp		:= ""
Local cJoinCTT		:= ""
Local cCatQuery		:= ""
Local cOrder		:= ""
Local cCategoria	:= MV_PAR05
Local cCcDe			:= MV_PAR06
Local cCcAte		:= MV_PAR07
Local dDataDe		:= MV_PAR08
Local dDataAte		:= MV_PAR09
Local cTipoAfDe     := MV_PAR10
Local cTipoAfAte    := MV_PAR11
Local nDias         := MV_PAR12
Local lCorpManage	:= fIsCorpManage( FWGrpCompany() )	// Verifica se o cliente possui Gestão Corporativa no Grupo Logado
Local cLayoutGC 	:= ''
Local nStartEmp		:= 0
Local nStartUnN		:= 0
Local nEmpLength	:= 0
Local nUnNLength	:= 0
Local nReg			:= 0
Local nOrdem		:= oSecFil:GetOrder() 

If nOrdem == 1
	cOrder := "%SRA.RA_FILIAL,SRA.RA_MAT,SR8.R8_DATAINI%"
ElseIf nOrdem == 2
	cOrder := "%SRA.RA_FILIAL,SRA.RA_NOME,SR8.R8_DATAINI%"
ElseIf nOrdem == 3
	cOrder := "%SRA.RA_FILIAL,SRA.RA_CC,SRA.RA_MAT,SR8.R8_DATAINI%"
EndIf

If lCorpManage
	cLayoutGC 	:= FWSM0Layout(cEmpAnt)
	nStartEmp	:= At("E",cLayoutGC)
	nStartUnN	:= At("U",cLayoutGC)
	nEmpLength	:= Len(FWSM0Layout(cEmpAnt, 1))
	nUnNLength	:= Len(FWSM0Layout(cEmpAnt, 2))	
EndIf	

cCatQuery := ""

For nReg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += "," 
	Endif
Next nReg        

cCatQuery := "%" + cCatQuery + "%"

cJoinCTT := "%" + FWJoinFilial("CTT", "SRA") + "%"

MakeSqlExpr(cNomePerg)

BEGIN REPORT QUERY oSecFil	

	BeginSql alias cMyAlias		
		SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CC, R8_DATAINI, R8_DATAFIM, R8_TIPOAFA AS MOTIVO, CTT_DESC01
		FROM %table:SRA% SRA
		INNER JOIN %table:SR8% SR8 ON SR8.%notDel% AND R8_FILIAL = RA_FILIAL AND R8_MAT = RA_MAT
		LEFT JOIN %table:CTT% CTT ON CTT.%notDel% AND %exp:cJoinCTT% AND CTT_CUSTO = RA_CC
		WHERE
		SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	AND
		SRA.RA_CC >= %exp:cCcDe% AND
		SRA.RA_CC <= %exp:cCcate% AND 
		SR8.R8_DATAINI >= %exp:DtoS(dDataDe)% AND
		SR8.R8_DATAINI <= %exp:DtoS(dDataAte)% AND
        SR8.R8_TIPOAFA >= %exp:cTipoAfDe% AND 
        SR8.R8_TIPOAFA <= %exp:cTipoAfAte% AND
        SR8.R8_DURACAO > %exp:nDias% AND 
		SRA.%notDel%
		ORDER BY %exp:cOrder%	
	EndSql	

	//MemoWrite("c:\temp\teste.sql",GetLastQuery()[2]) 

END REPORT QUERY oSecFil //PARAM MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR06, MV_PAR07 

//QUEBRA CENTRO DE CUSTO
If nOrdem == 3
	DEFINE BREAK oBreakCC OF oReport WHEN {|| (cMyAlias)->RA_FILIAL + (cMyAlias)->RA_CC}
	oBreakCC:OnBreak({|x|cTitFil := "Total de Afastamentos no Centro de Custos " + x, oReport:ThinLine(),oSecFil:SetHeaderSection(.T.)}) //"Total de Afastamentos no Centro de Custos "		
	oBreakCC:SetTotalText({||cTitFil})
	oBreakCC:SetTotalInLine(.F.)
	DEFINE FUNCTION NAME "DA" FROM oSecFil:Cell("RA_MAT")  FUNCTION COUNT BREAK oBreakCC NO END SECTION NO END REPORT
EndIf

//QUEBRA FILIAL
DEFINE BREAK oBreakFil OF oReport WHEN {|| (cMyAlias)->RA_FILIAL }		
oBreakFil:OnBreak({|x|cTitFil := "Total de Afastamentos na Filial " + x, oReport:ThinLine(),oSecFil:SetHeaderSection(.T.)}) //"Total de Afastamentos na Filial "
oBreakFil:SetTotalText({||cTitFil})
oBreakFil:SetTotalInLine(.F.)
DEFINE FUNCTION NAME "DA" FROM oSecFil:Cell("RA_MAT")  FUNCTION COUNT BREAK oBreakFil NO END SECTION NO END REPORT

If(lCorpManage)
	
	//QUEBRA UNIDADE DE NEGÓCIO
	DEFINE BREAK oBreakUni OF oReport WHEN {|| Substr((cMyAlias)->RA_FILIAL, nStartUnN, nUnNLength) }		
	oBreakUni:OnBreak({|x|cTitUniNeg := "Total de Afastamentos na Unidade de Negócio " + x, oReport:ThinLine(),oSecFil:SetHeaderSection(.T.)}) //"Total de Afastamentos na Unidade de Negócio "
	oBreakUni:SetTotalText({||cTitUniNeg})
	oBreakUni:SetTotalInLine(.F.)
	DEFINE FUNCTION NAME "DA" FROM oSecFil:Cell("RA_MAT")  FUNCTION COUNT BREAK oBreakUni NO END SECTION NO END REPORT
	
	//QUEBRA EMPRESA
	DEFINE BREAK oBreakEmp OF oReport WHEN {|| Substr((cMyAlias)->RA_FILIAL, nStartEmp, nEmpLength) }		
	oBreakEmp:OnBreak({|x|cTitEmp := "Total de Afastamentos na Empresa " + x, oReport:ThinLine(),oSecFil:SetHeaderSection(.T.)}) //"Total de Afastamentos na Empresa "
	oBreakEmp:SetTotalText({||cTitEmp})
	oBreakEmp:SetTotalInLine(.F.)
	DEFINE FUNCTION NAME "DA" FROM oSecFil:Cell("RA_MAT")  FUNCTION COUNT	BREAK oBreakEmp NO END SECTION NO END REPORT
		
EndIf

//oSecCab:Cell("RA_FILIAL"):HIDE()
//oSecCab:Cell("RA_CC"):HIDE()
//oSecCab:Cell("RA_MAT"):HIDE()
//oSecCab:Cell("RA_NOME"):HIDE()

//oSecFil:Cell("R8_DATAINI"):HIDE()
//oSecFil:Cell("R8_DATAFIM"):HIDE()
//oSecFil:Cell("MOTIVO"):HIDE()

//oSecCab:SetParentQuery()
//oSecCab:SetParentFilter({|cParam|If((cMyAlias)->RA_FILIAL+(cMyAlias)->RA_MAT == cParam,(oSecFil:SetHeaderSection(.F.),oReport:OnPageBreak({|| oSecFil:SetHeaderSection(.T.),oSecFil:Init(), oSecFil:PrintLine()}),.T.),.F.)},{||(cMyAlias)->RA_FILIAL+(cMyAlias)->RA_MAT})
oSecFil:Print()

Return( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
description Cria perguntas no dicionario de dados
@author  Kaique Mathias
@since   06/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function CriaSX1(cPerg)

    u_xPutSx1(cPerg,"01","Filial de?"             ,"Filial de?"       ,"Filial de?"          ,"mv_ch1"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par01","","","","","","","","","","","","","","","","",{"Filial inicio."   ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"02","Filial até?"            ,"Filial até?"      ,"Filial até?"         ,"mv_ch2"  ,"C" ,2,0,0,"G","",""   ,"","","mv_par02","","","","","","","","","","","","","","","","",{"Filial fim."      ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"03","Matricula de?"          ,"Matricula de?"    ,"Matricula de?"       ,"mv_ch3"  ,"C" ,6,0,0,"G","","SRA","","","mv_par03","","","","","","","","","","","","","","","","",{"Matricula de."    ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"04","Matricula até?"         ,"Matricula até?"   ,"Matricula até?"      ,"mv_ch4"  ,"C" ,6,0,0,"G","","SRA","","","mv_par04","","","","","","","","","","","","","","","","",{"Matricula até."   ,"","",""},{"","","",""},{"","",""},"")
	u_xPutSx1(cPerg,"05","Categorias a Imprimir ?","Categorias a Imprimir ?"   ,"Categorias a Imprimir ?"      ,"mv_ch5"  ,"C" ,15,0,0,"G","fCategoria()","","","","mv_par05","","","","","","","","","","","","","","","","",{"Matricula até."   ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"06","Centro de?"             ,"Centro de?"       ,"Centro de?"          ,"mv_ch6"  ,"C" ,9,0,0,"G","","CTT","","","mv_par06","","","","","","","","","","","","","","","","",{"Centro de."       ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"07","Centro até?"            ,"Centro até?"      ,"Centro até?"         ,"mv_ch7"  ,"C" ,9,0,0,"G","","CTT","","","mv_par07","","","","","","","","","","","","","","","","",{"Centro até."      ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"08","Data de?"               ,"Data de?"         ,"Data de?"            ,"mv_ch8"  ,"D" ,8,0,0,"G","","   ","","","mv_par08","","","","","","","","","","","","","","","","",{"Centro de."       ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"09","Data até?"              ,"Data até?"        ,"Data até?"           ,"mv_ch9"  ,"D" ,8,0,0,"G","","   ","","","mv_par09","","","","","","","","","","","","","","","","",{"Centro até."      ,"","",""},{"","","",""},{"","",""},"")
	u_xPutSx1(cPerg,"10","Tipo de?"               ,"Tipo de?"         ,"Tipo de?"            ,"mv_cha"  ,"C" ,3,0,0,"G","","RCMBRA","","","mv_par10","","","","","","","","","","","","","","","","",{"Tipo de afastamento até."      ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"11","Tipo até?"              ,"Tipo até?"        ,"Tipo até?"           ,"mv_chb"  ,"C" ,3,0,0,"G","","RCMBRA","","","mv_par11","","","","","","","","","","","","","","","","",{"Tipo de afastamento até."      ,"","",""},{"","","",""},{"","",""},"")
    u_xPutSx1(cPerg,"12","Dias Afastados?"        ,"Dias Afastados?"  ,"Dias Afastados?"     ,"mv_chc"  ,"N" ,5,0,0,"G","","   ","","","mv_par12","","","","","","","","","","","","","","","","",{"Dias afastados."      ,"","",""},{"","","",""},{"","",""},"")

Return( Nil ) 