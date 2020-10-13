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
!Nome              ! ESTR017                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Relatório de Estrutura de Produtos SG1                  !
+------------------+---------------------------------------------------------+
!Autor             ! Jair Andrade                                		     !
+------------------+---------------------------------------------------------+
!Data de Criação   ! 10/07/2019                                              !
+------------------+---------------------------------------------------------+
!   ATUALIZACÕES                                                             !
+-------------------------------------------+-----------+-----------+--------+
!   Descrição detalhada da atualização      !Nome do    ! Analista  !Data da !
!                                           !Solicitante! Respons.  !Atualiz.!
+-------------------------------------------+-----------+-----------+--------+
!                                           !           !           !        !
+-------------------------------------------+-----------+-----------+--------+
*/ 

User Function ESTR017()

	Local oReport
	Private cPerg := PadR("ESTR017",10)

	CriaSX1(cPerg)
	Pergunte(cPerg,.F.)

	oReport := ReportDef()
	oReport:PrintDialog()

Return 

Static Function ReportDef()

	Local oReport
	Local oSessao

	oReport := TReport():New("ESTR017", "Relatório de estrutura de produtos", cPerg, {|oReport| ReportPrint(oReport)}, "Relatório de estrutura de produtos")
	oReport:SetLandScape(.T.)
	oSessao := TRSection():New(oReport, "Relatório de estrutura de produtos" )

	// Colunas padrão


	TRCell():New( oSessao, "G1_FILIAL" 	, "", "Filial" 		, "", 10)
	TRCell():New( oSessao, "cDescFil" 	, "", "Descrição" 	, "", 30)
	TRCell():New( oSessao, "G1_COD" 	, "", "Codigo" 		,PesqPict("SG1","G1_COD"), TamSx3("G1_COD")[1])
	TRCell():New( oSessao, "G1_COMP" 	, "", "Componente"	, PesqPict("SG1","G1_COMP"), TamSx3("G1_COMP")[1])
	TRCell():New( oSessao, "G1_QUANT" 	, "", "Quantidade"	,PesqPict("SG1","G1_QUANT"), TamSx3("G1_QUANT")[1])
	TRCell():New( oSessao, "G1_PERDA" 	, "", "Perda"	 	,PesqPict("SG1","G1_PERDA"), TamSx3("G1_PERDA")[1])
	TRCell():New( oSessao, "G1_INI" 	, "", "Dt. Inicial"	, PesqPict("SG1","G1_INI"), TamSx3("G1_INI")[1]+10)
	TRCell():New( oSessao, "G1_FIM" 	, "", "Dt. Final" 	, PesqPict("SG1","G1_FIM"), TamSx3("G1_FIM")[1]+10)
	TRCell():New( oSessao, "cUsuInc" 	, "", "Incluido" 	, "", 20)
	TRCell():New( oSessao, "dUsuInc" 	, "", "Data Inc." 	, PesqPict("SG1","G1_INI"), TamSx3("G1_INI")[1]+10)
	TRCell():New( oSessao, "cUsuAlt" 	, "", "Alterado" 	, "", 20)
	TRCell():New( oSessao, "dUsuAlt" 	, "", "Data Alt." 	, PesqPict("SG1","G1_FIM"), TamSx3("G1_FIM")[1]+10)

	oReport:HideParamPage()

Return (oReport)

Static Function ReportPrint(oReport)

	Local oBreak
	Local oSessao 	:= oReport:Section(1)
	Local cAl 		:= GetNextAlias()
	Local cWhere	:= '%%'
	Local dDtInc 	:= CtoD("  /  /  ")
	Local dDtIncLGA := CtoD("  /  /  ")
	Local cUserLGI 	:= ""
	Local cUserLGA 	:= ""
	Local cStatus 	:= ""


	// Seleciona todas as ordens de carregamento e seus tickets associados de acordo com os parâmetros informados
	oSessao:BeginQuery()

	BeginSQL alias cAl

		SELECT Z14.Z14_XUSER,Z14_XDTMOV,SG1.*
		FROM  %table:SG1% SG1
		JOIN %table:Z14% Z14
		ON G1_FILIAL = Z14_FILIAL
		AND G1_COD = Z14_COD 
		AND Z14.D_E_L_E_T_ <> '*'
		WHERE (SG1.D_E_L_E_T_ <> '*')
		AND (SG1.G1_FILIAL >= %Exp:mv_par01%)
		AND (SG1.G1_FILIAL <= %Exp:mv_par02%)
		AND (SG1.G1_COD >= %Exp:mv_par03%)
		AND (SG1.G1_COD <= %Exp:mv_par04%)
		%Exp:cWhere%
		ORDER BY G1_FILIAL,G1_COD

	EndSQL
	//Memowrite("c:\temp\ESTR017.TXT",getLastQuery()[2])
	oSessao:EndQuery()

	DbSelectArea(cAl)

	(cAl)->(DbGoTop())

	ProcRegua(Reccount())

	oReport:SetMeter((cAl)->(RecCount()))

	oSessao:Init()
	Do While (!(cAl)->(Eof()))
		dDtInc 	:= CtoD("  /  /  ")
		dDtIncLGA := CtoD("  /  /  ")
		cUserLGI 	:= ""
		cUserLGA 	:= ""
		If oReport:Cancel()
			Exit
		EndIf

		cUserLGI := Embaralha((cAl)->G1_USERLGI, 1 )
		If !Empty(cUserLGI)
			dDtInc 	 := CTOD("01/01/96","DDMMYY") + Load2In4(Substr(cUserLGI,16))
		EndIf
		//cUserLGA := Embaralha((cAl)->G1_USERLGA, 1 )
		cUserLGA := (cAl)->Z14_XUSER
		If !Empty(cUserLGA)
			dDtIncLGA 	 := (cAl)->Z14_XDTMOV
		EndIf
		oSessao:Cell("G1_FILIAL"):SetValue((cAl)->G1_FILIAL)
		oSessao:Cell("cDescFil"):SetValue(FwFilialName( cEmpant, (cAl)->G1_FILIAL, 1 ))
		oSessao:Cell("G1_COD"):SetValue((cAl)->G1_COD)
		oSessao:Cell("G1_COMP"):SetValue((cAl)->G1_COMP)
		oSessao:Cell("G1_QUANT"):SetValue((cAl)->G1_QUANT)
		oSessao:Cell("G1_PERDA"):SetValue((cAl)->G1_PERDA)
		oSessao:Cell("G1_INI"):SetValue((cAl)->G1_INI)
		oSessao:Cell("G1_FIM"):SetValue((cAl)->G1_FIM)
		oSessao:Cell("cUsuInc"):SetValue(UsrRetName(SubStr( cUserLGI, 3, 6 ) ) )
		oSessao:Cell("dUsuInc"):SetValue(dDtInc)
		oSessao:Cell("cUsuAlt"):SetValue(cUserLGA)
		oSessao:Cell("dUsuAlt"):SetValue(dDtIncLGA)

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
	U_XPutSX1(cPerg, "03", "Produto De?"	,"MV_PAR03", "MV_CH3", "C", 15,	0, "G", cValid,     "SB1",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o produto inicial")
	U_XPutSX1(cPerg, "04", "Produto Até?"	,"MV_PAR04", "MV_CH4", "C", 15, 0, "G", cValid,     "SB1",   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o produto final")
Return
