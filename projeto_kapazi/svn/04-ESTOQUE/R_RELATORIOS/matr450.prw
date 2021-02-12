#INCLUDE "MATR450.CH"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR450 � Autor � Flavio Luiz Vicco      � Data �03/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao Consumo Real x Standard.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAPCP                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Marcos V.   �19/09/06�      �Revisao Geral- Release 3 e Release 4      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MATR450()
Local oReport 	:= ReportDef()
Private aRetTL	:= {}

oReport:PrintDialog()

Return Nil
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � ReportDef�Autor  �Flavio Luiz Vicco      �Data  �03/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao Consumo Real x Standard.                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�(Nenhum)                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oExpO1: Objeto do relatorio                                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local cTitle := OemToAnsi(STR0001) //"Consumo Real x Standard"

Private cPicD3C114 := PesqPict("SD3","D3_CUSTO1",14)
Private cPicD3C116 := PesqPict("SD3","D3_CUSTO1",16)
Private cPicD3C118 := PesqPict("SD3","D3_CUSTO1",18)
Private cPicD3Qtde := PesqPict("SD3","D3_QUANT" ,15)
Private cPicC2Qtde := PesqPict("SC2","C2_QUANT",15)
Private cPicD3Perc := PesqPict("SD3","D3_PMACNUT",7) //usa qq campo da D3 do tipo percentual
Private cTamCod    := TamSX3("D3_COD")[1]

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport := TReport():New("MATR450",cTitle,"MT451K",{|oReport| ReportPrint(oReport,'SD3')},STR0001) //"Consumo Real x Standard"
oReport:SetLandscape()

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01    // Listagem por Ordem de Producao ou Produto.    �
//� mv_par02    // Listagem Sintetica ou Analitica.              �
//� mv_par03    // De                                            �
//� mv_par04    // Ate                                           �
//� mv_par05    // Custo do Consumo Real 1...6 ( Moeda )         �
//� mv_par06    // Custo do Consumo Std  1...6                   �
//� mv_par07    // Movimentacao De                               �
//� mv_par08    // Movimentacao Ate                              �
//� mv_par09    // Calcular Pela Estrutura / Empenho             �
//� mv_par10    // Aglutina por Produto.                         �
//����������������������������������������������������������������
Pergunte(oReport:uParam,.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da secao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a secao.                   �
//�ExpA4 : Array com as Ordens do relatorio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao das celulas da secao do relatorio                               �
//�                                                                        �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relatorio. O SX3 sera consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de codigo para impressao.                                 �
//�        Default : ExpC2                                                 �
//�                                                                        �
//��������������������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Section 1 - Total em Quantidade da OP / Produto              �
//����������������������������������������������������������������
oSection1:= TRSection():New(oReport,STR0045,{"SD3"},/*aOrdem*/) //"Saldo Inicial OP / Produto"
oSection1:SetHeaderSection(.F.) // Inibe Header
oSection1:SetEditCell(.f.)

TRCell():New(oSection1,"CPROD",		"",STR0037	,/*Picture*/,17 					,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CDESC",		"",STR0038	,/*Picture*/,If(cTamCod>15, 37, 25),/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CUMED",		"",STR0039	,/*Picture*/, 2	,/*lPixel*/			,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"NQTDE",		"",STR0022	,cPicC2Qtde	,15	,/*lPixel*/			,/*{|| code-block de impressao }*/,,,"RIGHT")

//��������������������������������������������������������������Ŀ
//� Section 2 - Linha de Detalhe                                 �
//����������������������������������������������������������������
oSection2:= TRSection():New(oSection1,STR0044,{"SD3"},/*aOrdem*/) //"Itens de Movimenta��o Interna"
oSection2:SetHeaderPage(.T.)
oSection2:SetHeaderSection(.T.)
oSection2:SetEditCell(.f.)

TRCell():New(oSection2,"CPROD"		,"",STR0020	+CRLF+STR0037,/*Picture*/	,cTamCod+2	   				,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"CDESC"		,"",""		+CRLF+STR0038,/*Picture*/	,If(cTamCod>15, 22, 25)		,/*lPixel*/,/*{|| code-block de impressao }*/) //"M a t e r i a l"
TRCell():New(oSection2,"CUMED"		,"",""		+CRLF+STR0039,/*Picture*/	, 2							,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection2,"NQTDE"		,"",STR0021	+CRLF+STR0022,cPicD3Qtde	,15							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Consumo"###"Quantidade"
TRCell():New(oSection2,"NCUSUNIT"	,"",STR0023	+CRLF+STR0024,cPicD3C114	,14							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Real"###"Custo Un."
TRCell():New(oSection2,"NVLTOT"		,"","" 		+CRLF+STR0025,cPicD3C116	,16							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Valor total"

//Adicionada tratativa para retornar o custo
TRCell():New(oSection2,"NQTDE2"		,"",STR0021	+CRLF+STR0022,cPicD3Qtde	,15							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Consumo"###"Quantidade"
TRCell():New(oSection2,"NCUSUSTD"	,"",STR0026	+CRLF+STR0024,cPicD3C114	,14							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Standard"###"Custo Un."
TRCell():New(oSection2,"NVLTOT2"	,"",""   	+CRLF+STR0025,cPicD3C116	,16							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Valor Total"
//Adicionada tratativa para retornar o custo

TRCell():New(oSection2,"NQTDE3"		,"",STR0027	+CRLF+STR0040,cPicD3Qtde	,15							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Variacao"###"Quantidade"
TRCell():New(oSection2,"NTOTALVAR"	,"",""    	+CRLF+STR0025,cPicD3C114	,14							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Valor Total"
TRCell():New(oSection2,"NSVALOR"	,"",""      +CRLF+STR0028,cPicD3C114	,14							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"$Qdt."
TRCell():New(oSection2,"NSQUANT"	,"",""      +CRLF+STR0029,cPicD3Qtde	,13							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"$Valor"
TRCell():New(oSection2,"NPERC"		,"",""      +CRLF+"    %",cPicD3Perc	, 7 						,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")

//��������������������������������������������������������������Ŀ
//� Section 3 - Linha de Totais                                  �
//����������������������������������������������������������������
oSection3:= TRSection():New(oSection2,STR0046,{"SD3"},/*aOrdem*/) //"Totais por OP / Produto"
oSection3:SetHeaderSection(.F.)
oSection3:SetNoFilter("SD3")
oSection3:SetEditCell(.f.)

TRCell():New(oSection3,"CTOTAL"		,""	,STR0020+CRLF+STR0037	,/*Picture*/,cTamCod+2					,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"CDESC"		,""	,""		+CRLF+STR0038	,/*Picture*/,If(cTamCod>15, 22, 25) 	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"CUMED"		,""	,""	  	+CRLF+STR0039	,/*Picture*/, 2							,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection3,"NQTDE"		,""	,STR0021+CRLF+STR0022	,cPicD3Qtde	,15							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Quantidade"
TRCell():New(oSection3,"NTOTREALOPU",""	,STR0023+CRLF+STR0024	,cPicD3C114	,14							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Custo un."
TRCell():New(oSection3,"NTOTREALOP"	,""	,"" 	+CRLF+STR0025	,cPicD3C116	,16							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Valor total"
TRCell():New(oSection3,"NQTDE2"		,""	,STR0021+CRLF+STR0022	,cPicD3Qtde	,15							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Quantidade"
TRCell():New(oSection3,"NTOTSTDOPU",""	,STR0026+CRLF+STR0024	,cPicD3C114	,14							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Custo Un."
TRCell():New(oSection3,"NTOTSTDOP"	,""	,STR0025				,cPicD3C116	,16							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Valor Total"
TRCell():New(oSection3,"NQTDE3"		,""	,STR0022				,cPicD3Qtde	,15							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Quantidade"
TRCell():New(oSection3,"NTOTVAROP"	,""	,STR0025				,cPicD3C116	,16							,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT")//"Valor Total"

//��������������������������������������������������������������Ŀ
//� Section 4 - Resumo Geral                                     �
//����������������������������������������������������������������
oSection4:= TRSection():New(oReport,STR0047,{"SD3"},/*aOrdem*/) //"Resumo Aglutinado por Produto"
oSection4:SetHeaderPage(.T.)
oSection4:SetHeaderSection(.F.)
oSection4:SetNoFilter("SD3")
oSection4:SetEditCell(.f.)

TRCell():New(oSection4,"CPROD"		,"",""     +CRLF+STR0037	,/*Picture*/,cTamCod+2 	,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection4,"CDESC"		,"",""     +CRLF+STR0038	,/*Picture*/,25 		,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection4,"CUMED"		,"",""						,/*Picture*/, 2			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection4,"NQTDE"		,"",STR0030+CRLF+STR0041	,cPicD3Qtde	,15			,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Consumo Real"###"Quantidade"
TRCell():New(oSection4,"NVLTOT"		,"",""     +CRLF+STR0031	,cPicD3C118	,18			,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Valor"
TRCell():New(oSection4,"NQTDE2"		,"",STR0032+CRLF+STR0042	,cPicD3Qtde	,15			,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Consumo Std."###"Quantidade"
TRCell():New(oSection4,"NVLTOT2"	,"",""     +CRLF+STR0031	,cPicD3C118	,18			,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Valor"
TRCell():New(oSection4,"NQTDE3"		,"",STR0027+CRLF+STR0043	,cPicD3Qtde	,15			,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Variacao"###"Quantidade"
TRCell():New(oSection4,"NVLTOT3"	,"",""     +CRLF+STR0031	,cPicD3C118	,18			,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") //"Valor"
TRCell():New(oSection4,"NPERCTOT"	,"",""     +CRLF+"    %"	,cPicD3Perc	,7			,/*lPixel*/,/*{|| code-block de impressao }*/,,,"RIGHT") // Percentual( % )

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Flavio Luiz Vicco      �Data  �03/07/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao Consumo Real x Standard.                           ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport,cAliasSB1)
Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(1):Section(1)
Local oSection3  := oReport:Section(1):Section(1):Section(1)
Local oSection4  := oReport:Section(2)
Local cVazio1    := Space(Len(SD3->D3_OP))
Local aTam       := TamSX3("D3_CUSTO1")
Local cAnt       := ""
Local cOpAnt     := ""
Local nQuantG1   := 0
Local lOpConf    := .T.
Local aRecnoD4   := {}
Local nTotalVar  := 0
Local nQtdVar    := 0
Local nPercent   := 0
Local nCusStdOP  := nTotStdOP := nCusRealOP := nTotRealOP := nTotVarOP := 0
Local nCusUnit   := nCusUnitR := nCusUnitS  := nCusUStd   := 0
Local nSValor    := 0
Local nSQuant    := 0
Local nPosTrb1   := nPosTrb2  := nPosTrb3   := 	nPosComp	:= 0
Local nI		 := 0
Local cFilSB1    := xFilial("SB1")
Local cFilSC2    := xFilial("SC2")
Local cFilSG1    := xFilial("SG1")
Local cWhere	:= ""
Local cWhere2 	:= ""
Local aRetTL	:= {}
Local nXX 		:= 1

Private cAliasNew  := "SD3"
Private nTamDecQtd := TamSX3("D3_QUANT")[2]
Private nTamIntCus := aTam[1]
Private nTamDecCus := aTam[2]
Private aLstTrb1   := {}
Private aLstTrb2   := {}
Private aLstTrb3   := {}

aRetTL := Abretela() //abre a tela para informar Ops ou Produtos

dbSelectArea(cAliasNew)
dbSetOrder(6)
//������������������������������������������������������������������������Ŀ
//�Filtragem do relatorio                                                  �
//��������������������������������������������������������������������������

cAliasNew := GetNextAlias()
//��������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                        �
//����������������������������������������������������������������������
MakeSqlExpr(oReport:uParam)
//��������������������������������������������������������������������Ŀ
//�Query do relatorio da secao 1                                       �
//����������������������������������������������������������������������
oReport:Section(1):BeginQuery()

//��������������������������������������������������������������Ŀ
//� Filtro por OP / Produto                                      �
//����������������������������������������������������������������
If mv_par01 == 1
	// Filtrar por OP
	If Empty(aRetTL)
			cWhere := "% SD3.D3_OP BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 + "' %"
		Else
			cWhere := ""
			For nXX := 1 To Len(aRetTL)
				cWhere += "'"+ Alltrim(aRetTL[nXX]) +"',"
			Next

			cWhere := Substr(cWhere,1,Len(cWhere) - 1)

			cWhere := "% SD3.D3_OP IN ("+ cWhere +") %"

			Conout(cWhere)
	EndIf
	

Else
	// Filtrar por Produto Pai
	If Empty(aRetTL)
			cWhere := "% SD3.D3_OP IN (SELECT C2_NUM||C2_ITEM||C2_SEQUEN||C2_ITEMGRD FROM "+RetSqlName("SC2")+" SC2 " 
			cWhere += "WHERE SC2.C2_FILIAL = '"+xFilial("SC2")+"' "
			cWhere += "AND SC2.C2_PRODUTO BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 + "' "
			cWhere += "AND SC2.D_E_L_E_T_ = ' ' ) %"
		
		Else
			cWhere2 := ""
			For nXX := 1 To Len(aRetTL)
				cWhere2 += "'"+ Alltrim(aRetTL[nXX]) +"',"
			Next

			cWhere2 := Substr(cWhere2,1,Len(cWhere2) - 1)

			cWhere2 := " AND SC2.C2_PRODUTO IN ("+ cWhere2 +") "


			cWhere := "% SD3.D3_OP IN (SELECT C2_NUM||C2_ITEM||C2_SEQUEN||C2_ITEMGRD FROM "+RetSqlName("SC2")+" SC2 " 
			cWhere += "WHERE SC2.C2_FILIAL = '"+xFilial("SC2")+"' "
			//cWhere += "AND SC2.C2_PRODUTO BETWEEN '"+ mv_par03 +"' AND '"+ mv_par04 + "' "
			cWhere += cWhere2
			cWhere += "AND SC2.D_E_L_E_T_ = ' ' ) %"

			Conout(cWhere)
	EndIf
	//aRetTL
EndIf

BeginSql Alias cAliasNew

	SELECT SD3.* ,SD3.R_E_C_N_O_ D3REC
	
	FROM %table:SD3% SD3
	
	WHERE SD3.D3_FILIAL = %xFilial:SD3%
		AND SD3.D3_OP <> %Exp:cVazio1 %
		AND %Exp:cWhere%
		AND SD3.D3_CF <> 'ER0' AND SD3.D3_CF <> 'ER1'
		AND SD3.D3_EMISSAO >= %Exp:DTOS(mv_par07)%
		AND SD3.D3_EMISSAO <= %Exp:DTOS(mv_par08)%
		AND SD3.D3_ESTORNO <> 'S'
		AND SD3.%NotDel%
	
	ORDER BY %Order:SD3%
	
EndSql
//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relatorio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������

//GetLastQuery()[2]

oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

oReport:SetMeter(SD3->(RecCount()))

While !oReport:Cancel() .And. (cAliasNew)->(!Eof())
	oReport:IncMeter()

	If oReport:Cancel()
		Exit
	EndIf

	If SB1->(B1_FILIAL+B1_COD)# (cFilSB1+(cAliasNew)->D3_COD)
		SB1->(MsSeek(cFilSB1+(cAliasNew)->D3_COD))
	EndIf

	If SC2->(C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)# (cFilSC2+(cAliasNew)->D3_OP)
		SC2->(MsSeek(cFilSC2+(cAliasNew)->D3_OP))
	EndIf

	//���������������������������������������������������������������������������Ŀ
	//� Le requisicoes e devolucoes SD3 e grava no aLstTrb1 para gravacao do REAL �
	//�����������������������������������������������������������������������������
	If SubStr((cAliasNew)->D3_CF,2,1)$"E" .And. (cAliasNew)->(!Empty(D3_OP) )

		//��������������������������������������������������������������Ŀ
		//� Ordem de Producao / Produto                                  �
		//����������������������������������������������������������������
		If mv_par01 == 1
			nPosTrb1 := aScan(aLstTrb1,{|x| x[2]+x[1]==(cAliasNew)->D3_OP+(cAliasNew)->D3_COD})
		Else
			If mv_par10 == 1
				nPosTrb1 := aScan(aLstTrb1,{|x| x[7]+x[1]==SC2->C2_PRODUTO+(cAliasNew)->D3_COD})
			Else
				nPosTrb1 := aScan(aLstTrb1,{|x| x[7]+x[1]+x[2]==SC2->C2_PRODUTO+(cAliasNew)->D3_COD+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)})
			EndIf
		EndIf

		If Empty(nPosTrb1)
			aAdd(aLstTrb1,{	(cAliasNew)->D3_COD,		;	  		//01 - PRODUTO
							(cAliasNew)->D3_OP,			; 			//02 - OP
							(cAliasNew)->D3_NUMSEQ,		; 			//03 - NUMSEQ
							R450TRT("RE"),				; 			//04 - TRT
							(cAliasNew)->D3_CHAVE,		; 			//05 - CHAVE
							(cAliasNew)->D3_EMISSAO,	; 			//06 - EMISSAO
							SC2->C2_PRODUTO,			; 			//07 - PAI
							"",							;	 		//08 - FIXVAR
							R450Qtd("R",0,cAliasNew),	; 			//09 - QTDREAL
							0,							; 			//10 - QTDSTD
							0,							; 			//11 - QTDVAR
							0,							; 			//12 - CUSTOSTD
							R450Cus('R', mv_par05,,cAliasNew),;		//13 - CUSTOREAL
							0	})						  			//14 - CUSTOVAR
		Else
			aLstTrb1[nPosTrb1,03] := (cAliasNew)->D3_NUMSEQ				//03 - NUMSEQ
			aLstTrb1[nPosTrb1,04] := R450TRT("RE")						//04 - TRT
			aLstTrb1[nPosTrb1,05] := (cAliasNew)->D3_CHAVE				//05 - CHAVE
			aLstTrb1[nPosTrb1,06] := (cAliasNew)->D3_EMISSAO			//06 - EMISSAO
			aLstTrb1[nPosTrb1,09] += R450Qtd("R",0,cAliasNew)		 	//09 - QTDREAL
			aLstTrb1[nPosTrb1,13] += R450Cus('R', mv_par05,,cAliasNew)	//13 - CUSTOREAL
		EndIf

	EndIf

	//��������������������������������������������������������������Ŀ
	//� Le producoes e gravar TRB. para gravacao do STANDARD         �
	//����������������������������������������������������������������
	If (cAliasNew)->D3_ESTORNO != "S" .And. SubStr((cAliasNew)->D3_CF,1,2)$"PR"

		//��������������������������������������������������������������Ŀ
		//� Considera filtro de Usuario                                  �
		//����������������������������������������������������������������
		If !(SB1->(MsSeek(cFilSB1+(cAliasNew)->D3_COD)))
			(cAliasNew)->(DbSkip())
			Loop
		EndIf

		//��������������������������������������������������������������Ŀ
		//� Lista por Ordem de Producao / Produto                        �
		//����������������������������������������������������������������
		If mv_par01 == 1
			nPosTrb2 := aScan(aLstTrb2,{|x|x[2]==(cAliasNew)->D3_OP})
		Else
			nPosTrb2 := aScan(aLstTrb2,{|x|x[1]==(cAliasNew)->D3_COD})
		EndIf

		If Empty(nPosTrb2)
			aAdd(aLstTrb2,Array(4))
			nPosTrb2 := Len(aLstTrb2)
			aLstTrb2[nPosTrb2,4] := 0
		EndIf
		aLstTrb2[nPosTrb2,1] := (cAliasNew)->D3_COD
		aLstTrb2[nPosTrb2,2] := (cAliasNew)->D3_OP
		aLstTrb2[nPosTrb2,3] := (cAliasNew)->D3_UM
		aLstTrb2[nPosTrb2,4] += (cAliasNew)->D3_QUANT

		cProduto := (cAliasNew)->D3_COD

		//��������������������������������������������������������������Ŀ
		//� Calcular pela Estrutura                                      �
		//����������������������������������������������������������������
		If mv_par09 == 1
			dbSelectArea("SG1")
			dbSetOrder(1)
			dbSeek(cFilSG1+cProduto)
			While !Eof() .And. cFilSG1+cProduto == G1_FILIAL + G1_COD
				If dDataBase < G1_INI .Or. dDataBase > G1_FIM 
					dbSelectArea("SG1")
					dbSkip()
					Loop
				EndIf
				// CORRE��O ISSUE - DMANMAT01-14544
				
				If !EMPTY( SG1->G1_GROPC ) .AND. !EMPTY( SG1->G1_OPC )
					cAliasOpc := GetNextAlias()

					BeginSql Alias cAliasOpc
					
						SELECT 	SD3.D3_OP, SD3.D3_COD, SD3.D3_TRT, SD3.R_E_C_N_O_ D3REC
						
						FROM 	%table:SD3% SD3
						
						WHERE 	SD3.D3_FILIAL = %xFilial:SD3%
								AND SD3.D3_OP =  %Exp:( cAliasNew )->D3_OP%
								AND SD3.D3_COD = %Exp:SG1->G1_COMP%
								AND SD3.D3_TRT <> ''
								AND SD3.%NotDel%
					
						ORDER BY %Order:SD3%
						
					EndSql
				
					If ( cAliasOpc )->( !Eof() )
						If ( cAliasOpc )->D3_TRT <> SG1->G1_TRT 
							( cAliasOpc )->( dbCloseArea() )

							dbSelectArea("SG1")
							dbSkip()
							Loop
						EndIf 
					EndIf
					( cAliasOpc )->( dbCloseArea() )
					
				EndIf 
				// FIM
				
				dbSelectArea("SB1")
				MsSeek(cFilSB1+(cAliasNew)->D3_COD)
				nQuantG1 := 0
				If SG1->G1_FIXVAR == "F"
					nQuantG1 := SG1->G1_QUANT
					If (cAliasNew)->D3_PARCTOT == 'P'
						nQuantG1 := Round(nQuantG1*IIf(SC2->(C2_QUJE==C2_QUANT),1,SC2->(C2_QUJE/C2_QUANT)),nTamDecQtd)
					EndIf
				Else
					nQuantG1 := ExplEstr((cAliasNew)->D3_QUANT,SC2->C2_DATPRI,SC2->C2_OPC,SC2->C2_REVISAO)
				EndIf

				//��������������������������������������������������������������Ŀ
				//� Se Produto for FANTASMA gravar so os componentes.            �
				//����������������������������������������������������������������
				If RetFldProd(SB1->B1_COD,"B1_FANTASM") == "S" // Projeto Implementacao de campos MRP e FANTASM no SBZ
					R450Fant(nQuantG1 )
				Else
					//��������������������������������������������������������������Ŀ
					//� Gravar Valores da Producao no array aLstTrb1                 �
					//����������������������������������������������������������������
					dbSelectArea("SB1")
					If MsSeek(cFilSB1+SG1->G1_COMP)
						If mv_par01 == 1
							nPosTrb1 := aScan(aLstTrb1,{|x| x[2]+x[1]==(cAliasNew)->D3_OP+SG1->G1_COMP})
						Else
							If mv_par10 == 1
								nPosTrb1 := aScan(aLstTrb1,{|x| x[7]+x[1]==SC2->C2_PRODUTO+SG1->G1_COMP})
							Else
								nPosTrb1 := aScan(aLstTrb1,{|x| x[7]+x[1]+x[2]==SC2->C2_PRODUTO+SG1->G1_COMP+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)})
							EndIf
						EndIf
						//���������������������������������������������������������������Ŀ
						//� Valida Requesicoes de mesmo componente para a mesma estrutura �
						//�����������������������������������������������������������������
						If !Empty(nPosTrb1) .And. !Empty(aLstTrb1[nPosTrb1,4])
							aRetSD3 := R450TRT("PR",nPosTrb1)
						Else
							aRetSD3 := {"",0,.F.}
						EndIf
						
						If Empty(nPosTrb1) 
							aAdd(aLstTrb1,Array(14))
							nPosTrb1 := Len(aLstTrb1)
							aLstTrb1[nPosTrb1,01] := SG1->G1_COMP
							aLstTrb1[nPosTrb1,02] := (cAliasNew)->D3_OP
							aLstTrb1[nPosTrb1,09] := 0
							aLstTrb1[nPosTrb1,10] := 0
							aLstTrb1[nPosTrb1,11] := 0
							aLstTrb1[nPosTrb1,12] := 0
							aLstTrb1[nPosTrb1,13] := 0
							aLstTrb1[nPosTrb1,14] := 0
						EndIf
						aLstTrb1[nPosTrb1,04] := aRetSD3[1]
						aLstTrb1[nPosTrb1,07] := cProduto
						aLstTrb1[nPosTrb1,08] := SG1->G1_FIXVAR
						aLstTrb1[nPosTrb1,10] += Round(nQuantG1,nTamDecQtd)
						aLstTrb1[nPosTrb1,12] += R450Cus("S",mv_par06,Round(nQuantG1,nTamDecCus))
					EndIf
				EndIf
				dbSelectArea("SG1")
				dbSkip()
			EndDo

		//��������������������������������������������������������������Ŀ
		//� Calcular pelo Empenho                                        �
		//����������������������������������������������������������������
		Else
			dbSelectArea("SD4")
			dbSetOrder(2)
			dbSeek(xFilial("SD4")+(cAliasNew)->D3_OP)
			If (cAliasNew)->D3_OP # cOpAnt
				lOpConf:=.T.
			Else
				lOpConf:=.F.
			EndIf

			While SD4->(!Eof() .And. D4_FILIAL + D4_OP == xFilial("SD4")+(cAliasNew)->D3_OP ) .And. cOpAnt # (cAliasNew)->D3_OP .And. lOpConf

				If aScan(aRecnoD4, SD4->(RecNo())) > 0
					dbSkip()
					Loop
				EndIf

				aAdd(aRecnoD4, SD4->(RecNo()))

				//��������������������������������������������������������������Ŀ
				//� Gravar Valores da Producao no array aLstTrb1                 �
				//����������������������������������������������������������������
				dbSelectArea("SB1")
				MsSeek(cFilSB1+SD4->D4_COD)
				If mv_par01 == 1
					nPosTrb1 := aScan(aLstTrb1,{|x|x[2]+x[1]==(cAliasNew)->D3_OP+SD4->D4_COD})
				Else
					If mv_par10 == 1
						nPosTrb1 := aScan(aLstTrb1,{|x|x[7]+x[1]==SC2->C2_PRODUTO+SD4->D4_COD})
					Else
						nPosTrb1 := aScan(aLstTrb1,{|x| x[7]+x[1]+x[2]==SC2->C2_PRODUTO+SD4->D4_COD+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)})
					EndIf
				EndIf

				If Empty(nPosTrb1)
					aAdd(aLstTrb1,Array(14))
					nPosTrb1 := Len(aLstTrb1)
					aLstTrb1[nPosTrb1,01] := SD4->D4_COD
					aLstTrb1[nPosTrb1,02] := (cAliasNew)->D3_OP
					aLstTrb1[nPosTrb1,09] := 0
					aLstTrb1[nPosTrb1,10] := 0
					aLstTrb1[nPosTrb1,11] := 0
					aLstTrb1[nPosTrb1,12] := 0
					aLstTrb1[nPosTrb1,13] := 0
					aLstTrb1[nPosTrb1,14] := 0
				EndIf
				aLstTrb1[nPosTrb1,07] := cProduto
				aLstTrb1[nPosTrb1,08] := ""
				aLstTrb1[nPosTrb1,10] += Round(SD4->D4_QTDEORI * SC2->(C2_QUJE/C2_QUANT), nTamDecQtd)
				aLstTrb1[nPosTrb1,12] += R450Cus("S",mv_par06,Round(SD4->D4_QTDEORI * SC2->(C2_QUJE/C2_QUANT),nTamDecCus))

				dbSelectArea("SD4")
				dbSkip()
			EndDo

			cOpAnt := (cAliasNew)->D3_OP
		EndIf
		dbSelectArea(cAliasNew)
	EndIf
	(cAliasNew)->(dbSkip())
EndDo

//��������������������������������������������������������������Ŀ
//� Ordena por Ordem de Producao / Produto                       �
//����������������������������������������������������������������
If mv_par01 == 1
	aLstTrb1 := ASort(aLstTrb1,,, { | x,y | x[2]+x[1] < y[2]+y[1] })
Else
	aLstTrb1 := ASort(aLstTrb1,,, { | x,y | x[7]+x[1] < y[7]+y[1] })
EndIf

//��������������������������������������������������������������Ŀ
//� Inicio da Impressao do array.                                �
//����������������������������������������������������������������
oReport:SetTitle(oReport:Title()+IIF(mv_par01 == 1, STR0009,STR0010)) //" ( Por Ordem de Producao )"###" ( Por Produto )"
oReport:SetMeter(RecCount())
oSection1:Init()
oSection2:Init()
oSection3:Init()
nQuantOp := 0.00

For nI:=1 To Len(aLstTrb1)

	oReport:IncMeter()

	If oReport:Cancel()
		Exit
	EndIf

	//����������������������������������������������������������Ŀ
	//� Impressao por OP e PRODUTO                               �
	//������������������������������������������������������������
	If mv_par01 = 1
		nPosTrb2 := aScan(aLstTrb2,{|x| x[2]==aLstTrb1[nI,2]})
	Else
		nPosTrb2 := aScan(aLstTrb2,{|x| x[1]==aLstTrb1[nI,7]})
	EndIf
	If Empty(nPosTrb2)
		Loop
	EndIf
	If mv_par02 == 1
		oSection1:Cell("CPROD"):SetValue(If(mv_par01=1,STR0036+aLstTrb2[nPosTrb2,2],STR0035)) //"OP: "###"PRODUTO:"
		oSection1:Cell("CDESC"):SetValue(aLstTrb2[nPosTrb2,1])
		oSection1:Cell("CUMED"):SetValue(aLstTrb2[nPosTrb2,3])
		oSection1:Cell("NQTDE"):SetValue(aLstTrb2[nPosTrb2,4])
		oSection1:PrintLine()
		oReport:SkipLine() //-- Salta linha
		nQuantOp := aLstTrb2[nPosTrb2,4]
	EndIf
	nCusStdOP := nTotStdOP := nCusRealOP := nTotRealOP := nTotVarOP := 0
	nCusUnitR := nCusUnitS := 0

	cAnt 	  := IIf( mv_par01 == 1,aLstTrb1[nI,02],aLstTrb1[nI,07])

	While nI <= Len(aLstTrb1) .And. IIF( mv_par01 == 1,aLstTrb1[nI,2],aLstTrb1[nI,7]) == cAnt
		nTotalVar  := aLstTrb1[nI,13]-aLstTrb1[nI,12]  //	CUSTOREAL-CUSTOSTD
		nQtdVar    := aLstTrb1[nI,09]-aLstTrb1[nI,10]	//	QTDREAL-QTDSTD
		nPercent   := (nQtdVar/aLstTrb1[nI,10])*100	//	((QTDREAL-QTDSTD)/QTDSTD)*100
		nCusUnit   := IIf(Empty(aLstTrb1[nI,09]),aLstTrb1[nI,13],Round(aLstTrb1[nI,13]/aLstTrb1[nI,09],nTamDecCus))	//Round(CUSTOREAL/IIF(QTDREAL=0,1,QTDREAL),nTamDecCus)
		nCusUStd   := IIf(Empty(aLstTrb1[nI,10]),aLstTrb1[nI,12],Round(aLstTrb1[nI,12]/aLstTrb1[nI,10],nTamDecCus))	//Round(CUSTOSTD/IIF(QTDSTD=0,1,QTDSTD),nTamDecCus)
		nSValor    := Round(nCusUnit*nQtdVar,nTamDecCus)
		nSQuant    := Round(nTotalVar-nSValor,nTamDecCus)

		//Posicoes 10 e 12 = 10-> QTD STANDART E 12 - CUSTO STANDART

		//����������������������������������������������������������Ŀ
		//� Posiciona na tabela de PRODUTOS                          �
		//������������������������������������������������������������
		SB1->(DbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+aLstTrb1[nI,01]))
		If mv_par02 == 1 .And. (mv_par09 == 1 .Or. (QtdComp(aLstTrb1[nI,09],.T.) # QtdComp(0,.T.)))
			oSection2:Cell("CPROD"	):SetValue(aLstTrb1[nI,01])
			oSection2:Cell("CDESC"	):SetValue(SB1->B1_DESC)
			oSection2:Cell("CUMED"	):SetValue(SB1->B1_UM)

			oSection2:Cell("NQTDE"		):SetValue(aLstTrb1[nI,09])
			oSection2:Cell("NCUSUNIT"	):SetValue(nCusUnit)
			oSection2:Cell("NVLTOT"		):SetValue(aLstTrb1[nI,13])

			If Empty(nCusUStd) .And. !(Substr( Alltrim(aLstTrb1[nI,01]) ,1,3) $ "CIF/GGF/MOI/MOD")
					nCusUStd 		:= BuscCust(aLstTrb1[nI,01],aLstTrb2[nPosTrb2,2])

					aLstTrb1[nI,12] := nCusUStd * aLstTrb1[nI,10]
					aLstTrb1[nI,12]	:= Round(aLstTrb1[nI,12],nTamDecCus)

					nCusUStd		:= Round(nCusUStd,nTamDecCus)
				
				ElseIf (Substr( Alltrim(aLstTrb1[nI,01]) ,1,3) $ "CIF/GGF/MOI/MOD") .And. mv_par02 == 1
					nCusUStd		:= 	nCusUnit
					aLstTrb1[nI,12]	:= aLstTrb1[nI,13]
			EndIf 

			//Adiciona o CM do ultimo fechamento e soma total
			oSection2:Cell("NQTDE2"		):SetValue(aLstTrb1[nI,10])
			oSection2:Cell("NCUSUSTD"	):SetValue(nCusUStd)
			oSection2:Cell("NVLTOT2"	):SetValue(aLstTrb1[nI,12])

			oSection2:Cell("NQTDE3"		):SetValue(nQtdVar)
			oSection2:Cell("NTOTALVAR"	):SetValue(nTotalVar)
			oSection2:Cell("NSVALOR"	):SetValue(nSValor)
			oSection2:Cell("NSQUANT"	):SetValue(nSQuant)
			oSection2:Cell("NPERC"		):SetValue(nPercent)
			
			oSection2:PrintLine()
		EndIf
		//����������������������������������������������������������Ŀ
		//� Aglutinar Produto para Posterior Resumo.                 �
		//������������������������������������������������������������
		nPosTrb3 := aScan(aLstTrb3,{|x|x[1]==aLstTrb1[nI,1]})
		If Empty(nPosTrb3)
			aAdd(aLstTrb3,{	aLstTrb1[nI,01],; //PRODUTO
							aLstTrb1[nI,09],; //QTDREAL
							aLstTrb1[nI,10],; //QTDSTD
							aLstTrb1[nI,13],; //CUSTOREAL
							aLstTrb1[nI,12],; //CUSTOSTD
							SB1->B1_DESC})    //DESCRICAO
		Else
			aLstTrb3[nPosTrb3,02] += aLstTrb1[nI,09] //QTDREAL
			aLstTrb3[nPosTrb3,03] += aLstTrb1[nI,10] //QTDSTD
			aLstTrb3[nPosTrb3,04] += aLstTrb1[nI,13] //CUSTOREAL
			aLstTrb3[nPosTrb3,05] += aLstTrb1[nI,12] //CUSTOSTD
		EndIf
		nCusUnitR  += nCusUnit
		nCusUnitS  += nCusUStd
		nTotRealOP += aLstTrb1[nI,13]
		nTotStdOP  += aLstTrb1[nI,12]
		nTotVarOP  += nTotalVar
		nI++
		If nI > Len(aLstTrb1) .Or. IIf( mv_par01 == 1,aLstTrb1[nI,2],aLstTrb1[nI,7]) # cAnt
			nI--
			Exit
		EndIf
	EndDo
	//����������������������������������������������������������Ŀ
	//� Impressao dos Totais por OP/Produto.                     �
	//������������������������������������������������������������
	If mv_par02 == 1
		oReport:ThinLine() //-- Impressao de Linha Simples
		oSection3:Cell("CTOTAL"			):SetValue(STR0012+IIf(mv_par01==1,STR0013,STR0014)) //"Total "###"da OP:"###"do Produto:"
		oSection3:Cell("NTOTREALOPU"	):SetValue((nTotRealOP/nQuantOp))
		oSection3:Cell("NTOTREALOP"		):SetValue(nTotRealOP)
		oSection3:Cell("NTOTSTDOPU"		):SetValue((nTotStdOP/nQuantOp))
		oSection3:Cell("NTOTSTDOP"		):SetValue(nTotStdOP)
		oSection3:Cell("NTOTVAROP"		):SetValue(nTotRealOP - nTotStdOP)
		oSection3:PrintLine()
		oReport:ThinLine() //-- Impressao de Linha Simples
		oReport:SkipLine() //-- Salta linha
	EndIf
Next
oSection2:SetHeaderSection(.F.)
oSection4:SetHeaderSection(.T.)
oSection1:Finish()
oSection2:Finish()
oSection3:Finish()
//����������������������������������������������������������Ŀ
//� Impressao do Resumo Aglutinado por Produto.              �
//������������������������������������������������������������
oReport:SetTitle(STR0015) //"V A R I A C A O   DE   U S O   E   C O N S U M O"
oReport:SetMeter(Len(aLstTrb1))
oReport:EndPage()
oSection4:Init()
aLstTrb3 := aSort(aLstTrb3,,, { | x,y | x[1] < y[1] })
For nI:=1 To Len(aLstTrb3)
	oReport:IncMeter()
	If oReport:Cancel()
		Exit
	EndIf
	oSection4:Cell("CPROD" 		):SetValue(aLstTrb3[nI,01])
	oSection4:Cell("CDESC" 		):SetValue(aLstTrb3[nI,06])
	oSection4:Cell("NQTDE" 		):SetValue(aLstTrb3[nI,02])
	oSection4:Cell("NVLTOT"		):SetValue(aLstTrb3[nI,04])
	oSection4:Cell("NQTDE2"		):SetValue(aLstTrb3[nI,03])
	oSection4:Cell("NVLTOT2"	):SetValue(aLstTrb3[nI,05])
	oSection4:Cell("NQTDE3"		):SetValue(Round(aLstTrb3[nI,02]-aLstTrb3[nI,03],nTamDecCus))
	oSection4:Cell("NVLTOT3"	):SetValue(Round(aLstTrb3[nI,04]-aLstTrb3[nI,05],nTamDecCus))
	oSection4:Cell("NPERCTOT"	):SetValue( (oSection4:Cell("NQTDE3"):GetValue() / aLstTrb3[nI,03]) * 100  )
	oSection4:PrintLine()
	oReport:ThinLine() //-- Impressao de Linha Simples
Next
oSection4:Finish()
Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R450Cus   � Autor � Erike Yuri da Silva  � Data �14/03/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o Custo.                                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � ExpN1 := R450Cus(ExpC1,ExpN2,ExpN3)                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 := Tipo "S" para Standard e "R" para Real            ���
���          � ExpC1 := Tipo "S" para Standard e "R" para Real            ���
���          � ExpN2 := Indica a Moeda para obtencao do Custo             ���
���          � ExpN3 := Quantidade utilizada.                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR450                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function R450Cus(cTipo,nMoeda,nQtd,cAliasSD3)
Local aAreaAnt  := GetArea()
Local nRet      := 0

Default cAliasSD3 := "SD3"
Default nQtd      := 0

If cTipo = "R" 	// Custo Real
	nRet := (cAliasSD3)->( &("D3_CUSTO"+ Str(nMoeda,1)) ) * IIf(SubStr((cAliasSD3)->D3_CF, 1, 1) == 'R', 1, -1)
Else  // Custo Standard
	dbSelectArea("SB1")
	nRet := (nQtd*xMoeda(RetFldProd(SB1->B1_COD,"B1_CUSTD"),Val(RetFldProd(SB1->B1_COD,"B1_MCUSTD")), nMoeda, RetFldProd(SB1->B1_COD,"B1_DATREF") ))
EndIf

RestArea(aAreaAnt)
Return (nRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R450Fant  � Autor � Cesar Eduardo Valadao� Data � 01.06.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a Estrutura de Produto Fantasma                    ���
���          � Funcao Recursiva.                                          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � R450Fant(ExpN1)                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 := Quantidade do Pai.                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR450                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Static Function R450Fant(nQuantPai)
Local aAreaAnt  := GetArea()
Local aAreaSB1  := SB1->(GetArea())
Local aAreaSG1  := SG1->(GetArea())
Local cComponen := SG1->G1_COMP
Local nPosTrb1  := 0
Local nPosTrb2  := 0

dbSelectArea("SG1")
If dbSeek(xFilial("SG1")+cComponen, .F.)
	While !Eof() .And. G1_FILIAL+G1_COD == xFilial("SG1")+cComponen
		If G1_INI > dDataBase .Or. G1_FIM < dDataBase
			dbSkip()
			Loop
		EndIf
		//��������������������������������������������������������������Ŀ
		//� Gravar Valores da Producao em TRB do componente.             �
		//����������������������������������������������������������������
		dbSelectArea("SB1")
		If MsSeek(xFilial("SB1")+SG1->G1_COMP)
			If SG1->G1_FIXVAR == "F"
				nQuantG1 := SG1->G1_QUANT
			Else
				nQuantG1 := ExplEstr(nQuantPai,SC2->C2_DATPRI,SC2->C2_OPC,SC2->C2_REVISAO)
			EndIf
			If mv_par01 == 1
				nPosTrb1 := aScan(aLstTrb1,{|x| x[2]+x[1]==(cAliasNew)->D3_OP+SG1->G1_COMP})
			Else
				If mv_par10 == 1
					nPosTrb1 := aScan(aLstTrb1,{|x| x[7]+x[1]==SC2->C2_PRODUTO+SG1->G1_COMP})
				Else
					nPosTrb1 := aScan(aLstTrb1,{|x| x[7]+x[1]+x[2]==SC2->C2_PRODUTO+SG1->G1_COMP+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)})
				EndIf
			EndIf

			If RetFldProd(SB1->B1_COD,"B1_FANTASM") == "S" // Projeto Implementeacao de campos MRP e FANTASM no SBZ
				//��������������������������������������������������������������Ŀ
				//� Se Produto for FANTASMA gravar so os componentes.            �
				//����������������������������������������������������������������
				R450Fant(nQuantG1 )
			Else
				If !Empty(nPosTrb1) .And. !Empty(aLstTrb1[nPosTrb1,04])
					aRetSD3 := R450TRT("PR",nPosTrb1)
				Else
					aRetSD3 := {"",0,.F.}
				EndIF

				If Empty(nPosTrb1)
					aAdd(aLstTrb1,Array(14))
					nPosTrb1 := Len(aLstTrb1)
					aLstTrb1[nPosTrb1,01] := SG1->G1_COMP
					aLstTrb1[nPosTrb1,02] := (cAliasNew)->D3_OP
					aLstTrb1[nPosTrb1,09] := 0
					aLstTrb1[nPosTrb1,10] := 0
					aLstTrb1[nPosTrb1,12] := 0
					aLstTrb1[nPosTrb1,13] := 0
					aLstTrb1[nPosTrb1,14] := 0
				EndIf
				aLstTrb1[nPosTrb1,04] := aRetSD3[1]
				aLstTrb1[nPosTrb1,07] := cProduto
				aLstTrb1[nPosTrb1,08] := SG1->G1_FIXVAR
				aLstTrb1[nPosTrb1,10] += Round(nQuantG1,nTamDecQtd)
				aLstTrb1[nPosTrb1,12] += R450Cus("S",mv_par06,Round(nQuantG1,nTamDecCus))

			EndIf
		EndIf
		dbSelectArea("SG1")
		dbSkip()
	End
EndIf
RestArea(aAreaSB1)
RestArea(aAreaSG1)
RestArea(aAreaAnt)
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R450TRT   � Autor � Marcelo Iuspa        � Data � 24.11.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao para tratar duas ou mais requisicoes de um mesmo    ���
���          � componente utilizados dentro da mesma estrutura.           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � R450Fant(ExpC1,ExpN2)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 := Tipo de Movimento 'RE' ou 'PR'                    ���
���          � ExpN1 := Numero da Linha                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR450                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Static Function R450TRT(cTipoMov,nLin)
Local cConteudo := If(Empty(nLin),"",RTrim(aLstTrb1[nLin,4]))
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasSD3 := ""
Local nRegSD3   := 0
Local nPosCorte := 0
Local lReposSD3 := .F.
Local xRetorno

If cTipoMov == "RE"
	// Chamado a partir da leitura das REQUISICOES para compor o REAL
	If !Empty((cAliasNew)->D3_TRT)
		If Empty(cConteudo)
			xRetorno := "   /" + (cAliasNew)->D3_TRT
		Else
			xRetorno := cConteudo+"/" + (cAliasNew)->D3_TRT
		EndIf
	EndIf
Else
	// Chamado a partir da leitura das PRODUCOES para compor o STANDARD
	lReposSD3	:= .F.
	nPosCorte	:= At("/",cConteudo)
	If nPosCorte <> 0
		cTRTCorte	:= SubStr(cConteudo,1,nPosCorte-1)
		cConteudo	:= Substr(cConteudo,nPosCorte+1,Len(cConteudo))
	Else
		cTRTCorte	:= AllTrim(cConteudo)
		cConteudo	:= ""
	EndIf
	nRegSD3	:= SD3->( Recno() )

	cAliasSD3 := GetNextAlias()
	cQuery    := "SELECT SD3.R_E_C_N_O_ SD3RECNO "
	cQuery    +=   "FROM " + RetSqlName("SD3") + " SD3 "
	cQuery    +=  "WHERE SD3.D3_FILIAL  = '"  + xFilial('SD3') 			+ "' "
	cQuery    +=    "AND SD3.D3_EMISSAO = '"  + DTOS(aLstTrb1[nLin,06])+ "' "
	cQuery    +=    "AND SD3.D3_NUMSEQ  = '"  + aLstTrb1[nLin,03] 		+ "' "
	cQuery    +=    "AND SD3.D3_CHAVE   = '"  + aLstTrb1[nLin,05] 		+ "' "
	cQuery    +=    "AND SD3.D3_COD     = '"  + aLstTrb1[nLin,01] 		+ "' "
	cQuery    +=    "AND SD3.D_E_L_E_T_ = ' ' "
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSD3,.F.,.T.)
	Do While !Eof()
		xRetorno := {cConteudo,(cAliasSD3)->SD3RECNO,.T.}
		Exit
		dbSkip()
	EndDo
	(cAliasSD3)->(dbCloseArea())
	RestArea(aAreaAnt)

EndIf

Return (xRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R450Qtd   � Autor � Fernando Joly Siquini� Data �03/05/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna a Quantidade                                       ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � ExpN1 := R450Qtd(ExpC1,ExpN2,ExpN3)                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 := Tipo "R" Qtde Real, "S" Qtde Standard             ���
���          � ExpN2 := Quantidade Standard                               ���
���          � ExpC3 := Alias da tabela SD3                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR450                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function R450Qtd(cTipo,nQuant,cAliasSD3)

Local aAreaAnt   := GetArea()
Local nRet       := 0

Default cAliasSD3:= "SD3"

If cTipo = "R" // Quantidade Real
	nRet := (cAliasSD3)->D3_QUANT*IIf(SubStr((cAliasSD3)->D3_CF, 1, 1)=='R', 1, -1)
Else // Quantidade Standard
	nRet := nQuant
EndIf

RestArea(aAreaAnt)
Return (nRet)

//Abre tela
Static Function Abretela()
Local aArea			:= GetArea()
Local aAreaSM0		:= SM0->(GetArea())	//Bkp SM0
Local nQtd	 		:= 0
Local cCRLF			:= CRLF
Local nBtoOk		:= 0
Local aRet			:= {}
Local nX 			:= 1
Private aFiltros 	:= {}

aAdd(aFiltros,"")

oFont12 := TFont():New('Arial',,-12,,.F.)

Define MsDialog oDlg TITLE "Informa��es adicionais de produtos ou ordens de producao"  From 001,001 to 330,935 Pixel							

oGrpFil := TGroup():New(055,005,040,700,"Informe produtos ou OPs separados por(;)",oDlg,CLR_HBLUE,,.T.)

oSayAtr := tSay():New(052,007,{|| "Prod/OP:"  },oGrpFil,,,,,,.T.,CLR_BLACK,CLR_WHITE,50,9)
oGetAtr := tMultiget():new( 072, 040, {| u | if( pCount() > 0, aFiltros[1]:= u,aFiltros[1]) }, oDlg, 400, 60, , , , , , .T. )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT ENCHOICEBAR( oDlg,{ || nBtoOk := 1, oDlg:End() },{ || nBtoOk := 0, oDlg:End() } )

If nBtoOk == 0
		//MsgAlert("Cancelado pelo usu�rio")
		Return aRet
	Else
		aRet := StrTokArr(aFiltros[1], ";" )
EndIf

If Len(aRet) > 0
	
	For nX := 1 To Len(aRet)
		If mv_par01 == 1 //Filtra por Op
				DbSelectArea("SC2")
				SC2->(DbSetOrder(1))
				SC2->(DbGotop())
				If !SC2->(DbSeek(xFilial("SC2") + aRet[nX]))
					MsgAlert("Esta OP n�o existe na base -> " + Alltrim(aRet[nX]) ,"Kapazi")
				EndIf 

			Else //Produto
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(DbGoTop())
				If !SB1->(DbSeek(xFilial("SB1") + aRet[nX]))
					MsgAlert("Este produto n�o existe na base -> " + Alltrim(aRet[nX]) ,"Kapazi")
				EndIf
		EndIf 
			
	Next
	
EndIf

RestArea(aAreaSM0)
RestArea(aArea)
Return(aRet)


/*/{Protheus.doc} nomeStaticFunction
	Funcao para retornar o �ltimo custo
	@type  Static Function
	@author Luis
	@since 22/01/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function BuscCust(_cProd,_cOp)
Local aArea		:= GetArea()
Local aAreaC2	:= SC2->(GetArea())
Local nRet 		:= 0
Local dMVUlm	:= GetMv("MV_ULMES") //buscar do mes da op
Local cQuery	:= ""
Local cAliasB9	:= GetNextAlias()
Local cAliasB2	:= GetNextAlias()
Local dDtUltMes	
Default _cOp	:= ""

If !Empty(_cOp)
	DbSelectArea("SC2")
	SC2->(DbSetOrder(1))
	SC2->(DbGoTop())
	If SC2->(DbSeek( xFilial("SC2") + _cOp))
		dDtUltMes := LastDay(SC2->C2_EMISSAO,0)

		If dDtUltMes < dMVUlm
			dMVUlm	:= dDtUltMes
		EndIf
	EndIf
EndIf

cQuery	:= " SELECT DISTINCT B9_FILIAL,B9_DATA,B9_COD,B9_CM1 
cQuery	+= " FROM SB9040
cQuery	+= " WHERE D_E_L_E_T_ = ''
cQuery	+= " AND B9_FILIAL = '"+xFilial("SC2")+"'
cQuery	+= " AND B9_DATA = '"+ DTOS(dMVUlm) +"'
cQuery	+= " AND B9_COD = '"+ _cProd +"'
cQuery	+= " AND B9_CM1 > 0
cQuery	+= " ORDER BY B9_DATA DESC

TCQuery cQuery New Alias (cAliasB9) 

DbSelectArea((cAliasB9))
(cAliasB9)->(DbGotop()) 

If !(cAliasB9)->(EOF())
	nRet :=	(cAliasB9)->B9_CM1 //Round( (cAliasB9)->B9_CM1 ,2)
EndIf

If Empty(nRet)

	(cAliasB9)->(DbCloseArea())

	cQuery	:= " SELECT
	cQuery	+= " (SELECT SUM(B2_CM1) AS SOMA FROM SB2040 WHERE D_E_L_E_T_ = '' AND B2_FILIAL >= '01' AND B2_FILIAL <= '01' AND B2_COD = SB2.B2_COD  AND B2_CM1 > 0 ) AS VLTOT,  
	cQuery	+= " (SELECT COUNT(*) AS QTD FROM SB2040 WHERE D_E_L_E_T_ = '' AND B2_FILIAL >= '01' AND B2_FILIAL <= '01' AND B2_COD = SB2.B2_COD  AND B2_CM1 > 0 ) AS QTDTOT, 
	cQuery	+= " (SELECT SUM(B2_VATU1) AS SOMA FROM SB2040 WHERE D_E_L_E_T_ = '' AND B2_FILIAL >= '01' AND B2_FILIAL <= '01' AND B2_COD = SB2.B2_COD  AND B2_VATU1 > 0 AND B2_QATU > 0) AS VLMOD,  
	cQuery	+= " (SELECT SUM(B2_QATU) AS QTD FROM SB2040 WHERE D_E_L_E_T_ = '' AND B2_FILIAL >= '01' AND B2_FILIAL <= '01' AND B2_COD = SB2.B2_COD  AND B2_VATU1 > 0 AND B2_QATU > 0 ) AS QTDMOD,
	cQuery	+= " *	"
	cQuery	+= " FROM "+ RetSqlName("SB2")+" SB2  "
	cQuery	+= " WHERE SB2.D_E_L_E_T_ = '' "
	cQuery	+= " AND B2_FILIAL = '"+xFilial("SC2")+"'"
	cQuery	+= " AND B2_COD = '"+ _cProd +"'"
	cQuery	+= " AND B2_CM1 > 0 "

	/*
	If Substr(_cProd,1,3) != "MOD"
			cQuery	+= " AND B2_CM1 > 0 "
		Else
			cQuery	+= " AND ( B2_VATU1 > 0 AND B2_QATU > 0 ) "	
	EndIf
	*/
	TCQuery cQuery New Alias (cAliasB9) 

	DbSelectArea((cAliasB9))
	(cAliasB9)->(DbGotop()) 
	
	If !(cAliasB9)->(EOF())
		nRet := ( (cAliasB9)->VLTOT / (cAliasB9)->QTDTOT )
		/*
		If Substr(_cProd,1,3) != "MOD" 
				nRet := ( (cAliasB9)->VLTOT / (cAliasB9)->QTDTOT )//Round( ((cAliasB9)->VLTOT / (cAliasB9)->QTDTOT) ,2)
			Else 
				nRet := ( (cAliasB9)->VLMOD / (cAliasB9)->QTDMOD )
		EndIf
		*/
	EndIf

EndIf

(cAliasB9)->(DbCloseArea())

RestArea(aAreaC2)
RestArea(aArea)
Return(nRet)
