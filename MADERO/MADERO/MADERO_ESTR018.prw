#Include "Protheus.ch"
#Include "TopConn.ch"
/*
+----------------------------------------------------------------------------+
!                             FICHA TÉCNICA DO PROGRAMA                      !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Relatório                                               !
+------------------+---------------------------------------------------------+ 
!Módulo            ! Estoque / Custos                                        !
+------------------+---------------------------------------------------------+
!Nome              ! ESTR018                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Relatório Inventário SD3 	                 			 !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Matos                                  		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 25/05/2020                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
|											|			|			|		 |
+-------------------------------------------+-----------+-----------+--------+
*/
User function ESTR018()
	Local cTitle 	:= OemToAnsi("Relatório Inventário SD3")
	Local cHelp		:= OemToAnsi("Relatório Inventário SD3")
	Local cPerg 	:= padr("ESTR018",10)
	Local oRel		:= Nil
	Local oSection1	:= Nil
	Private rs 		:= 0  

	//Cria as perguntas se não existerem
	CriaSX1(cPerg)
	Pergunte(cPerg, .F.)

	//Criacao do componente de impressao
	oRel := tReport():New(cPerg,cTitle,cPerg,{|oRel|ReportPrint(oRel)},cHelp)
	//Seta a orientação do papel
	oRel:setLandscape()

	oSection1 := trSection():New(oRel,"Relatório Inventário SD3 Sintetico",{})
	trCell():New(oSection1,"D3_FILIAL",	"",RetTitle("D3_FILIAL")  ,PesqPict("SD3","D3_FILIAL")  	,TamSx3("D3_FILIAL")[1])
	trCell():New(oSection1,"ADK_NOME",	"",RetTitle("ADK_NOME")	  ,PesqPict("ADK","ADK_NOME") 		,TamSx3("ADK_NOME")[1])
	trCell():New(oSection1,"D3_DOC", 	"","Documento"  	   	  ,PesqPict("SD3","D3_DOC") 		,TamSx3("D3_DOC")[1])
	trCell():New(oSection1,"D3_EMISSAO","",	RetTitle("D3_EMISSAO"),PesqPict("SD3","D3_EMISSAO") 	,TamSx3("D3_EMISSAO")[1])

	oSection2 := TRSection():New(oRel,"Relatorio de  Inventário SD3 Analitico",{})
	trCell():New(oSection2,"D3_FILIAL",	"",RetTitle("D3_FILIAL")  ,PesqPict("SD3","D3_FILIAL")  	,TamSx3("D3_FILIAL")[1])
	trCell():New(oSection2,"ADK_NOME",	"",RetTitle("ADK_NOME")	  ,PesqPict("ADK","ADK_NOME") 		,TamSx3("ADK_NOME")[1])
	trCell():New(oSection2,"D3_DOC", 	"","Documento"     		  ,PesqPict("SD3","D3_DOC") 		,TamSx3("D3_DOC")[1])
	trCell():New(oSection2,"D3_EMISSAO","","Emissão"     		  ,PesqPict("SD3","D3_EMISSAO") 	,TamSx3("D3_EMISSAO")[1])
	trCell():New(oSection2,"D3_TM",  	"","Tp.Movimento"   	  ,PesqPict("SD3","D3_TM") 			,TamSx3("D3_TM")[1])
	trCell():New(oSection2,"D3_GRUPO", 	"","Grupo"  		   	  ,PesqPict("SD3","D3_GRUPO") 		,TamSx3("D3_GRUPO")[1])
	trCell():New(oSection2,"BM_DESC",	"","Desc.Grupo"  	   	  ,PesqPict("SD3","BM_DESC") 		,TamSx3("BM_DESC")[1])
	trCell():New(oSection2,"D3_COD",	"","Produto"  		  	  ,PesqPict("SD3","D3_COD") 		,TamSx3("D3_COD")[1]) 
	trCell():New(oSection2,"B1_DESC",	"","Desc.Produto"	  	  ,PesqPict("SB1","B1_DESC") 		,TamSx3("B1_DESC")[1])
	trCell():New(oSection2,"D3_UM", 	"","Unidade"  	   	  	  ,PesqPict("SD3","D3_UM") 			,TamSx3("D3_UM")[1])
	trCell():New(oSection2,"D3_LOCAL",	"","Armazem"  	   	  	  ,PesqPict("SD3","D3_LOCAL") 		,TamSx3("D3_LOCAL")[1])
	trCell():New(oSection2,"D3_QUANT",	"","Quantidade"  	   	  ,PesqPict("SD3","D3_QUANT") 		,TamSx3("D3_QUANT")[1])
	trCell():New(oSection2,"D3_CUSTO1",	"","Total"  	   	  	  ,PesqPict("SD3","D3_CUSTO1") 		,TamSx3("D3_CUSTO1")[1])

	//	Totalizacao
	oBreak1 := TRBreak():New(oSection2,	{|| .F.},	"Totais:",	.F.)
	TRFunction():New(oSection2:Cell("D3_QUANT"),,"SUM",oBreak1,,,,.F.,.F.)
	TRFunction():New(oSection2:Cell("D3_CUSTO1"),,"SUM",oBreak1,,,,.F.,.F.)

	oRel:SetTotalInLine(.F.)

	//Executa o relatório
	oRel:PrintDialog()
	Return
	//-------------------------------------------------------------------
	/*/{Protheus.doc} ReportPrint()
	Impressao do formulario grafico conforme laytout no formato retrato

	@author 	Jair Matos
	@since 		25/05/2018
	@version 	P12
	/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oRel)
	Local oSection1	:= oRel:Section(1)
	Local oSection2	:= oRel:Section(2)
	Local cAliasTemp:= GetNextAlias()
	Local cWhere	:= '%%'
	//Sintetico com Data
	If mv_par11 == 1

		oSection1:BeginQuery()

		BeginSql  Alias cAliasTemp
			SELECT D3_FILIAL ,D3_EMISSAO, D3_DOC,SUM(D3_QUANT) AS QUANT,SUM(D3_CUSTO1) AS TOTAL
			FROM %table:SD3% SD3  
			WHERE D3_FILIAL  BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND D3_EMISSAO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
			AND D3_GRUPO BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
			AND D3_COD BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
			AND D3_LOCAL BETWEEN %Exp:mv_par09% AND %Exp:mv_par10%	
			AND D3_CF IN('RE0')
			AND D3_TM IN('499','999')
			AND SD3.%notDel%
			%Exp:cWhere%
			GROUP BY D3_FILIAL,D3_EMISSAO,D3_DOC
			ORDER BY D3_FILIAL,D3_EMISSAO,D3_DOC
		EndSql
		_cResQry:= GETLastQuery()[2]
		//Memowrite("c:\temp\_ESTR018S.txt",_cResQry)
		oSection1:EndQuery()

		DbSelectArea(cAliasTemp)

		(cAliasTemp)->(DbGoTop())

		ProcRegua(Reccount())

		oRel:SetMeter((cAliasTemp)->(RecCount()))
		oSection1:Init()
		Do While (!(cAliasTemp)->(Eof()))

			If oRel:Cancel()
				Exit
			EndIf

			oSection1:Cell("D3_FILIAL"):SetValue((cAliasTemp)->D3_FILIAL)
			oSection1:Cell("ADK_NOME"):SetValue(FWFilialName (cEmpAnt,(cAliasTemp)->D3_FILIAL))
			oSection1:Cell("D3_DOC"):SetValue((cAliasTemp)->D3_DOC)	
			oSection1:Cell("D3_EMISSAO"):SetValue((cAliasTemp)->D3_EMISSAO)

			oSection1:PrintLine()
			(cAliasTemp)->(dbSkip())
		Enddo
		oSection1:Finish()
		//Sintético sem Data
	Else

		oSection2:BeginQuery()

		BeginSql  Alias cAliasTemp
			SELECT D3_FILIAL ,D3_EMISSAO, D3_COD ,D3_TM, D3_GRUPO, D3_DOC,D3_UM, D3_LOCAL, B1_DESC,D3_QUANT,
			D3_CUSTO1,BM_DESC,B1_DESC
			FROM %table:SD3% SD3 
			JOIN %table:SBM% SBM ON BM_GRUPO=D3_GRUPO AND SBM.D_E_L_E_T_ <> '*'   
			JOIN %table:SB1% SB1 ON B1_FILIAL = D3_FILIAL AND B1_COD = D3_COD AND SB1.D_E_L_E_T_ <> '*' 
			WHERE D3_FILIAL  BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND D3_EMISSAO BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
			AND D3_GRUPO BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
			AND D3_COD BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
			AND D3_LOCAL BETWEEN %Exp:mv_par09% AND %Exp:mv_par10%		
			AND SD3.%notDel%
			AND D3_CF IN('RE0','DE0')
			AND D3_TM IN('499','999')
			%Exp:cWhere%
			ORDER BY D3_FILIAL,D3_EMISSAO,D3_GRUPO,D3_TM,D3_COD
		EndSql

		_cResQry:= GETLastQuery()[2]
		//Memowrite("c:\temp\_ESTR018A.txt",_cResQry)

		oSection1:EndQuery()

		DbSelectArea(cAliasTemp)

		(cAliasTemp)->(DbGoTop())

		ProcRegua(Reccount())

		oRel:SetMeter((cAliasTemp)->(RecCount()))
		oSection2:Init()
		Do While (!(cAliasTemp)->(Eof()))

			If oRel:Cancel()
				Exit
			EndIf

			oSection2:Cell("D3_FILIAL"):SetValue((cAliasTemp)->D3_FILIAL)
			oSection2:Cell("ADK_NOME"):SetValue(alltrim(FWFilialName (cEmpAnt,(cAliasTemp)->D3_FILIAL)))
			oSection2:Cell("D3_DOC"):SetValue((cAliasTemp)->D3_DOC)
			oSection2:Cell("D3_EMISSAO"):SetValue((cAliasTemp)->D3_EMISSAO)
			oSection2:Cell("D3_TM"):SetValue((cAliasTemp)->D3_TM)
			oSection2:Cell("D3_GRUPO"):SetValue((cAliasTemp)->D3_GRUPO)
			oSection2:Cell("BM_DESC"):SetValue(alltrim((cAliasTemp)->BM_DESC))
			oSection2:Cell("D3_COD"):SetValue((cAliasTemp)->D3_COD) 
			oSection2:Cell("B1_DESC"):SetValue(alltrim((cAliasTemp)->B1_DESC))
			oSection2:Cell("D3_UM"):SetValue((cAliasTemp)->D3_UM) 
			oSection2:Cell("D3_LOCAL"):SetValue((cAliasTemp)->D3_LOCAL)
			oSection2:Cell("D3_QUANT"):SetValue(Iif((cAliasTemp)->D3_TM='999',-((cAliasTemp)->D3_QUANT),(cAliasTemp)->D3_QUANT))
			oSection2:Cell("D3_CUSTO1"):SetValue(Iif ((cAliasTemp)->D3_TM='999',-((cAliasTemp)->D3_CUSTO1),(cAliasTemp)->D3_CUSTO1)) 
			oSection2:PrintLine()

			(cAliasTemp)->(dbSkip())
		Enddo

		oSection2:Finish()
		oRel:SetTotalInLine(.F.)
	EndIf
Return
//---------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
Função para criação das perguntas na SX1

@author Jair  Matos
@since 25/05/2020
@version P12
@return Nil
/*/
//---------------------------------------------------------------------
Static Function CriaSX1(cPerg)
	cValid   := ""
	cF3      := ""
	cPicture := ""
	cDef01   := ""
	cDef02   := ""
	cDef03   := ""
	cDef04   := ""
	cDef05   := ""
	U_XPutSX1(cPerg, "01", "Filial De?"			,"MV_PAR01", "MV_CH1", "C", 10,	0, "G", cValid,     "SM0",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a Filial inicial")
	U_XPutSX1(cPerg, "02", "Filial Até?"		,"MV_PAR02", "MV_CH2", "C", 10, 0, "G", cValid,     "SM0",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a Filial final")
	U_XPutSX1(cPerg, "03", "Emissao De?"		,"MV_PAR03", "MV_CH3", "D", 08,	0, "G", cValid,     cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a Data inicial")
	U_XPutSX1(cPerg, "04", "Emissao Até?"  		,"MV_PAR04", "MV_CH4", "D", 08, 0, "G", cValid,     cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a Data final")
	U_XPutSX1(cPerg, "05", "Grupo De?"	   		,"MV_PAR05", "MV_CH5", "C", 04,	0, "G", cValid,     "SBM",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o Grupo inicial")
	U_XPutSX1(cPerg, "06", "Grupo Até?"	   		,"MV_PAR06", "MV_CH6", "C", 04, 0, "G", cValid,     "SBM",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o Grupo final")
	U_XPutSX1(cPerg, "07", "Produto De?"		,"MV_PAR07", "MV_CH7", "C", 15,	0, "G", cValid,     "SB1",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o Produto inicial")
	U_XPutSX1(cPerg, "08", "Produto Até?"		,"MV_PAR08", "MV_CH8", "C", 15, 0, "G", cValid,     "SB1",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o Produto final")
	U_XPutSX1(cPerg, "09", "Armazem De?"		,"MV_PAR09", "MV_CH9", "C", 02,	0, "G", cValid,     "NNR",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o Armazem inicial")
	U_XPutSX1(cPerg, "10", "Armazem Até?"		,"MV_PAR10", "MV_CHA", "C", 02, 0, "G", cValid,     "NNR",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o Armazem final")
	U_XPutSX1(cPerg, "11", "Rel.Sintetico?"		,"MV_PAR11", "MV_CHB", "N", 01,  0, "C", cValid,      cF3,   cPicture,         "Sim",   "Não",         cDef03,       cDef04,    cDef05, "Informe Sim / Não para Data")

Return