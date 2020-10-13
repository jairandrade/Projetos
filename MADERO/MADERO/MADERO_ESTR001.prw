#include "totvs.ch"
#include "rwmake.ch"
#include "topconn.ch"
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
!Nome              ! ESTR001                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Relatório de Inventario (MATR285) - customizado         !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Andrade                                		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 22/10/2018                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
! ALTERAR FUNCAO PARA PEGAR SALDO NA DATA DO INVENTARIO - CALCEST() !        !
+-------------------------------------------+-----------+-----------+--------+
*/

User Function ESTR001()

	Local oReport
	Private cPerg := PadR("ESTR001",10)
	Pergunte(cPerg,.F.)

	CriaSX1(cPerg)
	Pergunte(cPerg,.F.)

	oReport := ReportDef()
	oReport:PrintDialog()

Return

Static Function ReportDef()

	Local oReport
	Local oSessao

	oReport := TReport():New("ESTR001", "Relatório de Itens Inventariados", cPerg, {|oReport| ReportPrint(oReport)}, "Relatório de Itens Inventariados")
	oReport:SetLandScape(.T.)
	oSessao := TRSection():New(oReport, "Relatório de Itens Inventariados" )

	// Colunas padrão


	TRCell():New( oSessao, "B7_DATA" 	, "", "Dt.Invent." 	, PesqPict("SB7","B7_DATA"), TamSx3("B7_DATA")[1])
	TRCell():New( oSessao, "B7_COD" 	, "", "Produto" 	, "", 15)
	TRCell():New( oSessao, "B1_DESC" 	, "", "Descrição" 	, "", 40)
	TRCell():New( oSessao, "D3_GRUPO" 	, "", "Tp.Grupo"    , "", 04)
	TRCell():New( oSessao, "B1_UM" 		, "", "UM" 			, "", 02)
	TRCell():New( oSessao, "B7_LOCAL" 	, "", "AMZ" 		, "", 02)
	TRCell():New( oSessao, "B7_DOC" 	, "", "Documento" 	, "", 09)
	TRCell():New( oSessao, "B7_QUANT" 	, "", "Saldo"   	, PesqPict("SB7","B7_QUANT"), TamSx3("B7_QUANT")[1])
	TRCell():New( oSessao, "nQtdAnt" 	, "", "Qtd.Anterior", PesqPict("SB7","B7_QUANT"), TamSx3("B7_QUANT")[1])
	TRCell():New( oSessao, "DIFQUANT" 	, "", "Diferença"	, PesqPict("SB7","B7_QUANT"), TamSx3("B7_QUANT")[1])
	TRCell():New( oSessao, "nVlrUnit" 	, "", "Vlr.Unit.Atual", PesqPict("SB2","B2_CM1"), TamSx3("B2_CM1")[1])
	TRCell():New( oSessao, "nVlrTotal"  , "", "Vlr.Total" 	, PesqPict("SB7","B7_QUANT"), TamSx3("B7_QUANT")[1])
	TRCell():New( oSessao, "STATUS"     , "", "Status" 		, "", 15)

	//	Totalizacao
	// Somatórios de quantidade, volume
	oBreak := TRBreak():New(oSessao,oSessao:Cell("B7_DATA"),"SubTotal por Data")
	TRFunction():New(oSessao:Cell("B7_QUANT"),"B7_QUANT","SUM",oBreak,,,,.F.,.F.)
	TRFunction():New(oSessao:Cell("nQtdAnt"),"nQtdAnt","SUM",oBreak,,,,.F.,.F.)
	TRFunction():New(oSessao:Cell("DIFQUANT"),"DIFQUANT","SUM",oBreak,,,,.F.,.F.)
	TRFunction():New(oSessao:Cell("nVlrUnit"),"nVlrUnit","SUM",oBreak,,,,.F.,.F.)
	TRFunction():New(oSessao:Cell("nVlrTotal"),"nVlrUnit","SUM",oBreak,,,,.F.,.F.)

	oReport:HideParamPage()

Return (oReport)

Static Function ReportPrint(oReport)

	Local oBreak
	Local oSessao 	:= oReport:Section(1)
	Local nVlrUni := 0
	Local nVlrTot := 0
	Local nQtdAnt 	:= 0
	Local nDifQdt := 0
	Local cD3TM := ""
	Local nD3Quant := 0
	Local aRetorno :={}
	Local 	cQuery := ""
	Local cAl 	:= GetNextAlias()

	// Seleciona todas as ordens de carregamento e seus tickets associados de acordo com os parâmetros informados
	oSessao:BeginQuery()

	BeginSQL alias cAl

		SELECT 	SB7.B7_DATA,SB7.B7_COD, SB1.B1_DESC,SB1.B1_UM,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_STATUS
		FROM %table:SB7% SB7
		INNER JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
		AND SB1.B1_COD = SB7.B7_COD
		AND SB1.B1_COD BETWEEN %Exp:MV_PAR01%	AND %Exp:MV_PAR02%
		AND SB1.B1_TIPO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
		AND SB1.%NotDel%
		WHERE
		SB7.B7_FILIAL =  %xFilial:SB7%
		AND SB7.B7_LOCAL BETWEEN %Exp:MV_PAR05%	AND %Exp:MV_PAR06%
		AND SB7.B7_DATA BETWEEN %Exp:DTOS(MV_PAR09)%	AND %Exp:DTOS(MV_PAR10)%
		AND SB7.%NotDel%
		ORDER BY SB7.R_E_C_N_O_

	EndSQL
	Memowrite("c:\temp\ESTR001.TXT",getLastQuery()[2])
	oSessao:EndQuery()

	DbSelectArea(cAl)

	(cAl)->(DbGoTop())

	ProcRegua(Reccount())

	oReport:SetMeter((cAl)->(RecCount()))

	oSessao:Init()
	Do While (!(cAl)->(Eof()))

		If oReport:Cancel()
			Exit
		EndIf

		If (Select("ZSD3") <> 0)
			DbSelectArea("ZSD3")
			ZSD3->(DbCloseArea())
		Endif

		cQuery :=" SELECT SD3.D3_GRUPO,SD3.D3_DOC,SD3.D3_QUANT,SD3.D3_CUSTO1,SD3.D3_CF"
		cQuery +=" FROM "+RetSQLName('SD3')+" SD3 WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"'"
		cQuery +=" AND SD3.D3_COD = '"+(cAl)->B7_COD+"'"
		cQuery +=" AND SD3.D3_DOC = 'INVENT'"
		cQuery +=" AND SD3.D3_EMISSAO = '"+DTOS((cAl)->B7_DATA)+"'"
		cQuery +=" AND SD3.D3_GRUPO BETWEEN '" + mv_par07       + "' AND '" + mv_par08       + "' "
		cQuery +=" AND SD3.D_E_L_E_T_ <> '*' "
		cQuery +=" ORDER BY R_E_C_N_O_ "

		TCQuery cQuery new Alias "ZSD3"
		//Memowrite("c:\temp\ZSD3.txt",CQuery)
		ZSD3->(DbGoTop())

		While !ZSD3->(EOF())
			If ZSD3->D3_QUANT != nD3Quant
				nD3Quant :=ZSD3->D3_QUANT
				If Empty(ZSD3->D3_QUANT)
					//Verifica se o status está 1=nao processado ou 2 processado
					If (cAl)->B7_STATUS =="1" // pega o saldo fisico
						dbSelectArea("SB2")
						SB2->(dbSetOrder(1))//	B2_FILIAL+B2_COD+B2_LOCAL
						IF( SB2->(dbSeek(xFilial("SB2")+(cAl)->B7_COD+(cAl)->B7_LOCAL)) )
							nQtdAnt := SB2->B2_QATU
						EndIf
					Else
						nQtdAnt := (cAl)->B7_QUANT
					EndIf

					aRetorno := CalcEst((cAl)->B7_COD,(cAl)->B7_LOCAL,(cAl)->B7_DATA)
					nVlrUni := aRetorno[2] / aRetorno[1]			
					nDifQdt := (cAl)->B7_QUANT  - nQtdAnt
					nVlrTot := nVlrUni * nDifQdt
				Else
					nVlrUni := ZSD3->D3_CUSTO1 / nD3Quant
					//Verifica se o status está 1=nao processado ou 2 processado
					If (cAl)->B7_STATUS =="1" // pega o saldo fisico
						dbSelectArea("SB2")
						SB2->(dbSetOrder(1))//	B2_FILIAL+B2_COD+B2_LOCAL
						IF( SB2->(dbSeek(xFilial("SB2")+(cAl)->B7_COD+(cAl)->B7_LOCAL)) )
							nQtdAnt := SB2->B2_QATU
						EndIf
						nDifQdt := (cAl)->B7_QUANT - nQtdAnt
						nVlrTot := nDifQdt * nVlrUni
					Else
						//11/03/2020
						nQtdAnt := (cAl)->B7_QUANT - nD3Quant
						nDifQdt := nD3Quant
						nVlrTot := ZSD3->D3_CUSTO1
					EndIf
					cD3TM:=	Posicione("SD3", 07, xFilial("SD3") + (cAl)->B7_COD + (cAl)->B7_LOCAL +DTOS((cAl)->B7_DATA), "D3_TM")
					If cD3TM >'500'
						nVlrTot := nVlrTot*-1
						nDifQdt :=  nDifQdt*-1
					EndIf
				EndIf

				oSessao:Cell("B7_DATA"):SetValue(DTOC((cAl)->B7_DATA))
				oSessao:Cell("B7_COD"):SetValue((cAl)->B7_COD)
				oSessao:Cell("B1_DESC"):SetValue((cAl)->B1_DESC)
				oSessao:Cell("D3_GRUPO"):SetValue(ZSD3->D3_GRUPO)
				oSessao:Cell("B1_UM"):SetValue((cAl)->B1_UM)
				oSessao:Cell("B7_LOCAL"):SetValue((cAl)->B7_LOCAL)
				oSessao:Cell("B7_DOC"):SetValue(ZSD3->D3_DOC)
				oSessao:Cell("B7_QUANT"):SetValue((cAl)->B7_QUANT )
				oSessao:Cell("nQtdAnt"):SetValue(nQtdAnt)
				oSessao:Cell("DIFQUANT"):SetValue(nDifQdt)
				oSessao:Cell("nVlrUnit"):SetValue(round(nVlrUni,4))
				oSessao:Cell("nVlrTotal"):SetValue(round(nVlrTot,4))
				oSessao:Cell("STATUS"):SetValue(Iif((cAl)->B7_STATUS=="1","Não processado", "Processado"))

				oSessao:PrintLine()
			Exit
			EndIf
			ZSD3->(dbSkip())
		Enddo
		(cAl)->(dbSkip())
	Enddo

	oSessao:Finish()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
Função para criação das perguntas na SX1

@author Jair  Matos
@since 30/10/2018
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

	U_XPutSX1(cPerg, "01", "Produto De?"	,"MV_PAR01", "MV_CH1", "C", 15,	0, "G", cValid,     "SB1",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o produto inicial")
	U_XPutSX1(cPerg, "02", "Produto Até?"	,"MV_PAR02", "MV_CH2", "C", 15, 0, "G", cValid,     "SB1",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o produto final")
	U_XPutSX1(cPerg, "03", "Do Tipo?"	    ,"MV_PAR03", "MV_CH3", "C", 02, 0, "G", cValid,     "02",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o tipo inicial a ser considerado")
	U_XPutSX1(cPerg, "04", "Até Tipo?" 		,"MV_PAR04", "MV_CH4", "C", 02, 0, "G", cValid,     "02",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o tipo final a ser considerado")
	U_XPutSX1(cPerg, "05", "Armazem De?"	,"MV_PAR05", "MV_CH5", "C", 02,	0, "G", cValid,     cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o armazem inicial")
	U_XPutSX1(cPerg, "06", "Armazem Até?"	,"MV_PAR06", "MV_CH6", "C", 02, 0, "G", cValid,     cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o armazem final")
	U_XPutSX1(cPerg, "07", "Grupo De?"		,"MV_PAR07", "MV_CH7", "C", 04, 0, "G", cValid,     "SBM",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o grupo inicial")
	U_XPutSX1(cPerg, "08", "Grupo Até?"		,"MV_PAR08", "MV_CH8", "C", 04, 0, "G", cValid,     "SBM",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o grupo final")
	U_XPutSX1(cPerg, "09", "Data De?"		,"MV_PAR09", "MV_CH9", "D", 08,	0, "G", cValid,     cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a Data inicial")
	U_XPutSX1(cPerg, "10", "Data Até?"		,"MV_PAR10", "MV_CHA", "D", 08, 0, "G", cValid,     cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a Data final")
Return