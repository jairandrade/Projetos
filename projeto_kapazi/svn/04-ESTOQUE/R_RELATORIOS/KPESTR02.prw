/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIETARIO: KAPAZI                    																													  	 		    **/
/** MODULO			: Estoque   																																									 		**/
/** NOME 				: KPESTR02.RPW																  																										**/
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
/** NOME DA FUNCAO: U_KPESTR02()														                                                      **/
/** DESCRICAO	  	: Gerenciador do Relatório                                  					                					**/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIACAO /ALTERACOES / MANUTENCOES                       	   			 				**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitacao         		| Descricao                                  		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 25/09/2014 	| Marcos Sulivan	         |                        |   																						**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/	
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/	 

User Function KPESTR02()
	
	Private cPerg   	:= "KPESTR02"				//Grupo de pergunta
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
	oReport := TReport():New(cPerg, "Vendidos X Faturado", Nil, {|oReport| ImpRel() }, "Este relatório exibe Relação de Vendidos X Faturado")
		
	//Cria Seção Nota Fiscal
	oSecPd := TRSection():New(oReport, Nil, {}, Nil)
	
		//Campos
		TRCell():New(oSecPd, "COD_PRODUTO"			, Nil, "CODIGO"					, PesqPict("SB1", "B1_COD")				, TamSX3("B1_COD")[1])
		TRCell():New(oSecPd, "DESCRICAO"				, Nil, "DESCRICAO"			, PesqPict("SB1", "B1_DESC")			, TamSX3("B1_DESC")[1])     
		TRCell():New(oSecPd, "UNIDADE" 					, Nil, "UNIDADE"				, PesqPict("SB1", "B1_UM")				, TamSX3("B1_UM")[1])
		TRCell():New(oSecPd, "GRUPO"						, Nil, "GRUPO"					, PesqPict("SB1", "B1_GRUPO")			, TamSX3("B1_GRUPO")[1])
		TRCell():New(oSecPd, "SUBGRUPO"					, Nil, "SUBGRUPO"				, PesqPict("SZ2", "Z2_SBGRUP")		, TamSX3("Z2_SBGRUP")[1])
		TRCell():New(oSecPd, "DESC_SUBGRUPO"		, Nil, "DESC_SUBGRUPO"	, PesqPict("SZ2", "Z2_COD")				, TamSX3("Z2_COD")[1])
		TRCell():New(oSecPd, "FILIAL"						, Nil, "FILIAL"					, PesqPict("SB1", "C6_FILIAL")		, TamSX3("C6_FILIAL")[1])
		TRCell():New(oSecPd, "VENDIDO"					, Nil, "VENDIDO"				, PesqPict("SC6", "C6_QTDVEN")		, TamSX3("C6_QTDVEN")[1])
		TRCell():New(oSecPd, "VLR_VENDIDO"			, Nil, "VLR_VENDIDO"		, PesqPict("SC6", "C6_PRCVEN")		, TamSX3("C6_PRCVEN")[1])
		TRCell():New(oSecPd, "DESCONTO"					, Nil, "DESCONTO"				, PesqPict("SC6", "C6_VALDESC")		, TamSX3("C6_VALDESC")[1]) 
		TRCell():New(oSecPd, "FATURADO"					, Nil, "FATURADO"				, PesqPict("SD2", "D2_QUANT")			, TamSX3("D2_QUANT")[1]) 
		TRCell():New(oSecPd, "VLR_FATURADO"			, Nil, "VLR_FATURADO"		, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1])
						
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
    
  		QryBd2()
  		
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
  		
			oSecPd:Cell("COD_PRODUTO")	:SetValue(QMPF->PRODUTO)
			//oSecPd:Cell("COD_PRODUTO")	:SetAlign("LEFT")
			 
			oSecPd:Cell("DESCRICAO")				:SetValue(QMPF->DESCRICAO)
		 //	oSecPd:Cell("DESCRI")				:SetAlign("LEFT")
			 
			oSecPd:Cell("UNIDADE")					:SetValue(QMPF->UNIDADE)
		 //	oSecPd:Cell("TIPO")					:SetAlign("LEFT")
			  
			oSecPd:Cell("GRUPO")				:SetValue(QMPF->GRUPO) 
			//oSecPd:Cell("GRUPO")				:SetAlign("LEFT")
			
			oSecPd:Cell("SUBGRUPO")	:SetValue(QMPF->SUBGRUPO)
		 //	oSecPd:Cell("COD_SUBGRUPO")	:SetAlign("LEFT")
			 		
			oSecPd:Cell("DESC_SUBGRUPO")			:SetValue(QMPF->DESC_SUBGRUPO)
			//oSecPd:Cell("SUBGRUPO")			:SetAlign("LEFT")
			
			oSecPd:Cell("FILIAL")					:SetValue(QMPF->FILIAL)  
			//oSecPd:Cell("PESO")					:SetAlign("LEFT") 
			
			oSecPd:Cell("VENDIDO")	:SetValue(QMPF->VENDIDO) 
			//oSecPd:Cell("SALDO_ATUAL")	:SetAlign("LEFT")
			
			oSecPd:Cell("VLR_VENDIDO")		:SetValue(QMPF->VLR_VENDIDO)
			//oSecPd:Cell("QTD_PEDIDO")		:SetAlign("LEFT") 
			
			oSecPd:Cell("DESCONTO"):SetValue(QMPF->DESCONTO)   
			//oSecPd:Cell("QTD_DISPONIVEL"):SetAlign("LEFT")
			
			oSecPd:Cell("FATURADO")					:SetValue(QMPF->FATURADO)
			//oSecPd:Cell("VEND")				  :SetAlign("LEFT")         
			
			oSecPd:Cell("VLR_FATURADO")				:SetValue(QMPF->VLR_FATURADO)
		 //	oSecPd:Cell("DEVOL")				:SetAlign("LEFT")      
						
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

Static Function QryBd2()

  Local aArea 	:= GetArea()     	//Area
  Local cQr 		:= ""             //Recebe a query
  Local aEmpr		:= {}							//Array auxiliar para receber empresa
  Local aLoja		:= {}							//Array auxiliar para receber a loja 
  Local xAliasSM0   := SM0->(GetArea())
  Local nRegs     := 0
	Local nX        := 0
	Local nPos			:= 0
  
  //inicia array empresas       
	aEmpresas := {}
	
	//executa array para query em grupo
	If(mv_par05 == 2 )
							
			SM0	->(DbGoTop())
			
					While SM0->(!EOF())
					
						If SM0->M0_CODIGO <> "99"
						
								nPos := aScan( aEmpresas , { |x| x[1] == SM0->M0_CODIGO } )
						          
						  			IF nPos == 0
						          
						     			Aadd( aEmpresas , { SM0->M0_CODIGO , {{ SM0->M0_CODFIL , SubStr(SM0->M0_FILIAL,1,4) , 0 }} } )
						               
						     		Else      
						          
							      	Aadd( aEmpresas[nPos,2] , { SM0->M0_CODFIL , SM0->M0_FILIAL , 0 } )
						        
						        EndIF
						        
						EndIF
						
					SM0->(DbSkip())
						
					EndDo
						
	RestArea(xAliasSM0)   
							
	EndIf
	
	//executa array para query pela filial logada. 
	
	If(mv_par05 == 1)

			Aadd( aEmpresas , { SM0->M0_CODIGO , {{ SM0->M0_CODFIL , SubStr(SM0->M0_FILIAL,1,4) , 0 }} } )
		
			RestArea(xAliasSM0)
			
	EndIf	
	
     
  //cQuery += " FROM SD1" + aEmpresas[nX,1] + "0 SD1" 
	//Monta a query dos itens 
        

				cQr := " SELECT 	VEND.PRODUTO
				cQr += "			,VEND.GRUPO
				cQr += "			,VEND.SUBGRUPO
				cQr += "			,VEND.DESC_SUBGRUPO
				cQr += "			,VEND.FILIAL
				cQr += "			,VEND.UNIDADE
				cQr += "			,VEND.DESCRICAO
				cQr += "			,VEND.VENDIDO
				cQr += "			,VEND.VLR_VENDIDO
				cQr += "			,VEND.DESCONTO
				cQr += "			,VEND.FATURADO
				cQr += "			,VEND.VLR_FATURADO

							
				cQr += " FROM (  
				
				For nX := 1 To Len(aEmpresas)   
				
				cQr += " SELECT	SC6.C6_PRODUTO	PRODUTO
				cQr += "		,ISNULL(
				cQr += "		(
				cQr += "			SELECT	SB1.B1_DESC
				cQr += "			FROM	SB1010	SB1
				cQr += "			WHERE	SB1.D_E_L_E_T_ = ''
				cQr += "				AND SC6.C6_PRODUTO = SB1.B1_COD
								
				cQr += "		 ),'-')	DESCRICAO
						 
				cQr += "		,SC6.C6_FILIAL	FILIAL
				cQr += "		,SC6.C6_UM		UNIDADE
				cQr += "		,ISNULL(
				cQr += "		(
				cQr += "			SELECT	SB1.B1_GRUPO
				cQr += "			FROM	SB1010	SB1
				cQr += "			WHERE	SB1.D_E_L_E_T_ = ''
				cQr += "				AND SC6.C6_PRODUTO = SB1.B1_COD
								
				cQr += "		 ),'-')	GRUPO
				cQr += "		,ISNULL(
				cQr += "		(
				cQr += "			SELECT	SZ2.Z2_COD
				cQr += "			FROM	SB1010	SB1
				cQr += "			INNER JOIN	SZ2010	SZ2
				cQr += "					ON	SZ2.Z2_COD = SB1.B1_SBGRUP
				cQr += "			WHERE	SB1.D_E_L_E_T_ = ''
				cQr += "				AND SC6.C6_PRODUTO = SB1.B1_COD
								
				cQr += "		 ),'-')	SUBGRUPO
						 
				cQr += "		 		,ISNULL(
				cQr += "		(
				cQr += "			SELECT	SZ2.Z2_DESCRI
				cQr += "			FROM	SB1010	SB1
				cQr += "			INNER JOIN	SZ2010	SZ2
				cQr += "					ON	SZ2.Z2_COD = SB1.B1_SBGRUP
				cQr += "			WHERE	SB1.D_E_L_E_T_ = ''
				cQr += "				AND SC6.C6_PRODUTO = SB1.B1_COD
								
				cQr += "		 ),'-')	DESC_SUBGRUPO
				cQr += "		 ,SUM(SC6.C6_QTDVEN)	VENDIDO
				cQr += "		 ,SUM(SC6.C6_PRCVEN * SC6.C6_QTDVEN ) VLR_VENDIDO
						 
				cQr += "		 ,ISNULL(
				cQr += "		 (
						 
				cQr += "		 SUM(SC6.C6_VALDESC)
						 
				cQr += "		 ),0)	DESCONTO
						 
				cQr += "		 ,ISNULL(
				cQr += "		 (
				cQr += "		 SELECT SUM(SD2.D2_QUANT)
				cQr += "		 FROM	SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += "		 WHERE	SD2.D_E_L_E_T_ = ''
				cQr += "		 AND SD2.D2_COD = SC6.C6_PRODUTO
				cQr += "		 AND SD2.D2_EMISSAO BETWEEN '" + Dtos(mv_par03) + "' AND '" + Dtos(mv_par04) + "'
				cQr += "		 AND SD2.D2_CF IN (	'5101','5102','5124','5401','5403','5405','6101',
				cQr += "												'6102','6107','6108','6110','6116','6118','6119',
				cQr += "												'6124','6125','6401','6404','7101','7102')
				cQr += "		 ),0)	FATURADO
						 
				cQr += "		 		 ,ISNULL(
				cQr += "		 (
				cQr += "		 SELECT SUM(SD2.D2_QUANT * SD2.D2_PRCVEN)
				cQr += "		 FROM	SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += "		 WHERE	SD2.D_E_L_E_T_ = ''
				cQr += "		 AND SD2.D2_COD = SC6.C6_PRODUTO
				cQr += "		 AND SD2.D2_EMISSAO BETWEEN '" + Dtos(mv_par03) + "' AND '" + Dtos(mv_par04) + "'
				cQr += "		 AND SD2.D2_CF IN (	'5101','5102','5124','5401','5403','5405','6101',
				cQr += "												'6102','6107','6108','6110','6116','6118','6119',
				cQr += "												'6124','6125','6401','6404','7101','7102')
				cQr += "		 ),0)	VLR_FATURADO	 
				
				cQr += " FROM	SC6" + aEmpresas[nX,1] + "0		SC6
				
				cQr += " INNER JOIN			SC5" + aEmpresas[nX,1] + "0	SC5
				cQr += "			ON		SC6.C6_NUM = SC5.C5_NUM
				cQr += "			AND		SC5.D_E_L_E_T_ = ''
				
				cQr += " INNER JOIN			SB1010	SB1
			  cQr += " ON		SB1.B1_COD = SC6.C6_PRODUTO
			  cQr += " AND		SB1.D_E_L_E_T_ = ''
			  cQr += " AND		SB1.B1_SBGRUP BETWEEN '" + mv_par11 + "' AND '" + mv_par12 + "'
			  cQr += " AND		SB1.B1_GRUPO BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "'
				
				cQr += " WHERE	SC6.D_E_L_E_T_ = ''
				cQr += " AND SC6.C6_PRODUTO BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'
				cQr += " AND SC6.C6_UM BETWEEN  '" + mv_par07 + "' AND '" + mv_par08 + "' 
				
				
				If(mv_par05 == 1)
				
								cQr += " AND SC6.C6_FILIAL = '" + mv_par06 + "'    
								                                                
				EndIf
				
				cQr += "	AND SC6.C6_CF IN (	'5101','5102','5124','5401','5403','5405','6101',
				cQr += "						'6102','6107','6108','6110','6116','6118','6119',
				cQr += "						'6124','6125','6401','6404','7101','7102')
				
				cQr += " GROUP BY SC6.C6_PRODUTO
				cQr += "		,SC6.C6_FILIAL
				cQr += "		,SC6.C6_UM
				
				     If nX < Len(aEmpresas)
          			cQr +=  " UNION"
     					Endif
		Next

				cQr += "		)	
				cQr += " AS	VEND
				
				cQr += " ORDER BY VEND.PRODUTO		
							

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
                    "Produto?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("B1_COD")[01]                     ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SB1"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe o Codigo inicial do produto "     ,;
                     "que o relatório deve consirerar." }       ; // array de help
                  }                                             ;
      )
 
	//Cria as perguntas do array  02
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até Produto?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("B1_COD")[01]                     ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SB1"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe o Codigo Final do produto "     ,;
                     "que o relatório deve consirerar." }       ; // array de help
                  }                                             ;
      )

	//Cria as perguntas do array  03
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
                     "a ser considerada para calculo de média" }       ; // array de help
                  }                                             ;
      )
  
  //Cria as perguntas do array  04
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
                     "a ser considerada para calculo de média" } ; // array de help
                  }                                             ;
      )   
      
	//Cria as perguntas do array  05
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Tipo?"                		        			   ,; // descrição
                    "C"                                        ,; // tipo
                    1                                          ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "C"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    ""                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    "Filial"                           ,; // item 1 do combo
                    "Grupo"                       ,; // item 2 do combo
                    "Empresa"                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                   {"Informe o tipo de relatório." }            ; // array de help
                  }                                             ;
      )   
      
            	//Cria as perguntas do array  11 P/6
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Filial"                		        			   ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("C6_FILIAL")[01]                                          ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    ""                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                           ,; // item 1 do combo
                    ""                       ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                   {"Informe a filial" }            ; // array de help
                  }                                             ;
      )  
         
      
        //Cria as perguntas do array  07
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "De Qual Unid. Medida?"                		           ,; // descrição
                    "C"                                        ,; // tipo
                    2                                          ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "C"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SAH"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe a unidade de medida"  ,;
                     "a ser considerada no filtro" } ; // array de help
                  }                                             ;
      )
                               \
        //Cria as perguntas do array  08
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até Qual Unid. Medida?"                		           ,; // descrição
                    "C"                                        ,; // tipo
                    2                                          ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "C"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SAH"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe a unidade de medida"  ,;
                     "a ser considerada no filtro" } ; // array de help
                  }                                             ;
      ) 
      
    
      	//Cria as perguntas do array  09
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Grupo de?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("B1_GRUPO")[01]                     ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SBM"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe o Codigo inicial do Grupo"     ,;
                     "que o relatório deve consirerar." }       ; // array de help
                  }                                             ;
      ) 
      
      
  
	//Cria as perguntas do array  10
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até Grupo?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("B1_GRUPO")[01]                     ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SBM"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe o Codigo Final do Grupo "     ,;
                     "que o relatório deve consirerar." }       ; // array de help
                  }                                             ;
      )
      
            	//Cria as perguntas do array  11
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "SubGrupo de?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("B1_SBGRUP")[01]                     ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SBG"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe o Codigo inicial do SubGrupo"     ,;
                     "que o relatório deve consirerar." }       ; // array de help
                  }                                             ;
      ) 
      
      
  
	//Cria as perguntas do array  12
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até SubGrupo?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("B1_SBGRUP")[01]                     ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SBG"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe o Codigo Final do SubGrupo "     ,;
                     "que o relatório deve consirerar." }       ; // array de help
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