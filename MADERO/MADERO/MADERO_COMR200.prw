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
!Módulo            ! Compras                                                 !
+------------------+---------------------------------------------------------+
!Nome              ! COMR200                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Relatório de Notas de Entrada                           !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Andrade                                		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 16/10/2018                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/

//trocar A2.A2_USERLGI ,SA2.A2_USERLGA quando for criado os campos na tabela SF1 - CABEcalho

User Function COMR200()

Local oReport
Private cPerg := PadR("COMR200",10)

CriaSX1(cPerg)
Pergunte(cPerg,.F.)

oReport := ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()

Local oReport
Local oSessao

oReport := TReport():New("COMR200", "Relatório de Notas Entrada", cPerg, {|oReport| ReportPrint(oReport)}, "Relatório de Notas de Entrada")
oReport:SetLandScape(.T.)
oSessao := TRSection():New(oReport, "Relatório de Notas de Entrada" )

// Colunas padrão


TRCell():New( oSessao, "F1_FILIAL" 	, "", "Filial" 		, "", 10)
TRCell():New( oSessao, "cDescFil" 	, "", "Descrição" 	, "", 40)
TRCell():New( oSessao, "F1_DOC" 	, "", "NF" 	   		, "", 15)
TRCell():New( oSessao, "F1_SERIE" 	, "", "Série" 		, "", 03)
TRCell():New( oSessao, "F1_STATUS" 	, "", "Status" 		, "", 17)
TRCell():New( oSessao, "cFornece" 	, "", "Fornecedor" 	, "", 12)
TRCell():New( oSessao, "cLoja" 		, "", "Loja"   		, "", 04)
TRCell():New( oSessao, "A2_NREDUZ" 	, "", "Descrição" 	, "", 30)
TRCell():New( oSessao, "D1_TOTAL" 	, "", "Valor Total"	, PesqPict("SD1","D1_TOTAL"), TamSx3("D1_TOTAL")[1])
TRCell():New( oSessao, "D1_DTDIGIT" , "", "Dt.Digit." 	, "", 12)
TRCell():New( oSessao, "F1_EMISSAO" , "", "Dt.Emiss." 	, "", 12)
TRCell():New( oSessao, "F1_DTLANC"  , "", "Dt.Lanc." 	, "", 12)
TRCell():New( oSessao, "cUsuInc" 	, "", "Incluido" 	, "", 20)
TRCell():New( oSessao, "dUsuInc" 	, "", "Data Inc." 	, PesqPict("SD1","D1_EMISSAO"), TamSx3("D1_EMISSAO")[1])
TRCell():New( oSessao, "cUsuAlt" 	, "", "Alterado" 	, "", 20)
TRCell():New( oSessao, "dUsuAlt" 	, "", "Data Alt." 	, PesqPict("SD1","D1_EMISSAO"), TamSx3("D1_EMISSAO")[1])
TRCell():New( oSessao, "B1_COD" 	, "", "Produto" 	, "", 15)
TRCell():New( oSessao, "B1_DESC" 	, "", "Descrição" 	, "", 60)

//	Totalizacao
// Somatórios de quantidade, volume
//oBreak := TRBreak():New(oSessao,	{|| .F.},	"Totais:",	.F.)

//TRFunction():New(oSessao:Cell("D1_TOTAL"),,"SUM",oBreak,,,,.F.,.F.)

oReport:HideParamPage()

Return (oReport)

Static Function ReportPrint(oReport)

Local oBreak
Local oSessao 	:= oReport:Section(1)
Local cAl 		:= GetNextAlias()
Local cWhere	:= '%%'
Local dDtInc 
Local dDtAlt  
Local cStatus 	:= ""

If mv_par09 == 1
	cWhere := "%"
	cWhere += " AND (SF1.F1_STATUS ='A') "
	cWhere += "%"
ElseIf mv_par09 == 2
	cWhere := "%"
	cWhere += " AND (SF1.F1_STATUS =' ') "
	cWhere += "%"
ElseIf mv_par09 == 3
	cWhere := "%"
	cWhere += " AND (SF1.F1_STATUS ='B') "
	cWhere += "%"
ElseIf mv_par09 == 4
	cWhere := "%"
	cWhere += " AND (SF1.F1_STATUS ='C') "
	cWhere += "%"
EndIf


// Seleciona todas as ordens de carregamento e seus tickets associados de acordo com os parâmetros informados
oSessao:BeginQuery()

BeginSQL alias cAl
	
	SELECT SF1.F1_FILIAL,	SF1.F1_DOC,	SF1.F1_SERIE,SF1.F1_STATUS,  SF1.F1_FORNECE,SF1.F1_LOJA,
	(SELECT SUM(SD12.D1_TOTAL) FROM %table:SD1% SD12 WHERE SF1.F1_DOC = SD12.D1_DOC AND SF1.F1_SERIE = SD12.D1_SERIE AND SF1.F1_FILIAL = SD12.D1_FILIAL AND SD12.D_E_L_E_T_ <> '*') AS D1_TOTAL ,
	SF1.F1_DTDIGIT as D1_DTDIGIT,SF1.F1_EMISSAO,SF1.F1_DTLANC,SF1.F1_USERLGI, SF1.F1_USERLGA,
	(CASE WHEN NVL(F1_USERLGI,'') ='                 '  THEN TO_DATE('19000101', 'YYYYMMDD') ELSE
	CONCAT(ASCII(SUBSTR(F1_USERLGI,12,1)) - 50, ASCII(SUBSTR(F1_USERLGI,16,1)) - 50) + TO_DATE('19960101', 'YYYYMMDD') END ) AS DTLGAINC,
	(CASE WHEN NVL(F1_USERLGA,'') ='                 '  THEN TO_DATE('19000101', 'YYYYMMDD') ELSE
	CONCAT(ASCII(SUBSTR(F1_USERLGA,12,1)) - 50, ASCII(SUBSTR(F1_USERLGA,16,1)) - 50) + TO_DATE('19960101', 'YYYYMMDD') END ) AS DTLGAALT,
	SB1.B1_COD,SB1.B1_DESC ,SA2.A2_NOME AS A2_NREDUZ
	FROM  %table:SF1% SF1
	INNER JOIN %table:SD1% SD1 ON SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FILIAL = SD1.D1_FILIAL AND SD1.D_E_L_E_T_ <> '*'
	INNER JOIN %table:SB1% SB1 ON SB1.B1_COD = SD1.D1_COD AND SB1.B1_FILIAL = SD1.D1_FILIAL
	INNER JOIN %table:SA2% SA2 ON SF1.F1_FORNECE = SA2.A2_COD AND SA2.A2_LOJA = SF1.F1_LOJA AND SA2.D_E_L_E_T_ <> '*'
	WHERE (SF1.D_E_L_E_T_ <> '*')
	AND (SF1.F1_FORNECE >= %Exp:mv_par05%)
	AND (SF1.F1_FORNECE <= %Exp:mv_par06%)
	AND (SF1.F1_FILIAL >= %Exp:mv_par01%)
	AND (SF1.F1_FILIAL <= %Exp:mv_par02%)
	AND (SD1.D1_DTDIGIT >= %Exp:mv_par03%)
	AND (SD1.D1_DTDIGIT <= %Exp:mv_par04%)
	AND (SF1.F1_DOC >= %Exp:mv_par07%)
	AND (SF1.F1_DOC <= %Exp:mv_par08%)
	%Exp:cWhere%
	ORDER BY SF1.F1_FILIAL,SF1.F1_DTDIGIT,SF1.F1_DOC,SF1.F1_SERIE
	
EndSQL
//Memowrite("c:\temp\COMR200.TXT",getLastQuery()[2])
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
	
	If Empty((cAl)->F1_STATUS)
		cStatus:= "Não Classificado"
	ElseIf (cAl)->F1_STATUS =="A"
		cStatus:= "Classificado"
	ElseIf F1_STATUS=="B"
		cStatus:= "NF Bloq."
	ElseIf F1_STATUS=="C"
		cStatus:= "NF Bloq.S/Classf."
	Else
		cStatus:= "Outros"
	EndIf
	
  	If (cAl)->DTLGAINC ==CTOD('01/01/1900')
		dDtInc := ("  /  /  ")
	Else
		dDtInc :=DTOC((cAl)->DTLGAINC)
	EndIf
	
	If (cAl)->DTLGAALT ==CTOD('01/01/1900')
		dDtAlt := ("  /  /  ")
	Else
		dDtAlt :=DTOC((cAl)->DTLGAALT)
	EndIf
	     
	oSessao:Cell("F1_FILIAL"):SetValue((cAl)->F1_FILIAL)
	oSessao:Cell("cDescFil"):SetValue(FwFilialName( cEmpant, (cAl)->F1_FILIAL, 1 ))
	oSessao:Cell("F1_DOC"):SetValue((cAl)->F1_DOC)
	oSessao:Cell("F1_SERIE"):SetValue((cAl)->F1_SERIE)
	oSessao:Cell("F1_STATUS"):SetValue(cStatus)
	oSessao:Cell("cFornece"):SetValue((cAl)->F1_FORNECE)
	oSessao:Cell("cLoja"):SetValue((cAl)->F1_LOJA)
	oSessao:Cell("A2_NREDUZ"):SetValue((cAl)->A2_NREDUZ)
	oSessao:Cell("D1_TOTAL"):SetValue((cAl)->D1_TOTAL)
	oSessao:Cell("D1_DTDIGIT"):SetValue((cAl)->D1_DTDIGIT)
	oSessao:Cell("F1_EMISSAO"):SetValue((cAl)->F1_EMISSAO)
	oSessao:Cell("F1_DTLANC"):SetValue((cAl)->F1_DTLANC)
	oSessao:Cell("cUsuInc"):SetValue(UsrRetName(SubStr( Embaralha((cAl)->F1_USERLGI, 1 ), 3, 6 ) ) )
	oSessao:Cell("dUsuInc"):SetValue(dDtInc)
	oSessao:Cell("cUsuAlt"):SetValue(UsrRetName(SubStr( Embaralha((cAl)->F1_USERLGA, 1 ), 3, 6 ) ) )
	oSessao:Cell("dUsuAlt"):SetValue(dDtAlt)
	oSessao:Cell("B1_COD"):SetValue((cAl)->B1_COD )
	oSessao:Cell("B1_DESC"):SetValue((cAl)->B1_DESC )
	
	oSessao:PrintLine()
	(cAl)->(dbSkip())
Enddo

oSessao:Finish()

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
Função para criação das perguntas na SX1

@author Jair  Matos
@since 16/10/2018
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
U_XPutSX1(cPerg, "01", "Filial De?"		,"MV_PAR01", "MV_CH1", "C", 10,	0, "G", cValid,     "SM0",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a filial inicial")
U_XPutSX1(cPerg, "02", "Filial Até?"	,"MV_PAR02", "MV_CH2", "C", 10, 0, "G", cValid,     "SM0",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a filial final")
U_XPutSX1(cPerg, "03", "Data Inicio?"	,"MV_PAR03", "MV_CH3", "D", 08, 0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data inicial a ser considerada")
U_XPutSX1(cPerg, "04", "Data Fim?" 		,"MV_PAR04", "MV_CH4", "D", 08, 0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data final a ser considerada")
U_XPutSX1(cPerg, "05", "Fornecedor De?"	,"MV_PAR05", "MV_CH5", "C", 06,	0, "G", cValid,     "SA2",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o fornecedor inicial")
U_XPutSX1(cPerg, "06", "Fornecedor Até?","MV_PAR06", "MV_CH6", "C", 06, 0, "G", cValid,     "SA2",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o fornecedor final")
U_XPutSX1(cPerg, "07", "NF De?"			,"MV_PAR07", "MV_CH7", "C", 09, 0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a NF. inicial")
U_XPutSX1(cPerg, "08", "NF Até?"		,"MV_PAR08", "MV_CH8", "C", 09, 0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a NF. final")
U_XPutSX1(cPerg, "09", "Status?"		,"MV_PAR09", "MV_CH9", "N", 01,  0, "C", cValid,      cF3,   cPicture,"Classificado","Não Class.","Bloqueado","Bloq.s/Classf.","Todos", "Informe a opção")
Return
