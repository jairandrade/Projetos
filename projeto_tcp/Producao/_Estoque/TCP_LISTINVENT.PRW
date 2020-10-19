/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณISEST022  บ Autor ณ ALYSON AURIGLIETI    บ Data ณ   บฑฑ 
ฑฑบ           listagem para inventario por curva A B C บฑฑ 
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico para TCP                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

user function LISTINVENT

local oReport
//local cPerg  := 'ISEST022'
local cAlias := getNextAlias()

//criaSx1(cPerg)
//Pergunte(cPerg, .F.)

//oReport := reportDef(cAlias, cPerg)
oReport := reportDef(cAlias,)

oReport:printDialog()

return  

//+-----------------------------------------------------------------------------------------------+
//! Rotina para montagem dos dados do relat๓rio.                                  !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportPrint(oReport,cAlias)

//local cAlias2 := getNextAlias()
//local cAlias3 := getNextAlias()
local oSecao1 := oReport:Section(1)
local nTotCurv := 0 
local cCurvAbc := ""
oSecao1:BeginQuery()

BeginSQL Alias cAlias
	SELECT 
	BF_LOCAL AS ARMAZEM,BF_QUANT AS SALDO_DO_ENDERECO,BF_PRODUTO AS PRODUTO,
	B1_DESC AS DESCRICAO_PRODUTO,B1_UM AS UNIDADE_MEDIDA,B2_VATU1 AS SALDO_TOTAL, 
	(SELECT SUM(SB2.B2_VATU1) AS TOTAL FROM %Table:SBF% SBF , %Table:SB2% SB2 WHERE SBF.BF_LOCAL = '01' AND  SBF.D_E_L_E_T_ <> '*' AND  SBF.BF_PRODUTO = SB2.B2_COD AND SB2.D_E_L_E_T_ <> '*' ) AS TOTAL,
	((70 * (SELECT SUM(SB2.B2_VATU1) AS TOTAL FROM %Table:SBF% SBF ,%Table:SB2% SB2 WHERE SBF.BF_LOCAL = '01' AND  SBF.D_E_L_E_T_ <> '*' AND  SBF.BF_PRODUTO = SB2.B2_COD AND SB2.D_E_L_E_T_ <> '*' ))/100) as SETENTA,
	((90 * (SELECT SUM(SB2.B2_VATU1) AS TOTAL FROM %Table:SBF% SBF ,%Table:SB2% SB2 WHERE SBF.BF_LOCAL = '01' AND  SBF.D_E_L_E_T_ <> '*' AND  SBF.BF_PRODUTO = SB2.B2_COD AND SB2.D_E_L_E_T_ <> '*' ))/100) as NOVENTA,
  	B2_CM1 AS CUSTO_UNITARIO,
  	BF_LOCALIZ AS ENDERECO,
	'' AS QTD_PRIMEIRA_CONTAGEM,
	'' AS QTD_SEGUNDA_CONTAGEM,
	'' AS QTD_TERCEIRA_CONTAGEM,'' AS NOME_OPERADOR 
	FROM %Table:SBF% SBF
	INNER JOIN %Table:SB1% AS SB1 ON SBF.BF_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ <> '*'
	INNER JOIN %Table:SB2% AS SB2 ON SBF.BF_FILIAL = SB2.B2_FILIAL AND SBF.BF_PRODUTO = SB2.B2_COD 
	AND SB2.D_E_L_E_T_ <> '*' AND SB2.B2_LOCAL = '01' 
	AND SBF.D_E_L_E_T_ <> '*' AND SBF.BF_LOCAL = '01' 
	ORDER BY SB2.B2_VATU1 DESC
EndSQL 

oSecao1:EndQuery()

oReport:SetMeter((cAlias)->(RecCount()))

//oReport:Print()

nTotCurv:=0

(cAlias)->(DbGoTOp())
oSecao1:Init()
While !(cAlias)->(Eof())
	    If oReport:Cancel()
	        Exit
	    EndIf
		oReport:IncMeter()
	
		nTotCurv:=nTotCurv+(cAlias)->SALDO_TOTAL
		
		If nTotCurv <= (cAlias)->SETENTA
			cCurvAbc:="A"
		Elseif nTotCurv > (cAlias)->SETENTA .and. nTotCurv <= (cAlias)->NOVENTA	
			cCurvAbc:="B"
		Elseif nTotCurv > (cAlias)->NOVENTA	
			cCurvAbc:="C"
		Endif
								
		oSecao1:Cell("ARMAZEM"):SetValue((cAlias)->ARMAZEM)
		oSecao1:Cell("PRODUTO"):SetValue((cAlias)->PRODUTO)
		oSecao1:Cell("DESCRICAO_PRODUTO"):SetValue((cAlias)->DESCRICAO_PRODUTO)
		oSecao1:Cell("UNIDADE_MEDIDA"):SetValue((cAlias)->UNIDADE_MEDIDA)
		oSecao1:Cell("SALDO_DO_ENDERECO"):SetValue((cAlias)->SALDO_DO_ENDERECO)
		oSecao1:Cell("CUSTO_UNITARIO"):SetValue((cAlias)->CUSTO_UNITARIO)
		oSecao1:Cell("SALDO_TOTAL"):SetValue((cAlias)->SALDO_TOTAL)  
		oSecao1:Cell("CURVA_ABC"):SetValue(cCurvAbc)
		oSecao1:Cell("ENDERECO"):SetValue((cAlias)->ENDERECO)
		oSecao1:Cell("QTD_PRIMEIRA_CONTAGEM"):SetValue((cAlias)->QTD_PRIMEIRA_CONTAGEM)
		oSecao1:Cell("QTD_SEGUNDA_CONTAGEM"):SetValue((cAlias)->QTD_SEGUNDA_CONTAGEM)
		oSecao1:Cell("QTD_TERCEIRA_CONTAGEM"):SetValue((cAlias)->QTD_TERCEIRA_CONTAGEM)
		oSecao1:Cell("NOME_OPERADOR"):SetValue((cAlias)->NOME_OPERADOR)
												
	oSecao1:PrintLine() 

	(cAlias)->(DbSkip())
enddo
oSecao1:Finish()

return

//+-----------------------------------------------------------------------------------------------+
//! Fun็ใo para cria็ใo da estrutura do relat๓rio.                                                !
//+-----------------------------------------------------------------------------------------------+
Static Function ReportDef(cAlias,cPerg)

local cTitle  := "Lista Inventแrio por Curva ABC"
local cHelp   := "Permite gerar relat๓rio ."

local oReport
local oSection1

oReport	:= TReport():New('Lista Inventแrio',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)

//Primeira se็ใo
oSection1 := TRSection():New(oReport,"Endereco",{"SBF"})
									
TRCell():New(oSection1,"ARMAZEM", "SBF", "ARMAZEM")
TRCell():New(oSection1,"PRODUTO", "SB1", "PRODUTO")
TRCell():New(oSection1,"PRODUTO", "SB1", "DESCRICAO_PRODUTO")
TRCell():New(oSection1,"UNIDADE_MEDIDA", "SB1", "UNIDADE_MEDIDA")
TRCell():New(oSection1,"SALDO_DO_ENDERECO", "SBF", "SALDO_DO_ENDERECO")
TRCell():New(oSection1,"CUSTO_UNITARIO", "SBF", "CUSTO_UNITARIO","@E 999,999,999.99", 15,,,,,"RIGHT",,1)
TRCell():New(oSection1,"SALDO_TOTAL", "SBF", "SALDO_TOTAL","@E 999,999,999.99", 15,,,,,"RIGHT",,1)
TRCell():New(oSection1,"CURVA_ABC", "SBF", "CURVA_ABC","", 1,,,,,"CENTER",,1)
TRCell():New(oSection1,"ENDERECO", "SBF", "ENDERECO") 
TRCell():New(oSection1,"QTD_PRIMEIRA_CONTAGEM", "SBF", "QTD_PRIMEIRA_CONTAGEM")
TRCell():New(oSection1,"QTD_SEGUNDA_CONTAGEM", "SBF", "QTD_SEGUNDA_CONTAGEM")
TRCell():New(oSection1,"QTD_TERCEIRA_CONTAGEM", "SBF", "QTD_TERCEIRA_CONTAGEM")
TRCell():New(oSection1,"NOME_OPERADOR", "SBF", "NOME_OPERADOR")

//TRSection():Order( "ENDERECO" ) 
//oBreak1 := TRBreak():New(oSection1,oSection1:Cell("D3_LOCAL"),"Total",.F.)
//TRFunction():New(oSection1:Cell("D3_ENTRADA"),Nil,"SUM",oBreak1,,,,.F.,.T.)
//TRFunction():New(oSection1:Cell("D3_SAIDA"),Nil,"SUM",oBreak1,,,,.F.,.T.)
//TRFunction():New(oSection1:Cell("D3_SALDO"),Nil,"SUM",oBreak1,,,,.F.,.T.)

Return(oReport)

//+-----------------------------------------------------------------------------------------------+
//! Fun็ใo para cria็ใo das perguntas (se nใo existirem)                                          !
//+-----------------------------------------------------------------------------------------------+
/*Static function criaSX1(cPerg)

//putSx1(cPerg, '01', 'Armazem de ?', '', '', 'mv_ch1', 'C', 2, 0, 0, 'G', '', 'AL', '', '', 'mv_par01','','','','','','','','','','','','','','','','',{'Informe armazem de '})
//putSx1(cPerg, '02', 'Armazem ate ?', '', '', 'mv_ch2', 'C', 2, 0, 0, 'G', '', 'AL', '', '', 'mv_par02','','','','','','','','','','','','','','','','',{'Informe at้ armazem '})
//putSx1(cPerg, '03', 'Produto De?', '', '', 'mv_ch3', 'C', 9, 0, 0, 'G', '', 'SB1', '', '', 'mv_par03','','','','','','','','','','','','','','','','',{'Informe o Codigo do Produto'})
//putSx1(cPerg, '04', 'Produto ate?', '', '', 'mv_ch4', 'C', 9, 0, 0, 'G', '', 'SB1', '', '', 'mv_par04','','','','','','','','','','','','','','','','',{'Informe at้ qual Codigo de Produto'})

return*/
