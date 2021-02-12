/**********************************************************************************************************************************/
/** Faturamento                                                                                                                  **/
/** Relatorio de pedidos intangiveis.                                                                                            **/
/** Autor: luiz henrique jacinto                                                                                                 **/
/** RSAC Soluções                                                                                                                **/
/**********************************************************************************************************************************/
/** Data       | Responsável                    | Descrição                                                                      **/
/**********************************************************************************************************************************/                          
/** 27/04/2018 | Luiz Henrique Jacinto          | Criação da rotina/procedimento.                                                **/
/**********************************************************************************************************************************/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"

#Define ENTER CHR(13)+CHR(10)

/**********************************************************************************************************************************/
/** user function KFATA12R()                                                                                                      **/
/** inicio do relatorio                                                                                                          **/
/**********************************************************************************************************************************/
user function KFATA12R()

	// objeto relatorio
	private oReport
	// grupo de pergunta
	private cPerg   := "KFATA12R"

	
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	
	// cria o relatorio
	oReport := ReportDef()
	// orientacao papel
	oReport:SetLandScape()
	// tela de impressao
	oReport:PrintDialog()

return

static function ReportDef

	// titulo do relatorio
	Local cTitRel	:= "Pedidos intangiveis""
	// descritivo do relatorio
	local cDscRel	:= "Este relatorio tem por objetivo exibir os pedidos que geram intangiveis e os numeros dos intangiveis gerados."
	// ordem do relatorio
	local aOrdem  	:= {}
	// secao 1
	local oSection1 := Nil

	aadd(aOrdem,"Emp + Fil + Vend + Cli + Pedido")
	aadd(aOrdem,"Emp + Fil + Pedido")
	
	// cria o relatorio
	oReport := 	TReport():New(cPerg, cTitRel, cPerg	, {|oReport| ReportImpr() }, cDscRel)

	//Orientacao papel
	oReport:SetLandScape()

	//Inibe pagina parametros
	oReport:lParamPage := .F.

	//Nao exibe relatorio
	//oReport:lPreview   := .F.

	//Gera planilha
	oReport:nDevice    := 4

	// Não imprime parametros em excel
	oReport:lXlsHeader := .F.
	
	// cria secao
	oSection1 := TRSection():New( oReport, Nil	, {}, aOrdem )
	// cria as colunas
	TRCell():New( oSection1, "EMPRESA"		,""  	,"Empresa"		,"@!"					,02	,.F.)
	TRCell():New( oSection1, "C5_FILIAL"	,"SC5" 	,				,						, 	,	)
	TRCell():New( oSection1, "C5_NUM"		,"SC5" 	,				,						, 	,	)
	TRCell():New( oSection1, "C5_VEND1"		,"SC5" 	,				,						, 	,	)
	TRCell():New( oSection1, "A3_NOME"		,"SA3" 	,"Ven Nome"		,						, 	,	)
	TRCell():New( oSection1, "C5_CLIENTE"	,"SC5" 	,				,						, 	,	)
	TRCell():New( oSection1, "C5_LOJACLI"	,"SC5" 	,				,						, 	,	)
	TRCell():New( oSection1, "A1_NOME"		,"SA1" 	,"Cli Nome"		,						, 	,	)
	TRCell():New( oSection1, "C5_EMISSAO"	,"SC5" 	,"PV Emissao"	,						, 	,	)
	TRCell():New( oSection1, "A1_K_INTAN"	,"SA1" 	,				,						, 	,	)
	TRCell():New( oSection1, "B1_INTANG"	,"SB1" 	,				,						, 	,	)
	TRCell():New( oSection1, "C6_VALOR"		,"SC6" 	,				,						, 	,	)
	TRCell():New( oSection1, "C5_SERIE"		,"SC5" 	,				,						, 	,	)
	TRCell():New( oSection1, "D2_DOC"		,"SD2" 	,            	,						, 	,	)
	TRCell():New( oSection1, "D2_EMISSAO"	,"SD2" 	,"NF Emissao"	,						, 	,	)
	TRCell():New( oSection1, "C5_K_INTAN"	,"SC5" 	,				,						, 	,	)
	TRCell():New( oSection1, "C5_K_PO"		,"SC5" 	,				,						, 	,	)
	TRCell():New( oSection1, "IN_EMP"		,"   " 	,"Inta. Empresa","@!"					,02	,	)
	TRCell():New( oSection1, "IN_PED"		,"   " 	,"Inta. Pedido"	,"@!"					,06	,	)
	TRCell():New( oSection1, "IN_EMISSAO"	,"   " 	,"Inta. Emissao",X3Picture("D2_EMISSAO"),08	,	)

return oReport

static function ReportImpr()

	// secao nao-conformidades
	Local oSection1	:= oReport:Section(1)
	// ordem do relatorio
	Local nOrdem	:= oSection1:GetOrder()
	// restaura os registros
	Local cTemp		:= QryDados(nOrdem) 
	
	// seta regua
	oReport:SetMeter( 0 )
	oReport:lEmptyLineExcel:= .F.
	
	// inicio query
	(cTemp)->(DbGoTop())

	oSection1:Init()

	// loop sobre registros
	while !(cTemp)->( Eof() )
		If oReport:Cancel()
			Exit
		EndIf

		// incrementa regua
		oReport:IncMeter()

		// atribui valor as celullas
		oSection1:Cell("EMPRESA"	):SetValue( (cTemp)->EMPRESA	)
		oSection1:Cell("C5_FILIAL"	):SetValue( (cTemp)->C5_FILIAL	)
		oSection1:Cell("C5_NUM"		):SetValue( (cTemp)->C5_NUM		)
		oSection1:Cell("C5_VEND1"	):SetValue( (cTemp)->C5_VEND1	)
		oSection1:Cell("A3_NOME"	):SetValue( (cTemp)->A3_NOME	)
		oSection1:Cell("C5_CLIENTE"	):SetValue( (cTemp)->C5_CLIENTE	)
		oSection1:Cell("C5_LOJACLI"	):SetValue( (cTemp)->C5_LOJACLI	)
		oSection1:Cell("A1_NOME"	):SetValue( (cTemp)->A1_NOME	)
		oSection1:Cell("C5_EMISSAO"	):SetValue( (cTemp)->C5_EMISSAO	)
		oSection1:Cell("A1_K_INTAN"	):SetValue( (cTemp)->A1_K_INTAN	)
		oSection1:Cell("B1_INTANG"	):SetValue( (cTemp)->B1_INTANG	)
		oSection1:Cell("C6_VALOR"	):SetValue( (cTemp)->C6_VALOR	)
		oSection1:Cell("C5_SERIE"	):SetValue( (cTemp)->C5_SERIE	)
		oSection1:Cell("D2_DOC"		):SetValue( (cTemp)->D2_DOC		)
		oSection1:Cell("D2_EMISSAO"	):SetValue( (cTemp)->D2_EMISSAO	)
		oSection1:Cell("C5_K_INTAN"	):SetValue( (cTemp)->C5_K_INTAN	)
		oSection1:Cell("C5_K_PO"	):SetValue( (cTemp)->C5_K_PO	)
		oSection1:Cell("IN_EMP"		):SetValue( (cTemp)->IN_EMP		)
		oSection1:Cell("IN_PED"		):SetValue( (cTemp)->IN_PED		)
		oSection1:Cell("IN_EMISSAO"	):SetValue( (cTemp)->IN_EMISSAO	)
		
		// imprime linha
		oSection1:PrintLine()

		// desabilita a partir da 1a.
		oSection1:lHeaderSection := .F.

		// proximo registro
		(cTemp)->( DbSkip() )

	endDo

	// fecha query
	MyClose(cTemp)

	// finaliza impressao
	oSection1:Finish()

return

Static Function QryDados(nOrdem)
	Local cQuery 	:= ""
	Local cTemp		:= GetNextAlias()
	
	cQuery += "SELECT "+ENTER
	cQuery += "	'"+cEmpAnt+"' EMPRESA "+ENTER
	cQuery += "	,C5_FILIAL "+ENTER
	cQuery += "	,C5_NUM "+ENTER
	cQuery += "	,C5_VEND1 "+ENTER
	cQuery += "	,A3_NOME "+ENTER
	cQuery += "	,C5_CLIENTE "+ENTER
	cQuery += "	,C5_LOJACLI "+ENTER
	cQuery += "	,A1_NOME "+ENTER
	cQuery += "	,C5_EMISSAO "+ENTER
	cQuery += "	,A1_K_INTAN "+ENTER
	cQuery += "	,B1_INTANG "+ENTER
	cQuery += "	,sum(C6_VALOR ) C6_VALOR "+ENTER
	cQuery += "	,C5_SERIE "+ENTER
	cQuery += "	,ISNULL(D2_EMISSAO,'') D2_EMISSAO"+ENTER
	cQuery += "	,ISNULL(D2_DOC,'') D2_DOC"+ENTER
	cQuery += "	,C5_K_INTAN "+ENTER
	cQuery += "	,'04'+C5_FILIAL+C5_NUM C5_K_PO "+ENTER
	cQuery += "	,ISNULL(IN_EMP,'')IN_EMP "+ENTER
	cQuery += "	,ISNULL(IN_K_PO,'')IN_K_PO "+ENTER
	cQuery += "	,ISNULL(IN_PED,'')IN_PED "+ENTER
	cQuery += "	,ISNULL(IN_EMISSAO,'')IN_EMISSAO "+ENTER
	cQuery += "FROM "+RetSqlName("SC6")+" SC6 "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SC5")+" SC5 ON SC5.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND C5_FILIAL = C6_FILIAL "+ENTER
	cQuery += "		AND C5_NUM = C6_NUM "+ENTER
	cQuery += "		AND C5_TIPO = 'N' "+ENTER
	cQuery += "		AND C5_EMISSAO >= '20170101' "+ENTER
	cQuery += "		AND C5_PVINTAN ='S' "+ENTER
	cQuery += "		AND C5_EMISSAO >= '"+DtoS(MV_PAR01)+"' "+ENTER
	cQuery += "		AND C5_EMISSAO <= '"+DtoS(MV_PAR02)+"' "+ENTER
	cQuery += "		AND C5_VEND1 >= '"+mv_par07+"' "+ENTER
	cQuery += "		AND C5_VEND1 <= '"+mv_par08+"' "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND B1_FILIAL = '"+xFilial("SB1")+"'  "+ENTER
	cQuery += "		AND B1_COD = C6_PRODUTO "+ENTER
	cQuery += "		AND B1_INTANG = 'S' "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND A1_FILIAL = '"+xFilial("SA1")+"' "+ENTER
	cQuery += "		AND A1_COD = C6_CLI "+ENTER
	cQuery += "		AND A1_LOJA = C6_LOJA "+ENTER
	cQuery += "	INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND F4_FILIAL = C6_FILIAL "+ENTER
	cQuery += "		AND F4_CODIGO = C6_TES "+ENTER
	cQuery += "		AND F4_DUPLIC = 'S' "+ENTER
	cQuery += "	LEFT OUTER JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND D2_FILIAL = C6_FILIAL "+ENTER
	cQuery += "		AND D2_PEDIDO = C6_NUM "+ENTER
	cQuery += "		AND D2_ITEMPV = C6_ITEM "+ENTER
	cQuery += "	LEFT OUTER JOIN "+RetSqlName("SA3")+" SA3 ON SA3.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "		AND A3_FILIAL ='"+xFilial("SA1")+"' "+ENTER
	cQuery += "		AND A3_COD = C5_VEND1	 "+ENTER
	cQuery += "	LEFT OUTER JOIN ( "+ENTER
	// join com todas as empresas
	cQuery += "					SELECT "+ENTER
	cQuery += "						'01' IN_EMP "+ENTER
	cQuery += "						,C5_NUM IN_PED "+ENTER
	cQuery += "						,C5_K_PO IN_K_PO "+ENTER
	cQuery += "						,C5_EMISSAO IN_EMISSAO "+ENTER
	cQuery += "					FROM SC5010 "+ENTER
	cQuery += "					WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "					AND C5_EMISSAO>='20170101' "+ENTER
	cQuery += "					AND C5_K_PO<>'' "+ENTER
	cQuery += "				UNION "+ENTER
	cQuery += "					SELECT "+ENTER
	cQuery += "						'02' EMPRESA "+ENTER
	cQuery += "						,C5_NUM "+ENTER
	cQuery += "						,C5_K_PO "+ENTER
	cQuery += "						,C5_EMISSAO IN_EMISSAO "+ENTER
	cQuery += "					FROM SC5020 "+ENTER
	cQuery += "					WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "					AND C5_EMISSAO>='20170101' "+ENTER
	cQuery += "					AND C5_K_PO<>'' "+ENTER
	cQuery += "				UNION "+ENTER
	cQuery += "					SELECT "+ENTER
	cQuery += "						'03' EMPRESA "+ENTER
	cQuery += "						,C5_NUM "+ENTER
	cQuery += "						,C5_K_PO "+ENTER
	cQuery += "						,C5_EMISSAO IN_EMISSAO "+ENTER
	cQuery += "					FROM SC5030 "+ENTER
	cQuery += "					WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "					AND C5_EMISSAO>='20170101' "+ENTER
	cQuery += "					AND C5_K_PO<>'' "+ENTER
	cQuery += "				UNION "+ENTER
	cQuery += "					SELECT "+ENTER
	cQuery += "						'04' EMPRESA "+ENTER
	cQuery += "						,C5_NUM "+ENTER
	cQuery += "						,C5_K_PO "+ENTER
	cQuery += "						,C5_EMISSAO IN_EMISSAO "+ENTER
	cQuery += "					FROM SC5040 "+ENTER
	cQuery += "					WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "					AND C5_EMISSAO>='20170101' "+ENTER
	cQuery += "					AND C5_K_PO<>'' "+ENTER
	cQuery += "				UNION "+ENTER
	cQuery += "					SELECT "+ENTER
	cQuery += "						'05' EMPRESA "+ENTER
	cQuery += "						,C5_NUM "+ENTER
	cQuery += "						,C5_K_PO "+ENTER
	cQuery += "						,C5_EMISSAO IN_EMISSAO "+ENTER
	cQuery += "					FROM SC5050 "+ENTER
	cQuery += "					WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "					AND C5_EMISSAO>='20170101' "+ENTER
	cQuery += "					AND C5_K_PO<>'' "+ENTER
	cQuery += "				UNION "+ENTER
	cQuery += "					SELECT "+ENTER
	cQuery += "						'06' EMPRESA "+ENTER
	cQuery += "						,C5_NUM "+ENTER
	cQuery += "						,C5_K_PO "+ENTER
	cQuery += "						,C5_EMISSAO IN_EMISSAO "+ENTER
	cQuery += "					FROM SC5060 "+ENTER
	cQuery += "					WHERE D_E_L_E_T_<>'*' "+ENTER
	cQuery += "					AND C5_EMISSAO>='20170101' "+ENTER
	cQuery += "					AND C5_K_PO<>'' "+ENTER
	cQuery += "						) TAB ON IN_K_PO = '04'+C5_FILIAL+C5_NUM  "+ENTER
	cQuery += "WHERE  "+ENTER
	cQuery += "		SC6.D_E_L_E_T_<>'*' "+ENTER
	cQuery += "	AND C6_NUM >='"+mv_par03+"' "+ENTER
	cQuery += "	AND C6_NUM <='"+mv_par04+"' "+ENTER
	cQuery += "	AND C6_CLI >='"+mv_par05+"' "+ENTER
	cQuery += "	AND C6_CLI <='"+mv_par06+"' "+ENTER
	cQuery += "	AND D2_EMISSAO >='"+DtoS(mv_par09)+"' "+ENTER
	cQuery += "	AND D2_EMISSAO <='"+DtoS(mv_par10)+"' "+ENTER
	
	cQuery += "	 "+ENTER
	cQuery += "GROUP BY "+ENTER
	cQuery += "	C5_FILIAL "+ENTER
	cQuery += "	,C5_NUM "+ENTER
	cQuery += "	,C5_VEND1 "+ENTER
	cQuery += "	,A3_NOME  "+ENTER
	cQuery += "	,C5_CLIENTE "+ENTER
	cQuery += "	,C5_LOJACLI "+ENTER
	cQuery += "	,A1_NOME "+ENTER
	cQuery += "	,C5_EMISSAO "+ENTER
	cQuery += "	,A1_K_INTAN "+ENTER
	cQuery += "	,B1_INTANG "+ENTER
	cQuery += "	,C5_SERIE "+ENTER
	cQuery += "	,D2_DOC "+ENTER
	cQuery += "	,D2_EMISSAO "+ENTER
	cQuery += "	,C5_K_INTAN "+ENTER
	cQuery += "	,C5_K_PO "+ENTER
	cQuery += "	,D2_DOC "+ENTER
	cQuery += "	,D2_SERIE "+ENTER
	cQuery += "	,'"+cEmpAnt+"'+C5_FILIAL+C5_NUM "+ENTER
	cQuery += "	,ISNULL(IN_EMP,'') "+ENTER
	cQuery += "	,ISNULL(IN_K_PO,'') "+ENTER
	cQuery += "	,ISNULL(IN_PED,'') "+ENTER
	cQuery += "	,ISNULL(IN_EMISSAO,'') "+ENTER
	cQuery += "ORDER BY "+ENTER
	If nOrdem == 1
		cQuery += "	1,2,4,6,3 "+ENTER
	Else 
		cQuery += "	1,2,3 "+ENTER
	Endif
	
	MyClose(cTemp)
	
	TcQuery cQuery New Alias (cTemp)
	
	TCSetField(cTemp,"C5_EMISSAO","D",8,0)
	TCSetField(cTemp,"D2_EMISSAO","D",8,0)
	TCSetField(cTemp,"IN_EMISSAO","D",8,0)
	
	(cTemp)->( DbGoTop() )
	
Return cTemp

Static Function MyClose(_cAlias)
	If Select(_cAlias)>0
		(_cAlias)->( DbCloseArea())
	Endif
Return