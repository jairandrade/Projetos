#include 'protheus.ch'


User Function RAcd020()

	Local oReport

	Private cPerg   := "RACD020B"

	//CriaSX1()
	Pergunte(cPerg,.T.)

	//Interface de impressao
	oReport:= ReportDef()
	oReport:PrintDialog()

Return

/*/
A funcao estatica ReportDef devera ser criada para todos os
relatorios que poderao ser agendados pelo usuario.
/*/
Static Function ReportDef()

	Local oReport
	Local oOrdem, oEmpenho
	Local cTitle    := "Requisição com Assinatura"
	Local cQryRel   := GetNextAlias()

	//Criacao do componente de impressao
	oReport:= TReport():New("MATR265",cTitle,cPerg, {|oReport| ReportPrint(oReport,cQryRel)},OemToAnsi("Este relatorio tem o objetivo de facilitar a retirada de materiais"))
	//Define a orientacao de pagina do relatorio como retrato.
	oReport:SetPortrait()
	oReport:nFontBody := 10
	oReport:SetLineHeight(65)
	oReport:HideParamPage()

	//oOrdem (Ordem de Producao)
	oOrdem := TRSection():New(oReport,"Ordens de Serviço",{"SC2"},/*Ordem*/)
	oOrdem:SetLineStyle()
	oOrdem:SetLeftMargin(2)

	TRCell():New(oOrdem,'C2_NUM'     ,'SC2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oOrdem,'C2_EMISSAO' ,'SC2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oOrdem,'ZD3_ORDEM'  ,'ZD3',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	oOrdem:Cell('C2_NUM'    ):SetCellBreak()
	oOrdem:Cell('C2_EMISSAO'):SetCellBreak()


	//oEmpenho (Item Ordem de Producao)
	oEmpenho := TRSection():New(oOrdem,"Entregue",{},/*Ordem*/)
	oEmpenho:SetLeftMargin(5)

	TRCell():New(oEmpenho,'ZD3_PROD'    ,'ZD3',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oEmpenho,'B1_DESC'     ,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oEmpenho,'ZD3_LOTECT'  ,'ZD3',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oEmpenho,'ZD3_NUMSER'  ,'ZD3',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oEmpenho,'ZD3_QTESEP'  ,'ZD3',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oEmpenho,'B1_UM'       ,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)


	oReport:SetPageFooter(7,{|| ObsAndAss(oReport) })


Return oReport


/*/
A funcao estatica ReportPrint devera ser criada para todos
os relatorios que poderao ser agendados pelo usuario.
/*/
Static Function ReportPrint(oReport, cQryRel)

	Local oOrdem     := oReport:Section(1)
	Local oEmpenho   := oReport:Section(1):Section(1)

	Local lQuery      := .F.

	Local cChave := cCompara := cTitulo:= ""

	Local nSldSD4	  := 0

	Local cWhere := "%%"

	IF !Empty(mv_par02)
		cWhere := "%ZD3.ZD3_ORDEM  = '" + mv_par02 + "' AND%"
	EndIF

	//Transforma parametros Range em expressao SQL
	MakeSqlExpr(oReport:GetParam())

	BEGIN REPORT QUERY oOrdem
		BeginSQL Alias cQryRel

		select
			CB7.CB7_ORDSEP, CB7.CB7_OP,
			SC2.C2_NUM, SC2.C2_EMISSAO,
			ZD3_PROD, B1_DESC, B1_UM,
			ZD3_ORDEM, ZD3_LOCAL, ZD3_LOTECT, ZD3_NUMSER, sum(ZD3_QTESEP) as ZD3_QTESEP


		from %table:ZD3% ZD3

			INNER JOIN %table:SB1% SB1 ON
				SB1.B1_FILIAL = %xFilial:SB1% AND
				SB1.B1_COD = ZD3.ZD3_PROD AND
				SB1.D_E_L_E_T_ = ' '


			INNER JOIN %table:CB7% CB7 ON
				CB7.CB7_FILIAL = %xFilial:CB7% AND
				CB7.CB7_ORDSEP = ZD3.ZD3_ORDSEP AND
				CB7.D_E_L_E_T_ = ' '

			INNER JOIN %table:SC2% SC2 ON
				SC2.C2_FILIAL  = %xFilial:SC2% AND
				SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_GRADE = CB7.CB7_OP AND
				SC2.D_E_L_E_T_ = ' '

		where
			ZD3.ZD3_FILIAL = %xFilial:ZD3% AND
			CB7.CB7_OP = %Exp: mv_par01 % AND
			%Exp: cWhere %
			ZD3.D_E_L_E_T_ = ' '


		group by
			CB7.CB7_ORDSEP, CB7.CB7_OP,
			SC2.C2_NUM, SC2.C2_EMISSAO,
			ZD3_PROD, B1_DESC, B1_UM,
			ZD3_ORDEM, ZD3_LOCAL, ZD3_LOTECT, ZD3_NUMSER

			order by CB7.CB7_OP, ZD3_ORDEM

		EndSQL

	END REPORT QUERY oOrdem

	//Define a utilizacao da Query para a secao Filha
	oEmpenho:SetParentQuery()

	//regua
	oReport:SetMeter( SD4->(LastRec()) )

	oOrdem:Init()
	While !oReport:Cancel() .And. !(cQryRel)->(Eof())

		oReport:SkipLine()
		//Impressao da secao 1
		oOrdem:PrintLine()

		oEmpenho:Init()

		cOpAnt := (cQryRel)->(CB7_OP+ZD3_ORDEM)
		While !(cQryRel)->(Eof()) .And. (cQryRel)->(CB7_OP+ZD3_ORDEM) == cOpAnt

			oReport:IncMeter()
			//Impressao da secao 2
			oEmpenho:PrintLine()

			(cQryRel)->(dbSkip())
		EndDO

		oEmpenho:Finish()

		//Salta Pagina
		oReport:EndPage()
	EndDO
	oOrdem:Finish()
	(cQryRel)->(DbCloseArea())


Return



/*Static Function CriaSX1()

	//PutSx1(cPerg,'01','Ordem?'  ,'','','mv_ch1','C',13,0,0,'G','','SC2','','','mv_par01')
	//PutSx1(cPerg,'02','Entrega?','','','mv_ch2','C', 6,0,0,'G','','ZD3','','','mv_par02')

Return*/


Static Function ObsAndAss(oReport)

	oReport:ThinLine()
	oReport:PrintText(space(10) + "Observações")
	oReport:SkipLine(2)

	oReport:PrintText( space(10) + Replicate("_",40)       + space(10) + Replicate("_",40))
	oReport:PrintText( space(10) + PadC('Almoxarifado',40) + space(10) + PadC('Requisitante',40))

Return