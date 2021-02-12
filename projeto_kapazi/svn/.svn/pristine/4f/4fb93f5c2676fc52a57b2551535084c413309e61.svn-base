#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWBROWSE.CH"

User Function PLN001

LOCAL CTIT    := "Planilha Financeira"
LOCAL ASAY    := {}
LOCAL ABUT    := {}
LOCAL LOK     := .F.
LOCAL LFIM    := .F.
Private LEND:= .F.

PRIVATE CPERG := 'PLN001'
criasx1(cperg)
pergunte(cPerg,.f.)

AADD(ASAY, "ESTE PROGRAMA IMPRIME A Planilha Financeira por natureza.")
AADD(ASAY, "… NECESSARIO TER O MS EXCEL INSTALADO NO COMPUTADOR, POIS O RELATÛRIO È")
AADD(ASAY, "GERADO DIRETAMENTO EM PLANILHA.")

AADD(ABUT, {5, .T., {|| PERGUNTE(CPERG, .T.)}})
AADD(ABUT, {1, .T., {|O| O:OWND:END(), LOK := .T.}})
AADD(ABUT, {2, .T., {|O| O:OWND:END()}})

FORMBATCH(CTIT, ASAY, ABUT)

IF LOK
	
	//--VERIFICA SE O EXCEL ESTA INSTALADO
	IF !APOLECLIENT('MSEXCEL')
		AVISO("MSEXCEL","… NECESSARIO QUE O MS EXCEL ESTEJ· INSTALADO.",{"OK"},1)
		RETURN
	ENDIF
	
	//PROCESSAMENTO DO RELATÛRIO
	PROCESSA({|LEND|PROCPCO(@LEND)},"Planilha Financeira","AGUARDE. PREPARANDO DADOS PARA IMPRESS„O...",.T.)
	
ENDIF

RETURN


Static Function PROCPCO(LEND)
LOCAL CTBP    := GETNEXTALIAS()
LOCAL CDIRDOCS := MSDOCPATH()
LOCAL ASTRU	   := {}
LOCAL CARQUIVO := CRIATRAB(,.F.)
LOCAL CPATH	   := ALLTRIM(GETTEMPPATH())
LOCAL OEXCELAPP
LOCAL NLIN   := 0
LOCAL CGRUPO := ""
LOCAL CDESCRI := ""
LOCAL AGRUPO := {}
LOCAL ALINHAS := {}
LOCAL NREGS := 0
PRIVATE ACONT:={}
PRIVATE NHANDLE

//CRIA O ARQUIVO GetTempPath()

NHANDLE := MSFCREATE(CDIRDOCS+"\"+CARQUIVO+".XML",0)

//VERIFICA SE CONSEGUIU CRIAR O ARQUIVO
IF ( NHANDLE <= 0 )
	AVISO("EXCEL","FALHA NA GERAÁ„O DO ARQUIVO EXCEL.",{"OK"},1)
	RETURN
ENDIF
//gXml('<?xml version="1.0"?>')


//NlINHAS:=CONTAREGISTROS()



gXml('<?xml version="1.0"?>')
gXml('<?mso-application progid="Excel.Sheet"?>')
gXml('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"')
gXml(' xmlns:o="urn:schemas-microsoft-com:office:office"')
gXml(' xmlns:x="urn:schemas-microsoft-com:office:excel"')
gXml(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"')
gXml(' xmlns:html="http://www.w3.org/TR/REC-html40">')
gXml(' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">')
gXml('  <Author>Totvs</Author>')
gXml('  <LastAuthor>Totvs</LastAuthor>')
gXml('  <Created>2015-10-18T21:47:43Z</Created>')
gXml('  <Version>11.9999</Version>')
gXml(' </DocumentProperties>')
gXml(' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">')
gXml('  <AllowPNG/>')
gXml(' </OfficeDocumentSettings>')
gXml(' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">')
gXml('  <WindowHeight>9045</WindowHeight>')
gXml('  <WindowWidth>20490</WindowWidth>')
gXml('  <WindowTopX>0</WindowTopX>')
gXml('  <WindowTopY>0</WindowTopY>')
gXml('  <ProtectStructure>False</ProtectStructure>')
gXml('  <ProtectWindows>False</ProtectWindows>')
gXml(' </ExcelWorkbook>')
gXml(' <Styles>')
gXml('  <Style ss:ID="Default" ss:Name="Normal">')
gXml('   <Alignment ss:Vertical="Bottom"/>')
gXml('   <Borders/>')
gXml('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>')
gXml('   <Interior/>')
gXml('   <NumberFormat/>')
gXml('   <Protection/>')
gXml('  </Style>')
gXml('  <Style ss:ID="s21">')
gXml('   <Borders>')
gXml('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('   </Borders>')
gXml('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#FFFFFF" ss:Bold="1"/>')
gXml('   <Interior ss:Color="#33CCCC" ss:Pattern="Solid"/>')
gXml('  </Style>')
gXml('  <Style ss:ID="s22">')
gXml('   <Borders>')
gXml('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')                                     
gXml('   </Borders>')
gXml('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#FFFFFF" ss:Bold="1"/>')
gXml('   <Interior ss:Color="#33CCCC" ss:Pattern="Solid"/>')
gXml('  </Style>')
gXml('  <Style ss:ID="s23">')
gXml('   <Borders>')
gXml('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('   </Borders>')
gXml('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#FFFFFF" ss:Bold="1"/>')
gXml('   <Interior ss:Color="#33CCCC" ss:Pattern="Solid"/>')
gXml('  </Style>')
gXml('  <Style ss:ID="s24">')
gXml('   <Borders>')
gXml('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('   </Borders>')
gXml('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>')
gXml('   <Interior ss:Color="#CCFFFF" ss:Pattern="Solid"/>')
gXml('  </Style>')
gXml('  <Style ss:ID="s25">')
gXml('   <Borders>')
gXml('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('   </Borders>')
gXml('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>')
gXml('   <Interior ss:Color="#CCFFFF" ss:Pattern="Solid"/>')
gXml('  </Style>')
gXml('  <Style ss:ID="s26">')
gXml('   <Borders>')
gXml('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"')
gXml('     ss:Color="#99CCFF"/>')
gXml('   </Borders>')
gXml('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>')
gXml('   <Interior ss:Color="#CCFFFF" ss:Pattern="Solid"/>')
gXml('  </Style>')
gXml('  <Style ss:ID="s27">')
gXml('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"')
gXml('    ss:Underline="Single"/>')
gXml('  </Style>')
gXml(' </Styles>')
cTmpEmp:=SM0->M0_CODIGO
dbSelectArea('SM0')
DBSetOrder()
DbgoTop()
cEmp_:=""
While !SM0->(eof())
	if cEmp_<>SM0->M0_CODIGO
		cEmp_:=SM0->M0_CODIGO
		
		NlINHAS:=CONTAREG()
		if NlINHAS > 0
			gXml(' <Worksheet ss:Name="'+SM0->M0_CODIGO+'">')
			gXml('  <Table ss:ExpandedColumnCount="10" ss:ExpandedRowCount="'+cValtoChar(NlINHAS+100)+'" x:FullColumns="1"')
			gXml('   x:FullRows="1" ss:DefaultRowHeight="15">') 
			
			gXml(' 	<Column ss:Width="76.5"/>')
	   	gXml(' <Column ss:Width="30.75"/>')
	   	gXml(' <Column ss:Width="122.25"/>')
	   	gXml(' <Column ss:Width="48.75"/>')
	   	gXml(' <Column ss:Width="60.75"/>')
	   	gXml(' <Column ss:Width="101.25"/>')
	   	gXml(' <Column ss:Width="54.75"/>')
	   	gXml(' <Column ss:Width="55.5"/>')
	   	gXml(' <Column ss:Width="36.75"/>')
	   	gXml(' <Column ss:Width="361.5"/>')

			gXml('      <Row ss:AutoFitHeight="0">')
			gXml('    <Cell><Data ss:Type="String">'+SM0->M0_NOMECOM+'</Data></Cell>')
			gXml('   </Row>')
			gXml('   <Row ss:AutoFitHeight="0">')
			gXml('    <Cell ss:StyleID="s21"><Data ss:Type="String">TIPO</Data></Cell>')
			gXml('    <Cell ss:StyleID="s22"><Data ss:Type="String">Grupo</Data></Cell>')
			gXml('    <Cell ss:StyleID="s22"><Data ss:Type="String">Desc.</Data></Cell>')
			gXml('    <Cell ss:StyleID="s22"><Data ss:Type="String">NATUREZA</Data></Cell>')
			gXml('    <Cell ss:StyleID="s22"><Data ss:Type="String">FORNECEDOR</Data></Cell>')
			gXml('    <Cell ss:StyleID="s22"><Data ss:Type="String">NOME_FORNECEDOR</Data></Cell>')
			gXml('    <Cell ss:StyleID="s22"><Data ss:Type="String">VENC_REAL</Data></Cell>')
			gXml('    <Cell ss:StyleID="s22"><Data ss:Type="String">VALOR_TITU</Data></Cell>')
			gXml('    <Cell ss:StyleID="s22"><Data ss:Type="String">SALDO</Data></Cell>')
			gXml('    <Cell ss:StyleID="s23"><Data ss:Type="String">HISTORICO</Data></Cell>')
			gXml('   </Row>')
			
		cSql:="  SELECT SE2.E2_TIPO AS 'TIPO'"
		cSql+="	, SE2.E2_NATUREZ AS 'NATUREZA'"
		cSql+="	, CASE "
		cSql+="		WHEN A2_GRUPNAT ='' THEN SED.ED_GRUPNAT "
		cSql+="		WHEN A2_GRUPNAT <>'' THEN A2_GRUPNAT 
		cSql+="	END AS 'GRUPO'"
		cSql+="	, Z01_DESC AS 'DESC_GRUPO'"
		cSql+="	, SE2.E2_FORNECE AS 'FORNECEDOR'"
		cSql+="	, SE2.E2_NOMFOR AS 'NOME_FORNECEDOR'"
		cSql+="	, SE2.E2_VENCREA AS 'VENC_REAL'"
		cSql+="	, SE2.E2_VALOR AS 'VALOR_TITU'"
		cSql+="	, SE2.E2_SALDO AS 'SALDO'"
		cSql+="	, SE2.E2_HIST AS 'HISTORICO'"
		cSql+="	FROM SE2"+padr(cEmpant,3,'0')+ " SE2"
		cSql+="	inner JOIN "+RetSqlName('SED')+" SED"
		cSql+="		ON ED_CODIGO = E2_NATUREZ "
		cSql+="		AND SED.D_E_L_E_T_<>'*'"
		cSql+="		AND ED_FILIAL = '"+xFilial('SED')+"'" 
		cSql+=" INNER JOIN "+RetSqlName('SA2')+" SA2"
		cSql+=" 	ON A2_COD=E2_FORNECE"
		cSql+="   AND A2_LOJA = E2_LOJA"
		cSql+="   AND SA2.D_E_L_E_T_<>'*'"
		cSql+="	LEFT JOIN "+RetSqlName('Z01')+" Z01"
		cSql+="		ON ED_GRUPNAT = Z01_C0DIGO"
		cSql+="	WHERE (SE2.D_E_L_E_T_='') "
		cSql+="	AND (SE2.E2_VENCREA Between '"+DTOS(MV_PAR01)+"' And '"+DTOS(MV_PAR02)+"')"  
		
		cSql+=" 	 UNION		
		
		
		cSql+="		SELECT SE5.E5_TIPO AS 'TIPO',
		cSql+="       SE5.E5_NATUREZ AS 'NATUREZA',
		cSql+="       '' AS 'GRUPO',
		cSql+="       '' AS 'DESC_GRUPO',
		cSql+="       SE5.E5_FORNECE AS 'FORNECEDOR',
		cSql+="       '' AS 'NOME_FORNECEDOR',
		cSql+="       '' AS 'VENC_REAL',
		cSql+="       SE5.E5_VALOR AS 'VALOR_TITU',
 		cSql+="      '' AS 'SALDO',
		cSql+="       SE5.E5_HISTOR AS 'HISTORICO'
       
		cSql+="			FROM SE5"+padr(cEmpant,3,'0')+ " SE5"

		cSql+="			INNER JOIN	SED"+padr(cEmpant,3,'0')+ " SED"
		cSql+="			ON		SED.ED_CODIGO = SE5.E5_NATUREZ
		cSql+="			AND		SED.D_E_L_E_T_ = ''
		cSql+="			AND		SED.ED_CODIGO = '21201'

		cSql+="			WHERE (SE5.D_E_L_E_T_='')
		cSql+="		  AND (SE5.E5_DATA BETWEEN '"+DTOS(MV_PAR01)+"' And '"+DTOS(MV_PAR02)+"')"   
		
			IF Select('TRE2')<>0
				TRE2->(dbCloseArea())
			EndIF
			TcQuery cSql New  Alias "TRE2"
			While !TRE2->(Eof())
				gXml('   <Row ss:AutoFitHeight="0">')
				gXml('    <Cell ss:StyleID="s24"><Data ss:Type="String">'+alltrim(TRE2->TIPO)+'</Data></Cell>') 
				gXml('    <Cell ss:StyleID="s25"><Data ss:Type="String">'+alltrim(TRE2->GRUPO)+'</Data></Cell>')
				gXml('    <Cell ss:StyleID="s25"><Data ss:Type="String">'+alltrim(TRE2->DESC_GRUPO)+'</Data></Cell>')
				gXml('    <Cell ss:StyleID="s25"><Data ss:Type="String">'+alltrim(TRE2->NATUREZA)+'</Data></Cell>')
				gXml('    <Cell ss:StyleID="s25"><Data ss:Type="String">'+alltrim(TRE2->FORNECEDOR)+'</Data></Cell>')
				gXml('    <Cell ss:StyleID="s25"><Data ss:Type="String">'+alltrim(TRE2->NOME_FORNECEDOR)+'</Data></Cell>')
				gXml('    <Cell ss:StyleID="s25"><Data ss:Type="String">'+alltrim(DTOC(STOD(TRE2->VENC_REAL)))+'</Data></Cell>')
				gXml('    <Cell ss:StyleID="s25"><Data ss:Type="Number">'+cvaltochar(TRE2->VALOR_TITU)+'</Data></Cell>')
				gXml('    <Cell ss:StyleID="s25"><Data ss:Type="Number">'+cvaltochar(TRE2->SALDO)+'</Data></Cell>')
				gXml('    <Cell ss:StyleID="s26"><Data ss:Type="String">'+alltrim(TRE2->HISTORICO)+'</Data></Cell>' )
				gXml('   </Row>')
				TRE2->(dbSkip())
			EndDO
			
			
			gXml('  </Table>')
			gXml('  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">')
			gXml('   <PageSetup>')
			gXml('    <Header x:Margin="0.31496062000000002"/>')
			gXml('    <Footer x:Margin="0.31496062000000002"/>')
			gXml('    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"')
			gXml('     x:Right="0.511811024" x:Top="0.78740157499999996"/>')
			gXml('   </PageSetup>')
			gXml('   <Unsynced/>')
			gXml('   <Selected/>')
			gXml('   <Panes>')
			gXml('    <Pane>')
			gXml('     <Number>3</Number>')
			gXml('     <ActiveRow>3</ActiveRow>')
			gXml('     <ActiveCol>1</ActiveCol>')
			gXml('    </Pane>')
			gXml('   </Panes>')
			gXml('   <ProtectObjects>False</ProtectObjects>')
			gXml('   <ProtectScenarios>False</ProtectScenarios>')
			gXml('  </WorksheetOptions>')
			gXml(' </Worksheet>')
		EndIF
	EndIF
	SM0->(DBSKIP())
EndDO

 /*
gXml('  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">')
gXml('   <PageSetup>')
gXml('    <Header x:Margin="0.31496062000000002"/>')
gXml('    <Footer x:Margin="0.31496062000000002"/>')
gXml('    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"')
gXml('     x:Right="0.511811024" x:Top="0.78740157499999996"/>')
gXml('   </PageSetup>')
gXml('   <Unsynced/>')
gXml('   <Print>')
gXml('    <ValidPrinterInfo/>')
gXml('    <PaperSizeIndex>9</PaperSizeIndex>')
gXml('    <VerticalResolution>0</VerticalResolution>')
gXml('   </Print>')
gXml('   <Panes>')
gXml('    <Pane>')
gXml('     <Number>3</Number>')
gXml('     <RangeSelection>R1C1:R3C9</RangeSelection>')
gXml('    </Pane>')
gXml('   </Panes>')
gXml('   <ProtectObjects>False</ProtectObjects>')
gXml('   <ProtectScenarios>False</ProtectScenarios>')
gXml('  </WorksheetOptions>')
gXml(' </Worksheet>')  */
gXml('</Workbook>')


FCLOSE(NHANDLE)

//--COPIA PARA O TEMP
CPYS2T(CDIRDOCS+"\"+CARQUIVO+".XML",CPATH,.T.)

//--ABRE O XML NO EXCEL
OEXCELAPP := MSEXCEL():NEW()
OEXCELAPP:WORKBOOKS:OPEN( CPATH+CARQUIVO+".XML" )
OEXCELAPP:SETVISIBLE(.T.)
OEXCELAPP:DESTROY()

Return

STATIC FUNCTION GXML(CTEXTO)
FWRITE(NHANDLE,NoAcento(CTEXTO)+CHR(13)+CHR(10))
RETURN


Static Function CONTAREG()
Local nret:=0

cEmpant:=SM0->M0_CODIGO
cSql:="  SELECT SE2.E2_TIPO AS 'TIPO'"
cSql+="	, SE2.E2_NATUREZ AS 'NATUREZA'"
cSql+="	, CASE "
cSql+="		WHEN A2_GRUPNAT ='' THEN SED.ED_GRUPNAT "
cSql+="		WHEN A2_GRUPNAT <>'' THEN A2_GRUPNAT 
cSql+="	END AS 'GRUPO'"
cSql+="	, Z01_DESC AS 'DESC_GRUPO'"
cSql+="	, SE2.E2_FORNECE AS 'FORNECEDOR'"
cSql+="	, SE2.E2_NOMFOR AS 'NOME_FORNECEDOR'"
cSql+="	, SE2.E2_VENCREA AS 'VENC_REAL'"
cSql+="	, SE2.E2_VALOR AS 'VALOR_TITU'"
cSql+="	, SE2.E2_SALDO AS 'SALDO'"
cSql+="	, SE2.E2_HIST AS 'HISTORICO'"
cSql+="	FROM SE2"+padr(cEmpant,3,'0')+ " SE2"
cSql+="	inner JOIN "+RetSqlName('SED')+" SED"
cSql+="		ON ED_CODIGO = E2_NATUREZ "
cSql+="		AND SED.D_E_L_E_T_<>'*'"
cSql+="		AND ED_FILIAL = '"+xFilial('SED')+"'"
cSql+=" INNER JOIN "+RetSqlName('SA2')+" SA2"
cSql+=" 	ON A2_COD=E2_FORNECE"
cSql+="   AND A2_LOJA = E2_LOJA"
cSql+="   AND SA2.D_E_L_E_T_<>'*'"
cSql+="	LEFT JOIN "+RetSqlName('Z01')+" Z01"
cSql+="		ON ED_GRUPNAT = Z01_C0DIGO"
cSql+="	WHERE (SE2.D_E_L_E_T_='') "
cSql+="	AND (SE2.E2_VENCREA Between '"+DTOS(MV_PAR01)+"' And '"+DTOS(MV_PAR02)+"')" 


		cSql+=" 	 UNION		
		
		
		cSql+="		SELECT SE5.E5_TIPO AS 'TIPO',
		cSql+="       SE5.E5_NATUREZ AS 'NATUREZA',
		cSql+="       '' AS 'GRUPO',
		cSql+="       '' AS 'DESC_GRUPO',
		cSql+="       SE5.E5_FORNECE AS 'FORNECEDOR',
		cSql+="       '' AS 'NOME_FORNECEDOR',
		cSql+="       '' AS 'VENC_REAL',
		cSql+="       SE5.E5_VALOR AS 'VALOR_TITU',
 		cSql+="      '' AS 'SALDO',
		cSql+="       SE5.E5_HISTOR AS 'HISTORICO'
       
		cSql+="			FROM SE5"+padr(cEmpant,3,'0')+ " SE5"

		cSql+="			INNER JOIN	SED"+padr(cEmpant,3,'0')+ " SED"
		cSql+="			ON		SED.ED_CODIGO = SE5.E5_NATUREZ
		cSql+="			AND		SED.D_E_L_E_T_ = ''
		cSql+="			AND		SED.ED_CODIGO = '21201'

		cSql+="			WHERE (SE5.D_E_L_E_T_='')
		cSql+="		  AND (SE5.E5_DATA BETWEEN '"+DTOS(MV_PAR01)+"' And '"+DTOS(MV_PAR02)+"')"   


IF Select('TRE2')<>0
	TRE2->(dbCloseArea())
EndIF
TcQuery cSql New Alias "TRE2"
While !TRE2->(Eof())
	nret++
	TRE2->(dbSkip())
EndDO

Return nret

 static FUNCTION NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
cString:=strtran(cString,'√','A')
cString:=strtran(cString,'„','a')
cString:=strtran(cString,'¡','A')
cString:=strtran(cString,'…','E')
cString:=strtran(cString,'È','e')
cString:=strtran(cString,'Ì','i')
cString:=strtran(cString,'Õ','I')
cString:=strtran(cString,'”','O')
cString:=strtran(cString,'’','O')
cString:=strtran(cString,'ı','o')
cString:=strtran(cString,'∫',' ')
Return cString



Static Function criasx1(cperg)

PutSX1(cPerg, "01", "Periodo de"             , "", "", "mv_ch1", "D" , 08,  					0, 0, "G", "", ""   , "", "", "mv_par01", "","","","","","","","","","","","","","","","")
PutSX1(cPerg, "02", "Periodo Ate"            , "", "", "mv_ch2", "D" , 08,  					0, 0, "G", "", ""   , "", "", "mv_par02", "","","","","","","","","","","","","","","","")

Return
