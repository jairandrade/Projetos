#include 'protheus.ch'


/*/{Protheus.doc} COMR101
Relatório de tolerancias

@author Rafael Ricardo Vieceli
@since 03/07/2018
@version 1.0

@type function
/*/
user function COMR101()

	Local oReport

	//Interface de impressao
	oReport:= ReportDef()
	oReport:PrintDialog()

Return


/*/{Protheus.doc} ReportDef
Definição da estrutura do relatório

@author Rafael Ricardo Vieceli
@since 03/07/2018
@version 1.0
@return object, Objecto TReport

@type function
/*/
static function ReportDef()

	Local oReport
	Local oItens

	Local cPerg := "COMR101"
	Local cAlias := getNextAlias()

	CriaSX1(cPerg)
	Pergunte(cPerg,.F.)

	oReport:= TReport():New("COMR101","Este relatorio emite uma relacao de Pedidos de Compras vs Documentos de Entrada",cPerg, {|oReport| ReportPrint(oReport, cAlias)},"Este relatorio emite uma relacao de Pedidos de Compras vs Documentos de Entrada")
	oReport:SetLandscape()


	oItens := TRSection():New(oReport,"Pedido x Documentos")

	TRCell():New(oItens, 'F1_FILIAL','SF1')

	TRCell():New(oItens, 'C_FORNE' , '', "Cod./Loja","",11,/*lPixel*/,{|| (cAlias)->(A2_COD+"/"+A2_LOJA) })
	TRCell():New(oItens, 'A2_NOME' , 'SA2', "Fornecedor")
	TRCell():New(oItens, 'A2_CGC'  , 'SA2')

	TRCell():New(oItens, 'C7_NUM'    , 'SC7', "Pedido")
	TRCell():New(oItens, 'C7_EMISSAO', 'SC7', 'Data PV')

	TRCell():New(oItens, 'C_DOCSERIE', '', "NF/Serie","",12,/*lPixel*/,{|| (cAlias)->(alltrim(F1_DOC)+"/"+alltrim(F1_SERIE)) })
	TRCell():New(oItens, 'F1_EMISSAO', 'SF1', 'Emissão NF')
	TRCell():New(oItens, 'F1_DTDIGIT', 'SF1', 'D.Classif.')

	TRCell():New(oItens, 'B1_COD' , 'SB1')
	TRCell():New(oItens, 'B1_DESC', 'SB1')

	TRCell():New(oItens, 'D1_QUANT', 'SD1', 'Qtde NF')
	TRCell():New(oItens, 'C7_QUANT', 'SC7', 'Qtde PC')
	TRCell():New(oItens, 'P_QUANT' , '', "% Qtde","@E 9,999.99",9,/*lPixel*/,{|| (cAlias)->D1_QUANT / (cAlias)->C7_QUANT * 100 },,,"RIGHT")

	TRCell():New(oItens, 'D1_VUNIT', 'SD1', 'Unit NF')
	TRCell():New(oItens, 'C7_PRECO', 'SC7', 'Unit PC')
	TRCell():New(oItens, 'P_VALOR' , '', "% Valor","@E 9,999.99",9,/*lPixel*/,{|| (cAlias)->D1_VUNIT / (cAlias)->C7_PRECO * 100 },,,"RIGHT")

	TRCell():New(oItens, 'D1_TOTAL', 'SD1')


	oItens:Cell("A2_NOME"):lLineBreak := .T.
	oItens:Cell("B1_DESC"):lLineBreak := .T.

return oReport


/*/{Protheus.doc} ReportPrint
Impressão do relatório

@author Rafael Ricardo Vieceli
@since 03/07/2018
@version 1.0
@param oReport, object, Objeto TReport
@param cAlias, characters, Alias SQL
@type function
/*/
static function ReportPrint(oReport, cAlias)
Local oItens := oReport:Section(1)
Local cWhere := '%1=1%'
Local cFilSA2:= xFilial("SA2")

	IF mv_par13 == 1
		//quantidade do pedido menor que quantidade entrege (pode ter varias notas do mesmo pedido)
		//OU preço menor
		cWhere := "%( SC7.C7_QUANT < SC7.C7_QUJE OR SC7.C7_QUANT < SD1.D1_QUANT OR SC7.C7_PRECO < SD1.D1_VUNIT)%"
	EndIF

	oItens:BeginQuery()
	BeginSQL Alias cAlias

		select
			SF1.F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_EMISSAO, SF1.F1_DTDIGIT,
			SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_CGC,
			SD1.D1_PEDIDO, SD1.D1_ITEMPC, SD1.D1_QUANT, SD1.D1_VUNIT, SD1.D1_TOTAL,
			SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_QUANT, SC7.C7_QUJE,  SC7.C7_PRECO,
			SB1.B1_COD, SB1.B1_DESC

		from %table:SF1% SF1

			inner join %table:SD1% SD1
				on  SD1.D1_FILIAL  = SF1.F1_FILIAL
				and SD1.D1_DOC     = SF1.F1_DOC
				and SD1.D1_SERIE   = SF1.F1_SERIE
				and SD1.D1_FORNECE = SF1.F1_FORNECE
				and SD1.D1_LOJA    = SF1.F1_LOJA
				and SD1.D_E_L_E_T_ = ' '

			inner join %table:SC7% SC7
				on  SC7.C7_FILIAL  = SD1.D1_FILIAL
				and SC7.C7_NUM     = SD1.D1_PEDIDO
				and SC7.C7_ITEM    = D1_ITEMPC
				and SC7.D_E_L_E_T_ = ' '

			inner join %table:SA2% SA2
				on  SA2.A2_FILIAL  = %Exp:cFilSA2%
				and SA2.A2_COD     = SF1.F1_FORNECE
				and SA2.A2_LOJA    = SF1.F1_LOJA
				and SA2.D_E_L_E_T_ = ' '

			inner join %table:SB1% SB1
				on  SB1.B1_FILIAL  = SF1.F1_FILIAL
				and SB1.B1_COD     = SD1.D1_COD
				and SB1.B1_GRUPO  >= %Exp: mv_par11 %
				and SB1.B1_GRUPO  <= %Exp: mv_par12 %
				and SB1.D_E_L_E_T_ = ' '

		where
		    SF1.F1_FILIAL  >= %Exp: mv_par01 %
		and SF1.F1_FILIAL  <= %Exp: mv_par02 %
		and concat(SF1.F1_FORNECE,SF1.F1_LOJA) >= %Exp: mv_par03 + mv_par04 %
		and concat(SF1.F1_FORNECE,SF1.F1_LOJA) <= %Exp: mv_par05 + mv_par06 %
		and SF1.F1_EMISSAO >= %Exp: mv_par07 %
		and SF1.F1_EMISSAO <= %Exp: mv_par08 %
		and SF1.F1_DTDIGIT >= %Exp: mv_par09 %
		and SF1.F1_DTDIGIT <= %Exp: mv_par10 %
		and SF1.F1_STATUS  <> ' '
		and %Exp: cWhere %
		and SF1.D_E_L_E_T_  = ' '


	EndSQL
	oItens:EndQuery()

	//impressão do relatório
	oItens:Print()

return


/*/{Protheus.doc} CriaSX1
Cria as perguntas

@author Rafael Ricardo Vieceli
@since 03/07/2018
@version 1.0
@param cPerg, characters, Codigo da Pergunta
@type function
/*/
static function CriaSX1(cPerg)

	//MV_PAR01 Filial de Filial inicial
	//MV_PAR02 Filial até Filial final
	PutSx1(cPerg,'01','Filial de?'              ,'','','mv_ch1','C',FWSizeFilial(),0,0,'G','','SM0','','','mv_par01')
	PutSx1(cPerg,'02','Filial até?'             ,'','','mv_ch2','C',FWSizeFilial(),0,0,'G','','SM0','','','mv_par02')
	//MV_PAR03 Fornecedor de Fornecedor inicial
	//MV_PAR04 Loja de loja inicial do fornecedor
	PutSx1(cPerg, '03', 'Fornecedor de?' 		, '', '', 'mv_ch3', 'C', TamSX3('A2_COD')[1] , 0, 0, 'G', '', 'SA2', '', '', 'mv_par03')
	PutSx1(cPerg, '04', 'Loja de?' 		        , '', '', 'mv_ch4', 'C', TamSX3('A2_LOJA')[1], 0, 0, 'G', '', ''   , '', '', 'mv_par04')
	//MV_PAR05 Fornecedor até Fornecedor final
	//MV_PAR06 Loja até Loja final do fornecedor
	PutSx1(cPerg, '05', 'Fornecedor até?' 		, '', '', 'mv_ch5', 'C', TamSX3('A2_COD')[1] , 0, 0, 'G', '', 'SA2', '', '', 'mv_par05')
	PutSx1(cPerg, '06', 'Loja até?' 		    , '', '', 'mv_ch6', 'C', TamSX3('A2_LOJA')[1], 0, 0, 'G', '', ''   , '', '', 'mv_par06')
	//MV_PAR07 Emissão de Data de emissão inicial
	//MV_PAR08 Emissão até Data emissão final
	PutSx1(cPerg, '07', 'Dt. Emissão De?'   , '', '', 'mv_ch7', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par07')
	PutSx1(cPerg, '08', 'Dt. Emissão Ate?'  , '', '', 'mv_ch8', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par08')
	//MV_PAR09 Dt. Digitação de Data de digitação / classificação inicial
	//MV_PAR10 Dt. Digitação até Data de digitação / classificação final
	PutSx1(cPerg, '09', 'Dt. Digitacao De?'   , '', '', 'mv_ch9', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par09')
	PutSx1(cPerg, '10', 'Dt. Digitacao Ate?'  , '', '', 'mv_cha', 'D', 8, 0, 0, 'G', '', '', '', '', 'mv_par10')
	//MV_PAR11 Grupo de Grupo de produtos iniciais
	//MV_PAR12 Grupo até Grupo de produtos finais
	PutSx1(cPerg, '11', 'Grupo de?' 		, '', '', 'mv_chb', 'C', TamSX3('B1_GRUPO')[1], 0, 0, 'G', '', 'SBM', '', '', 'mv_par11')
	PutSx1(cPerg, '12', 'Grupo até?' 		, '', '', 'mv_chc', 'C', TamSX3('B1_GRUPO')[1], 0, 0, 'G', '', 'SBM', '', '', 'mv_par12')
	//MV_PAR13 Verifica tolerâncias S=Verifica; N=Não verifica
	PutSx1(cPerg, '13', 'Verifica tolerâncias?' ,'','','mv_chd','N',1,0,0,'C','','','','','mv_par13','Sim',,,,'Não')

return


Static Function PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar, cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid, cF3, cGrpSxg,cPyme, cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01, cDef02,cDefSpa2,cDefEng2, cDef03,cDefSpa3,cDefEng3, cDef04,cDefSpa4,cDefEng4, cDef05,cDefSpa5,cDefEng5, aHelpPor,aHelpEng,aHelpSpa,cHelp)

	Local lPort := .f., lSpa  := .f., lIngl := .f.
	Local cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	default cPyme := " "; default cF3 := " "; default cGrpSxg := " "; default cCnt01  := ""; default cHelp	:= ""

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	IF ! dbSeek( cGrupo + cOrdem )
	    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa	:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng	:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
		Reclock( "SX1" , .T. )
		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid
		Replace X1_VAR01   With cVar01
		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg
		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif
		Replace X1_CNT01   With cCnt01
		If cGSC == "C"			// Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1
			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2
			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3
			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4
			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif
		Replace X1_HELP  With cHelp
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
		MsUnlock()

	EndIF

Return
