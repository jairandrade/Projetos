#INCLUDE "MATR600.CH" 
#INCLUDE "FIVEWIN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MATR600  ³ Autor ³ Marco Bianchi         ³ Data ³ 27/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao de Pedidos de Vendas por Vendedor/Cliente          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFAT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
user Function UMATR600()

	Local oReport
	
	If FindFunction("TRepInUse") .And. TRepInUse()
		//-- Interface de impressao
		oReport := ReportDef()
		oReport:PrintDialog()
	Else
		MATR600R3()
	EndIf

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Marco Bianchi         ³ Data ³27/06/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

	Local oReport
	Local oVendedor
	Local oPedVC
	Local oTotGer
	Local cNome 	:= ""
	Local cMun		:= ""
	Local nTotPed1	:= 0
	Local nTotGer	:= 0
	
	
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
	oReport := TReport():New("MATR600",STR0015,"MTR600", {|oReport| ReportPrint(oReport,oPedVC,oVendedor,oTotGer)},STR0016 + " " + STR0017)	// "Pedidos Por Vendedor/Cliente"###"Este relatorio ira emitir a relacao de Pedidos por"###"ordem de Vendedor/Cliente."
	oReport:SetPortrait() 
	oReport:SetTotalInLine(.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas  		                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AjustaSX1()
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
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao da celulas da secao do relatorio                                ³
	//³                                                                        ³
	//³TRCell():New                                                            ³
	//³ExpO1 : Objeto TSection que a secao pertence                            ³
	//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
	//³ExpC3 : Nome da tabela de referencia da celula                          ³
	//³ExpC4 : Titulo da celula                                                ³
	//³        Default : X3Titulo()                                            ³
	//³ExpC5 : Picture                                                         ³
	//³        Default : X3_PICTURE                                            ³
	//³ExpC6 : Tamanho                                                         ³
	//³        Default : X3_TAMANHO                                            ³
	//³ExpL7 : Informe se o tamanho esta em pixel                              ³
	//³        Default : False                                                 ³
	//³ExpB8 : Bloco de código para impressao.                                 ³
	//³        Default : ExpC2                                                 ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oVendedor := TRSection():New(oReport,STR0024,{"TRB","SA3"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Pedidos Por Vendedor/Cliente"
	oVendedor:SetTotalInLine(.F.)
	TRCell():New(oVendedor,"VENDEDOR"	,"TRB",STR0028,PesqPict("SA3","A3_COD")	,TamSx3("A3_COD"	)[1],/*lPixel*/,/*{|| code-block de impressao }*/	)	// Codigo do Vendedor
	TRCell():New(oVendedor,"A3_NOME"		,		,RetTitle("A3_NOME")	,PesqPict("SA3","A3_NOME")	,TamSx3("A3_NOME"	)[1],/*lPixel*/,{|| SA3->A3_NOME }						)	// Nome do Vendedor
	
	oPedVC := TRSection():New(oVendedor,STR0025,{"TRB"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Pedidos Por Vendedor/Cliente"
	oPedVC:SetTotalInLine(.F.)
	TRCell():New(oPedVC,"CLIENTE"	,"TRB",STR0029	,PesqPict("SA1","A1_COD")	,TamSx3("A1_COD"		)[1],/*lPixel*/,/*{|| code-block de impressao }*/	)	// Codigo do Cliente
	TRCell():New(oPedVC,"CNOME"		,		,RetTitle("A1_NOME")	,PesqPict("SA1","A1_NOME")	,TamSx3("A1_NOME"		)[1],/*lPixel*/,{|| cNome }								)	// Razao Social do Cliente
	TRCell():New(oPedVC,"CMUN"		,		,RetTitle("A1_MUN")	,PesqPict("SA1","A1_MUN")	,TamSx3("A1_MUN"		)[1],/*lPixel*/,{|| cMun }									)	// Municipio do Cliente
	TRCell():New(oPedVC,"NUMPED"	,"TRB",RetTitle("C5_NUM")	,PesqPict("SC5","C5_NUM")	,TamSx3("C5_NUM"		)[1],/*lPixel*/,/*{|| code-block de impressao }*/	)	// Numero do Pedido de Venda
	TRCell():New(oPedVC,"NTOTPED1"	,		,STR0019					,TM(nTotPed1,18,2),TamSx3("C6_VALOR"	)[1],/*lPixel*/,{|| nTotPed1 },,,"RIGHT")	// "Total"
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Esta Secao serve apenas para receber as Querys que irao gerar o arquivo³
	//³ temporario para impressao 							                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTemp := TRSection():New(oReport,STR0026,{"SC5","SA1"},,/*Campos do SX3*/,/*Campos do SIX*/)		// "Pedidos Por Vendedor/Cliente"
	oTemp:SetTotalInLine(.F.)
	
	oTemp1 := TRSection():New(oReport,STR0027,{"SC6"},,/*Campos do SX3*/,/*Campos do SIX*/)		// "Pedidos Por Vendedor/Cliente"
	oTemp1:SetTotalInLine(.F.)
	
	
	// Secao Total Geral
	oTotGer := TRSection():New(oReport,"",,/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)	// "Pedidos Por Vendedor/Cliente"
	oTotGer:SetTotalInLine(.F.)
	                            
	TRCell():New(oTotGer,""	,,STR0030	,PesqPict("SA1","A1_COD")	,TamSx3("A1_COD"		)[1],/*lPixel*/,/*{|| code-block de impressao }*/	)	// Codigo do Cliente
	TRCell():New(oTotGer,""	,," ",PesqPict("SA1","A1_NOME")	,TamSx3("A1_NOME"		)[1],/*lPixel*/,/*{|| code-block de impressao }*/								)	// Razao Social do Cliente
	TRCell():New(oTotGer,""	,," ",PesqPict("SA1","A1_MUN")	,TamSx3("A1_MUN"		)[1],/*lPixel*/,/*{|| code-block de impressao }*/									)	// Municipio do Cliente
	TRCell():New(oTotGer,""	,," ",PesqPict("SC5","C5_NUM")	,TamSx3("C5_NUM"		)[1],/*lPixel*/,/*{|| code-block de impressao }*/	)	// Numero do Pedido de Venda
	TRCell():New(oTotGer,"NTOTGER"	,," "					,TM(nTotGer,18,2),/*TamSx3("C6_VALOR"	)[1]*/,/*lPixel*/,{|| nTotGer },,,"RIGHT")	// "Total"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do Cabecalho no topo da pagina                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):Section(1):SetHeaderPage()
	oReport:Section(1):SetTotalText(STR0022) 
	
	oReport:Section(2):SetEditCell(.F.)
	oReport:Section(3):SetEditCell(.F.)
	
	oReport:Section(1):Section(1):SetEdit(.F.)
	oReport:Section(4):SetEdit(.F.)

Return(oReport)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Marco Bianchi          ³ Data ³27/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,oPedVC,oVendedor,oTotGer)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao das Variaveis                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cCli,cVend,nTotPed1,cLoja
	Local aCampos 	:= {}
	Local aTam		:= {}
	Local cExt		:= ""
	Local cVendCh	:= ""
	Local j, Suf
	Local nTotSC6 	:= 0 
	Local cEstoq 	:= If( (mv_par13 == 1),"S",If( (mv_par13 == 2),"N","SN" ) )
	Local cDupli 	:= If( (mv_par14 == 1),"S",If( (mv_par14 == 2),"N","SN" ) )
	
	Local cFilSA3 := ""
	#IFNDEF TOP
		Local cFilSA1 := ""
		Local cFilSC5 := ""
		Local cFilSC6 := ""
	#ENDIF	
	Local aPedido	:= {}
	Local nCont		:= 0
	Local nPos		:= 0
	Local nTotGer   := 0
	                                                                  
	TRPosition():New(oReport:Section(1),"SA3",1,{|| xFilial("SA3")+TRB->VENDEDOR })
	TRPosition():New(oReport:Section(1):Section(1),"SA1",1,{|| xFilial("SA1")+TRB->CLIENTE+TRB->LOJA })
	
	If mv_par15 ==  1
		TRFunction():New(oPedVC:Cell("NTOTPED1"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,TM(nTotPed1,18,2),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		oReport:Section(1):Section(1):SetTotalText(STR0021)
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetBlock: faz com que as variaveis locais possam ser         ³
	//³ utilizadas em outras funcoes nao precisando declara-las      ³
	//³ como private											  	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):Section(1):Cell("CNOME" 	):SetBlock({|| cNome	})
	oReport:Section(1):Section(1):Cell("CMUN" 		):SetBlock({|| cMun		})
	oReport:Section(1):Section(1):Cell("NTOTPED1" 	):SetBlock({|| nTotPed1	})
	oReport:Section(4):Cell("NTOTGER" 	):SetBlock({|| nTotGer	})
	cNome 	:= ""
	cMun	:= ""
	nTotPed1:= 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define array para arquivo de trabalho                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTam:=TamSX3("C5_VEND1")
	AADD(aCampos,{ "VENDEDOR","C",aTam[1],aTam[2] } )
	aTam:=TamSX3("C6_NUM")
	AADD(aCampos,{ "NUMPED"  ,"C",aTam[1],aTam[2] } )
	aTam:=TamSX3("C5_CLIENTE")
	AADD(aCampos,{ "CLIENTE" ,"C",aTam[1],aTam[2] } )
	aTam:=TamSX3("C5_EMISSAO")
	AADD(aCampos,{ "EMISSAO" ,"D",aTam[1],aTam[2] } )
	aTam:=TamSX3("C5_LOJACLI")
	AADD(aCampos,{ "LOJA"    ,"C",aTam[1],aTam[2] } )
	AADD(aCampos,{ "MOEDA"   ,"N",1,0 } )
	aTam:=TamSX3("F1_VALBRUT")
	AADD(aCampos,{ "TOTPED"    ,"N",aTam[1],aTam[2] } )
	aTam:=TamSX3("A1_NOME")
	AADD(aCampos,{ "CLINOME"   ,"C",aTam[1],aTam[2] } )
	aTam:=TamSX3("A1_MUN")
	AADD(aCampos,{ "CLIMUN"   ,"C",aTam[1],aTam[2] } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pula pagina na quebra por vendedor                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par07 == 1
		oReport:Section(1):SetPageBreak(.T.)
	EndIf	
	TRFunction():New(oPedVC:Cell("NTOTPED1"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,TM(nTotPed1,18,2),/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oVendedor)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo de Trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNomArq := CriaTrab(aCampos)
	Use &cNomArq	Alias TRB   NEW
	// IndRegua("TRB",cNomArq,"VENDEDOR+CLIENTE+NUMPED",,,STR0018)		// "Selecionando Registros..."
	IndRegua("TRB",cNomArq,"VENDEDOR+NUMPED+CLIENTE",,,STR0018)		// "Selecionando Registros..."
	          
	If len(oReport:Section(1):GetAdvplExp("SA3")) > 0
		cFilSA3 := oReport:Section(1):GetAdvplExp("SA3")
	EndIf
	
	
	#IFDEF TOP
		If ( TcSrvType()<>"AS/400" )
			GTrabTopR4(oReport)
		Else
	#ENDIF
	
		If len(oReport:Section(2):GetAdvplExp("SA1")) > 0
			cFilSA1 := oReport:Section(2):GetAdvplExp("SA1")
		EndIf
		If len(oReport:Section(2):GetAdvplExp("SC5")) > 0
			cFilSC5 := oReport:Section(2):GetAdvplExp("SC5")
		EndIf
		If len(oReport:Section(3):GetAdvplExp("SC6")) > 0
			cFilSC6 := oReport:Section(3):GetAdvplExp("SC6")
		EndIf
	
		dbSelectArea("SC5")		// Cabecalho do Pedido de Vendas
		dbSetOrder(2)			// Filial,Emissao,Numero do Pedido
		dbSeek(xFilial()+DTOS(mv_par01),.T.)
		
		oReport:SetMeter(RecCount())		// Total de Elementos da regua
		While !Eof() .And. C5_EMISSAO >= mv_par01 .And. C5_EMISSAO <= mv_par02 .and. C5_FILIAL == xFilial()
	
	      // Verifica filtro do usuario
			If !Empty(cFilSC5) .And. !(&cFilSC5)
				dbSelectArea("SC5")
				dbSkip()
				Loop
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se esta no mesmo pedido para pegar somente os itens ³
			//³ que esteja de acordo com a pergunta de considera residuo e se³
			//³ o conteudo do campo C6_BLQ = "R ".                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC6")		// Itens do Pedido de Vendas
			dbSetOrder(1)			// Filial,Pedido,Item,Produto
			dbSeek(xFilial()+SC5->C5_NUM)
		
			While !Eof() .And. C6_FILIAL == xFilial("SC6") .And. C6_NUM == SC5->C5_NUM
			
				If MV_PAR09 == 2 .And. C6_BLQ == "R "
					dbSkip()
					Loop
				EndIf				 	
			
				SF4->( dbSetOrder( 1 ) )		// Cadastro de Tes: Filial,Codigo Tes 
				SF4->( MsSeek( xFilial( "SF4" ) + SC6->C6_TES ) ) 
				If !AvalTes(SC6->C6_TES,cEstoq,cDupli)
					dbSkip()
					Loop
				Endif
			
				// Nao considera pedidos do tipo "D" ou "B"
				If AT(SC5->C5_TIPO,"DB") != 0
					dbSelectArea("SC6")
					dbSkip()
					Loop
				EndIf           
				
		      // Verifica filtro do usuario
				If !Empty(cFilSC6) .And. !(&cFilSC6)
					dbSelectArea("SC6")
					dbSkip()
					Loop
				EndIf
				
				oReport:IncMeter()		// Icrementa regua
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se Vendedor devera ser impresso                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For j:=1 TO 5
					suf := "C5_VEND"+Str(j,1)
					dbSelectArea("SC5")
					IF Empty(&suf)
						Exit
					EndIF
					cVendCh := &suf
					dbSelectArea("SA3")
					If (dbSeek(cFilial+cVendCH))
						dbSelectArea("SC5")
						IF &suf >= mv_par03 .And. &suf <= mv_par04
							If TRB->(!dbSeek(cVendCh+SC5->C5_CLIENTE+SC5->C5_NUM))
								GravTrabR4(j)
							EndIf
						EndIF
					Endif
				Next j
			
				dbSelectArea("SC6")
				dbSkip()
			
			EndDo
			dbSelectArea("SC5")
			dbSkip()
		EndDO
	#IFDEF TOP
		EndIf	
	#ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do Relatorio                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("TRB")
	dbGoTop()
	oReport:Section(1):Init()
	oReport:SetMeter(RecCount())		// Total de Elementos da regua
	While !Eof() 
	
		// Verifica filtro do usuario
		dbSelectArea("SA3")
		SA3->(dbSetOrder(1))
		SA3->(dbSeek( xFilial("SA3") + TRB->VENDEDOR ))
		dbSelectArea("SA3")
		If !Empty(cFilSA3) .And. !(&cFilSA3)
			dbSelectArea("TRB")
			dbSkip()
			Loop
		EndIf
	
		#IFNDEF TOP
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1))
			SA1->(dbSeek( xFilial("SA1") + TRB->CLIENTE+TRB->LOJA ))
			If !Empty(cFilSA1) .And. !(&cFilSA1)
				dbSelectArea("TRB")
				dbSkip()
				Loop
			EndIf
		#ENDIF		
		
		dbSelectArea("TRB")
		cVend := TRB->VENDEDOR
		oReport:Section(1):PrintLine()
		
		dbSelectArea("TRB")   
		While !Eof() .And.  TRB->VENDEDOR == cVend
			
			#IFDEF TOP
				If ( TcSrvType()<>"AS/400" )
				Else
			#ENDIF
				IF TRB->CLIENTE < mv_par05 .Or. TRB->CLIENTE > mv_par06 .Or. TRB->LOJA < mv_par10 .Or. TRB->LOJA > mv_par11
					dbSkip()
					Loop
				EndIF
			#IFDEF TOP
				EndIf
			#ENDIF		
			
			cCli 		:= TRB->CLIENTE
			cLoja		:= TRB->LOJA   
			oReport:Section(1):Section(1):Init()
			While !Eof() .And. TRB->VENDEDOR == cVend .And. TRB->CLIENTE == cCli .And. TRB->LOJA == cLoja
				
				oReport:IncMeter()
				#IFDEF TOP
					If ( TcSrvType()<>"AS/400" )
						nTotPed1:=xMoeda( TRB->TOTPED, TRB->MOEDA, mv_par08, TRB->EMISSAO )
					Else
				#ENDIF
					dbSelectArea("SC6")
					dbSeek( xFilial()+TRB->NUMPED )
					nTotPed1 := 0
				
					While !Eof() .And. TRB->NUMPED == SC6->C6_NUM
						IF MV_PAR09 == 2 .And. C6_BLQ == "R "
							dbSkip()
						Else
					 		SF4->( dbSetOrder( 1 ) ) 
						 	SF4->( MsSeek( xFilial( "SF4" ) + SC6->C6_TES ) ) 
					 	
							If AvalTes(SC6->C6_TES,cEstoq,cDupli)
								If cPaisLoc=="BRA"
								 	nTotSC6 := If( SF4->F4_AGREG == "N" .And. MV_PAR12 == 1, 0, C6_VALOR )
									nTotPed1 += xMoeda( nTotSC6,TRB->MOEDA,mv_par08,TRB->EMISSAO)
								Else
									nTotPed1 += xMoeda( C6_VALOR ,TRB->MOEDA,mv_par08,TRB->EMISSAO)
								Endif
							Endif
							dbSkip()
						EndIf
					Enddo			
				#IFDEF TOP
					EndIf
				#ENDIF            
	
	         	DbSelectArea("TRB")
				#IFDEF TOP
					If ( TcSrvType()<>"AS/400" )
						cNome := TRB->CLINOME
						cMun  := TRB->CLIMUN
					Else
				#ENDIF
					SA1->(dbSetOrder(1))
					SA1->(dbSeek( xFilial("SA1") + TRB->CLIENTE+TRB->LOJA ))
					cNome := SA1->A1_NOME
					cMun  := SA1->A1_MUN
				#IFDEF TOP
					EndIf
				#ENDIF  
				
				oReport:Section(1):Section(1):PrintLine()			
				
				If mv_par16 == 2
					nPos := AScan(aPedido,{|x| x[1]+x[2]+x[3] == cCli+cLoja+TRB->NUMPED})
					If nPos == 0
						AADD(aPedido,{cCli,cLoja,TRB->NUMPED})
						nTotGer += nTotPed1
					EndIf	
				Else	
					nTotGer += nTotPed1			
				EndIf		
				
	
				
				dbSkip()
				
			EndDo
	
			// Total por Cliente
			IF (mv_par15 == 1 .And. TRB->CLIENTE+TRB->LOJA <> cCli+cLoja) .Or. (mv_par15 == 1 .And. TRB->VENDEDOR <> cVend)
				oReport:Section(1):Section(1):SetTotalText(STR0021 + cCli+cLoja)
				oReport:Section(1):Section(1):Finish()
				oReport:Section(1):Section(1):Init()
			EndIF
	
			dbSelectArea("TRB")
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime totalizador                									   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:Section(1):SetTotalText(STR0022 + cVend)
		oReport:section(1):Finish()
		oReport:section(1):Init()
		
		dbSelectArea("TRB")
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime Total geral                									   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par07 == 2
		oReport:section(4):Init()
		oReport:section(4):Printline()
		oReport:section(4):Finish()
	EndIf	
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura Areas                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("TRB")
	cExt := OrdBagExt()
	dbCloseArea()
	If File(cNomArq+GetDBExtension())
		FERASE(cNomArq+GetDBExtension())		//arquivo de trabalho
	Endif
	
	If File(cNomArq + cExt)
		FERASE(cNomArq+cExt)					//indice gerado
	Endif
	
	dbSelectArea("SC5")
	dbSetOrder(1)
	
	dbSelectArea("SA3")
	dbClearFilter()
	dbSetOrder(1)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravTrabR4³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Arquivo de Trabalho                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nEl - Ordem do Vendedor                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR600                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FuncTion GravTrabR4(nEl)

	Local suf := "SC5->C5_VEND" + Str(nEl,1)
	
	RecLock("TRB",.t.)
	Replace VENDEDOR With &suf
	Replace NUMPED   With SC5->C5_NUM
	Replace CLIENTE  With SC5->C5_CLIENTE
	Replace EMISSAO  With SC5->C5_EMISSAO
	Replace LOJA     With SC5->C5_LOJACLI
	Replace MOEDA    With SC5->C5_MOEDA
	MsUnlock()
	dbSelectArea("SC5")

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GTrabTopR4³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Arquivo de Trabalho                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nEl - Ordem do Vendedor                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR600                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GTrabTopR4(oReport)

	Local aArea		:= GetArea()
	Local nJ      	:= 0
	Local cSC5Tmp 	:= GetNextAlias()
	Local cSC5Tmp2	:= GetNextAlias()
	Local cCampos  	:= ""
	Local cQuery2 	:= ""
	Local cVendCh 	:= ""
	Local cSuf    	:= ""
	Local nVend	  	:= Fa440CntVen()
	Local cVend   	:= ""
	Local cWhere   	:= ""
	Local cWhere2  	:= ""
	Local cPedTemp 	:= ""
	Local aVend   	:= {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr(oReport:uParam)
	
	cSuf:="0"
	cWhere := "%("
	For nJ:=1 to nVend
		cSuf := Soma1(cSuf)
		cVend := "C5_VEND"+cSuf
		If SC5->(FieldPos(cVend))>0
			Aadd(aVend,cVend)
			cCampos+=cVend+","
			If Len(cWhere) > 2
				cWhere+="or "
			Endif
			cWhere+="("+cVend+"<>'' and "+cVend+">='"+mv_par03+"' and "+cVend+"<='"+mv_par04+"') "
		Endif
	Next
	cWhere += ")%"
	
	cCampos := "%,"
	For nJ := 1 To SC5->(FCount())
		If nJ > 1
			cCampos += ", "
		EndIf		
		cCampos += SC5->(FieldName(nJ))
	Next
	cCampos += "%"
	
	cWhere2 := "% AND"      
	If cPaisLoc=="BRA"
		If MV_PAR12==1
			cWhere2 += " SF4.F4_AGREG <> 'N' AND "
		Endif
	Endif
	If mv_par13==1
		cWhere2 += " SF4.F4_ESTOQUE = 'S' AND "
	ElseIf mv_par13==2
		cWhere2 += " SF4.F4_ESTOQUE = 'N' AND "
	EndIf
	If mv_par14==1
		cWhere2 += " SF4.F4_DUPLIC = 'S' AND "
	ElseIf mv_par14==2
		cWhere2 += " SF4.F4_DUPLIC = 'N' AND "
	EndIf
	If MV_PAR09==2
		cWhere2 += " SC6.C6_BLQ <> 'R ' AND "
	Endif
	cWhere2 += "%"   
	
	
	If TcSrvType() != "AS/400"
	
		oReport:Section(2):BeginQuery()	
		BeginSql Alias cSC5Tmp
	
		SELECT A1_NOME,A1_MUN %Exp:cCampos%
		FROM %Table:SC5% SC5, %Table:SA1% SA1
		WHERE SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.%notdel%
			AND SC5.C5_CLIENTE >= %Exp:MV_PAR05%  AND SC5.C5_CLIENTE <= %Exp:MV_PAR06%
			AND SC5.C5_LOJACLI >= %Exp:MV_PAR10% AND SC5.C5_LOJACLI <= %Exp:MV_PAR11%
			AND SC5.C5_EMISSAO >= %Exp:Dtos(MV_PAR01)% AND SC5.C5_EMISSAO <= %Exp:Dtos(MV_PAR02)%
			AND SC5.C5_TIPO NOT IN ('D','B')
			AND %Exp:cWhere%
			AND SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SC5.C5_CLIENTE
			AND SA1.A1_LOJA = SC5.C5_LOJACLI
			AND SA1.%notdel%
			AND
			(SELECT SUM(C6_VALOR) 
			FROM %Table:SC6% SC6, %Table:SF4% SF4
			WHERE SC6.C6_FILIAL = %xFilial:SC6%
				AND SC6.C6_NUM = SC5.C5_NUM
				AND SF4.F4_FILIAL = %xFilial:SF4%
				AND SF4.F4_CODIGO = SC6.C6_TES
				%Exp:cWhere2%
				SC6.%notdel%
				AND SF4.%notdel%) > 0
		EndSql 
		oReport:Section(2):EndQuery(/*Array com os parametros do tipo Range*/)	
	
	Else
	    
		oReport:Section(2):BeginQuery()	
		BeginSql Alias cSC5Tmp
	
		SELECT A1_NOME,A1_MUN %Exp:cCampos%
		FROM %Table:SC5% SC5, %Table:SA1% SA1
		WHERE SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.%notdel%
			AND SC5.C5_CLIENTE >= %Exp:MV_PAR05%  AND SC5.C5_CLIENTE <= %Exp:MV_PAR06%
			AND SC5.C5_LOJACLI >= %Exp:MV_PAR10% AND SC5.C5_LOJACLI <= %Exp:MV_PAR11%
			AND SC5.C5_EMISSAO >= %Exp:Dtos(MV_PAR01)% AND SC5.C5_EMISSAO <= %Exp:Dtos(MV_PAR02)%
			AND SC5.C5_TIPO NOT IN ('D','B')
			AND %Exp:cWhere%
			AND SA1.A1_FILIAL = %xFilial:SA1%
			AND SA1.A1_COD = SC5.C5_CLIENTE
			AND SA1.A1_LOJA = SC5.C5_LOJACLI
			AND SA1.%notdel%
			AND
			0 < (SELECT SUM(C6_VALOR)
				FROM %Table:SC6% SC6, %Table:SF4% SF4
				WHERE SC6.C6_FILIAL = %xFilial:SC6%
					AND SC6.C6_NUM = SC5.C5_NUM
					AND SF4.F4_FILIAL = %xFilial:SF4%
					AND SF4.F4_CODIGO = SC6.C6_TES
					%Exp:cWhere2%
					AND SC6.%notdel%
					AND SF4.%notdel%)
		EndSql 
		oReport:Section(2):EndQuery(/*Array com os parametros do tipo Range*/)
					
	EndIf
	
	
	oReport:SetMeter(SC6->(LastRec()))
	DbSelectArea(cSC5Tmp)
	While (cSC5Tmp)->(!Eof())
		
		cPedTemp := (cSC5Tmp)->C5_NUM
		oReport:Section(3):BeginQuery()	
		BeginSql Alias cSC5Tmp2
		SELECT SUM(C6_VALOR) nTotPed
		FROM %Table:SC6% SC6, %Table:SF4% SF4
		WHERE SC6.C6_FILIAL = %xFilial:SC6%
			AND SC6.C6_NUM = %Exp:cPedTemp%
			AND SF4.F4_FILIAL = %xFilial:SF4%
			AND SF4.F4_CODIGO = SC6.C6_TES
			%Exp:cWhere2%
			SC6.%notdel%
			AND SF4.%notdel%
		EndSql 
		oReport:Section(3):EndQuery(/*Array com os parametros do tipo Range*/)	
		
	
		If (cSC5Tmp2)->nTotPed > 0
			For nJ:=1 to nVend
				cVend := aVend[nJ]
				cVendCh := (cSC5Tmp)->&cVend
				
				If !Empty(cVendCH) .And. cVendCh >= mv_par03 .And. cVendCh <= mv_par04
					RecLock("TRB",.t.)
					Replace TRB->VENDEDOR With cVendCH
					Replace TRB->NUMPED   With (cSC5Tmp)->C5_NUM
					Replace TRB->CLIENTE  With (cSC5Tmp)->C5_CLIENTE
					Replace TRB->EMISSAO  With (cSC5Tmp)->C5_EMISSAO
					Replace TRB->LOJA     With (cSC5Tmp)->C5_LOJACLI
					Replace TRB->MOEDA    With (cSC5Tmp)->C5_MOEDA
					Replace TRB->TOTPED   With (cSC5Tmp2)->nTotPed
					Replace TRB->CLINOME  With (cSC5Tmp)->A1_NOME
					Replace TRB->CLIMUN   With (cSC5Tmp)->A1_MUN
					TRB->(MsUnlock())
				Endif
			Next
		EndIf
		DbSelectArea(cSC5Tmp2)
		dbCloseArea()
		DbSelectArea(cSC5Tmp)
		oReport:IncMeter()
		(cSC5Tmp)->(DbSkip())
	Enddo
	
	DbSelectArea(cSC5Tmp)
	DbCloseArea()
	
	RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR600  ³ Autor ³ Wagner Xavier         ³ Data ³ 14.04.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao de Pedidos de Vendas por Vendedor/Cliente          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function Matr600R3()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL CbTxt
	LOCAL titulo := OemToAnsi(STR0001)	//"Pedidos Por Vendedor/Cliente"
	LOCAL cDesc1 := OemToAnsi(STR0002)	//"Este relatorio ira emitir a relacao de Pedidos por"
	LOCAL cDesc2 := OemToAnsi(STR0003)	//"ordem de Vendedor/Cliente."
	LOCAL cDesc3 := ""
	LOCAL CbCont,cabec1,cabec2,wnrel
	LOCAL tamanho:="P"
	LOCAL limite := 80
	LOCAL cString:="SC5"
	LOCAL lContinua := .T.
	LOCAL nTotCli1,nTotVend1,nTotGer1,nContCli
	LOCAL cCli,cVend,nTotPed1,cLoja
	LOCAL aCampos := {},cVencCh
	LOCAL aTam    := {}
	
	PRIVATE aReturn := { STR0004, 1,STR0005, 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
	PRIVATE nomeprog:="MATR600"
	PRIVATE aLinha  := { },nLastKey := 0
	PRIVATE cPerg   :="MTR600"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AjustaSX1()
	pergunte("MTR600",.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01        	// A partir da data                      ³
	//³ mv_par02        	// Ate a data                            ³
	//³ mv_par03        	// Vendedor de                           ³
	//³ mv_par04 	     	// Vendedor ate                          ³
	//³ mv_par05	     	// Cliente de                            ³
	//³ mv_par06        	// Cliente ate                           ³
	//³ mv_par07        	// Salta pagina entre vendedores(Sim/Nao)³
	//³ mv_par08        	// Qual Moeda                            ³
	//³ mv_par09        	// Considera residuo                     ³
	//³ mv_par10	     	// Loja Cliente de                       ³
	//³ mv_par11        	// Loja Cliente ate                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:="MATR600"            //Nome Default do relatorio em Disco
	
	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)
	
	If  nLastKey==27
		dbClearFilter()
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey==27
		dbClearFilter()
		Return
	Endif
	
	RptStatus({|lEnd| C600Imp(@lEnd,wnRel,cString)},Titulo)
	
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C600IMP  ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR600			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C600Imp(lEnd,WnRel,cString)

	LOCAL CbTxt
	LOCAL titulo := OemToAnsi(STR0001)		//"Pedidos Por Vendedor/Cliente"
	LOCAL CbCont,cabec1,cabec2
	LOCAL tamanho:="P"
	LOCAL lContinua := .T.
	LOCAL nTotCli1,nTotVend1,nTotGer1,nContCli
	LOCAL cCli,cVend,nTotPed1,cLoja
	LOCAL aCampos := {}
	LOCAL aTam:={}, aTamSXG, aCoord, aTam2
	Local cExt
	LOCAL cVendCh
	LOCAL j, Suf
	LOCAL nTotSC6 := 0 
	LOCAL cEstoq := If( (mv_par13 == 1),"S",If( (mv_par13 == 2),"N","SN" ) )
	LOCAL cDupli := If( (mv_par14 == 1),"S",If( (mv_par14 == 2),"N","SN" ) )
	LOCAL nTotGerAux := 0
	LOCAL aPedido := {}
	LOCAL nPos    := 0	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cbtxt    := SPACE(10)
	cbcont   := 0
	li       :=80
	m_pag    :=1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define array para arquivo de trabalho                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTam:=TamSX3("C5_VEND1")
	AADD(aCampos,{ "VENDEDOR","C",aTam[1],aTam[2] } )
	aTam:=TamSX3("C6_NUM")
	AADD(aCampos,{ "NUMPED"  ,"C",aTam[1],aTam[2] } )
	aTam:=TamSX3("C5_CLIENTE")
	AADD(aCampos,{ "CLIENTE" ,"C",aTam[1],aTam[2] } )
	aTam:=TamSX3("C5_EMISSAO")
	AADD(aCampos,{ "EMISSAO" ,"D",aTam[1],aTam[2] } )
	aTam:=TamSX3("C5_LOJACLI")
	AADD(aCampos,{ "LOJA"    ,"C",aTam[1],aTam[2] } )
	AADD(aCampos,{ "MOEDA"   ,"N",1,0 } )
	aTam:=TamSX3("F1_VALBRUT")
	AADD(aCampos,{ "TOTPED"    ,"N",aTam[1],aTam[2] } )
	aTam:=TamSX3("A1_NOME")
	AADD(aCampos,{ "CLINOME"   ,"C",aTam[1],aTam[2] } )
	aTam:=TamSX3("A1_MUN")
	AADD(aCampos,{ "CLIMUN"   ,"C",aTam[1],aTam[2] } )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao dos cabecalhos                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	aTamSXG := TamSXG("001")
	
	titulo := STR0006 + " em "+GetMv("MV_MOEDA"+Str(MV_PAR08,1))   //"PED. DE VENDAS POR VENDEDOR/CLIENTE"
	If aTamSXG[1] == aTamSXG[3]
		cabec1 := STR0007		//"CODIGO RAZAO SOCIAL             PRACA                  PEDIDO            TOTAL"
									// 999999 XXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXX   999999 9999999999999999
		aCoord := {07, 32, 55, 62}
		aTam2  := {22, 20}
	Else
		cabec1 := STR0014		//"CODIGO               RAZAO SOCIAL         PRACA           PEDIDO           TOTAL"
									// 999999xxxxxxxxxxxxxx XXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX 9999999999999999999999
									//           1         2         3         4         5         6         7
									// 01234567890123456789012345678901234567890123456789012345678901234567890123456789
		aCoord := {21, 42, 58, 64}
		aTam2  := {20, 15}
	EndIf
	cabec2 := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria arquivo de Trabalho                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNomArq := CriaTrab(aCampos)
	Use &cNomArq	Alias TRB   NEW
	IndRegua("TRB",cNomArq,"VENDEDOR+CLIENTE+NUMPED",,,STR0008)		//"Selecionando Registros..."
	
	#IFDEF TOP
		If ( TcSrvType()<>"AS/400" )
			GerTrabTop()
		Else
	#ENDIF
		dbSelectArea("SC5")
		dbSetOrder(2)
		dbSeek(xFilial()+DTOS(mv_par01),.T.)
		
		SetRegua(RecCount())		// Total de Elementos da regua
	
		While !Eof() .And. lContinua .And. C5_EMISSAO >= mv_par01 .And. C5_EMISSAO <= mv_par02 .and. C5_FILIAL == xFilial()
	
			If !Empty(aReturn[7]) .And. !&(aReturn[7])
				dbSkip()
				Loop
			EndIf	
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se esta no mesmo pedido para pegar somente os itens ³
			//³ que esteja de acordo com a pergunta de considera residuo e se³
			//³ o conteudo do campo C6_BLQ = "R ".                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
			dbSelectArea("SC6")
			dbSetOrder(1)
			dbSeek(xFilial()+SC5->C5_NUM)
		
			While !Eof() .And. lContinua .And. C6_NUM == SC5->C5_NUM
			
				If MV_PAR09 == 2 .And. C6_BLQ == "R "
					dbSkip()
					Loop
				EndIf				 	
			
				SF4->( dbSetOrder( 1 ) ) 
				SF4->( MsSeek( xFilial( "SF4" ) + SC6->C6_TES ) ) 
				If !AvalTes(SC6->C6_TES,cEstoq,cDupli)
					dbSkip()
					Loop
				Endif
			
				dbSelectArea("SC5")
				dbSetOrder(2)
			
				If AT(C5_TIPO,"DB") != 0
					dbSelectArea("SC6")
					dbSkip()
					Loop
				EndIf
				IncRegua()
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se Vendedor devera ser impresso                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FOR j:=1 TO 5
					suf := "C5_VEND"+Str(j,1)
					dbSelectArea("SC5")
					IF Empty(&suf)
						Exit
					EndIF
					cVendCh := &suf
					dbSelectArea("SA3")
					If (dbSeek(cFilial+cVendCH))
						dbSelectArea("SC5")
						IF &suf >= mv_par03 .And. &suf <= mv_par04
							If TRB->(!dbSeek(cVendCh+SC5->C5_CLIENTE+SC5->C5_NUM))
								GravaTrab(j)
							EndIf
						EndIF
					Endif
				NEXT j
			
				dbSelectArea("SC6")
				dbSkip()
			
			EndDo
			dbSelectArea("SC5")
			dbSkip()
		EndDO
	#IFDEF TOP
		EndIf	
	#ENDIF
	
	dbSelectArea("TRB")
	dbGoTop()
	nTotGer1 := 0
	nTotGerAux := 0
	
	SetRegua(RecCount())		// Total de Elementos da regua
	
	While !Eof() .And. lContinua
		
		IF lEnd
			@PROW()+1,001 Psay STR0009		//"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		Endif
		
		cVend := VENDEDOR
		dbSelectArea("SA3")
		dbSetOrder(1)
		dbSeek( xFilial() + cVend )
		
		IF li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_NORM"))
		EndIF
		@li,  0 Psay STR0010+ cVend + "  " + SA3->A3_NOME		//"VENDEDOR : "
		li++
		dbSelectArea("TRB")
		nTotVend1 := 0
		
		While !Eof() .And. lContinua .And. VENDEDOR == cVend
			
			IF lEnd
				@PROW()+1,001 Psay STR0009		//"CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			Endif
			#IFDEF TOP
				If ( TcSrvType()<>"AS/400" )
				Else
			#ENDIF
				IF CLIENTE < mv_par05 .Or. CLIENTE > mv_par06 .Or. LOJA < mv_par10 .Or. LOJA > mv_par11
					dbSkip()
					Loop
				EndIF
			#IFDEF TOP
				EndIf
			#ENDIF		
			nTotCli1 := 0
			cCli := CLIENTE
			cLoja:= LOJA
			nContCli := 0
			While !Eof() .And. lContinua .And. VENDEDOR == cVend .And. CLIENTE == cCli .And. LOJA == cLoja
				
				IF lEnd
					@PROW()+1,001 Psay STR0009		//"CANCELADO PELO OPERADOR"
					lContinua := .F.
					EXIT
				ENDIF
				
				IncRegua()
				
				IF li > 55
					cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_NORM"))				   				
				EndIF
				
				#IFDEF TOP
					If ( TcSrvType()<>"AS/400" )
						nTotPed1:=xMoeda( TRB->TOTPED, TRB->MOEDA, mv_par08, TRB->EMISSAO )
					Else
				#ENDIF
					dbSelectArea("SC6")
					dbSeek( xFilial()+TRB->NUMPED )
					nTotPed1 := 0
				
					While !Eof() .And. TRB->NUMPED == SC6->C6_NUM
						IF MV_PAR09 == 2 .And. C6_BLQ == "R "
							dbSkip()
						Else
					 		SF4->( dbSetOrder( 1 ) ) 
						 	SF4->( MsSeek( xFilial( "SF4" ) + SC6->C6_TES ) ) 
					 	
							If AvalTes(SC6->C6_TES,cEstoq,cDupli)
								If cPaisLoc=="BRA"
								 	nTotSC6 := If( SF4->F4_AGREG == "N" .And. MV_PAR12 == 1, 0, C6_VALOR )
									nTotPed1 += xMoeda( nTotSC6,TRB->MOEDA,mv_par08,TRB->EMISSAO)
								Else
									nTotPed1 += xMoeda( C6_VALOR ,TRB->MOEDA,mv_par08,TRB->EMISSAO)
								Endif
							Endif
							dbSkip()
						EndIf
					Enddo			
				#IFDEF TOP
					EndIf
				#ENDIF            
	
	         	DbSelectArea("TRB")
				@li, 0 Psay TRB->CLIENTE + " "
				#IFDEF TOP
					If ( TcSrvType()<>"AS/400" )
						@li, aCoord[1] Psay SubStr(CLINOME, 1, aTam2[1])
						@li, aCoord[2] Psay SubStr(CLIMUN,  1, aTam2[2])
					Else
				#ENDIF
					SA1->(dbSetOrder(1))
					SA1->(dbSeek( xFilial("SA1") + TRB->CLIENTE+TRB->LOJA ))
					@li, aCoord[1] Psay SubStr(SA1->A1_NOME, 1, aTam2[1])
					@li, aCoord[2] Psay SubStr(SA1->A1_MUN,  1, aTam2[2])
				#IFDEF TOP
					EndIf
				#ENDIF
				@li, aCoord[3] Psay NUMPED
				@li, aCoord[4] Psay nTotPed1	Picture tm(nTotPed1,16)
				li++
				nTotCli1 += nTotPed1
				nContCli++			
	
				If mv_par16 == 2
					nPos := AScan(aPedido,{|x| x[1]+x[2]+x[3] == cCli+cLoja+TRB->NUMPED})
					If nPos == 0
						AADD(aPedido,{cCli,cLoja,TRB->NUMPED})
						nTotGerAux += nTotPed1
					EndIf	
				EndIf		
				
				dbSkip()
				
			EndDO
			IF li > 55
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,GetMv("MV_NORM"))
			EndIF
	
			//-- Total por Cliente
			IF mv_par15 == 1 .And. CLIENTE+LOJA <> cCli+cLoja
				@li, 0         Psay STR0011+ cCli + cLoja		//"TOTAL CLIENTE   ---> "
				@li, aCoord[4] Psay nTotCli1	   	   Picture  tm(nTotCli1,16)
			EndIF
			nTotVend1 += nTotCli1
			If mv_par15 == 1
				li++
			EndIf
			dbSelectArea("TRB")
		End
		
		@li, 0         Psay STR0012+ cVend		//"TOTAL VENDEDOR  ---> "
		@li, aCoord[4] Psay nTotVend1		Picture tm(nTotVend1,16)
		If mv_par07 == 1
			li:=90
		Else
			li++
			@li,00 PSay Repl("-",80)
			li++
		Endif
		
		If mv_par16 == 2
			nTotGer1 += nTotGerAux
			nTotGerAux := 0
		Else	
			nTotGer1 += nTotVend1
		EndIf	
			
		dbSelectArea("TRB")
	EndDo
	
	IF li != 80
		If mv_par07 # 1
			@li,  0        Psay STR0013	//"T O T A L  G E R A L : "
			@li, aCoord[4] Psay nTotGer1	Picture tm(nTotGer1,16)
		Endif
		roda(cbcont,cbtxt,"P")
	EndIF
	
	dbSelectArea("TRB")
	cExt := OrdBagExt()
	dbCloseArea()
	If File(cNomArq+GetDBExtension())
		FERASE(cNomArq+GetDBExtension())    //arquivo de trabalho
	Endif
	
	If File(cNomArq + cExt)
		FERASE(cNomArq+cExt)    //indice gerado
	Endif
	
	dbSelectArea("SC5")
	dbSetOrder(1)
	
	dbSelectArea("SA3")
	dbClearFilter()
	dbSetOrder(1)
	
	If aReturn[5] == 1
		Set Printer TO
		dbCommitall()
		ourspool(wnrel)
	Endif
	
	MS_FLUSH()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravaTrab ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Arquivo de Trabalho                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nEl - Ordem do Vendedor                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR600                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FuncTion GravaTrab(nEl)

	Local suf := "SC5->C5_VEND" + Str(nEl,1)
	RecLock("TRB",.t.)
	Replace VENDEDOR With &suf
	Replace NUMPED   With SC5->C5_NUM
	Replace CLIENTE  With SC5->C5_CLIENTE
	Replace EMISSAO  With SC5->C5_EMISSAO
	Replace LOJA     With SC5->C5_LOJACLI
	Replace MOEDA    With SC5->C5_MOEDA
	MsUnlock()
	dbSelectArea("SC5")
	Return .T.
	#IFDEF TOP
	Static Function GerTrabTop()
	Local aArea:=GetArea()
	Local aStruSC5:= {}
	Local nJ      := 0
	Local nLoop   := 0
	Local cSC5Tmp := GetNextAlias()
	Local cSC5Tmp2:= GetNextAlias()
	Local cQuerTmp := ""				//Utilizada para adequar a query segundo necessidades de bancos Sybase
	Local cQuery  := ""
	Local cQuery2 := ""
	Local cVendCh := ""
	Local cSuf    := ""
	Local nVend	  := Fa440CntVen()
	Local cVend   := ""
	Local cCond   := ""
	Local cPedido := ""
	Local aVend   := {}
	
	aStruSC5  := SC5->(dbStruct())
	
	cQuery:="SELECT "
	cSuf:="0"
	For nJ:=1 to nVend
		cSuf := Soma1(cSuf)
		cVend := "C5_VEND"+cSuf
		If SC5->(FieldPos(cVend))>0
			Aadd(aVend,cVend)
			cQuery+=cVend+","
			If !Empty(cCond)
				cCond+="or "
			Endif
			cCond+="("+cVend+"<>'' and "+cVend+">='"+mv_par03+"' and "+cVend+"<='"+mv_par04+"') "
		Endif
	Next	                                                        
	For nJ := 1 To SC5->(FCount())
		If nJ > 1
			cQuery += ", "
		EndIf		
		cQuery += SC5->(FieldName(nJ))
	Next      
	cQuery+=",A1_NOME,A1_MUN "
	cQuery+="FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1 "
	cQuery+="WHERE "
	cQuery+="SC5.C5_FILIAL='"+xFilial("SC5")+"' "
	cQuery+="AND SC5.D_E_L_E_T_=' ' "
	cQuery+="AND SC5.C5_CLIENTE>='"+MV_PAR05+"' AND SC5.C5_CLIENTE<='"+MV_PAR06+"' "
	cQuery+="AND SC5.C5_LOJACLI>='"+MV_PAR10+"' AND SC5.C5_LOJACLI<='"+MV_PAR11+"' "
	cQuery+="AND SC5.C5_EMISSAO>='"+Dtos(MV_PAR01)+"' AND SC5.C5_EMISSAO<='"+Dtos(MV_PAR02)+"' "
	cQuery+="AND SC5.C5_TIPO NOT IN ('D','B') "
	cQuery+="AND ("+cCond+") "
	cQuery+="AND SA1.A1_FILIAL='"+xFilial("SA1")+"' "	
	cQuery+="AND SA1.A1_COD=SC5.C5_CLIENTE "
	cQuery+="AND SA1.A1_LOJA=SC5.C5_LOJACLI "
	cQuery+="AND SA1.D_E_L_E_T_=' ' "
	If TcSrvType() != "AS/400"		
		cQuery+="AND ("
	Else
		cQuery+="AND 0 < ("
	EndIf
	cQuery2:="SELECT SUM(C6_VALOR) nTotPed FROM "+RetSqlName("SC6")+" SC6,"+RetSqlName("SF4")+" SF4 "
	cQuery2+="WHERE "
	cQuery2+="SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
	cQuery2+="SC6.C6_NUM=C5_NUM AND "
	cQuery2+="SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery2+="SF4.F4_CODIGO=SC6.C6_TES  AND "
	If cPaisLoc=="BRA"
		If MV_PAR12==1
			cQuery2+="SF4.F4_AGREG<>'N' AND "
		Endif
	Endif
	If mv_par13==1
		cQuery2 += "SF4.F4_ESTOQUE = 'S' AND "
	ElseIf mv_par13==2
		cQuery2 += "SF4.F4_ESTOQUE = 'N' AND "
	EndIf
	If mv_par14==1
		cQuery2 += "SF4.F4_DUPLIC = 'S' AND "
	ElseIf mv_par14==2
		cQuery2 += "SF4.F4_DUPLIC = 'N' AND "
	EndIf
	cQuery2+="SF4.D_E_L_E_T_=' ' AND "		
	If MV_PAR09==2
		cQuery2+="SC6.C6_BLQ<>'R ' AND "
	Endif
	cQuery2+="SC6.D_E_L_E_T_=' ' "
	
	cQuerTmp := STRTRAN(cQuery2,"nTotPed","")
	cQuerTmp := STRTRAN(cQuerTmp,"C5_NUM","SC5.C5_NUM")
	If TcSrvType() != "AS/400"
		cQuery += cQuerTmp + ") > 0 "
	Else
		cQuery += cQuerTmp + ")"	
	EndIf
	cQuery:=ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cSC5Tmp)
	
	For nLoop := 1 To Len(aStruSC5)
		If aStruSC5[nLoop][2] <> "C" .and. FieldPos(aStruSC5[nLoop][1]) > 0
			TcSetField(cSC5Tmp,aStruSC5[nLoop][1],aStruSC5[nLoop][2],aStruSC5[nLoop][3],aStruSC5[nLoop][4])
		EndIf
	Next nLoop
	
	SetRegua(SC6->(LastRec()))
	DbSelectArea(cSC5Tmp)
	While (cSC5Tmp)->(!Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a validacao do filtro do usuario           	        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(aReturn[7]) .And. !&(aReturn[7])
			(cSC5Tmp)->(DbSkip())
			Loop
		EndIf	
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,StrTran(cQuery2,"=C5_NUM","='"+(cSC5Tmp)->C5_NUM+"'")),cSC5Tmp2)
		If (cSC5Tmp2)->nTotPed>0
			For nJ:=1 to nVend
				cVend := aVend[nJ]
				cVendCh := (cSC5Tmp)->&cVend
				If !Empty(cVendCH) .And. cVendCh >= mv_par03 .And. cVendCh <= mv_par04
					RecLock("TRB",.t.)
					Replace TRB->VENDEDOR With cVendCH
					Replace TRB->NUMPED   With (cSC5Tmp)->C5_NUM
					Replace TRB->CLIENTE  With (cSC5Tmp)->C5_CLIENTE
					Replace TRB->EMISSAO  With (cSC5Tmp)->C5_EMISSAO
					Replace TRB->LOJA     With (cSC5Tmp)->C5_LOJACLI
					Replace TRB->MOEDA    With (cSC5Tmp)->C5_MOEDA
					Replace TRB->TOTPED   With (cSC5Tmp2)->nTotPed
					Replace TRB->CLINOME  With (cSC5Tmp)->A1_NOME
					Replace TRB->CLIMUN   With (cSC5Tmp)->A1_MUN
					TRB->(MsUnlock())
				Endif
			Next
		EndIf
		DbSelectArea(cSC5Tmp2)
		dbCloseArea()
		DbSelectArea(cSC5Tmp)
		IncRegua()
		(cSC5Tmp)->(DbSkip())
	Enddo
	
	DbSelectArea(cSC5Tmp)
	DbCloseArea()
	RestArea(aArea)

Return
#ENDIF


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³Alexandre Lemes     º Data ³ 18/12/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATR600 AP7                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()

	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}
	Local cCpo		:= ""
	Local cValCpo	:= ""
	Local lDel		:= .F.
	Local nG		:= 0
	Local nX		:= 0
	
	Aadd( aHelpPor, "Indica se exclui os movimentos cuja TES" )
	Aadd( aHelpPor, "possua agrega valor = 'Nao' do calculo " )
	Aadd( aHelpPor, "do valor total" )
	
	Aadd( aHelpSpa, "Considerar solamente los itemes con TES" )
	Aadd( aHelpSpa, "que adicionen el valor a factura.      " )
	Aadd( aHelpSpa, "" )
	
	Aadd( aHelpEng, "" )
	Aadd( aHelpEng, "" )
	Aadd( aHelpEng, "" )
	
	If cPaisLoc<>"BRA"
		SX1->(dbSetOrder(1))
		If SX1->(DbSeek("MTR60012"))
			If Empty(SX1->X1_PERSPA) .Or. Empty(SX1->X1_PERENG)
				RecLock("SX1",.F.)
				DbDelete()
				MsUnLock()
				DbCommit()
			Endif
		Endif
		If SX1->(DbSeek("MTR60001"))
			RecLock("SX1",.F.)
			Replace SX1->X1_PERSPA With "¿De Fecha ?"
			Replace SX1->X1_PERENG With "From Date ?"
			SX1->(MsUnLock())
			SX1->(DbCommit())
		Endif
		For nG := 13 to 15
			cCpo := Str(nG,2)
			If SX1->(DbSeek("MTR600"+cCpo))
				nX := 0
				lDel := .F.
				While nX < 5 .And. !lDel
					nX++
					cCpo := "X1_DEF"+StrZero(nX,2)
					cValCpo := SX1->(FieldGet(FieldPos(cCpo)))
					If !Empty(cValCpo)
						cCpo := "X1_DEFSPA" + Str(nX,1)
						cValCpo := SX1->(FieldGet(FieldPos(cCpo)))
						If Empty(cValCpo)
							lDel := .T.
						Else
							cCpo := "X1_DEFENG" + Str(nX,1)
							cValCpo := SX1->(FieldGet(FieldPos(cCpo)))
							If Empty(cValCpo)
								lDel := .T.
							Endif
						Endif
						If lDel
							RecLock("SX1",.F.)
							SX1->(DbDelete())
							SX1->(MsUnLock())
							SX1->(DbCommit())
						Endif
					Else
						nX := 5
					Endif
				Enddo
			Endif
		Next
	Endif
	
	PutSx1("MTR600","12","Considera agrega='Nao'","¿Solo TES que agreguen valor ?","Only TIO that add value?","mv_chc","N",1,0,2,"C","","","","","mv_par12","Sim","Si","Si","","Nao","No","No","","","","","","","","","")
	PutSX1Help("P.MTR60012.",aHelpPor,aHelpEng,aHelpSpa)
	
	/**/
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}     
	Aadd(aHelpPor,"Sera considerado a TES de movimentacao ")
	Aadd(aHelpPor,"do estoque no cadastro de itens do     ")
	Aadd(aHelpPor,"pedido de venda (SD2).                 ")  
	//
	Aadd(aHelpSpa,"Sera considerado el TES de movimiento  ")
	Aadd(aHelpSpa,"del stock en el archivo de Items del   ")
	Aadd(aHelpSpa,"Pedido de Venta (SD2).                 ") 
	//
	Aadd(aHelpEng,"The inventory transaction TIO in the   ")
	Aadd(aHelpEng,"sales order items file (SD2) will be   ")
	Aadd(aHelpEng,"considered.                            ")
	PutSX1("MTR600","13","TES qto estoque     ?","¿TES del estoque   ?","Inventory relat.TIO?","mv_chd","N",1,0,3,"C","","","","S","mv_par13","Movta.Estoque   ","Afecta Stock  ","Invent.Movement","","Nao Movimenta","No hace Movim.","Do not move   ","Considera Ambas","Considera Ambas","Consider both","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	//
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}     
	Aadd(aHelpPor,"Sera considerado o TES de geracao da   ")
	Aadd(aHelpPor,"duplicata no cadastro de itens do      ")
	Aadd(aHelpPor,"pedido  de venda (SD2).                ")  
	//
	Aadd(aHelpSpa,"Sera considerado el TES de generacion  ")
	Aadd(aHelpSpa,"del titulo en el archivo de Items del  ")
	Aadd(aHelpSpa,"Pedido de Venta (SD2).                 ") 
	//
	Aadd(aHelpEng,"The trade note generation TIO in the   ")
	Aadd(aHelpEng,"sales order items file (SD2) will be   ")
	Aadd(aHelpEng,"considered.                            ")
	PutSX1("MTR600","14","TES qto faturamento ?","¿TES de faturamento?","Invoicing relat.TIO?","mv_che","N",1,0,3,"C","","","","S","mv_par14","Gera finaneceiro","Genera financ.","Gener. financ. ","","Nao gera     ","No genera     ","Do not generate","Considera Ambas","Considera Ambas","Consider both","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	//
	aHelpPor := {}
	aHelpEng := {}
	aHelpSpa := {}     
	Aadd(aHelpPor,"Sera considerado o Total por Clientes  ")
	//
	Aadd(aHelpSpa,"Sera considerado el Total por Clientes ")
	//
	Aadd(aHelpEng,"The Total will be considered by Customers")
	PutSx1("MTR600","15","Total por Clientes ?","Total por Clientes ?","Customer Total     ?","mv_chf","N",1,0,0,"C","","","","","mv_par15","Sim","Si","Yes",""  ,"Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa) 
	      
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}
	AADD(aHelpPor,"Por vendedor: Soma os totais dos vende- ")
	AADD(aHelpPor,"dores.")
	AADD(aHelpPor,"Por pedido: Caso dois vendedores sejam")
	AADD(aHelpPor,"informados no mesmo pedido, valor do ")
	AADD(aHelpPor,"pedido sera somado apenas 1 vez.")
	
	AADD(aHelpSpa,"Para el vendedor: la suma total de " )
	AADD(aHelpSpa,"los vendedores." )
	AADD(aHelpSpa,"Por pedido: el caso de que dos proveedo-" )
	AADD(aHelpSpa,"res se les informa a el mismo pedido, el" )
	AADD(aHelpSpa,"valor del pedido debe ser añadido sólo " )
	AADD(aHelpSpa,"1 vez." )
	
	AADD(aHelpEng,"For seller: the sum total of sellers.")
	AADD(aHelpEng,"By sales order: If two vendors are in-")
	AADD(aHelpEng,"formed in the same sales order, the re-")
	AADD(aHelpEng,"quest would be value added only 1 time.")
	PutSx1('MTR600', '16', 'Total Geral por?', 'Total General por', 'Grand Total for', 'mv_che', 'N', 1, 0, 1, 'C', '', '', '', '', 'mv_par16', 'Vendedor','Vendedor','Seller', '', 'Pedido','Pedido','Sales Order','','','','','','','','','',aHelpPor,aHelpEng,aHelpSpa)
	PutSX1Help("P.MTR61016.",aHelpPor,aHelpEng,aHelpSpa)

Return