/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIETARIO: KAPAZI                    																													  	 		    **/
/** MODULO			: Estoque   																																									 		**/
/** NOME 				: KPESTR11.RPW																  																										**/
/** FINALIDADE	: RELATORIO DE VENDAS X FATURAMENTO                                                              **/
/** SOLICITANTE	: Laertes                   					                                                        		**/
/** DATA 				: 25/09/2014																																							 				**/
/** RESPONSAVEL	: RSAC SOLUCOES               																																		**/
/**---------------------------------------------------------------------------------------------------------------**/
/**                                          DECLARACAO DAS BIBLIOTECAS                                         	**/
/**---------------------------------------------------------------------------------------------------------------**/
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
/**---------------------------------------------------------------------------------------------------------------**/
/**                                           DEFINICAO DE PALAVRAS 	  			 								                  	**/
/**---------------------------------------------------------------------------------------------------------------**/
#Define ENTER CHR(13)+CHR(10) 
/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: U_KPESTR11()														                                                      **/
/** DESCRICAO	  	: Gerenciador do Relatório                                  					                					**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO /ALTERACOES / MANUTENCOES                       	   			 				**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                  		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 25/09/2014 	| Marcos Sulivan - Laertes	         |             |   																						**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/	 

User Function KPESTR11()
	
	Private cPerg   	:= "KPESTR11"				//Grupo de pergunta
  Private oReport 	:= Nil							//Objeto relatorio
  
  //Processamento das perguntas
  Processa({|lEnd| ProcSx1()})
  Pergunte(cPerg, .T.)  
  
  //Cria o relatório
  oReport := RelEntLv()  
  
  //Origentação do papel
	oReport:GetOrientation() 
  
  //Inibe pagina parametros
  oReport:lParamPage := .T.
  
	//Tela de impressao
  oReport:PrintDialog()

Return Nil 

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: RelEntLv()							  							                                                      **/
/** DESCRICAO	  	: Define o layout do realatorio a ser impresso             					                					**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO /ALTERACOES / MANUTENCOES                       	   			 				**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                  		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 25/09/2014 	| Marcos Sulivan         |                        |   																						**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/

Static Function RelEntLv()
	
	Local oSecPd  	:= Nil 					//Sessão Principal  
	Local oSecLotes := Nil					//Sessão 1
	
	Local oSomNf		:= Nil					//Sessão 2
	Local oTotal		:= Nil					//Sessão 3

	//Cria o relatório
	oReport := TReport():New(cPerg, "FATURAMENTO X NCM", Nil, {|oReport| ImpRel() }, "Este relatório exibe o Faturamento pelo NCM")
		
	//Cria Seção Nota Fiscal
	oSecPd := TRSection():New(oReport, Nil, {}, Nil)
	
		//Campos
		TRCell():New(oSecPd, "CODIGO"			, Nil, "CODIGO"					, PesqPict("SB1", "B1_COD")				, TamSX3("B1_COD")[1])  
		
		//Campos
		TRCell():New(oSecPd, "DESCRICAO"	, Nil, "DESCRICAO"					, PesqPict("SB1", "B1_DESC")				, TamSX3("B1_DESC")[1])   
		
			//Campos
		TRCell():New(oSecPd, "POSIPI"			, Nil, "POSIPI"					, PesqPict("SB1", "B1_POSIPI")				, TamSX3("RA_SALARIO")[1])  
		
			//Campos
		TRCell():New(oSecPd, "DOCUMENTO"	, Nil, "DOCUMENTO"					, PesqPict("SD2", "D2_DOC")				, TamSX3("D2_DOC")[1])
		
			//Campos
		TRCell():New(oSecPd, "VALICM"			, Nil, "VALICM"					, PesqPict("SD2", "D2_VALICM")				, TamSX3("D2_VALICM")[1])
		
					//Campos
		TRCell():New(oSecPd, "VALIPI"			, Nil, "VALIPI"					, PesqPict("SD2", "D2_VALIPI")				, TamSX3("D2_VALIPI")[1])
		
					//Campos
		TRCell():New(oSecPd, "CODFIS"			, Nil, "CODFIS"					, PesqPict("SD2", "D2_CF")				, TamSX3("D2_CF")[1])
		
					//Campos
		TRCell():New(oSecPd, "VALOR"			, Nil, "VALOR"					, PesqPict("SD2", "D2_TOTAL")				, TamSX3("D2_TOTAL")[1])
		
							//Campos
		TRCell():New(oSecPd, "EMISSAO"			, Nil, "EMISSAO"					, PesqPict("SD2", "D2_EMISSAO")				, TamSX3("D2_EMISSAO")[1])

Return oReport 

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: ImpRel()							  							                                                      **/
/** DESCRICAO	  	:  define o layout do realatorio a ser impresso             					                					**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO /ALTERACOES / MANUTENCOES                       	   			 				**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                  		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 25/09/2014 	| Marcos Sulivan        |                        |   																						**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/

Static Function ImpRel()

	Local nRegs			:= 0										//Quantidade de registros
	Local oSecPd		:= oReport:Section(1)  	//Sessão das notas fiscais
	//Local oSecLotes := oReport:Section(2)		//Sessão Principal
    
 		QryBd3()
  		
		//Acessa o inicio da query
		QMPF->(DbGoTop())
 
 	 //Conta os registros
 		QMPF->(DbEval({|| nRegs++ })) 
 	
		//Acessa o inicio da query
		QMPF->(DbGoTop())
		
		//Inicializa o contador
		oReport:SetMeter(nRegs)

			//Inicia impressao
 			oSecPd:Init()
  
 	 	//Loop na query
 		While (!QMPF->(Eof()))
 		  
 			//Incrementa progresso
 			oReport:IncMeter()
  		
			oSecPd:Cell("CODIGO")	:SetValue(QMPF->CODIGO)
			//oSecPd:Cell("NOME")	:SetAlign("LEFT") 
			
				oSecPd:Cell("DESCRICAO")	:SetValue(QMPF->DESCRICAO) 
			//oSecPd:Cell("DATA")	:SetAlign("LEFT")  
			
				oSecPd:Cell("POSIPI")	:SetValue(QMPF->POSIPI) 
			//oSecPd:Cell("SALARIO")	:SetAlign("LEFT")   
			
				oSecPd:Cell("DOCUMENTO")	:SetValue(QMPF->DOCUMENTO) 
			//oSecPd:Cell("DEPARTAMENTO")	:SetAlign("LEFT")
			
				oSecPd:Cell("VALICM")	:SetValue(QMPF->VALICM) 
			//oSecPd:Cell("FUNCAO")	:SetAlign("LEFT")
			
				oSecPd:Cell("VALIPI")	:SetValue(QMPF->VALIPI) 
			//oSecPd:Cell("FUNCAO")	:SetAlign("LEFT")
			
				oSecPd:Cell("CODFIS")	:SetValue(QMPF->CODFIS) 
			//oSecPd:Cell("FUNCAO")	:SetAlign("LEFT")
			
				oSecPd:Cell("VALOR")	:SetValue(QMPF->VALOR) 
			//oSecPd:Cell("FUNCAO")	:SetAlign("LEFT") 
			
				oSecPd:Cell("EMISSAO")	:SetValue(QMPF->EMISSAO) 
			//oSecPd:Cell("FUNCAO")	:SetAlign("LEFT")
			      
						
			//Imprime a linha
			oSecPd:PrintLine()	
					  	  
   	//Próximo registro
		QMPF->(DbSkip())
	
		EndDo

		//Fecha a query
		QMPF->(DbCloseArea())
		
		//Finaliza a ultima seção  
  	//oSecPd:Finish() 
		oSecPd:Finish()  


Return Nil 

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: QryBd2()							  							                                                        **/
/** DESCRICAO	  	: Recupera dados de venda de acordo com parametros SB1xSB2xSD1xSD2xSZ2 somente da filial				**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO /ALTERACOES / MANUTENCOES                       	   			 				**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                  		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 25/09/2014 	| Marcos Sulivan         |                        |   																						**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/

Static Function QryBd3()

  Local aArea 	:= GetArea()     	//Area
  Local cQr 		:= ""             //Recebe a query

     

	//Monta a query dos itens 
        

		cQr := " SELECT 	SB1.B1_COD		CODIGO,
		cQr += "		SB1.B1_DESC		DESCRICAO,
		cQr += "		SB1.B1_POSIPI	POSIPI,
		cQr += "		SD2.D2_DOC		DOCUMENTO,
		cQr += "		SD2.D2_VALICM	VALICM,
		cQr += "		SD2.D2_VALIPI	VALIPI,
		cQr += "		SD2.D2_CF		CODFIS,
		cQr += "		SD2.D2_TOTAL	VALOR,
		cQr += "		SD2.D2_EMISSAO	EMISSAO


		cQr += "		FROM	"+ RetSqlName("SB1") +"		SB1

		cQr += "		JOIN	"+ RetSqlName("SD2") +"		SD2
		cQr += "  	ON	SD2.D2_COD = SB1.B1_COD
		cQr += "	AND SD2.D_E_L_E_T_ = ''
		cQr += "	AND SD2.D2_EMISSAO BETWEEN   '" + Dtos(mv_par01) + "' AND '" + Dtos(mv_par02) + "'
	
		cQr += "	WHERE	SB1.D_E_L_E_T_ = ''

		cQr += "	ORDER BY SB1.B1_COD
		cQr += "		,SD2.D2_EMISSAO				
				
	
							

  //Cria uma alías para a query     
 	TcQuery cQr new alias "QMPF"
  
  //Restaura a area
  RestArea(aArea)
  
Return Nil   

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: ProcSx1()							  							        	                                              **/
/** DESCRICAO	  	: Processa as perguntas do relatório						             					                					**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO /ALTERACOES / MANUTENCOES                       	   			 				**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                  		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 28/05/2014 	| Velton Teixeira        |                        |   																						**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                           DEFINIÇÕES DAS PERGUNTAS    	              		      									**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** aParPerg[]                                                                                                    **/
/** aParPerg[n][01] : nome da pergunta                                                                            **/
/** aParPerg[n][02] : descrição                                                                                   **/
/** aParPerg[n][03] : tipo                                                                                        **/
/** aParPerg[n][04] : tamanho                                                                                     **/
/** aParPerg[n][05] : decimais                                                                                    **/
/** aParPerg[n][06] : indice de pre selecao de combo                                                              **/
/** aParPerg[n][07] : tipo de objeto ( G=Edit|S=Text|C=Combo|R=Range|F=File|E=Expression|K=Check )                **/
/** aParPerg[n][08] : rotina de validação do SX1                                                                  **/
/** aParPerg[n][09] : F3                                                                                          **/
/** aParPerg[n][10] : grupo de perguntas                                                                          **/
/** aParPerg[n][11] : item 1 do combo                                                                             **/
/** aParPerg[n][11] : item 2 do combo                                                                             **/
/** aParPerg[n][11] : item 3 do combo                                                                             **/
/** aParPerg[n][11] : item 4 do combo                                                                             **/
/** aParPerg[n][11] : item 5 do combo                                                                             **/
/** aParPerg[n][12] : array de help                                                               								**/
/**---------------------------------------------------------------------------------------------------------------**/

Static Function ProcSx1()

  Local aParPerg 	:= {}  						//Array com os parametros
  Local cIndice 	:= "00" 					//Indice da pergunta
  Local cVarCh 		:= "mv_ch0"    	  //Parametro mv_ch
  Local cVarPar 	:= "mv_par00"			//Parametro mv_par
	Local cIdx0 		:= "0"  					//Indice 0
Local nI 
 

	//Cria as perguntas do array  01
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Da Data?"                                 ,; // descrição
                    "D"                                        ,; // tipo
                    8                                          ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    ""                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe a data de início"  ,;
                     "" }       ; // array de help
                  }                                             ;
      )
  
  //Cria as perguntas do array  02
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até a Data?"                		           ,; // descrição
                    "D"                                        ,; // tipo
                    8                                          ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    ""                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe a data de fim"  ,;
                     "" } ; // array de help
                  }                                             ;
      )   
  

      

  //Inicializa as variaveis
  cIndice := "00"
  cIdx0 := "0"
  cVarCh := "mv_ch0"
  cVarPar := "mv_par00"
             
  //Inicializa a barra de progressos                    
  procRegua(len(aParPerg))

  //Loop sobre os parametros a adicionar        
  For nI := 1 to len(aParPerg)
    
    //Incrementa os contadores
    cIndice := soma1(cIndice)
    cIdx0 := soma1(cIdx0)
    cVarCh := "mv_ch" + cIdx0
    cVarPar := "mv_par" + cIndice

    //Incrementa a barra de progressos
    incProc("Criando perguntas " + allTrim(cIndice) + "/" + strZero(len(aParPerg), 2) + "..." )

 
	  //Adiciona o parametro
	  putSX1( aParPerg[nI][01] ,; // nome da pergunta
	          cIndice          ,; // indice
	          aParPerg[nI][02] ,; // descricao portugues
	          aParPerg[nI][02] ,; // descricao espanhol
	          aParPerg[nI][02] ,; // descricao ingles
	          cVarCh           ,; // variavel mv_ch
	          aParPerg[nI][03] ,; // tipo
	          aParPerg[nI][04] ,; // tamanho
	          aParPerg[nI][05] ,; // decimais
	          aParPerg[nI][06] ,; // indice de pre-seleção (combo)
	          aParPerg[nI][07] ,; // tipo do objeto
	          aParPerg[nI][08] ,; // validação
	          aParPerg[nI][09] ,; // F3
	          aParPerg[nI][10] ,; // grupo de perguntas
	          " "              ,; // parametro pyme
	          cVarPar          ,; // variavel mv_par
	          aParPerg[nI][11] ,; // item 1 do combo (portugues)
	          aParPerg[nI][11] ,; // item 1 do combo (espanhol)
	          aParPerg[nI][11] ,; // item 1 do combo (ingles)
	          ""               ,; // conteudo padrao da pergunta
	          aParPerg[nI][12] ,; // item 2 do combo (portugues)
	          aParPerg[nI][12] ,; // item 2 do combo (espanhol)
	          aParPerg[nI][12] ,; // item 2 do combo (ingles)
	          aParPerg[nI][13] ,; // item 3 do combo (portugues)
	          aParPerg[nI][13] ,; // item 3 do combo (espanhol)
	          aParPerg[nI][13] ,; // item 3 do combo (ingles)
	          aParPerg[nI][14] ,; // item 4 do combo (portugues)
	          aParPerg[nI][14] ,; // item 4 do combo (espanhol)
	          aParPerg[nI][14] ,; // item 4 do combo (ingles)
	          aParPerg[nI][15] ,; // item 5 do combo (portugues)
	          aParPerg[nI][15] ,; // item 5 do combo (espanhol)
	          aParPerg[nI][15] ,; // item 5 do combo (ingles)
	          aParPerg[nI][16] ,; // memo de help (portugues)
	          aParPerg[nI][16] ,; // memo de help (espanhol)
	          aParPerg[nI][16] ,; // memo de help (ingles)
	          "" ; // help
	        )
	
  Next nI

Return nil