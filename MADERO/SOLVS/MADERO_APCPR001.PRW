#INCLUDE "MATR820.CH"
//#INCLUDE "FIVEWIN.CH"

Static cAliasTop
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ APCPR001  ³ Autor ³ Thiago Berna          ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordens de Producao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Madero                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function APCPR001()
Local oReport


//-- Verifica se o SH8 esta locado para atualizacao por outro processo                
If !IsLockSH8()
	
	If TRepInUse()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Interface de impressao                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:= ReportDef()
		If !oReport:PrintDialog()
	   		dbSelectArea("SH8")
			dbClearFilter()
			dbCloseArea()
			Return Nil
		EndIf
	Else
		APCPR001R3()
	EndIf

EndIf
	
Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Thiago Berna           ³ Data ³09/09/19  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³APCPR001                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local oReport
Local oSection1, oSection2, Section3
Local aOrdem	:= {STR0002,STR0003,STR0004,STR0005}	//"Por Numero"###"Por Produto"###"Por Centro de Custo"###"Por Prazo de Entrega"
Local cTitle	:= STR0039 //"Ordens de Producao"
Local nlargDesc	:= 0 
cAliasTop := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= TReport():New("APCPR001",cTitle,"MTR820", {|oReport| ReportPrint(oReport, cAliasTop)},OemToAnsi(STR0001)) //"Este programa ira imprimir a Rela‡„o das Ordens de Produ‡„o"
oReport:SetPortrait()     // Define a orientacao de pagina do relatorio como retrato.
oReport:HideParamPage()   // Desabilita a impressao da pagina de parametros.
oReport:nFontBody	:= 9  // Define o tamanho da fonte.
oReport:nLineHeight	:= 50 // Define a altura da linha.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas - MTR820                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Da OP                                 ³
//³ mv_par02            // Ate a OP                              ³
//³ mv_par03            // Da data                               ³
//³ mv_par04            // Ate a data                            ³
//³ mv_par05            // Imprime roteiro de operacoes          ³
//³ mv_par06            // Imprime codigo de barras              ³
//³ mv_par07            // Imprime Nome Cientifico               ³
//³ mv_par08            // Imprime Op Encerrada                  ³
//³ mv_par09            // Impr. por Ordem de                    ³
//³ mv_par10            // Impr. OP's Firmes, Previstas ou Ambas ³
//³ mv_par11            // Impr. Item Negativo na Estrutura      ³
//³ mv_par12            // Imprime Lote/Sub-Lote                 ³
//³ mv_par13            // Imprime operações vencidas?           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(oReport:GetParam(),.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da secao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a secao.                   ³
//³ExpA4 : Array com as Ordens do relatorio                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF mv_par07 == 1 
   nlargDesc := 150
ELSE   	
	nlargDesc := 80
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 1 (oSection1)                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0050,{"SC2","SB1","SC5","SA1"},aOrdem) // "Ordens de Produção"
oSection1:SetLineStyle() //Define a impressao da secao em linha

TRCell():New(oSection1,'C2_NUM'		,'SC2',STR0073   ,PesqPict('SC2','C2_NUM')	 ,TamSX3('C2_NUM')[1]	  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'C2_PRODUTO'	,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/		   ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'B1_DESC' 	,'SB1',/*Titulo*/,/*Picture*/					,nlargDesc,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T. )
TRCell():New(oSection1,'C2_EMISSAO' ,'SC2',STR0040   ,PesqPict("SC2","C2_EMISSAO")	,10						,/*lPixel*/,/*{|| DTOC(dDataBase) }*/)
TRCell():New(oSection1,'C5_CLIENTE'	,'SC5',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'C5_LOJACLI'	,'SC5',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'A1_NOME'  	,'SA1',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'QtdeProd'	,'SC2',STR0041   ,PesqPict("SC2","C2_QUANT")	,TamSX3("C2_QUANT")[1]	,/*lPixel*/,{|| aSC2Sld(cAliasTop) }) //STR0041
TRCell():New(oSection1,'C2_QUANT'	,'SC2',STR0042   ,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'OpQuant'  	,'SC2',STR0043   ,PesqPict("SC2","C2_QUANT")	,TamSX3("C2_QUANT")[1]	,/*lPixel*/,{|| (cAliasTop)->C2_QUANT - (cAliasTop)->C2_QUJE })
TRCell():New(oSection1,'B1_UM'	 	,'SB1',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'C2_CC'		,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'C2_STATUS'	,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'C2_DATPRI'	,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,{|| DTOC((cAliasTop)->C2_DATPRI) })
TRCell():New(oSection1,'C2_DATPRF'	,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,{|| DTOC((cAliasTop)->C2_DATPRF) })
TRCell():New(oSection1,'C2_DATAJI'	,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,{|| DTOC((cAliasTop)->C2_DATAJI) })
TRCell():New(oSection1,'C2_DATAJF'	,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,{|| DTOC((cAliasTop)->C2_DATAJF) })
TRCell():New(oSection1,'RealIni'	,'SC2',STR0044   ,/*Picture*/                 ,8						,/*lPixel*/,{|| "__/__/__" })
TRCell():New(oSection1,'RealFim'	,'SC2',STR0045   ,/*Picture*/                 ,8						,/*lPixel*/,{|| "__/__/__" })
TRCell():New(oSection1,'C2_OBS'		,'SC2',/*Titulo*/,/*Picture*/					,/*Tamanho*/			,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection1:Cell('B1_DESC'  ):SetCellBreak()
oSection1:Cell('C2_EMISSAO'):SetCellBreak()
oSection1:Cell('A1_NOME'  ):SetCellBreak()
oSection1:Cell('C2_QUANT' ):SetCellBreak()
oSection1:Cell('OpQuant'  ):SetCellBreak()
oSection1:Cell('B1_UM'    ):SetCellBreak()
oSection1:Cell('C2_CC'    ):SetCellBreak()
oSection1:Cell('C2_STATUS'):SetCellBreak()
oSection1:Cell('C2_DATPRF'):SetCellBreak()
oSection1:Cell('C2_DATAJF'):SetCellBreak()
oSection1:Cell('RealFim'  ):SetCellBreak()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 2 (oSection2)                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection2 := TRSection():New(oSection1,STR0051,{"SD4","SB1","NNR"},/*Ordem*/) //"Empenhos"      
oSection2:SetHeaderBreak()   

TRCell():New(oSection2,'D4_COD'	 	,'SD4',STR0058   ,PesqPict('SD4','D4_COD')    ,TamSX3('D4_COD')[1]+3    ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,.F./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,'B1_DESC' 	,'SB1',STR0059   ,PesqPict('SB1','B1_DESC')   ,/*30*/ ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T./*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
oSection2:Cell("B1_DESC"):SetLineBreak() 
TRCell():New(oSection2,'D4_QUANT' 	,'SD4',STR0043   ,PesqPict('SD4','D4_QUANT')  ,TamSX3('D4_QUANT')[1]  ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,'B1_UM'   	,'SB1',STR0061   ,PesqPict('SB1','B1_UM')     ,TamSX3('B1_UM')[1]     ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,'D4_LOCAL'	,'SD4',STR0072   ,PesqPict('SD4','D4_LOCAL')  ,TamSX3('D4_LOCAL')[1]  ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,'NNR_DESCRI','NNR',/*Titulo*/,PesqPict('NNR','NNR_DESCRI'),TamSX3('NNR_DESCRI')[1],/*lPixel*/,{||Posicione("NNR",1,xFilial("NNR")+SD4->D4_LOCAL,"NNR_DESCRI")},/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,'D4_TRT'  	,'SD4',STR0064   ,PesqPict('SD4','D4_TRT')    ,TamSX3('D4_TRT')[1]    ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,'D4_LOTECTL','SD4',/*Titulo*/,PesqPict('SD4','D4_LOTECTL'),TamSX3('D4_LOTECTL')[1],/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

//TRCell():New(oSection2,'D4_NUMLOTE','SD4',/*Titulo*/,PesqPict('SD4','D4_NUMLOTE'),TamSX3('D4_NUMLOTE')[1],/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
TRCell():New(oSection2,'D4_DTVALID','SD4','Validade',PesqPict('SD4','D4_DTVALID'),TamSX3('D4_DTVALID')[1],/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

TRCell():New(oSection2,'D4_OP'  	,'SD4',/*Titulo*/,PesqPict('SD4','D4_OP')     ,TamSX3('D4_OP')[1]     ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 3 (oSection3)                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection3 := TRSection():New(oSection1,STR0052,{"SG2","SH8","SH1","SH4"},/*Ordem*/) //"Operações"
oSection3:SetHeaderBreak()
oSection3:SetReadOnly()

TRCell():New(oSection3,'G2_RECURSO' ,'SG2',/*Titulo*/,/*Picture*/,12 	     ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'H1_DESCRI'	,'SH1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'G2_FERRAM'	,'SG2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,'H4_DESCRI'	,'SH4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/)
TRCell():New(oSection3,'G2_OPERAC'	,'SG2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/)
TRCell():New(oSection3,'G2_DESCRI'	,'SG2',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.T.)

oSection3:Cell('H1_DESCRI'):HideHeader()
oSection3:Cell('H4_DESCRI'):HideHeader()
oSection3:Cell('G2_DESCRI'):HideHeader()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 4 (oSection4)                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection4 := TRSection():New(oSection3,STR0053,{"SG2","SH8","SH1","SH4"},/*Ordem*/) //"Tempo Rot. Oper."
oSection4:SetLineStyle() //Define a impressao da secao em linha
oSection4:SetReadOnly()

TRCell():New(oSection4,'H8_DTINI'	,'SH8',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection4,'H8_HRINI'	,'SH8',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection4,'H8_DTFIM'	,'SH8',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection4,'H8_HRFIM'	,'SH8',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection4,'IniAloc'	,'SH8',STR0046   ,'@!'  , 24        ,/*lPixel*/,{|| " ____/ ____/____ ___:___" })
TRCell():New(oSection4,'FimAloc'	,'SH8',STR0047   ,'@!'  , 24        ,/*lPixel*/,{|| " ____/ ____/____ ___:___" })
TRCell():New(oSection4,'H8_QUANT'	,'SH8',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection4,'QtdeProd'	,'SH8',STR0048   ,/*Picture*/, 12       ,/*lPixel*/,{|| Space(12) })
TRCell():New(oSection4,'QtdPerda'	,'SH8',STR0049   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Space(12) })
TRCell():New(oSection4,'VldInici'  ,'SH8',STR0074,'@!', 10,/*lPixel*/,/*{|| code-block de impressao }*/) //"Validade inicial"
TRCell():New(oSection4,'VldFinal'  ,'SH8',STR0075,'@!', 10,/*lPixel*/,/*{|| code-block de impressao }*/) //"Validade Final"

oSection4:Cell('H8_HRFIM'):SetCellBreak()
oSection4:Cell('FimAloc' ):SetCellBreak()
oSection4:Cell('QtdPerda' ):SetCellBreak()

oSection1:SetNoFilter({"SA1","SC5"})
oSection2:SetNoFilter({"SD4","SB1","SB2","SC2"})
oSection3:SetNoFilter({"SG2","SH8","SH1","SH4"})
oSection4:SetNoFilter({"SG2","SH8","SH1","SH4"})

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint ³ Autor ³Thiago Berna         ³ Data ³09/09/19  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos  ³±±
±±³          ³os relatorios que poderao ser agendados pelo usuario.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³APCPR001                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport, cAliasTop)
Local oSection1	:= oReport:Section(1)
Local oSection2	:= oReport:Section(1):Section(1)
Local oSection3	:= oReport:Section(1):Section(2)
Local oSection4	:= oReport:Section(1):Section(2):Section(1)
Local oSection5
Local nOrdem    := oSection1:GetOrder()
Local oBreak
Local cIndex	:= ""
Local cCondicao	:= ""
Local cCode    	:= ""
Local cCodeEnd  := ""
Local cCodeLot  := ""
Local nLargura  := 0
Local nCntFor   := 0
Local nLinBar	:= 0
Local cWhere01, cWhere02, cWhere03
Local cOrderBy
Local nLoops := 0
Local lPlanilha := oReport:nDevice == 4
Private aArray	 := {}
Private lItemNeg := GetMv("MV_NEGESTR") .And. mv_par11 == 1
Private lPcpator := GetMv("MV_PCPATOR")



If !lPlanilha .Or. len(oReport:aXlsTable) == 0
	oSection1:Cell("C2_NUM"):Disable()
Endif	

// Definindo quebra para secao 2 e ocultando celula utilizada somente para quebra
oBreak := TRBreak():New(oSection2,oSection2:Cell("D4_OP"),Nil,.F.)
oSection2:Cell("D4_OP"):Disable()

If lPlanilha
	oSection5 := TRSection():New(oReport,'',{"SC2"},/*Ordem*/)
	TRCell():New(oSection5,'C2_NUM'  	,'SC2',/*Titulo*/,PesqPict('SC2','C2_NUM')     ,TamSX3('C2_NUM')[1]     ,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/)
Endif


If mv_par12 == 2
	oSection2:Cell("D4_LOTECTL"):Disable()
	//oSection2:Cell("D4_NUMLOTE"):Disable()
    oSection2:Cell("D4_DTVALID"):Disable()
ElseIf !oReport:oPage:IsLandScape()
	//oSection2:Cell("B1_DESC"):SetSize(19)
	oSection2:Cell("NNR_DESCRI"):SetSize(10)
	//oSection2:Cell("D4_NUMLOTE"):SetTitle(STR0057)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:GetParam())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Condicao Where para filtrar OP's                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cWhere01 := "%'"+AllTrim(mv_par01)+"'%"
cWhere02 := "%'"+AllTrim(mv_par02)+"'%"

cWhere03 := "%"
If mv_par08 == 2
	cWhere03 += "AND SC2.C2_DATRF = ' '"
Endif
cWhere03 += "%"

cOrderBy := "%"
If nOrdem == 4
	cOrderBy += "SC2.C2_FILIAL, SC2.C2_DATPRF"
Else                                  
	cOrderBy += SqlOrder(SC2->(IndexKey(nOrdem)))
EndIf
cOrderBy += "%"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatorio da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:BeginQuery()	
BeginSql Alias cAliasTop

SELECT SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD, SC2.C2_DATPRF,
       SC2.C2_DATRF, SC2.C2_PRODUTO, SC2.C2_DESTINA, SC2.C2_PEDIDO, SC2.C2_ROTEIRO, SC2.C2_QUJE,
       SC2.C2_PERDA, SC2.C2_QUANT, SC2.C2_DATPRI, SC2.C2_CC, SC2.C2_DATAJI, SC2.C2_DATAJF,
       SC2.C2_STATUS, SC2.C2_OBS, SC2.C2_TPOP, 
       SC2.C2_XLOCALI, SC2.C2_XLOTE, SC2.C2_XDTVAL,
       SC2.R_E_C_N_O_  SC2RECNO, SC2.C2_EMISSAO

FROM %table:SC2% SC2

WHERE SC2.C2_FILIAL = %xFilial:SC2% AND
	  SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD >= %Exp:cWhere01% AND
	  SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD <= %Exp:cWhere02% AND
      SC2.C2_DATPRF BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND
	  SC2.%NotDel%
	  %Exp:cWhere03%

ORDER BY %Exp:cOrderby%

EndSql
oSection1:EndQuery()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicionamento das tabelas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRPosition():New(oSection1,"SB1",1,{|| xFilial("SB1")+(cAliasTop)->C2_PRODUTO })
TRPosition():New(oSection1,"SC5",1,{|| xFilial("SC5")+(cAliasTop)->C2_PEDIDO })
TRPosition():New(oSection1,"SA1",1,{|| xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetMeter(SC2->(LastRec()))
oSection1:Init()
oSection2:Init()
//oSection3:Init()
//oSection4:Init()
If lPlanilha
	oSection5:Init()
Endif

dbSelectArea(cAliasTop)
While !oReport:Cancel() .And. !(cAliasTop)->(Eof())
	//-- Valida se a OP deve ser Impressa ou nao
	If !MtrAValOP(mv_par10,"SC2",cAliasTop)
		dbSkip()
		Loop
	EndIf    

	//Definindo a descricao do produto
	MR820Desc(oReport, cAliasTop)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desabilitando celulas que nao deverao serem impressas   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasTop)->C2_DESTINA <> "P"
    	oSection1:Cell('C5_CLIENTE'):Disable()
    	oSection1:Cell('C5_LOJACLI'):Disable()
    	oSection1:Cell('A1_NOME'   ):Disable()
 	EndIf
	If Empty((cAliasTop)->C2_STATUS)
		oSection1:Cell("C2_STATUS"):SetValue("Normal")
	EndIf
	If (cAliasTop)->C2_QUJE + (cAliasTop)->C2_PERDA > 0
		oSection1:Cell('OpQuant'):Disable()
	Else
		oSection1:Cell('QtdeProd'):Disable()
		oSection1:Cell('C2_QUANT'):Disable()
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definindo o titulo do Relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:SetTitle(STR0010+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)) //"        O R D E M   D E   P R O D U C A O       NRO :"

	If mv_par06 == 1 
		nLinBar := 2.5

		If !oReport:lHeaderVisible
			nLinBar -= 2
		EndIf

        //Calcula a largura da pagina em centimetros
        nLargura:= oReport:getwidth() * 21 / 2480
		
		//oReport:PrintText("")
        oReport:PrintText(Space(nLargura * 0.33) + "OP: " +(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + IIF(oReport:GetOrientation() == 2,Space(nLargura*1.3 + 3),Space(nLargura + 3)) + 'Local - Endereco: ' + GetMV('MV_XARMPRD',,'50') + (cAliasTop)->(C2_XLOCALI)  + IIF(oReport:GetOrientation() == 2,Space(nLargura*1.5),Space(nLargura*0.40)) + 'Lote: ' + AllTrim((cAliasTop)->(C2_XLOTE)) + ' - ' +  DTOC((cAliasTop)->(C2_XDTVAL)) )
		nLoops := 250/oReport:nLineHeight
		If nLoops - Int(nLoops) > 0
			nLoops := Int(nLoops+1)
		EndIf
		For nCntFor := 1 to nLoops
			oReport:SkipLine()
		Next nCntFor

		cCode   := (cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
        cCodeEnd:= GetMV('MV_XARMPRD',,'50') + (cAliasTop)->(C2_XLOCALI)
        cCodeLot:= (cAliasTop)->(C2_XLOTE) 

		MSBAR3("EAN128",nLinBar,((nLargura / 7) * 1) - (nLargura / 7) + nLargura * 0.05,Trim(cCode),@oReport:oPrint,Nil,Nil,Nil,Nil ,1.5 ,Nil,Nil,Nil,.F.)
        MSBAR3("EAN128",nLinBar,((nLargura / 7) * 4) - (nLargura / 7),Trim(cCodeEnd),@oReport:oPrint,Nil,Nil,Nil,Nil ,1.5 ,Nil,Nil,Nil,.F.)
        MSBAR3("EAN128",nLinBar,((nLargura / 7) * 7) - (nLargura / 7),Trim(cCodeLot),@oReport:oPrint,Nil,Nil,Nil,Nil ,1.5 ,Nil,Nil,Nil,.F.)
	
	EndIf
	
	If lPlanilha
		oReport:SkipLine()
		oSection5:Cell("C2_NUM"):SetValue((cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
		oSection5:Cell('C2_NUM'):Enable()	
		If len(oReport:aXlsTable) > 0
			oSection1:Cell("C2_NUM"):SetValue((cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
			oSection1:Cell('C2_NUM'):Enable()
		Endif
		//Impressao da Section 5
		oSection5:PrintLine()
		oReport:IncMeter()
	Endif
	
	//Impressao da Section 1
	oSection1:PrintLine()
	oReport:IncMeter()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Habilitando celulas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasTop)->C2_DESTINA <> "P"
    	oSection1:Cell('C5_CLIENTE'):Enable()
    	oSection1:Cell('C5_LOJACLI'):Enable()
    	oSection1:Cell('A1_NOME'   ):Enable()
 	EndIf
	If (cAliasTop)->C2_QUJE + (cAliasTop)->C2_PERDA > 0
		oSection1:Cell('OpQuant'):Enable()
	Else
		oSection1:Cell('QtdeProd'):Enable()
		oSection1:Cell('C2_QUANT'):Enable()
	Endif
	
	If mv_par05 == 1
		Mr820Ope(oReport, cAliasTop, nLinBar, nLargura) //Impressao da Section 3 e Section 4
	EndIf
	
	//--- Inicio fluxo impressao secao 2
	SB1->(dbSeek(xFilial("SB1")+(cAliasTop)->C2_PRODUTO))
	
	aArray := {}
	MontStruc((cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
	
	If mv_par09 == 1
		aSort( aArray,1,, { |x, y| (x[1]+x[9]) < (y[1]+y[9]) } )
	Else
		aSort( aArray,1,, { |x, y| (x[9]+x[1]) < (y[9]+y[1]) } )
	ENDIF
	                         
	For nCntFor := 1 TO Len(aArray)

	    SB1->(dbSetOrder(1))
	    SB1->(MsSeek(xFilial("SB1")+aArray[nCntFor][1]))

	    SD4->(dbSetOrder(2))
	    SD4->(MsSeek(xFilial("SD4")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+aArray[nCntFor][1]+aArray[nCntFor][6]))

		oSection2:Cell("D4_COD"    ):SetValue(aArray[nCntFor][1])
		oSection2:Cell("B1_DESC"   ):SetValue(aArray[nCntFor][2])
		oSection2:Cell("D4_QUANT"  ):SetValue(aArray[nCntFor][5])
		oSection2:Cell("B1_UM"     ):SetValue(aArray[nCntFor][4])
		oSection2:Cell("D4_LOCAL"  ):SetValue(aArray[nCntFor][6])
		oSection2:Cell("NNR_DESCRI"):SetValue(aArray[nCntFor][7])
		oSection2:Cell("D4_TRT"    ):SetValue(aArray[nCntFor][9])
		oSection2:Cell("D4_OP"     ):SetValue((cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
		If mv_par12 == 1
			oSection2:Cell("D4_LOTECTL"):SetValue(aArray[nCntFor][11])
			//oSection2:Cell("D4_NUMLOTE"):SetValue(aArray[nCntFor][12])
            oSection2:Cell("D4_DTVALID"):SetValue(aArray[nCntFor][12])
		EndIf
	    
	    //Impressao da Section 2
		oSection2:PrintLine()
	Next nCntFor
	
	oReport:EndPage() //-- Salta Pagina
	dbSelectArea(cAliasTop)
	dbSkip()

EndDo

If lPlanilha
	oSection5:Finish()
Endif
//oSection4:Finish()
//oSection3:Finish()
oSection2:Finish()
oSection1:Finish()
(cAliasTop)->(DbCloseArea())
dbSelectArea("SH8")
dbClearFilter()
dbCloseArea()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MR820Desc   ³ Autor ³Thiago Berna         ³ Data ³09/09/19  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atribui a descricao do produto conforme opcao selecionada   ³±±
±±³          ³no parametro mv_par07 (Descricao do Produto ?).             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±³          ³ExpC1: Alias do arquivo Ordem de Producao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³APCPR001                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MR820Desc(oReport, cAliasTop)
Local oSection1 := oReport:Section(1)
Local lSB1Desc 	:= .T.
local cDescCampo	:= ''

If mv_par07 == 1
	SB5->(dbSetOrder(1))
	If SB5->(dbSeek(xFilial("SB5")+(cAliasTop)->C2_PRODUTO) .And. !Empty(B5_CEME))
		
		dbSelectArea("SX3")
		SX3->(dbSetOrder(2))
		SX3->(DbSeek("B5_CEME") )
		cDescCampo := Alltrim(X3Titulo()) 
		oSection1:Cell("B1_DESC"):SetTitle(cDescCampo)
		oSection1:Cell("B1_DESC"):SetLineBreak(.T.)
		oSection1:Cell("B1_DESC"):SetSize(150)
		oSection1:Cell("B1_DESC"):SetValue(SB5->B5_CEME)
		lSB1Desc := .F.		
	EndIf
ElseIf mv_par07 == 3
	If (cAliasTop)->C2_DESTINA == "P"
		SC6->(dbSetOrder(1))
		If SC6->(dbSeek(xFilial("SC6")+(cAliasTop)->C2_PEDIDO+(cAliasTop)->C2_ITEM))
			If !Empty(SC6->C6_DESCRI) .and. SC6->C6_PRODUTO == (cAliasTop)->C2_PRODUTO
				//oSection1:Cell("B1_DESC"):GetFieldInfo("C6_DESCRI")
				dbSelectArea("SX3")
				SX3->(dbSetOrder(2))
				SX3->(DbSeek("B1_DESC") )
				cDescCampo := Alltrim(X3Titulo()) 
				oSection1:Cell("B1_DESC"):SetTitle(cDescCampo)
				oSection1:Cell("B1_DESC"):SetLineBreak(.T.)
				oSection1:Cell("B1_DESC"):SetSize(80)
				oSection1:Cell("B1_DESC"):SetValue(SC6->C6_DESCRI)
				lSB1Desc := .F.
			EndIf
		EndIf
	EndIf
EndIf

If (mv_par07 <> 2) .And. lSB1Desc
	SB1->(dbSetOrder(1))
	If SB1->( dbSeek(xFilial("SB1")+(cAliasTop)->C2_PRODUTO) )
		//oSection1:Cell("B1_DESC"):GetFieldInfo("B1_DESC")
		dbSelectArea("SX3")
		SX3->(dbSetOrder(2))
		SX3->(DbSeek("B1_DESC") )
		cDescCampo := Alltrim(X3Titulo()) 
		oSection1:Cell("B1_DESC"):SetTitle(cDescCampo)
		oSection1:Cell("B1_DESC"):SetLineBreak(.T.)
		oSection1:Cell("B1_DESC"):SetSize(80)
		oSection1:Cell("B1_DESC"):SetValue(SB1->B1_DESC)
	EndIf
EndIf

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ Mr820Ope ³ Autor ³ Thiago Berna          ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Imprime Roteiro de Operacoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Mr820Ope()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APCPR001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function Mr820Ope(oReport, cAliasTop, nLinBar, nLargura)
Local oSection3 := oReport:Section(1):Section(2)
Local oSection4	:= oReport:Section(1):Section(2):Section(1)
Local oBreak
Local cRoteiro	:= ""                 
Local cSeekWhile:= ""
Local lSH8 		:= .F.
local lSG2		:= .T. 
Local aArea   	:= GetArea()
Local nLinImp	:= 1

oBreak:= TRBreak():New(oSection3,oSection3:Cell("G2_RECURSO"),Nil,.F.)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se imprime ROTEIRO da OP ou PADRAO do produto    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty((cAliasTop)->C2_ROTEIRO)
	cRoteiro:=(cAliasTop)->C2_ROTEIRO
Else
	If !Empty(SB1->B1_OPERPAD)
		cRoteiro:=SB1->B1_OPERPAD
	Else
		If a630SeekSG2(1,(cAliasTop)->C2_PRODUTO,xFilial("SG2")+(cAliasTop)->C2_PRODUTO+"01")
			cRoteiro:="01"
		EndIf
	EndIf
EndIf
	
//Valida se as operações serão geradas individualmente na Ordem Produção.(.T. Sim(SHY), .F. Considera SG2.)
If lPcpator
	dbselectarea("SHY")
	dbSetOrder(1)
	IF dbSeek(xFilial("SHY")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD+C2_ROTEIRO))
		lSG2 := .F.
	EndIF
EndIF

If (cAliasTop)->C2_QUJE + (cAliasTop)->C2_PERDA > 0
	//#TB20200615 Thiago Berna - Ajustado para posicionar corretamente o codigo de barras
	//Alguem havia alterado de 8.5 para 9 e sem um comentario nao da para saber o motivo
	//nLinBar += 9 //8.5
	nLinBar += 8.5
Else
	//#TB20200615 Thiago Berna - Ajustado para posicionar corretamente o codigo de barras
	//Alguem havia alterado de 8 para 8.5 e sem um comentario nao da para saber o motivo
	//nLinBar += 8.5 //8
	nLinBar += 8
EndIf

IF lSG2

	cSeekWhile := "SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO)"
	If a630SeekSG2(1,(cAliasTop)->C2_PRODUTO,xFilial("SG2")+(cAliasTop)->C2_PRODUTO+cRoteiro,@cSeekWhile) 

		oSection3:Init()
		oSection4:Init()

		While SG2->(!Eof()) .And. Eval(&cSeekWhile)
			SH8->(dbSetOrder(1))
			If SH8->(dbSeek(xFilial("SH8")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SG2->G2_OPERAC))
				lSH8 := .T.
			EndIf
			
			If lSH8
				While SH8->(!Eof()) .And. SH8->(H8_FILIAL+H8_OP+H8_OPER) == xFilial("SH8")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SG2->G2_OPERAC
					SH1->(dbSeek(xFilial("SH1")+SH8->H8_RECURSO))
					SH4->(dbSeek(xFilial("SH4")+SG2->G2_FERRAM))
					
					If mv_par13 == 2
						If !Empty(SG2->G2_DTINI)
							If SG2->G2_DTINI > (cAliasTop)->C2_DATPRI
								SH8->(dbSkip())
								Loop
							EndIf
						EndIf
						If !Empty(SG2->G2_DTFIM)
							If SG2->G2_DTFIM < (cAliasTop)->C2_DATPRI
								SH8->(dbSkip())
								Loop
							EndIf
						EndIf
					EndIf
					
					If mv_par06 == 1 
						oSection3:Cell('G2_RECURSO'):SetValue("")
						MSBAR3("EAN128",nLinBar,0.1,Trim(SH8->H8_RECURSO),@oReport:oPrint,Nil,Nil,Nil,Nil ,0.7 ,Nil,Nil,Nil,.F.)
					else
						oSection3:Cell('G2_RECURSO'):SetValue(SH8->H8_RECURSO)
					EndIf
					oSection3:Cell('H1_DESCRI' ):SetValue(SH1->H1_DESCRI)
					oSection3:Cell('G2_FERRAM' ):SetValue(SG2->G2_FERRAM)
					oSection3:Cell('H4_DESCRI' ):SetValue(SH4->H4_DESCRI)
					If mv_par06 == 1 
						oSection3:Cell('G2_OPERAC' ):SetValue("")
						MSBAR3("EAN128",nLinBar,((nLargura / 2.9) * 2.9) - (nLargura / 2.9),Trim(SG2->G2_OPERAC),@oReport:oPrint,Nil,Nil,Nil,Nil ,0.7 ,Nil,Nil,Nil,.F.)
					Else
						oSection3:Cell('G2_OPERAC' ):SetValue(SG2->G2_OPERAC)
					EndIf
					oSection3:Cell('G2_DESCRI' ):SetValue(SG2->G2_DESCRI)
					oSection4:Cell('VldInici'):SetValue(DTOC(SG2->G2_DTINI))
					oSection4:Cell('VldFinal'):SetValue(DTOC(SG2->G2_DTFIM))
					If nLinImp > 1
						oReport:PrintText("")
					EndIf
					oSection3:PrintLine()
					If nLinImp > 1
						oReport:PrintText("")
					EndIf
					oSection4:PrintLine()
					oReport:ThinLine()
					SH8->(dbSkip())
					If nLinImp == 1
						nLinBar += 2.85
					Else
						nLinBar += 3.1
					EndIf
					nLinImp++
				EndDo
			Else
				If mv_par13 == 2
					If !Empty(SG2->G2_DTINI)
						If SG2->G2_DTINI > (cAliasTop)->C2_DATPRI
							SG2->(dbSkip())
							Loop
						EndIf
					EndIf
					If !Empty(SG2->G2_DTFIM)
						If SG2->G2_DTFIM < (cAliasTop)->C2_DATPRI
							SG2->(dbSkip())
							Loop
						EndIf
					EndIf
				EndIf
				
				SH1->(dbSeek(xFilial("SH1")+SG2->G2_RECURSO))
				SH4->(dbSeek(xFilial("SH4")+SG2->G2_FERRAM))

				If mv_par06 == 1 
					oSection3:Cell('G2_RECURSO'):SetValue("")
					MSBAR3("EAN128",nLinBar,0.1,Trim(SG2->G2_RECURSO),@oReport:oPrint,Nil,Nil,Nil,Nil ,0.7 ,Nil,Nil,Nil,.F.)
				else
					oSection3:Cell('G2_RECURSO'):SetValue(SG2->G2_RECURSO)
				EndIf
				oSection3:Cell('H1_DESCRI' ):SetValue(Space(5) + SH1->H1_DESCRI)
				oSection3:Cell('G2_FERRAM' ):SetValue(SG2->G2_FERRAM)
				oSection3:Cell('H4_DESCRI' ):SetValue(SH4->H4_DESCRI)
				If mv_par06 == 1 
					oSection3:Cell('G2_OPERAC' ):SetValue("")
					MSBAR3("EAN128",nLinBar,((nLargura / 2.9) * 2.9) - (nLargura / 2.9),Trim(SG2->G2_OPERAC),@oReport:oPrint,Nil,Nil,Nil,Nil ,0.7 ,Nil,Nil,Nil,.F.)
				else
					oSection3:Cell('G2_OPERAC' ):SetValue(SG2->G2_OPERAC)
				EndIf
				oSection3:Cell('G2_DESCRI' ):SetValue(SG2->G2_DESCRI)

				If nLinImp > 1
					oReport:PrintText("")
				EndIf
				oSection3:PrintLine()
				
				oSection4:Cell('H8_DTINI'):Disable()
				oSection4:Cell('H8_HRINI'):Disable()
				oSection4:Cell('H8_DTFIM'):Disable()
				oSection4:Cell('H8_HRFIM'):Disable()
				oSection4:Cell('H8_QUANT'):SetValue(aSC2Sld(cAliasTop))
				oSection4:Cell('VldInici'):SetValue(DTOC(SG2->G2_DTINI))
				oSection4:Cell('VldFinal'):SetValue(DTOC(SG2->G2_DTFIM))
				
				If nLinImp > 1
					oReport:PrintText("")
				ENDIF
				
				oSection4:PrintLine()
				oReport:ThinLine()

				oSection4:Cell('H8_DTINI'):Enable()
				oSection4:Cell('H8_HRINI'):Enable()
				oSection4:Cell('H8_DTFIM'):Enable()
				oSection4:Cell('H8_HRFIM'):Enable()
			Endif

			SG2->(dbSkip())
			If nLinImp == 1
				nLinBar += 2.85
			Else
				nLinBar += 3.1
			EndIf
			nLinImp++
		EndDo

		oSection3:Finish()
		oSection4:Finish()

	Endif

Else // Considera tabela SHY 
	dbselectarea("SHY")
	dbSetOrder(1)
	IF dbSeek(xFilial("SHY")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD+C2_ROTEIRO))

		oSection3:Init()
		oSection4:Init()

		While SHY->(!Eof()) .And. SHY->(HY_FILIAL+HY_OP+HY_ROTEIRO) = xFilial("SHY")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD+C2_ROTEIRO)
			SH8->(dbSetOrder(1))
			If SH8->(dbSeek(xFilial("SH8")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SHY->HY_OPERAC))
				lSH8 := .T.
			EndIf
			
			If lSH8
				While SH8->(!Eof()) .And. SH8->(H8_FILIAL+H8_OP+H8_OPER) == xFilial("SH8")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SHY->HY_OPERAC
					SH1->(dbSeek(xFilial("SH1")+SH8->H8_RECURSO))
					SH4->(dbSeek(xFilial("SH4")+SHY->HY_FERRAM))
					
					If mv_par13 == 2
						If !Empty(SHY->HY_DATAINI)
							If SHY->HY_DATAINI > (cAliasTop)->C2_DATPRI
								SH8->(dbSkip())
								Loop
							EndIf
						EndIf
						If !Empty(SHY->HY_DATAFIM)
							If SHY->HY_DATAFIM < (cAliasTop)->C2_DATPRI
								SH8->(dbSkip())
								Loop
							EndIf
						EndIf
					EndIf
					
					If mv_par06 == 1
						oSection3:Cell('G2_RECURSO'):SetValue("")
						MSBAR3("EAN128",nLinBar,0.1,Trim(SH8->H8_RECURSO),@oReport:oPrint,Nil,Nil,Nil,Nil ,0.7 ,Nil,Nil,Nil,.F.)
					else
						oSection3:Cell('G2_RECURSO'):SetValue(SH8->H8_RECURSO)
					EndIf
					oSection3:Cell('H1_DESCRI' ):SetValue(SH1->H1_DESCRI)
					oSection3:Cell('G2_FERRAM' ):SetValue(SHY->HY_FERRAM)
					oSection3:Cell('H4_DESCRI' ):SetValue(SH4->H4_DESCRI)
					If mv_par06 == 1
						oSection3:Cell('G2_OPERAC' ):SetValue("")
						MSBAR3("EAN128",nLinBar,((nLargura / 2.9) * 2.9) - (nLargura / 2.9),Trim(SHY->HY_OPERAC),@oReport:oPrint,Nil,Nil,Nil,Nil ,0.7 ,Nil,Nil,Nil,.F.)
					else
						oSection3:Cell('G2_OPERAC' ):SetValue(SHY->HY_OPERAC)
					Endif
					oSection3:Cell('G2_DESCRI' ):SetValue(SHY->HY_DESCRI)
					oSection4:Cell('VldInici'):SetValue(DTOC(STOD(REPLACE(SHY->HY_DATAINI,'-',''))))
					oSection4:Cell('VldFinal'):SetValue(DTOC(STOD(REPLACE(SHY->HY_DATAFIM,'-',''))))
					
					If nLinImp > 1
						oReport:PrintText("")
					EndIf
					oSection3:PrintLine()
					If nLinImp > 1
						oReport:PrintText("")
					EndIf
					oSection4:PrintLine()
					oReport:ThinLine()
					SH8->(dbSkip())
					If nLinImp == 1
						nLinBar += 2.85
					Else
						nLinBar += 3.1
					EndIf
					nLinImp++
				EndDo
			Else
				If mv_par13 == 2
					If !Empty(SHY->HY_DATAINI)
						If SHY->HY_DATAINI > (cAliasTop)->C2_DATPRI
							SHY->(dbSkip())
							Loop
						EndIf
					EndIf
					If !Empty(SHY->HY_DATAFIM)
						If SHY->HY_DATAFIM < (cAliasTop)->C2_DATPRI
							SHY->(dbSkip())
							Loop
						EndIf
					EndIf
				EndIf
				
				SH1->(dbSeek(xFilial("SH1")+SHY->HY_RECURSO))
				SH4->(dbSeek(xFilial("SH4")+SHY->HY_FERRAM))

				If mv_par06 == 1
					oSection3:Cell('G2_RECURSO'):SetValue("")
					MSBAR3("EAN128",nLinBar,0.1,Trim(SHY->HY_RECURSO),@oReport:oPrint,Nil,Nil,Nil,Nil ,0.7 ,Nil,Nil,Nil,.F.)
				else
					oSection3:Cell('G2_RECURSO'):SetValue(SHY->HY_RECURSO)
				ENDIF
				oSection3:Cell('H1_DESCRI' ):SetValue(SH1->H1_DESCRI)
				oSection3:Cell('G2_FERRAM' ):SetValue(SHY->HY_FERRAM)
				oSection3:Cell('H4_DESCRI' ):SetValue(SH4->H4_DESCRI)
				If mv_par06 == 1
					oSection3:Cell('G2_OPERAC' ):SetValue("")
					MSBAR3("EAN128",nLinBar,((nLargura / 2.9) * 2.9) - (nLargura / 2.9),Trim(SHY->HY_OPERAC),@oReport:oPrint,Nil,Nil,Nil,Nil ,0.7 ,Nil,Nil,Nil,.F.)
				else
					oSection3:Cell('G2_OPERAC' ):SetValue(SHY->HY_OPERAC)
				EndIf
				oSection3:Cell('G2_DESCRI' ):SetValue(SHY->HY_DESCRI)
				If nLinImp > 1
					oReport:PrintText("")
				EndIf
				oSection3:PrintLine()
				
				oSection4:Cell('H8_DTINI'):Disable()
				oSection4:Cell('H8_HRINI'):Disable()
				oSection4:Cell('H8_DTFIM'):Disable()
				oSection4:Cell('H8_HRFIM'):Disable()
				oSection4:Cell('H8_QUANT'):SetValue(aSC2Sld(cAliasTop))
				oSection4:Cell('VldInici'):SetValue(DTOC(STOD(REPLACE(SHY->HY_DATAINI,'-',''))))
				oSection4:Cell('VldFinal'):SetValue(DTOC(STOD(REPLACE(SHY->HY_DATAFIM,'-',''))))
				If nLinImp > 1
					oReport:PrintText("")
				EndIf
				oSection4:PrintLine()
				oReport:ThinLine()

				oSection4:Cell('H8_DTINI'):Enable()
				oSection4:Cell('H8_HRINI'):Enable()
				oSection4:Cell('H8_DTFIM'):Enable()
				oSection4:Cell('H8_HRFIM'):Enable()
			Endif
			SHY->(dbSkip())
			If nLinImp == 1
				nLinBar += 2.85
			Else
				nLinBar += 3.1
			EndIf
			nLinImp++
		EndDo

		oSection3:Finish()
		oSection4:Finish()
	Endif	
EndIf
RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ APCPR001  ³ Autor ³ Thiago Berna         ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ordens de Producao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ APCPR001(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function APCPR001R3()
Local titulo  := STR0039 //"Ordens de Producao"
Local cString := "SC2"
Local wnrel   := "APCPR001"
Local cDesc   := STR0001	//"Este programa ira imprimir a Rela‡„o das Ordens de Produ‡„o"
Local aOrd    := {STR0002,STR0003,STR0004,STR0005}	//"Por Numero"###"Por Produto"###"Por Centro de Custo"###"Por Prazo de Entrega"
Local tamanho := "M"

Private aReturn  := {STR0006,1,STR0007, 1, 2, 1, "",1 }	//"Zebrado"###"Administracao"
Private cPerg    :="MTR820"
Private nLastKey := 0
Private lItemNeg := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("MTR820",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Da OP                                 ³
//³ mv_par02            // Ate a OP                              ³
//³ mv_par03            // Da data                               ³
//³ mv_par04            // Ate a data                            ³
//³ mv_par05            // Imprime roteiro de operacoes          ³
//³ mv_par06            // Imprime codigo de barras              ³
//³ mv_par07            // Imprime Nome Cientifico               ³
//³ mv_par08            // Imprime Op Encerrada                  ³
//³ mv_par09            // Impr. por Ordem de                    ³
//³ mv_par10            // Impr. OP's Firmes, Previstas ou Ambas ³
//³ mv_par11            // Impr. Item Negativo na Estrutura      ³
//³ mv_par12            // Imprime Lote/Sub-Lote                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-- Verifica se o SH8 esta locado para atualizacao por outro processo                
If !IsLockSH8()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc,"","",.F.,aOrd,.F.,Tamanho)
	
	lItemNeg := GetMv("MV_NEGESTR") .And. mv_par11 == 1
	
	If nLastKey == 27
		dbSelectArea("SH8")
		dbClearFilter()
		dbCloseArea()
		dbSelectArea("SC2")
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		dbSelectArea("SH8")
		dbClearFilter()
		dbCloseArea()
		dbSelectArea("SC2")
		Return
	Endif
	
	RptStatus({|lEnd| R820Imp(@lEnd,wnRel,titulo,"M")},titulo)

EndIf
	
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R820Imp  ³ Autor ³ Thiago Berna          ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APCPR001			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R820Imp(lEnd,wnRel,titulo,tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbCont,cabec1,cabec2
Local limite     := 80
Local nQuant     := 1
Local nomeprog   := "APCPR001"
Local nPagina	 := 1
Local nTipo      := 18
Local cPictQuant := PesqPictQt("D4_QUANT",TamSX3("D4_QUANT")[1])
Local cProduto   := SPACE(LEN(SC2->C2_PRODUTO))
Local cQtd,i,nBegin
Local cIndSC2    := CriaTrab(NIL,.F.), nIndSC2
Local bBlockFiltro := {|| .T.}

Private aArray   := {}
Private li       := 80

cAliasTop  := "SC2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
m_pag    := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1 := ""
cabec2 := ""

dbSelectArea("SC2")

cAliasTop := GetNextAlias()
cQuery := "SELECT SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD, SC2.C2_DATPRF, "
cQuery += "SC2.C2_DATRF, SC2.C2_PRODUTO, SC2.C2_DESTINA, SC2.C2_PEDIDO, SC2.C2_ROTEIRO, SC2.C2_QUJE, "
cQuery += "SC2.C2_PERDA, SC2.C2_QUANT, SC2.C2_DATPRI, SC2.C2_CC, SC2.C2_DATAJI, SC2.C2_DATAJF, "
cQuery += "SC2.C2_STATUS, SC2.C2_OBS, SC2.C2_TPOP, "
cQuery += "SC2.C2_XLOCALI, SC2.C2_XLOTE, SC2.C2_XDTVAL, "
cQuery += "SC2.R_E_C_N_O_  SC2RECNO FROM "+RetSqlName("SC2")+" SC2 WHERE "
cQuery += "SC2.C2_FILIAL='"+xFilial("SC2")+"' AND SC2.D_E_L_E_T_=' ' AND "
If	Upper(TcGetDb()) $ 'ORACLE,DB2,POSTGRES,INFORMIX'
	cQuery += "SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD >= '" + AllTrim(mv_par01) + "' AND "
	cQuery += "SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD <= '" + AllTrim(mv_par02) + "' AND "
Endif
cQuery += "SC2.C2_DATPRF BETWEEN '" + Dtos(mv_par03) + "' AND '" + Dtos(mv_par04) + "' "
If mv_par08 == 2
	cQuery += "AND SC2.C2_DATRF = ' '"
Endif	
If aReturn[8] == 4
	cQuery += "ORDER BY SC2.C2_FILIAL, SC2.C2_DATPRF"
Else
	cQuery += "ORDER BY " + SqlOrder(SC2->(IndexKey(aReturn[8])))
EndIf
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
aEval(SC2->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
dbSelectArea(cAliasTop)

If ! Empty(aReturn[7])
	bBlockFiltro := &("{|| " + aReturn[7] + "}")
Endif	

SetRegua(SC2->(LastRec()))

While !Eof()
	
	IF lEnd
		@ Prow()+1,001 PSay STR0009	//"CANCELADO PELO OPERADOR"
		Exit
	EndIF
	
	IncRegua()
	

	If C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD < xFilial('SC2')+mv_par01 .or. C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD > xFilial('SC2')+mv_par02
		dbSkip()
		Loop
	EndIf   

	If !Empty(aReturn[7])
		SC2->(dbGoto((cAliasTop)->SC2RECNO))
		
		If !(SC2->(Eval(bBlockFiltro)))
			(cAliasTop)->(dbSkip())
			Loop                 
		EndIf	
	Endif	

	//-- Valida se a OP deve ser Impressa ou n„o
	If !MtrAValOP(mv_par10,"SC2",cAliasTop)
		dbSkip()
		Loop
	EndIf
	
	cProduto  := C2_PRODUTO
	nQuant    := aSC2Sld(cAliasTop)
	
	dbSelectArea("SB1")
	dbSeek(xFilial()+cProduto)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona o primeiro elemento da estrutura , ou seja , o Pai  ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AddAr820(nQuant)
	
	MontStruc((cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD),nQuant) 
	
	If mv_par09 == 1
		aSort( aArray,2,, { |x, y| (x[1]+x[8]) < (y[1]+y[8]) } ) 
	Else
		aSort( aArray,2,, { |x, y| (x[8]+x[1]) < (y[8]+y[1]) } )
	ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime cabecalho                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPagina := 1
	cabecOp(Tamanho, nPagina)
	
	For I := 2 TO Len(aArray)
		@Li,   0 PSay substr(aArray[I][1],1,tamsx3('B1_COD')[1])
		//@Li,   0 PSay aArray[I][1]    	 				   	// CODIGO PRODUTO
		For nBegin := 1 To Len(Alltrim(aArray[I][2])) Step 31
			@li,016 PSay Substr(aArray[I][2],nBegin,31) 

			li++
		Next nBegin   
		Li--
		
		cQtd := Alltrim(Transform(aArray[I][5],cPictQuant))
		@Li , (46+11-Len(cQtd)) PSay cQtd					// QUANTIDADE
		
		//@Li ,46 PSay substr(aArray[I][5],1,tamsx3("D4_QUANT")[1])  
		 
		If mv_par12 == 2
			@Li ,  58 PSay "  |   "+aArray[I][4]+"|    "	  // UNIDADE DE MEDIDA
			@li ,  72 PSay aArray[I][6]+"| "                  // ALMOXARIFADO
			@li ,  76 PSay Substr(aArray[I][7],1,12)+"    |"  // DESCRICAO ARMAZEM
			@li ,  94 PSay aArray[I][8]                       // LOCALIZACAO 
			@li ,  104 PSay "   |"+aArray[I][9]               // SEQUENCIA
		Else
			@Li ,  58 PSay "| "+aArray[I][4]+" |"					// UNIDADE DE MEDIDA
			@li ,  65 PSay aArray[I][6]+" |"                        // ALMOXARIFADO 
			@li ,  70 PSay Substr(aArray[I][7],1,12)+" |"  	        // DESCRICAO ARMAZEM
			@li ,  85 PSay aArray[I][8]//Substr(aArray[I][7],1,12)  // LOCALIZACAO
			@li , 100 PSay " | "+aArray[I][9]                  	    // SEQUENCIA
			@li , 106 PSay " | "+aArray[I][11]                  	// LOTE
			//@li , 119 PSay " | "+aArray[I][12]                  	// SUB-LOTE
            @li , 119 PSay " | " + DTOC(aArray[I][12])             	// VALIDADE
		EndIf
		Li++
		@Li ,  00 PSay __PrtThinLine()
		Li++
		   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao couber, salta para proxima folha              ADMIN   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF li > 59
			Li := 0
			nPagina++
			m_pag++
			CabecOp(Tamanho, nPagina)		// imprime cabecalho da OP
		EndIF
		
	Next I
	
	If mv_par05 == 1
		RotOper()   	// IMPRIME ROTEIRO DAS OPERACOES
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprimir Relacao de medidas para Cliente == HUNTER DOUGLAS.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SMX")
	If Found() .And. (cAliasTop)->C2_DESTINA == "P"
		R820Medidas()
	EndIf
	
	Li := 0					// linha inicial - ejeta automatico
	aArray:={}
	
	dbSelectArea(cAliasTop)
	dbSkip()
	
EndDO

dbSelectArea("SH8")
dbCloseArea()

dbSelectArea("SC2")
(cAliasTop)->(dbCloseArea())
dbClearFilter()
dbSetOrder(1)

If aReturn[5] = 1
	Set Printer TO
	dbCommitall()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ AddAr820 ³ Autor ³ Thiago Berna          ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Adiciona um elemento ao Array                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ AddAr820(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Quantidade da estrutura                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APCPR001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function AddAr820(nQuantItem)
Local cDesc   := SB1->B1_DESC
Local cLocal  := ""
Local cKey    := ""
Local cRoteiro:= ""   
Local lExiste   
Local nQtdDc  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se imprime nome cientifico do produto. Se Sim    ³
//³ verifica se existe registro no SB5 e se nao esta vazio    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par07 == 1
	dbSelectArea("SB5")
	dbSeek(xFilial()+SB1->B1_COD)
	If Found() .and. !Empty(B5_CEME)
		cDesc := B5_CEME
	EndIf
ElseIf mv_par07 == 2
	cDesc := SB1->B1_DESC
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se imprime descricao digitada ped.venda, se sim  ³
	//³ verifica se existe registro no SC6 e se nao esta vazio    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasTop)->C2_DESTINA == "P"
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial()+(cAliasTop)->C2_PEDIDO+(cAliasTop)->C2_ITEM)
		If Found() .and. !Empty(C6_DESCRI) .and. C6_PRODUTO==SB1->B1_COD
			cDesc := C6_DESCRI
		ElseIf C6_PRODUTO # SB1->B1_COD
			dbSelectArea("SB5")
			dbSeek(xFilial()+SB1->B1_COD)
			If Found() .and. !Empty(B5_CEME)
				cDesc := B5_CEME
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se imprime ROTEIRO da OP ou PADRAO do produto    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty((cAliasTop)->C2_ROTEIRO)
	cRoteiro:=(cAliasTop)->C2_ROTEIRO
Else
	If !Empty(SB1->B1_OPERPAD)
		cRoteiro:=SB1->B1_OPERPAD
	Else
		dbSelectArea("SG2")
		If dbSeek(xFilial()+(cAliasTop)->C2_PRODUTO+"01")
			cRoteiro:="01"
		EndIf
	EndIf
EndIf
 
dbSelectArea("NNR")
dbSeek(xFilial()+SD4->D4_LOCAL)

/*dbSelectArea("SB2")
dbSeek(xFilial()+SB1->B1_COD+SD4->D4_LOCAL) */

dbSelectArea("SD4")
cKey:=SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE
cLocal:= " "
                                  
lExiste := .F.

nQtdDc := 0
DbSelectArea("SDC")
	DbSetOrder(2)
	DbSeek(xFilial("SDC")+cKey)
	If !Eof() .And. SDC->(DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE) == cKey 
		While !Eof().And. SDC->(DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE) == cKey 
			cLocal  :=DC_LOCALIZ      
			nQtdEnd :=DC_QUANT 
		
			AADD(aArray, {SB1->B1_COD,cDesc,SB1->B1_TIPO,SB1->B1_UM,nQtdEnd,SD4->D4_LOCAL,NNR->NNR_DESCRI,cLocal,SD4->D4_TRT,cRoteiro,If(mv_par12 == 1,SD4->D4_LOTECTL,""),If(mv_par12 == 1,/*SD4->D4_NUMLOTE*/SD4->D4_DTVALID,"") } )
			lExiste := .T.
			nQtdDc += nQtdEnd 
			dbSkip()
		end
	EndIf

dbSelectArea("SD4")

cLocal := ' '
if !lExiste 
	AADD(aArray, {SB1->B1_COD,cDesc,SB1->B1_TIPO,SB1->B1_UM,nQuantItem,SD4->D4_LOCAL,NNR->NNR_DESCRI,cLocal,SD4->D4_TRT,cRoteiro,If(mv_par12 == 1,SD4->D4_LOTECTL,""),If(mv_par12 == 1,/*SD4->D4_NUMLOTE*/SD4->D4_DTVALID,"") } )
Else
	If nQuantItem > nQtdDc
		AADD(aArray, {SB1->B1_COD,cDesc,SB1->B1_TIPO,SB1->B1_UM,(nQuantItem - nQtdDc),SD4->D4_LOCAL,NNR->NNR_DESCRI,cLocal,SD4->D4_TRT,cRoteiro,If(mv_par12 == 1,SD4->D4_LOTECTL,""),If(mv_par12 == 1,/*SD4->D4_NUMLOTE*/SD4->D4_DTVALID,"") } )	
	EndIf
endif

Return
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ MontStruc³ Autor ³ Thiago Berna          ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta um array com a estrutura do produto                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ MontStruc(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto a ser explodido                  ³±±
±±³          ³ ExpN1 = Quantidade base a ser explodida                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APCPR001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function MontStruc(cOp,nQuant)

dbSelectArea("SD4")
dbSetOrder(2)
dbSeek(xFilial()+cOp)

While !Eof() .And. D4_FILIAL+D4_OP == xFilial()+cOp
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no produto desejado                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB1")
	If dbSeek(xFilial()+SD4->D4_COD)
		If SD4->D4_QUANT > 0 .Or. (lItemNeg .And. SD4->D4_QUANT < 0)
			AddAr820(SD4->D4_QUANT)
		EndIf
	Endif
	dbSelectArea("SD4")
	dbSkip()
Enddo

dbSetOrder(1)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ CabecOp  ³ Autor ³ Thiago Berna          ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Monta o cabecalho da Ordem de Producao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ CabecOp()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APCPR001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
/*/
Static Function CabecOp(Tamanho, nPagOp)             

Local cTitulo := If(mv_par12 == 2,STR0010,STR0054)+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) 
Local cCabec1 := STR0066+RTrim(SM0->M0_NOME)+" / "+STR0067+Alltrim(SM0->M0_FILIAL)
//Local cCabec2 := If(mv_par12 == 2,STR0011,STR0055)	//"  C O M P O N E N T E S                                   |    |    |              |                 |     |            |"
//Local cCabec3 := If(mv_par12 == 2,STR0012,STR0056)	//"CODIGO          DESCRICAO                      QUANTIDADE | UM | AM | DESCRICAO    | ENDERECO        | SEQ | LOTE       | SUB-LOTE"
Local cCabec2 := If(mv_par12 == 2,'  C O M P O N E N T E S                                     |     |       |                 |             |   ','  C O M P O N E N T E S                                   |    |    |              |                 |     |            |')	//"  C O M P O N E N T E S                                   |    |    |              |                 |     |            |"
Local cCabec3 := If(mv_par12 == 2,'CODIGO          DESCRICAO                      QUANTIDADE   |   UM|     AM| DESCRICAO       | ENDERECO    |SEQ','CODIGO          DESCRICAO                      QUANTIDADE | UM | AM | DESCRICAO    | ENDERECO        | SEQ | LOTE       | SUB-LOTE')	//"CODIGO          DESCRICAO                      QUANTIDADE | UM | AM | DESCRICAO    | ENDERECO        | SEQ | LOTE       | SUB-LOTE"
													// 012345678901234567890123456789012345678901234567890123456789012345678901234567890
                      						  		//	       1         2         3         4         5         6         7         8
Local nBegin  
Local nLinha    := 0
Local nomeprog  := "APCPR001"  
Local cPictQuant:= PesqPictQt("C2_QUANT",TamSX3("C2_QUANT")[1])

Local cCode     := ''
Local cCodeEnd  := ''
Local cCodeLot  := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar se o ambiente é cliente ou servidor.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
//If SetPrintEnv() == 1
	//nLinha := 2.0 
	nLinha := 1.8 
//Else
//	nLinha := 0.8
//EndIf

If li # 5
	li := 0
Endif

Cabec(cTitulo,cCabec1,"",NomeProg,Tamanho,18,,.F.)

Li+=2
IF (mv_par06 == 1) .And. aReturn[5] # 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o codigo de barras do numero da OP              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPr := ReturnPrtObj()   
	cCode := (cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
	cCodeEnd:= GetMV('MV_XARMPRD',,'50') + (cAliasTop)->(C2_XLOCALI)
    cCodeLot:= (cAliasTop)->(C2_XLOTE)

    //Calcula a largura da pagina em centimetros
    nLargura:= 21

    @Li-2,00 PSay Space(nLargura * 0.55) + "OP: " + C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD + Space(nLargura*1.1 + 3) + 'Local - Endere�o: ' + GetMV('MV_XARMPRD',,'50') + (cAliasTop)->(C2_XLOCALI)  + Space(nLargura*0.40) + 'Lote: ' + AllTrim((cAliasTop)->(C2_XLOTE)) + ' - ' +  DTOC((cAliasTop)->(C2_XDTVAL)) 
    
    //MSBAR3("CODE128",nLinha,0.5,Alltrim(cCode),oPr,Nil,Nil,Nil,nil ,1.5 ,Nil,Nil,Nil)
	
    MSBAR3("EAN128",nLinha,((nLargura / 7) * 1) - (nLargura / 7) + nLargura * 0.05,Trim(cCode),oPr,Nil,Nil,Nil,Nil ,1.5 ,Nil,Nil,Nil)
    oPr := ReturnPrtObj()
    MSBAR3("EAN128",nLinha,((nLargura / 7) * 2.5) - (nLargura / 7),Trim(cCodeEnd),oPr,Nil,Nil,Nil,Nil ,1.5 ,Nil,Nil,Nil)
    oPr := ReturnPrtObj()
    MSBAR3("EAN128",nLinha,((nLargura / 7) * 3.9) - (nLargura / 7),Trim(cCodeLot),oPr,Nil,Nil,Nil,Nil ,1.5 ,Nil,Nil,Nil)
	
	Li += 5
ENDIF
@Li,00 PSay STR0013+aArray[1][1]+ " " +aArray[1][2]	//"Produto: "
Li++
@Li,00 PSay STR0014+DTOC(dDatabase)						//"Emissao:"
@Li,73 PSay STR0015+TRANSFORM(nPagOp,'999')				//"Fol:"
Li++

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime nome do cliente quando OP for gerada            ³
//³ por pedidos de venda                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAliasTop)->C2_DESTINA == "P"
	dbSelectArea("SC5")
	dbSetOrder(1)
	If dbSeek(xFilial()+(cAliasTop)->C2_PEDIDO,.F.)
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial()+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		@Li,00 PSay STR0016	//"Cliente :"
		@Li,10 PSay SC5->C5_CLIENTE+"-"+SC5->C5_LOJACLI+" "+A1_NOME
		dbSelectArea("SG1")
		Li++
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime a quantidade original quando a quantidade da    ³
//³ Op for diferente da quantidade ja entregue              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAliasTop)->C2_QUJE + (cAliasTop)->C2_PERDA > 0
	@Li,00 PSay STR0017                 //"Qtde Prod.:"
	@Li,11 PSay aSC2Sld(cAliasTop)		PICTURE cPictQuant
	@Li,26 PSay STR0018                 //"Qtde Orig.:"
	@Li,37 PSay (cAliasTop)->C2_QUANT	PICTURE cPictQuant
Else
	@Li,00 PSay STR0019			//"Quantidade :"
	@Li,15 PSay (cAliasTop)->C2_QUANT - (cAliasTop)->C2_QUJE	PICTURE cPictQuant
Endif

@Li,56 PSay STR0020	//"INICIO             F I M"
Li++
@Li,00 PSay STR0021+aArray[1][4]			//"Unid. Medida : "
@Li,42 PSay STR0022+DTOC((cAliasTop)->C2_DATPRI)	//"Prev. : "
@Li,62 PSay STR0022+DTOC((cAliasTop)->C2_DATPRF)	//"Prev. : "
Li++
@Li,00 PSay STR0023+(cAliasTop)->C2_CC				//"C.Custo: "
@Li,42 PSay STR0024+DTOC((cAliasTop)->C2_DATAJI)	//"Ajuste: "
@Li,62 PSay STR0024+DTOC((cAliasTop)->C2_DATAJF)	//"Ajuste: "
Li++
If (cAliasTop)->C2_STATUS == "S"
	@Li,00 PSay STR0025						//"Status: OP Sacramentada"
ElseIf (cAliasTop)->C2_STATUS == "U"
	@Li,00 PSay STR0026						//"Status: OP Suspensa"
ElseIf (cAliasTop)->C2_STATUS $ " N"
	@Li,00 PSay STR0027						//"Status: OP Normal"
EndIf
@Li,42 PSay STR0028							//	"Real  :   /  /      Real  :   /  / "
Li++

If !(Empty((cAliasTop)->C2_OBS))
	@Li,00 PSay STR0029						//"Observacao: "
	For nBegin := 1 To Len(Alltrim((cAliasTop)->C2_OBS)) Step 65
		@li,012 PSay Substr((cAliasTop)->C2_OBS,nBegin,65)
		li++
	Next nBegin
EndIf

@Li,00 PSay __PrtFatLine()
Li++
@Li,00 PSay cCabec2
Li++
@Li,00 PSay cCabec3
Li++
@Li,00 PSay __PrtFatLine()
Li++

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ RotOper  ³ Autor ³ Thiago Berna          ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Imprime Roteiro de Operacoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ RotOper()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APCPR001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function RotOper()
Local cSeekWhile := "SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO)"
dbSelectArea("SG2")

If !Empty((cAliasTop)->C2_ROTEIRO)
	aArray[1][9]:=(cAliasTop)->C2_ROTEIRO
Else
	If !Empty(SB1->B1_OPERPAD)
		aArray[1][9]:=SB1->B1_OPERPAD
	Else
		If a630SeekSG2(1,(cAliasTop)->C2_PRODUTO,xFilial("SG2")+(cAliasTop)->C2_PRODUTO+"01")
			aArray[1][9]:="01"
		EndIf
	EndIf
EndIf

If a630SeekSG2(1,aArray[1][1],xFilial("SG2")+aArray[1][1]+aArray[1][9],@cSeekWhile) 
	
	//cRotOper()
	
	While !Eof() .And. Eval(&cSeekWhile)
		
		dbSelectArea("SH4")
		dbSeek(xFilial()+SG2->G2_FERRAM)
		
		dbSelectArea("SH8")
		dbSetOrder(1)
		dbSeek(xFilial()+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SG2->G2_OPERAC)
		lSH8 := IIf(Found(),.T.,.F.)
		
		If lSH8
			While !Eof() .And. SH8->H8_FILIAL+SH8->H8_OP+SH8->H8_OPER == xFilial()+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SG2->G2_OPERAC
				ImpRot(lSH8)
				dbSelectArea("SH8")
				dbSkip()
			End
		Else
			ImpRot(lSH8)
		Endif
		
		dbSelectArea("SG2")
		dbSkip()
		
	EndDo
	
Endif

Return Li

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ ImpRot   ³ Autor ³ Thiago Berna          ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Imprime Roteiro de Operacoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ ImpRot()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APCPR001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function ImpRot(lSH8)
Local nBegin

dbSelectArea("SH1")
dbSeek(xFilial()+IIf(lSH8,SH8->H8_RECURSO,SG2->G2_RECURSO))

Verilim()

@Li,00 PSay IIF(lSH8,SH8->H8_RECURSO,SG2->G2_RECURSO)+" "+SUBS(SH1->H1_DESCRI,1,25)
@Li,33 PSay SG2->G2_FERRAM+" "+SUBS(SH4->H4_DESCRI,1,20)
@Li,61 PSay SG2->G2_OPERAC

For nBegin := 1 To Len(Alltrim(SG2->G2_DESCRI)) Step 16
	@li,064 PSay Substr(SG2->G2_DESCRI,nBegin,16)
	li++

   IF li > 60
		Li := 0
		cRotOper()
	EndIF
Next nBegin

Li+=1
@Li,00 PSay STR0032+IIF(lSH8,DTOC(SH8->H8_DTINI),Space(8))+" "+IIF(lSH8,SH8->H8_HRINI,Space(5))+" "+STR0033+" ____/ ____/____ ___:___"	//"INICIO  ALOC.: "###" INICIO  REAL :"
Li++
@Li,00 PSay STR0034+IIF(lSH8,DTOC(SH8->H8_DTFIM),Space(8))+" "+IIF(lSH8,SH8->H8_HRFIM,Space(5))+" "+STR0035+" ____/ ____/____ ___:___"	//"TERMINO ALOC.: "###" TERMINO REAL :"
Li++
@Li,00 PSay STR0019	//"Quantidade :"
@Li,13 PSay IIF(lSH8,SH8->H8_QUANT,aSC2Sld(cAliasTop)) PICTURE PesqPictQt("H8_QUANT",14)
@Li,28 PSay STR0036	//"Quantidade Produzida :               Perdas :"
Li++
@Li,00 PSay __PrtThinLine()
Li++

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ RotOper  ³ Autor ³ Thiago Berna          ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Imprime Roteiro de Operacoes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ RotOper()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APCPR001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function cRotOper()

//Local cCabec1 := SM0->M0_NOME+STR0030	//"              ROTEIRO DE OPERACOES              NRO :"
Local cCabec1 := SM0->M0_NOME+STR0030+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)	//"              ROTEIRO DE OPERACOES              NRO :"

Local cCabec2 := STR0031					//"RECURSO                       FERRAMENTA               OPERACAO"

Li++
@Li,00 PSay __PrtFatLine()
Li++
@Li,00 PSay cCabec1
//@Li,67 PSay (cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
Li++
@Li,00 PSay __PrtFatLine()
Li++
@Li,00 PSay STR0013+aArray[1][1]	//"Produto: "
ImpDescr(aArray[1][2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime a quantidade original quando a quantidade da    ³
//³ Op for diferente da quantidade ja entregue              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAliasTop)->C2_QUJE + (cAliasTop)->C2_PERDA > 0
	@Li,00 PSay STR0017                 //"Qtde Prod.:"
	@Li,11 PSay aSC2Sld(cAliasTop)      PICTURE PesqPictQt("C2_QUANT",TamSX3("C2_QUANT")[1])
	@Li,26 PSay STR0018                 //"Qtde Orig.:"
	@Li,37 PSay (cAliasTop)->C2_QUANT   PICTURE PesqPictQt("C2_QUANT",TamSX3("C2_QUANT")[1])
Else
	@Li,00 PSay STR0019            //"Quantidade :"
	@Li,15 PSay aSC2Sld(cAliasTop)	PICTURE PesqPictQt("C2_QUANT",TamSX3("C2_QUANT")[1])
Endif

Li++
@Li,00 PSay STR0023+(cAliasTop)->C2_CC	//"C.Custo: "
Li++
@Li,00 PSay __PrtFatLine()
Li++
@Li,00 PSay cCabec2
Li++
@Li,00 PSay __PrtFatLine()
Li++
Return Li

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³ Verilim  ³ Autor ³ Thiago Berna          ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ Verilim()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 			                                          		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APCPR001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function Verilim()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a possibilidade de impressao da proxima operacao alocada na ³
//³ mesma folha.																			 ³
//³ 7 linhas por operacao => (total da folha) 66 - 7 = 59					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF Li > 59						// Li > 55
	Li := 0
	cRotOper()					// Imprime cabecalho roteiro de operacoes
Endif
Return Li

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpDescr ³ Autor ³ Thiago Berna          ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprimir descricao do Produto.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpProd(Void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APCPR001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpDescr(cDescri)
Local nBegin

For nBegin := 1 To Len(Alltrim(cDescri)) Step 50
	@li,025 PSay Substr(cDescri,nBegin,50)
	li++
Next nBegin

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R820Medidas³ Autor ³ Thiago Berna         ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o registros referentes as medidas do Pedido Filho. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R820Medidas(Void)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APCPR001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R820Medidas()
Local aArrayPro := {}, lImpItem := .T.
Local nCntArray := 0,a01 := "",a02 := ""
Local nX:=0,nI:=0,nL:=0,nY:=0
Local cNum:="", cItem:="",lImpCab := .T.
Local nBegin, cProduto:="", cDesc, cDescri, cDescri1, cDescri2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Relacao de Medidas do cliente quando OP for gerada ³
//³ por pedidos de vendas.                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC5")
dbSetOrder(1)
If dbSeek(xFilial()+(cAliasTop)->C2_PEDIDO,.F.)
	cNum := (cAliasTop)->C2_NUM
	cItem := (cAliasTop)->C2_ITEM
	cProduto := (cAliasTop)->C2_PRODUTO
	
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprimir somente se houver Observacoes...                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !Empty(SC5->C5_OBSERVA)
		IF li > 53
			@ 03,001 PSay "HUNTER DOUGLAS DO BRASIL LTDA"
			@ 05,008 PSay "CONFIRMACAO DE PEDIDOS  -  "+IIF( SC5->C5_VENDA=="01","ASSESSORIA","DISTRIBUICAO")
			@ 05,055 PSay "No. RMP    : "+SC5->C5_NUM+"-"+SC5->C5_VENDA
			@ 06,055 PSay "DATA IMPRES: "+DTOC(dDataBase)
			li := 07
		EndIF
		li++
		@ li,001 PSay "--------------------------------------------------------------------------------"
		li++
		cDescri := SC5->C5_OBSERVA
		@ li,001 PSay " OBSERVACAO: "
		@ li,018 PSay SubStr(cDescri,1,60)
		For nBegin := 61 To Len(Trim(cDescri)) Step 60
			li++
			cDesc:=Substr(cDescri,nBegin,60)
			@ li,018 PSay cDesc
		Next nBegin
		li++
		cDescri1 := SC5->C5_OBSERV1
		@ li,018 PSay SubStr(cDescri1,1,60)
		For nBegin := 61 To Len(Trim(cDescri1)) Step 60
			li++
			cDesc:=Substr(cDescri1,nBegin,60)
			@ li,018 PSay cDesc
		Next nBegin
		Li++
		cDescri2 := SC5->C5_OBSERV2
		@ li,018 PSay SubStr(cDescri2,1,60)
		For nBegin := 61 To Len(Trim(cDescri2)) Step 60
			li++
			cDesc:=Substr(cDescri2,nBegin,60)
			@ li,018 PSay cDesc
		Next nBegin
		li++
		@ li,001 PSay "--------------------------------------------------------------------------------"
		li++
	EndIf
	
	*/
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregar as medidas em array para impressao.                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SMX")
	dbSetOrder(2)
	dbSeek(xFilial()+cNum+cProduto)
	While !Eof() .And. M6_FILIAL+M6_NRREL+M6_PRODUTO == xFilial()+cNum+cProduto
		IF M6_ITEM == cItem
			AADD(aArrayPro,M6_ITEM+" - "+M6_PRODUTO)
			nCntArray++
			cCnt := StrZero(nCntArray,2)
			aArray&cCnt := {}
			While !Eof() .And. M6_FILIAL+M6_NRREL+M6_PRODUTO == xFilial()+cNum+cProduto
				If M6_ITEM == cItem
					AADD(aArray&cCnt,{ Str(M6_QUANT,9,2),STR0076 ,M6_COMPTO}) //PECAS COM
				EndIf
				dbSkip()
			End
		Else
			dbSkip()
		EndIF
	End
	cCnt := StrZero(nCntArray+1,2)
	aArray&cCnt := {}
	
	For nX := 1 TO Len(aArrayPro)
		If li > 58
			R820CabMed()
		EndIF
		@ li,009 PSay aArrayPro[nx]
		Li++
		Li++
		dbSelectArea("SMX")
		dbSetOrder(2)
		dbSeek( xFilial()+cNum+Subs(aArrayPro[nX],06,15) )
		While !Eof() .And. M6_FILIAL+M6_NRREL+M6_PRODUTO == xFilial()+cNum+Subs(aArrayPro[nX],06,15)
			If li > 58
				R820CabMed()
			EndIF
			IF M6_ITEM == Subs(aArrayPro[nX],1,2)
				@ li,002 PSay M6_QUANT
				@ li,013 PSay STR0076
				@ li,023 PSay M6_COMPTO
				@ li,035 PSay M6_OBS
				li ++
			EndIF
			dbSkip()
		End
		li++
	Next nX
	@ li,001 PSay "--------------------------------------------------------------------------------"
EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R820CabMed ³ Autor ³ Thiago Berna         ³ Data ³ 09/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime o cabecalho referentes as medidas do Pedido Filho. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R820CabMed(Void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APCPR001                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R820CabMed()
Local cCabec1 := SM0->M0_NOME+STR0037	//"               RELACAO DE MEDIDAS             NRO :"

Li := 0

Li++
@Li,00 PSay __PrtFatLine()
Li++
@Li,00 PSay cCabec1
@Li,67 PSay (cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
Li++
@Li,00 PSay __PrtFatLine()
Li++
Li++
Return Nil
