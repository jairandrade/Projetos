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
!Nome              ! ESTR200                                                 !
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

User Function ESTR200()

Local oReport
Private cPerg := PadR("ESTR200",10)

CriaSX1(cPerg)
Pergunte(cPerg,.F.)

oReport := ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()

Local oReport
Local oSessao

oReport := TReport():New("ESTR200", "Relatório de Itens Inventariados", cPerg, {|oReport| ReportPrint(oReport)}, "Relatório de Itens Inventariados")
oReport:SetLandScape(.T.)
oSessao := TRSection():New(oReport, "Relatório de Itens Inventariados" )

// Colunas padrão


TRCell():New( oSessao, "B7_DATA" 	, "", "Dt.Invent." 	, PesqPict("SB7","B7_DATA"), TamSx3("B7_DATA")[1])
TRCell():New( oSessao, "B7_COD" 	, "", "Produto" 	, "", 15)
TRCell():New( oSessao, "B1_DESC" 	, "", "Descrição" 	, "", 40)
TRCell():New( oSessao, "B1_GRUPO" 	, "", "Tp.Grupo"    , "", 04)
TRCell():New( oSessao, "B1_UM" 		, "", "UM" 			, "", 02)
TRCell():New( oSessao, "B7_LOCAL" 	, "", "AMZ" 		, "", 02)
TRCell():New( oSessao, "B7_DOC" 	, "", "Documento" 	, "", 09)
TRCell():New( oSessao, "B7_QUANT" 	, "", "Saldo"   	, PesqPict("SB7","B7_QUANT"), TamSx3("B7_QUANT")[1])
TRCell():New( oSessao, "nQtdAnt" 	, "", "Qtd.Anterior", PesqPict("SB7","B7_QUANT"), TamSx3("B7_QUANT")[1])
TRCell():New( oSessao, "DIFQUANT" 	, "", "Diferença"	, PesqPict("SB7","B7_QUANT"), TamSx3("B7_QUANT")[1])
TRCell():New( oSessao, "nVlrUnit" 	, "", "Vlr.Unitario", PesqPict("SB2","B2_CM1"), TamSx3("B2_CM1")[1])
TRCell():New( oSessao, "nVlrTotal"  , "", "Vlr.Total" 	, PesqPict("SB7","B7_QUANT"), TamSx3("B7_QUANT")[1])

//	Totalizacao
// Somatórios de quantidade, volume
oBreak := TRBreak():New(oSessao,oSessao:Cell("B7_DATA"),"SubTotal por Data")
TRFunction():New(oSessao:Cell("B7_QUANT"),"B7_QUANT","SUM",oBreak,,,,.F.,.F.)
TRFunction():New(oSessao:Cell("nVlrUnit"),"nVlrUnit","ONPRINT",oBreak,,,,.F.,.F.) 
TRFunction():New(oSessao:Cell("nVlrTotal"),,"ONPRINT",oBreak,,,{ || oSessao:GetFunction("B7_QUANT"):GetLastValue() * oSessao:GetFunction("nVlrUnit"):GetLastValue()},.F.,.F.)  

//TRFunction():New(oSessao:Cell("DIFQUANT"),,"SUM",oBreak,,,,.F.,.F.)
//oBreak1 := trBreak():New(oSessao,{||},"Total Geral",.F.)
//TRFunction():New(oSessao:Cell("B7_QUANT"),,"SUM",oBreak1,,,,.F.,.F.)
//TRFunction():New(oSessao:Cell("nVlrTotal"),,"ONPRINT",oBreak1,,"@E 999,999.99",{ || 0},.F.,.F.)
//TRFunction():New(oSessao:Cell("nVlrUnit"),,"ONPRINT",oBreak1,,,,.F.,.F.)
oReport:HideParamPage()

Return (oReport)

Static Function ReportPrint(oReport)

Local oBreak
Local oSessao 	:= oReport:Section(1)
Local cWhere	:= '%%'
Local nCont		:= 0
Local nSaldoB7 := 0
Local nVlrUni := 0     
Local nQtdAnt 	:= 0  
Local cAl 		:= GetNextAlias()  

// Seleciona todas as ordens de carregamento e seus tickets associados de acordo com os parâmetros informados
oSessao:BeginQuery()

BeginSQL alias cAl
	
	SELECT 	SB7.B7_DATA,SB7.B7_COD, SB1.B1_DESC,SB1.B1_GRUPO,SB1.B1_UM,SB7.B7_LOCAL,B7_QUANT,SD3.D3_DOC,SD3.D3_QUANT,SD3.D3_CUSTO1,
	(SD3.D3_CUSTO1 / SD3.D3_QUANT) AS VLRUNIT,
	(SELECT B7_QUANT FROM %table:SB7% SB71 WHERE SB71.D_E_L_E_T_= ' ' AND SB71.B7_COD = SB7.B7_COD AND SB71.B7_DATA < SB7.B7_DATA) AS NQTDANT
	FROM %table:SB7% SB7
	INNER JOIN %table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1%
	AND SB1.B1_COD = SB7.B7_COD
	AND SB1.B1_COD BETWEEN %Exp:MV_PAR01%	AND %Exp:MV_PAR02%
	AND SB1.B1_TIPO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
	AND SB1.B1_GRUPO BETWEEN %Exp:MV_PAR07%	AND %Exp:MV_PAR08%
	AND SB1.%NotDel%
	LEFT OUTER JOIN %table:SD3% SD3 ON SD3.D3_FILIAL = %xFilial:SD3%
	AND SD3.D3_COD = SB7.B7_COD
	//AND SD3.D3_DOC = 'INVENT'
	AND SD3.D3_EMISSAO = SB7.B7_DATA
	AND SD3.%NotDel%
	WHERE
	SB7.B7_FILIAL =  %xFilial:SB7%
	AND SB7.B7_LOCAL BETWEEN %Exp:MV_PAR05%	AND %Exp:MV_PAR06%
	AND SB7.%NotDel%
	GROUP BY SB7.B7_DATA,SB7.B7_COD, SB1.B1_DESC,SB1.B1_GRUPO,SB1.B1_UM,SB7.B7_LOCAL,B7_QUANT,SD3.D3_DOC,SD3.D3_QUANT,SD3.D3_CUSTO1
	ORDER BY SB7.B7_DATA,SB7.B7_COD
	//AND %Exp:cWhere%
	
EndSQL
//			Memowrite("c:\temp\ESTR200.TXT",getLastQuery()[2])
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
	
	If Empty((cAl)->NQTDANT)
		nQtdAnt := Posicione("SB9", 01, xFilial("SB9") + (cAl)->B7_COD + (cAl)->B7_LOCAL, "B9_QINI")
	Else
		nQtdAnt := (cAl)->NQTDANT
	EndIf
	//calcula campo b7_quant(saldo)
	If (cAl)->D3_DOC=='INVENT   '
		nSaldoB7 := (cAl)->B7_QUANT 
		nCont:= (cAl)->B7_QUANT
	Else
		nSaldoB7	:=nQtdAnt+(cAl)->D3_QUANT 
		nCont		:=	nSaldoB7
	EndIf
	
	nVlrUni := ((cAl)->D3_CUSTO1 / (cAl)->D3_QUANT)
	
	oSessao:Cell("B7_DATA"):SetValue(DTOC((cAl)->B7_DATA))
	oSessao:Cell("B7_COD"):SetValue((cAl)->B7_COD)
	oSessao:Cell("B1_DESC"):SetValue((cAl)->B1_DESC)
	oSessao:Cell("B1_GRUPO"):SetValue((cAl)->B1_GRUPO)
	oSessao:Cell("B1_UM"):SetValue((cAl)->B1_UM)
	oSessao:Cell("B7_LOCAL"):SetValue((cAl)->B7_LOCAL)
	oSessao:Cell("B7_DOC"):SetValue((cAl)->D3_DOC)
	oSessao:Cell("B7_QUANT"):SetValue(nSaldoB7)
	oSessao:Cell("nQtdAnt"):SetValue(nQtdAnt)
	oSessao:Cell("DIFQUANT"):SetValue((cAl)->D3_QUANT)
	oSessao:Cell("nVlrUnit"):SetValue(nVlrUni)
	oSessao:Cell("nVlrTotal"):SetValue((cAl)->D3_CUSTO1)

	oSessao:PrintLine()
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
U_XPutSX1(cPerg, "03", "Do Tipo?"	    ,"MV_PAR03", "MV_CH3", "C", 02, 0, "G", cValid,      "02",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o tipo inicial a ser considerado")
U_XPutSX1(cPerg, "04", "Até Tipo?" 		,"MV_PAR04", "MV_CH4", "C", 02, 0, "G", cValid,      "02",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o tipo final a ser considerado")
U_XPutSX1(cPerg, "05", "Armazem De?"	,"MV_PAR05", "MV_CH5", "C", 02,	0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o armazem inicial")
U_XPutSX1(cPerg, "06", "Armazem Até?"	,"MV_PAR06", "MV_CH6", "C", 02, 0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o armazem final")
U_XPutSX1(cPerg, "07", "Grupo De?"		,"MV_PAR07", "MV_CH7", "C", 04, 0, "G", cValid,     "SBM",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o grupo inicial")
U_XPutSX1(cPerg, "08", "Grupo Até?"		,"MV_PAR08", "MV_CH8", "C", 04, 0, "G", cValid,     "SBM",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o grupo final")

Return
