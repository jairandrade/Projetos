#INCLUDE "MATR860.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³XMATR860   ³ Autor ³Thiago Berna          ³ Data ³ 10/08/20 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacao Das Ordens de Producao.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß           
*/
User Function XMATR860()
Local   oReport
Private cQryOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(FindFunction("MATA330_V")	.And. MATA330_V() >= 20091212)
	Aviso(STR0046,STR0050,{STR0057})	//"Atenção"##"Atualizar MATA330.PRX !!!"##"OK"
	Return
EndIf

//If TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= ReportDef()
	oReport:PrintDialog()
//Else
//	MATR860R3()
//EndIf

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Felipe Nunes Toledo    ³ Data ³23/06/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR860			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local oReport
Local oSection1

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
oReport:= TReport():New("XMATR860",OemToAnsi(STR0001),"MTR860", {|oReport| ReportPrint(oReport)},OemToAnsi(STR0002)+OemToAnsi(STR0003)) //##"O objetivo deste relat¢rio ‚ exibir detalhadamente todas as movimenta-‡”es feitas para cada Ordem de Produ‡„o ,mostrando inclusive os custos."
oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas (MTR860)                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // OP inicial                                   ³
//³ mv_par02     // OP final                                     ³
//³ mv_par03     // moeda selecionada ( 1 a 5 )                  ³
//³ mv_par04     // De  Data Movimentacao                        ³
//³ mv_par05     // Ate Data Movimentacao					     ³
//³ mv_par06     // Totaliza Mov.do mat. movimentados pela O.P.  ³
//³ mv_par07     // Qual Custo Imprimir ? ( Medio / Reposicao )  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(oReport:uParam,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Secao 1 (oSection1)                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0043,{"SD3","SB1","SD5"},/*Ordem*/) //"Ordens de Produção"
oSection1:SetHeaderPage()
oSection1:SetTotalInLine(.F.)

TRCell():New(oSection1,'D3_CC'    	,'SD3',/*Titulo*/,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'D3_OP'	  	,'SD3',/*Titulo*/,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'D3_CF'   	,'SD3',/*Titulo*/,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'D3_COD'   	,'SD3',/*Titulo*/,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'B1_DESC'  	,'SB1',/*Titulo*/,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'D5_QUANT' 	,'SD5',/*Titulo*/,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'D3_UM'    	,'SD3', STR0054 ,/*Picture*/					        	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'Unitario'  	,'SD3', STR0022  ,PesqPict("SD3","D3_CUSTO1",17)	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'Custo'   	,'SD3', STR0023  ,PesqPict("SD3","D3_CUSTO1",17)	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
oSection1:Cell("Custo"):GetFieldInfo("D3_CUSTO1")
TRCell():New(oSection1,'D3_DOC'   	,'SD3',/*Titulo*/,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'D3_EMISSAO'	,'SD3',/*Titulo*/,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'D5_LOTECTL'	,'SD5',/*Titulo*/,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'B1_CUSTD'	,'SB1',/*Titulo*/,/*Picture*/						,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'TotalSTD'	,'SB1',/*Titulo*/,PesqPict("SB1","B1_CUSTD",17)		,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint ³ Autor ³Felipe Nunes Toledo  ³ Data ³23/06/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos  ³±±
±±³          ³os relatorios que poderao ser agendados pelo usuario.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR860			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section(1)
Local dDataFec	:= GETMV("MV_ULMES")
Local cOrderBy  := ''
Local cCampoCus := ''
Local oBreak, oBreak2
Local oFunction
Local cOpAnt
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MV_CUSREP - Parametro utilizado para habilitar o calculo do   ³
//³            Custo de Reposicao.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCusRep  := SuperGetMv("MV_CUSREP",.F.,.F.) .And. (MA330AvRep())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do titulo do relatorio³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetTitle(STR0001+" - "+AllTrim(GetMv("MV_SIMB"+Ltrim(Str(mv_par03))))+ " / " + IIf(lCusRep .And. mv_par07==2,STR0051,STR0052) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alerta o usuario que o custo de reposicao esta desativado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par07==2 .And. !lCusRep
	Help(" ",1,"A860CUSRP")
	mv_par07 := 1
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatorio                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatorio da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection1:BeginQuery()	

cQryOP    := GetNextAlias()

cOrderBy := "% D3_FILIAL, D3_OP, D3_CHAVE, D3_NUMSEQ, D3_COD  %"

BeginSql Alias cQryOP

SELECT SD3.*,
       SB1.B1_COD, SB1.B1_DESC, SB1.B1_CUSTD, SD5.D5_LOTECTL, SD5.D5_QUANT,
       CASE WHEN SUBSTRING(SB1.B1_COD,1,3) = 'MOD' OR SB1.B1_CCCUSTO <> ' ' THEN 'S' ELSE 'N' END ISMOD

FROM %table:SD3% SD3

FULL OUTER JOIN %table:SD5% SD5
ON SD5.D5_FILIAL   = %xFilial:SD5%	 AND 
SD5.D5_PRODUTO = SD3.D3_COD       	 AND
SD5.D5_OP = SD3.D3_OP            	 AND
SD5.D5_NUMSEQ = SD3.D3_NUMSEQ      	 AND	
SD5.%NotDel%		

INNER JOIN %table:SB1% SB1 
ON SB1.B1_FILIAL   = %xFilial:SB1%	 AND 
SB1.B1_COD = SD3.D3_COD            	 AND
SB1.%NotDel%					 

WHERE SD3.D3_FILIAL = %xFilial:SD3%  AND 
SD3.D3_COD      = SB1.B1_COD     	 AND
SD3.D3_OP    	>= %Exp:mv_par01%	 AND 
SD3.D3_OP       <= %Exp:mv_par02%	 AND 
SD3.D3_EMISSAO  >= %Exp:mv_par04%	 AND 
SD3.D3_EMISSAO  <= %Exp:mv_par05%	 AND 
SD3.D3_OP        <> ' '            	 AND
SD3.D3_ESTORNO   <> 'S'           	 AND
SD3.%NotDel%		     

ORDER BY %Exp:cOrderBy%

EndSql 

oSection1:EndQuery()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Totalizando a OP conforme parametro MV_PAR01                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par06 == 1
	oBreak    := TRBreak():New(oSection1,oSection1:Cell("D3_OP"),NIL,.F.)
	oFunction := TRFunction():New(oSection1:Cell('D5_QUANT'),NIL,"SUM",oBreak,NIL,/*Picture*/,{|| If((cQryOP)->ISMOD == 'N' .And. SubStr((cQryOP)->D3_CF,1,2)<>"PR", oSection1:Cell('D5_QUANT'):GetValue(), 0) },.F.,.F.)
	oFunction := TRFunction():New(oSection1:Cell('Custo'   ),NIL,"SUM",oBreak,NIL,/*Picture*/,{|| If((cQryOP)->ISMOD == 'N' .And. SubStr((cQryOP)->D3_CF,1,2)<>"PR", oSection1:Cell('Custo'   ):GetValue(), 0) },.F.,.F.)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definindo a Quebra Por Ordem de Producao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBreak2   := TRBreak():New(oSection1,oSection1:Cell("D3_OP"),STR0056,.T.) //"Total OP"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Totalizando Por Ordem de Producao        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(lCusRep .And. mv_par07==2)
	oFunction := TRFunction():New(oSection1:Cell('B1_CUSTD'),NIL,"MAX",oBreak2,STR0024,/*Picture*/,/*uFormula*/,.F.,.F.) //"Custo Unit STD -----"
	oFunction := TRFunction():New(oSection1:Cell('TotalSTD'),NIL,"SUM",oBreak2,STR0025,/*Picture*/,/*uFormula*/,.F.,.F.) //"Custo Total STD ----"
EndIf	
oFunction := TRFunction():New(oSection1:Cell('D5_QUANT'),NIL,"SUM",oBreak2,STR0026,/*Picture*/,{|| If((cQryOP)->ISMOD == 'S', oSection1:Cell('D5_QUANT'):GetValue() , 0 ) },.F.,.F.) //"Qtd. Mao de Obra ---"
oFunction := TRFunction():New(oSection1:Cell('Custo'   ),NIL,"SUM",oBreak2,STR0027,/*Picture*/,{|| If((cQryOP)->ISMOD == 'S', oSection1:Cell('Custo'):GetValue()    , 0 ) },.F.,.F.) //"Custo Mao de Obra --"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Totais Gerais                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFunction := TRFunction():New(oSection1:Cell('D5_QUANT'),NIL,"SUM",NIL,STR0028,/*Picture*/,{|| If((cQryOP)->ISMOD == 'N' .And. SubStr((cQryOP)->D3_CF,1,2)=="RE" .And. SubStr(D3_CF,3,1) # "9", oSection1:Cell('D5_QUANT'):GetValue(), 0) },.F.,.T.) //"QTDE. TOTAL REQUISICOES ------->"
oFunction := TRFunction():New(oSection1:Cell('Custo'   ),NIL,"SUM",NIL,STR0029,PesqPict("SD3","D3_CUSTO1",17),{|| If((cQryOP)->ISMOD == 'N' .And. SubStr((cQryOP)->D3_CF,1,2)=="RE" .And. SubStr(D3_CF,3,1) # "9", oSection1:Cell('Custo'   ):GetValue(), 0) },.F.,.T.) //"CUSTO TOTAL REQUISICOES ------->"

oFunction := TRFunction():New(oSection1:Cell('D5_QUANT'),NIL,"SUM",NIL,STR0030,/*Picture*/,{|| If(SubStr(D3_CF,1,2)=="PR",oSection1:Cell('D5_QUANT'):GetValue(),0) },.F.,.T.) //"QTDE. TOTAL PRODUCAO ---------->"
oFunction := TRFunction():New(oSection1:Cell('Custo'   ),NIL,"SUM",NIL,STR0031,PesqPict("SD3","D3_CUSTO1",17),{|| If(SubStr(D3_CF,1,2)=="PR",oSection1:Cell('Custo'   ):GetValue(),0) },.F.,.T.) //"CUSTO TOTAL PRODUCAO ---------->"

oFunction := TRFunction():New(oSection1:Cell('D5_QUANT'),NIL,"SUM",NIL,STR0032,/*Picture*/,{|| If((cQryOP)->ISMOD == 'N' .And. SubStr((cQryOP)->D3_CF,1,2)=="DE" .And. SubStr(D3_CF,3,1) # "9", (- oSection1:Cell('D5_QUANT'):GetValue()), 0) },.F.,.T.) //"QTDE. TOTAL DEVOLUCOES  ------->"
oFunction := TRFunction():New(oSection1:Cell('Custo'   ),NIL,"SUM",NIL,STR0033,PesqPict("SD3","D3_CUSTO1",17),{|| If((cQryOP)->ISMOD == 'N' .And. SubStr((cQryOP)->D3_CF,1,2)=="DE" .And. SubStr(D3_CF,3,1) # "9", (- oSection1:Cell('Custo'   ):GetValue()), 0) },.F.,.T.) //"CUSTO TOTAL DEVOLUCOES  ------->"

oFunction := TRFunction():New(oSection1:Cell('D5_QUANT'),NIL,"SUM",NIL,STR0034,/*Picture*/,{|| If((cQryOP)->ISMOD == 'N' .And. SubStr((cQryOP)->D3_CF,1,2)=="RE" .And. SubStr(D3_CF,3,1)=="9", oSection1:Cell('D5_QUANT'):GetValue(), 0) },.F.,.T.) //"QTDE. TOTAL REQ PODER 3 ------->"
oFunction := TRFunction():New(oSection1:Cell('Custo'   ),NIL,"SUM",NIL,STR0035,PesqPict("SD3","D3_CUSTO1",17),{|| If((cQryOP)->ISMOD == 'N' .And. SubStr((cQryOP)->D3_CF,1,2)=="RE" .And. SubStr(D3_CF,3,1)=="9", oSection1:Cell('Custo'   ):GetValue(), 0) },.F.,.T.) //"CUSTO TOTAL REQ PODER 3 ------->"
                                                                        
oFunction := TRFunction():New(oSection1:Cell('D5_QUANT'),NIL,"SUM",NIL,STR0036,/*Picture*/,{|| If((cQryOP)->ISMOD == 'N' .And. SubStr((cQryOP)->D3_CF,1,2)=="DE" .And. SubStr(D3_CF,3,1)=="9", (- oSection1:Cell('D5_QUANT'):GetValue()), 0) },.F.,.T.) //"QTDE. TOTAL DEV PODER 3 ------->"
oFunction := TRFunction():New(oSection1:Cell('Custo'   ),NIL,"SUM",NIL,STR0037,PesqPict("SD3","D3_CUSTO1",17),{|| If((cQryOP)->ISMOD == 'N' .And. SubStr((cQryOP)->D3_CF,1,2)=="DE" .And. SubStr(D3_CF,3,1)=="9", (- oSection1:Cell('Custo'   ):GetValue()), 0) },.F.,.T.) //"CUSTO TOTAL DEV PODER 3 ------->"

oFunction := TRFunction():New(oSection1:Cell('D5_QUANT'),NIL,"SUM",NIL,STR0038,/*Picture*/,{|| If((cQryOP)->ISMOD == 'S' .And. SubStr((cQryOP)->D3_CF,1,2)=="RE" .And. SubStr(D3_CF,3,1) # "9", oSection1:Cell('D5_QUANT'):GetValue(), 0) },.F.,.T.) //"QTDE. TOTAL REQ. MAO DE OBRA -->"
oFunction := TRFunction():New(oSection1:Cell('Custo'   ),NIL,"SUM",NIL,STR0039,PesqPict("SD3","D3_CUSTO1",17),{|| If((cQryOP)->ISMOD == 'S' .And. SubStr((cQryOP)->D3_CF,1,2)=="RE" .And. SubStr(D3_CF,3,1) # "9", oSection1:Cell('Custo'   ):GetValue(), 0) },.F.,.T.) //"CUSTO TOTAL REQ. MAO DE OBRA -->"

oFunction := TRFunction():New(oSection1:Cell('D5_QUANT'),NIL,"SUM",NIL,STR0040,/*Picture*/,{|| If((cQryOP)->ISMOD == 'S' .And. SubStr((cQryOP)->D3_CF,1,2)=="DE" .And. SubStr(D3_CF,3,1) # "9", (- oSection1:Cell('D5_QUANT'):GetValue()), 0) },.F.,.T.) //"QTDE. TOTAL DEV. MAO DE OBRA -->"
oFunction := TRFunction():New(oSection1:Cell('Custo'   ),NIL,"SUM",NIL,STR0041,PesqPict("SD3","D3_CUSTO1",17),{|| If((cQryOP)->ISMOD == 'S' .And. SubStr((cQryOP)->D3_CF,1,2)=="DE" .And. SubStr(D3_CF,3,1) # "9", (- oSection1:Cell('Custo'   ):GetValue()), 0) },.F.,.T.) //"CUSTO TOTAL DEV. MAO DE OBRA -->"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inibindo celulas, utilizadas apenas para totalizadores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:Cell('B1_CUSTD'):Hide()
oSection1:Cell('B1_CUSTD'):HideHeader()
oSection1:Cell('TotalSTD'):Hide()
oSection1:Cell('TotalSTD'):HideHeader()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o campo a ser impresso no valor de acordo com a moeda selecionada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case mv_par03 == 1
		If lCusRep .And. mv_par07==2
			cCampoCus :=   "(cQryOP)->D3_CUSRP1"
		Else
			cCampoCus :=   "(cQryOP)->D3_CUSTO1"
		EndIf	
	Case mv_par03 == 2
		If lCusRep .And. mv_par07==2
			cCampoCus :=   "(cQryOP)->D3_CUSRP2"
		Else
			cCampoCus :=   "(cQryOP)->D3_CUSTO2"
		EndIf	
	Case mv_par03 == 3
		If lCusRep .And. mv_par07==2
			cCampoCus :=   "(cQryOP)->D3_CUSRP3"
		Else
			cCampoCus :=   "(cQryOP)->D3_CUSTO3"
		EndIf	
	Case mv_par03 == 4
		If lCusRep .And. mv_par07==2
			cCampoCus :=   "(cQryOP)->D3_CUSRP4"
		Else
			cCampoCus :=   "(cQryOP)->D3_CUSTO4"
		EndIf	
	Case mv_par03 == 5
		If lCusRep .And. mv_par07==2
			cCampoCus :=   "(cQryOP)->D3_CUSRP5"
		Else
			cCampoCus :=   "(cQryOP)->D3_CUSTO5"
		EndIf	
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatorio                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetMeter(SD3->(LastRec()))
oSection1:Init()
dbSelectArea(cQryOP)
While !oReport:Cancel() .And. !(cQryOP)->(Eof())
	cOpAnt := (cQryOP)->D3_OP
	While (cQryOP)->D3_FILIAL+(cQryOP)->D3_OP == xFilial("SD3")+cOpAnt
		oReport:Section(1):Cell('D3_OP'   ):SetValue( (cQryOP)->D3_OP )
		//oReport:Section(1):Cell('D5_LOTECTL'):SetValue( (cQryOP)->D5_LOTECTL )
		If ((cQryOP)->ISMOD == 'S')
			oReport:Section(1):Cell('D5_QUANT'):SetValue( If(SubStr((cQryOP)->D3_CF,1,2)=="DE",( -R860ToDec((cQryOP)->D3_QUANT )),R860ToDec((cQryOP)->D3_QUANT)) )
		Else
			oReport:Section(1):Cell('D5_QUANT'):SetValue( If(SubStr((cQryOP)->D3_CF,1,2)=="DE",( -(cQryOP)->D5_QUANT ),(cQryOP)->D5_QUANT) )
		EndIf
		oReport:Section(1):Cell('Unitario'):SetValue( (&(cCampoCus + '/D3_QUANT')) )
		oReport:Section(1):Cell('Custo'   ):SetValue( If(SubStr((cQryOP)->D3_CF,1,2)=="DE",( -&(cCampoCus + IIF((cQryOP)->ISMOD == 'N','*D5_QUANT/D3_QUANT',''))),&(cCampoCus + IIF((cQryOP)->ISMOD == 'N','*D5_QUANT/D3_QUANT',''))) )
		If !(lCusRep .And. mv_par07==2)
			oReport:Section(1):Cell('B1_CUSTD'):SetValue( If(SubStr((cQryOP)->D3_CF,1,2)=="PR", RetFldProd((cQryOP)->B1_COD,"B1_CUSTD",cQryOP) ,0) )
		EndIf	
		If !(lCusRep .And. mv_par07==2)
			oReport:Section(1):Cell('TotalSTD'):SetValue( If(SubStr((cQryOP)->D3_CF,1,2)=="PR",( oSection1:Cell('B1_CUSTD'):GetValue() * oSection1:Cell('D5_QUANT'):GetValue() ) , 0)  )
		EndIf	
		If SubStr((cQryOP)->D3_CF,1,2) == "PR"
			oReport:SkipLine()
		EndIF
		If oReport:Cancel()
    	   	Exit
		EndIf
		oReport:IncMeter()
		oSection1:PrintLine()
		dbSkip()
	EndDo
	If lCusRep .And. mv_par07==2
		oReport:PrintText( cOpAnt+STR0018+DTOC(dDataFec)+") => "+Transform(Posicione("SC2",1,xFilial("SC2")+cOpAnt,"C2_VFIMRP"+Str(MV_PAR03,1)),PesqPict("SC2","C2_VFIM1")) ) //" - Valor final no ultimo fechamento ("
	Else
		oReport:PrintText( cOpAnt+STR0018+DTOC(dDataFec)+") => "+Transform(Posicione("SC2",1,xFilial("SC2")+cOpAnt,"C2_VFIM"+Str(MV_PAR03,1)),PesqPict("SC2","C2_VFIM1")) ) //" - Valor final no ultimo fechamento ("
	EndIf		
	oReport:PrintText( STR0042+Posicione("SC2",1,xFilial("SC2")+cOpAnt,"C2_PRODUTO") ) // "Produto : "
EndDo
oSection1:Finish()
(cQryOP)->(DbCloseArea())
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR860  ³ Autor ³ Eveli Morasco         ³ Data ³ 06/03/93   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacao Das Ordens de Producao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo Pim.³04/12/97³09746A³perg.total.mat.movimentacao p/OP(mv_par06)  ³±±
±±³Rodrigo Sart³24/03/98³08957A³Incl. Impressao das Qtds totais (mv_par06)  ³±±
±±³Rodrigo Sart³24/06/98³XXXXXX³Acerto no tamanho do documento para 12      ³±±
±±³            ³        ³      ³posicoes                                    ³±±
±±³Rodrigo Sart³04/11/98³XXXXXX³ Acerto p/ Bug Ano 2000                     ³±±
±±³Fernando J. ³02/12/98³18752A³A fun‡„o PesqPictQT foi substituida pela    ³±±
±±³            ³        ³      ³PesqPict.                                   ³±±
±±³CesarValadao³31/03/99³XXXXXX³Manutencao na SetPrint()                    ³±±
±±³CesarValadao³20/05/99³XXXXXX³Retirada Condicao Especifica p/ TOP         ³±±
±±³            ³        ³      ³IndRegua() - cCondicao                      ³±±
±±³Patricia Sal³25/11/99³25324A³IndRegua()-cCondicao-Acerto para imprimir so³±±
±±³            ³        ³      ³mente Op's e filtrar por SUBS(D3_CF,2,1)    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XMR860R3()
Local titulo   	:= STR0001	//"Relacao por Ordem de Producao"
Local cDesc1   	:= STR0002	//"O objetivo deste relat¢rio ‚ exibir detalhadamente todas as movimenta-"
Local cDesc2   	:= STR0003	//"‡”es feitas para cada Ordem de Produ‡„o ,mostrando inclusive os custos."
Local cString  	:= "SD3"
Local wnrel		:= "MATR860"
Local Tamanho  	:= "G"

PRIVATE aReturn  	:= {STR0004,1,STR0005, 2, 2, 1, "",1 }	//"Zebrado"###"Administracao"
PRIVATE nLastKey	:= 0
PRIVATE cPerg 		:= "MTR860"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // OP inicial                                   ³
//³ mv_par02     // OP final                                     ³
//³ mv_par03     // moeda selecionada ( 1 a 5 )                  ³
//³ mv_par04     // De  Data Movimentacao                        ³
//³ mv_par05     // Ate Data Movimentacao					     ³
//³ mv_par06     // Totaliza Mov.do mat. movimentados pela O.P.  ³
//³ mv_par07     // Qual Custo Imprimir ? ( Medio / Reposicao )  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,"",.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
EndIf

RptStatus({|lEnd| R860Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R860Imp  ³ Autor ³ Waldemiro L. Lustosa  ³ Data ³ 13.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada do Relat¢rio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR860			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R860Imp(lEnd,wnRel,titulo,tamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cabec1,cabec2
Local cRodaTxt     := ''
Local cOpAnt       := ''
Local cCampoCus    := ''
Local cCondicao    := ''
Local nomeprog     := "MATR860"

Local nCntImpr     := 0
Local nTipo        := 0
Local nCusto       := 0
Local nTotQuant    := 0
Local nTotCusto    := 0
Local nTotReq      := 0
Local nTotProd     := 0
Local nTotDev      := 0
Local nTotReqTer   := 0
Local nTotDevTer   := 0
Local nTotQuantMod := 0
Local nTotCustoMod := 0
Local nTotReqMod   := 0
Local nTotDevMod   := 0
Local nQuantReq    := 0
Local nQuantProd   := 0
Local nQuantDev    := 0
Local nQuantDevTer := 0
Local nQuantReqTer := 0
Local nQtdReqMod   := 0 
Local nQtdDevMod   := 0
Local aColPos      := {}
Local lContinua    := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para controle do cursor de progressao do relatorio ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nTotRegs := 0 ,nMult := 1 ,nPosAnt := 4 ,nPosAtu := 4 ,nPosCnt := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local bBloco := { |nV,nX| Trim(nV)+IIf(Valtype(nX)='C',"",Str(nX,1)) }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizada para verificar ultimo fechamento estoque ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local dDataFec:= GETMV("MV_ULMES")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o tamanho do codigo do produto                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lNewTamProd := TamSX3("B1_COD")[1] > 15 // Verifica o tamanho do codigo do produto
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MV_CUSREP - Parametro utilizado para habilitar o calculo do   ³
//³            Custo de Reposicao.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lCusRep  := SuperGetMv("MV_CUSREP",.F.,.F.) .And. (MA330AvRep())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE li := 80 ,m_pag := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cNomArq := ''
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se deve comprimir ou nao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alerta o usuario que o custo de reposicao esta desativado.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par07==2 .And. !lCusRep
	Help(" ",1,"A860CUSRP")
	mv_par07 := 1
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona informacoes ao titulo do relatorio                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("NewHead")#"U"
	NewHead += " - "+AllTrim(GetMv("MV_SIMB"+Ltrim(Str(mv_par03))))
Else
	Titulo  += " - "+AllTrim(GetMv("MV_SIMB"+Ltrim(Str(mv_par03)))) + " / " + IIf(lCusRep .And. mv_par07==2,STR0051,STR0052)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos conforme Tamanho Produto                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1 := IIf(lNewTamProd,STR0044,STR0006)	//"CENTRO               ORDEM DE    MOV CODIGO DO       DESCRICAO              QUANTIDADE    UM         CUSTO       C U S T O  NUMERO       DATA DE"
cabec2 := IIf(lNewTamProd,STR0045,STR0007)	//"CUSTO                PRODUCAO        PRODUTO                                                      UNITARIO       T O T A L  DOCUMENTO    EMISSAO"
*****											   12345678901234567890 12345612121 123 123456789012345 12345678901234567890 99,999,999.9999 12 99,999,999.99 9999,999,999.99 123456789012 12/12/1234
*****											   0         1         2         3         4         5         6         7         8         9        10        11        12        13
*****											   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o campo a ser impresso no valor de acordo com a moeda selecionada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case mv_par03 == 1
		If lCusRep .And. mv_par07==2
			cCampoCus :=   "SD3->D3_CUSRP1"
		Else
			cCampoCus :=   "SD3->D3_CUSTO1"
		EndIf	
	Case mv_par03 == 2
		If lCusRep .And. mv_par07==2
			cCampoCus :=   "SD3->D3_CUSRP2"
		Else
			cCampoCus :=   "SD3->D3_CUSTO2"
		EndIf	
	Case mv_par03 == 3
		If lCusRep .And. mv_par07==2
			cCampoCus :=   "SD3->D3_CUSRP3"
		Else
			cCampoCus :=   "SD3->D3_CUSTO3"
		EndIf	
	Case mv_par03 == 4
		If lCusRep .And. mv_par07==2
			cCampoCus :=   "SD3->D3_CUSRP4"
		Else
			cCampoCus :=   "SD3->D3_CUSTO4"
		EndIf	
	Case mv_par03 == 5
		If lCusRep .And. mv_par07==2
			cCampoCus :=   "SD3->D3_CUSRP5"
		Else
			cCampoCus :=   "SD3->D3_CUSTO5"
		EndIf	
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o nome do arquivo de indice de trabalho             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq := CriaTrab("",.F.)

dbSelectArea("SD3")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o indice de trabalho                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCondicao := "D3_FILIAL == '"+xFilial("SD3")+"' .And. D3_OP >= '"+mv_par01+"'"
cCondicao += " .And. D3_OP <= '"+mv_par02+"' .And. D3_OP <> ' ' .And. DTOS(D3_EMISSAO) >= '"+DTOS(mv_par04)+"'.And. DTOS(D3_EMISSAO) <= '"+DTOS(mv_par05)+"'"

IndRegua("SD3",cNomArq,"D3_FILIAL+D3_OP+D3_CHAVE+D3_NUMSEQ+D3_COD",,cCondicao,STR0008)     //"Selecionando Registros..."
dbGoTop()

nTotReq     :=0
nTotReqTer  :=0
nTotDev     :=0
nTotDevTer  :=0
nTotProd    :=0
nTotReqMod  :=0
nTotDevMod  :=0
nTotReqMo3  :=0
nTotDevMo3  :=0
nQuantReq   :=0
nQuantReqTer:=0
nQuantProd  :=0
nQuantDev   :=0
nQuantDevTer:=0
nQtdReqMod  :=0
nQtdDevMod  :=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aColPos - Define o posicionamento das colunas            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ny := 5
If lNewTamProd
	aColPos := {000,021,035,039,070,101,122,126,143,162,187,095,128,099,143}
Else
	aColPos := {000,021,035,039,055,086,102,106,123,142,166,080,113,084,123}
EndIf

SetRegua(LastRec())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Correr SD3 para ler as REs, DEs e Producoes.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While lContinua .And. !Eof()
	
	If lEnd
		@ PROW()+1,001 PSay STR0009	//"CANCELADO PELO OPERADOR"
		Exit
	EndIf
	IncRegua()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Correr SD3 para a mesma OP.                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotQuant    := 0
	nTotCusto    := 0
	nQtdeProd    := 0
	nTotQuantMod := 0
	nTotCustoMod := 0
	cOpAnt       := D3_OP
	While !Eof() .And. D3_FILIAL+D3_OP = xFilial()+cOpAnt
		
		If lEnd
			@ PROW()+1,001 PSay STR0009	//"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		EndIf
		
		IncRegua()
		
		If li > 58
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		EndIf
		
		If D3_ESTORNO == "S"
			dbSkip()
			Loop
		EndIf

		nCusto := &(cCampoCus)
		If !IsProdMod(SD3->D3_COD)
			nTotQuant += IIf( SubStr(D3_CF,1,2) == "RE", D3_QUANT, 0 )
			nTotQuant += IIf( SubStr(D3_CF,1,2) == "DE", ( -D3_QUANT ), 0 )
			If SubStr(D3_CF,3,1) # "9"
				nTotCusto += IIf( SubStr(D3_CF,1,2) == "RE", nCusto, 0 )
				nTotCusto += IIf( SubStr(D3_CF,1,2) == "DE", ( -nCusto ), 0 )
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Totaliza‡„o separada para a m„o-de-obra                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotQuantMod += IIf( SubStr(D3_CF,1,2) == "RE", D3_QUANT, 0 )
			nTotQuantMod += IIf( SubStr(D3_CF,1,2) == "DE", ( -D3_QUANT ), 0 )
			If SubStr(D3_CF,3,1) # "9"
				nTotCustoMod += IIf( SubStr(D3_CF,1,2) == "RE", nCusto, 0 )
				nTotCustoMod += IIf( SubStr(D3_CF,1,2) == "DE", ( -nCusto ), 0 )
			EndIf
		EndIf
		
		nQtdeProd += IIf( SubStr(D3_CF,1,2) == "PR", D3_QUANT , 0 )
		nQtdeProd += IIf( SubStr(D3_CF,1,2) == "ER", -D3_QUANT , 0 )
		
		dbSelectArea("SB1")
		dbSeek(cFilial+SD3->D3_COD)
		dbSelectArea("SD3")
		If SubStr(D3_CF,1,2) == "PR"
			Li++
		EndIf

		@ Li,aColPos[01] PSay D3_CC
		@ Li,aColPos[02] PSay D3_OP
		@ Li,aColPos[03] PSay D3_CF
		@ Li,aColPos[04] PSay D3_COD
		@ Li,aColPos[05] PSay SubStr(SB1->B1_DESC,1,30)
		If SubStr(D3_CF,1,2) == "DE"
			If IsProdMod(SD3->D3_COD)
				@ Li,aColPos[06] PSay ( -R860ToDec(D3_QUANT) )			Picture PesqPict("SD3","D3_QUANT" ,15)
			Else
				@ Li,aColPos[06] PSay ( -D3_QUANT )			Picture PesqPict("SD3","D3_QUANT" ,15)
			EndIf
			@ Li,aColPos[07] PSay D3_UM
			@ Li,aColPos[08] PSay ( nCusto/D3_QUANT )	Picture PesqPict("SD3","D3_CUSTO1",17)
			@ Li,aColPos[09] PSay ( -nCusto )			Picture PesqPict("SD3","D3_CUSTO1",17)
		Else
			If IsProdMod(SD3->D3_COD)
				@ Li,aColPos[06] PSay ( R860ToDec(D3_QUANT) )			Picture PesqPict("SD3","D3_QUANT" ,15)
			Else
				@ Li,aColPos[06] PSay ( D3_QUANT )			Picture PesqPict("SD3","D3_QUANT" ,15)
			EndIf
			@ Li,aColPos[07] PSay D3_UM
			@ Li,aColPos[08] PSay ( nCusto/D3_QUANT )	Picture PesqPict("SD3","D3_CUSTO1",17)
			@ Li,aColPos[09] PSay nCusto				Picture PesqPict("SD3","D3_CUSTO1",17)
		EndIf
		@ Li,aColPos[10] PSay Substr(D3_DOC,1,20)		Picture PesqPict("SD3","D3_DOC"	  ,12)
		@ Li,aColPos[11] PSay D3_EMISSAO
		Li++
		
		If !IsProdMod(SD3->D3_COD)
			If SubStr(D3_CF,1,2) == "RE"
				If SubStr(D3_CF,3,1) # "9"
					nTotReq		+= nCusto
					nQuantReq	+= D3_QUANT
				Else
					nTotReqTer	+= nCusto				
					nQuantReqTer+= D3_QUANT
				EndIf	
			Elseif SubStr(D3_CF,1,2) == "DE"
				If SubStr(D3_CF,3,1) # "9"
					nTotDev		+= nCusto
					nQuantDev	+= D3_QUANT
				Else
					nTotDevTer	+= nCusto				
					nQuantDevTer+= D3_QUANT
				EndIf
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Totaliza‡„o separada para a m„o-de-obra                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SubStr(D3_CF,1,2) == "RE"
				If SubStr(D3_CF,3,1) # "9"
					nTotReqMod	+= nCusto
				Else
					nTotReqMo3	+= nCusto				
				EndIf
				nQtdReqMod	+= D3_QUANT
			Elseif SubStr(D3_CF,1,2) == "DE"
				If SubStr(D3_CF,3,1) # "9"
					nTotDevMod	+= nCusto
				Else
					nTotDevMo3	+= nCusto				
				EndIf
				nQtdDevMod	+= D3_QUANT
			Endif
		EndIf
		
		If SubStr(D3_CF,1,2) == "PR"
			nTotProd		+= nCusto
			nQuantProd	+= D3_QUANT
		EndIf
		
		dbSkip()
		
	End

	Li++

	If (nTotQuant+nTotQuantMod) != 0
		@ Li,000 PSay STR0010 + cOpAnt	//"TOTAL  "
		If !(lCusRep .And. mv_par07==2)
			@ Li,021 PSay STR0011			//"Custo STD : "
			@ Li,035 PSay RetFldProd(SB1->B1_COD,"B1_CUSTD") Picture PesqPict("SB1","B1_CUSTD",12)
			@ Li,047 PSay "/"
			@ Li,051 PSay ( RetFldProd(SB1->B1_COD,"B1_CUSTD") * nQtdeProd ) Picture PesqPict("SB1","B1_CUSTD",17)
		EndIf	
		If mv_par06 == 1
			@ Li,aColPos[14] PSay nTotQuant	Picture PesqPict("SD3","D3_QUANT" ,17)
		Endif
		@ Li,aColPos[15] 	 PSay nTotCusto Picture PesqPict("SD3","D3_CUSTO1",17)
		Li++
		If nTotQuantMod <> 0 .Or. nTotCustoMod <> 0
			@ Li,000  PSay STR0012	//"       MAO DE OBRA:"
			@ Li,aColPos[14] PSay R860ToDec(nTotQuantMod) Picture PesqPict("SD3","D3_QUANT" ,17)
			@ Li,aColPos[15] PSay nTotCustoMod Picture PesqPict("SD3","D3_CUSTO1",17)
			Li++
		Endif
	EndIf
	If SC2->(dbSeek(xFilial("SC2")+cOPAnt))
		@ li,000 PSay cOpAnt+STR0018+DTOC(dDataFec)+")" //" - Valor final no ultimo fechamento ("
		If lCusRep .And. mv_par07==2
			@ li,aColPos[15] PSay &(Eval(bBloco,"SC2->C2_VFIMRP",mv_par03)) Picture PesqPict("SD3","D3_CUSTO1",17)
		Else
			@ li,aColPos[15] PSay &(Eval(bBloco,"SC2->C2_VFIM",mv_par03)) Picture PesqPict("SD3","D3_CUSTO1",17)
		EndIf	
		li++
		@ li,000 PSay STR0019+" "+SC2->C2_PRODUTO
		li++
	EndIf
	
	@ Li,000 PSay Replicate("-",220)
	Li += 2
	
EndDo

If li != 80
	Li++
	@ Li,000 PSay STR0013	//"TOTAL REQUISICOES ---->"
	If mv_par06 == 1
		@ Li,aColPos[12] PSay nQuantReq		Picture PesqPict("SD3","D3_QUANT" ,17)
	EndIf
	@ Li,aColPos[15] 	 PSay nTotReq		Picture PesqPict("SD3","D3_CUSTO1",17)
	Li++
	If li > 58
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf
	@ Li,000 PSay STR0014	//"TOTAL PRODUCAO    ---->"
	If mv_par06 == 1
		@ Li,aColPos[12] PSay nQuantProd	Picture PesqPict("SD3","D3_QUANT" ,17)
	EndIf
	@ Li,aColPos[15] 	 PSay nTotProd		Picture PesqPict("SD3","D3_CUSTO1",17)
	Li++
	@ Li,000 PSay STR0015	//"TOTAL DEVOLUCOES  ---->"
	If mv_par06 == 1
		@ Li,aColPos[12] PSay nQuantDev		Picture PesqPict("SD3","D3_QUANT" ,17)
	EndIf
	@ Li,aColPos[15] 	 PSay nTotDev		Picture PesqPict("SD3","D3_CUSTO1",17)
	Li++
	If li > 57
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf

	@ Li,000 PSay STR0020	// "TOTAL REQ PODER 3 ---->"
	If mv_par06 == 1
		@ Li,aColPos[12] PSay nQuantReqTer	Picture PesqPict("SD3","D3_QUANT" ,17)
	EndIf
	@ Li,aColPos[15] 	 PSay nTotReqTer	Picture PesqPict("SD3","D3_CUSTO1",17)
	Li++
	If li > 57
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf

	@ Li,000 PSay STR0021	//"TOTAL DEV PODER 3 ---->"
	If mv_par06 == 1
		@ Li,aColPos[12] PSay nQuantDevTer	Picture PesqPict("SD3","D3_QUANT" ,17)
	EndIf
	@ Li,aColPos[15] 	 PSay nTotDevTer	Picture PesqPict("SD3","D3_CUSTO1",17)
	Li++
	If li > 57
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf

	If nTotReqMod <> 0
		@ Li,000 PSay STR0016	//"TOTAL REQUISICOES MAO DE OBRA ---->"
		If mv_par06 == 1
			@ Li,aColPos[12] PSay nQtdReqMod	Picture PesqPict("SD3","D3_QUANT" ,17)
		EndIf
		@ Li,aColPos[15] 	 PSay nTotReqMod   	Picture PesqPict("SD3","D3_CUSTO1",17)
		Li++
	EndIf
	If nTotDevMod <> 0
		@ Li,000 PSay STR0017	//"TOTAL DEVOLUCOES  MAO DE OBRA ---->"
		If mv_par06 == 1
			@ Li,aColPos[12] PSay nQtdDevMod	Picture PesqPict("SD3","D3_QUANT" ,17)
		EndIf
		@ Li,aColPos[15] 	 PSay nTotDevMod   	Picture PesqPict("SD3","D3_CUSTO1",17)
		Li++
	Endif
	Roda(nCntImpr,cRodaTxt,Tamanho)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens originais do arquivo                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("SD3")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq += OrdBagExt()
FErase( cNomArq )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD3")
RetIndex("SD3")
Set Filter To
dbSetOrder(1)

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ R860ToDec ³     Autor ³ Luiza Liebl  ³     Data ³ 13.05.19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Converte valor centesimal para decimal                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR860			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R860ToDec(nValor)
Local nHoras
Local nMinutos
Local nTotal

	If(GetMv("MV_TPHR")=="N")
		nHoras := Int(nValor)
		nMinutos := (((nValor-nHoras)*60)/100)
		nTotal := nHoras + nMinutos
	Else
		nTotal := nValor
	EndIf

return nTotal