/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIETARIO: KAPAZI                    																													  	 		    **/
/** MODULO			: Estoque   																																									 		**/
/** NOME 				: KPESTR03.RPW																  																										**/
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
/** NOME DA FUNCAO: U_KPESTR04()														                                                      **/
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

User Function KPESTR04()
	
	Private cPerg   	:= "KPESTR04"				//Grupo de pergunta
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
		TRCell():New(oSecPd, "CODCLI"						, Nil, "COD. CLIENTE"		, PesqPict("SA1", "A1_COD")				, TamSX3("A1_COD")[1])
		TRCell():New(oSecPd, "LOJA"							, Nil, "LOJA"						, PesqPict("SA1", "A1_LOJA")			, TamSX3("A1_LOJA")[1])     
		TRCell():New(oSecPd, "NOMEREDUZ"				, Nil, "NOME"						, PesqPict("SA1", "A1_NREDUZ")		, TamSX3("A1_NREDUZ")[1])
		TRCell():New(oSecPd, "BAIRRO"						, Nil, "BAIRRO"					, PesqPict("SA1", "A1_BAIRRO")		, TamSX3("A1_BAIRRO")[1])
		TRCell():New(oSecPd, "CIDADE"						, Nil, "CIDADE"					, PesqPict("SA1", "A1_MUN")				, TamSX3("A1_MUN")[1])
		TRCell():New(oSecPd, "UF"								, Nil, "UF"							, PesqPict("SA1", "A1_ESTADO")		, TamSX3("A1_ESTADO")[1])
		TRCell():New(oSecPd, "VENDEDOR"					, Nil, "COD VEND"			, PesqPict("SA3", "A3_COD")			, TamSX3("A3_COD")[1])
		TRCell():New(oSecPd, "NOMEVEND"					, Nil, "NOME VEND"			, PesqPict("SA3", "A3_NOME")			, TamSX3("A3_NOME")[1])
		TRCell():New(oSecPd, "JANEIRO"					, Nil, "JANEIRO"				, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1]) 
		TRCell():New(oSecPd, "FEVEREIRO"				, Nil, "FEVEREIRO"			, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1]) 
		TRCell():New(oSecPd, "MARCO"						, Nil, "MARCO"					, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1]) 
		TRCell():New(oSecPd, "ABRIL"						, Nil, "ABRIL"					, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1]) 
		TRCell():New(oSecPd, "MAIO"							, Nil, "MAIO"						, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1]) 
		TRCell():New(oSecPd, "JUNHO"						, Nil, "JUNHO"					, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1]) 
		TRCell():New(oSecPd, "JULHO"						, Nil, "JULHO"					, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1]) 
		TRCell():New(oSecPd, "AGOSTO"						, Nil, "AGOSTO"					, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1]) 
		TRCell():New(oSecPd, "SETEMBRO"					, Nil, "SETEMBRO"				, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1]) 
		TRCell():New(oSecPd, "OUTUBRO"					, Nil, "OUTUBRO"				, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1])
		TRCell():New(oSecPd, "NOVEMBRO"					, Nil, "NOVEMBRO"				, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1]) 
		TRCell():New(oSecPd, "DEXEMBRO"					, Nil, "DEZEMBRO"				, PesqPict("SD2", "D2_TOTAL")			, TamSX3("D2_TOTAL")[1]) 
		TRCell():New(oSecPd, "ULTIMA"				, Nil, "ULT COMPRA"			, PesqPict("SD2", "D2_EMISSAO")			, TamSX3("D2_EMISSAO")[1])  

						
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
  		
			oSecPd:Cell("CODCLI")						:SetValue(QMPF->CODCLI)
			//oSecPd:Cell("COD_PRODUTO")	:SetAlign("LEFT")
			 
			oSecPd:Cell("LOJA")				:SetValue(QMPF->LOJA)
		 //	oSecPd:Cell("DESCRI")				:SetAlign("LEFT")
			 
			oSecPd:Cell("NOMEREDUZ")					:SetValue(QMPF->NOMEREDUZ)
		 //	oSecPd:Cell("TIPO")					:SetAlign("LEFT")
			  
			oSecPd:Cell("BAIRRO")				:SetValue(QMPF->BAIRRO) 
			//oSecPd:Cell("GRUPO")				:SetAlign("LEFT")
			
			oSecPd:Cell("CIDADE")	:SetValue(QMPF->CIDADE)
		 //	oSecPd:Cell("COD_SUBGRUPO")	:SetAlign("LEFT")
			 		
			oSecPd:Cell("UF")			:SetValue(QMPF->UF)
			//oSecPd:Cell("SUBGRUPO")			:SetAlign("LEFT")
			
			oSecPd:Cell("VENDEDOR")					:SetValue(QMPF->VENDEDOR)  
			//oSecPd:Cell("PESO")					:SetAlign("LEFT") 
			
			oSecPd:Cell("NOMEVEND")	:SetValue(QMPF->NOMEVEND) 
			//oSecPd:Cell("SALDO_ATUAL")	:SetAlign("LEFT")
			
			oSecPd:Cell("JANEIRO")		:SetValue(QMPF->JANEIRO)
			//oSecPd:Cell("QTD_PEDIDO")		:SetAlign("LEFT") 
			
			oSecPd:Cell("FEVEREIRO")	:SetValue(QMPF->FEVEREIRO)   
			//oSecPd:Cell("QTD_DISPONIVEL"):SetAlign("LEFT")
			
			oSecPd:Cell("MARCO")					:SetValue(QMPF->MARCO)
			//oSecPd:Cell("VEND")				  :SetAlign("LEFT")         
			
			oSecPd:Cell("ABRIL")				:SetValue(QMPF->ABRIL)
		 //	oSecPd:Cell("DEVOL")				:SetAlign("LEFT") 

			oSecPd:Cell("MAIO")				:SetValue(QMPF->MAIO)
		 //	oSecPd:Cell("DEVOL")				:SetAlign("LEFT") 
		 
		 oSecPd:Cell("JUNHO")				:SetValue(QMPF->JUNHO)
		 //	oSecPd:Cell("DEVOL")				:SetAlign("LEFT")
		 
		 oSecPd:Cell("JULHO")				:SetValue(QMPF->JULHO)
		 //	oSecPd:Cell("DEVOL")				:SetAlign("LEFT")
		 
		 oSecPd:Cell("AGOSTO")				:SetValue(QMPF->AGOSTO)
		 //	oSecPd:Cell("DEVOL")				:SetAlign("LEFT")
		 
		 oSecPd:Cell("SETEMBRO")				:SetValue(QMPF->SETEMBRO)
		 //	oSecPd:Cell("DEVOL")				:SetAlign("LEFT")        
		 
		 oSecPd:Cell("OUTUBRO")				:SetValue(QMPF->OUTUBRO)
		 //	oSecPd:Cell("DEVOL")				:SetAlign("LEFT")
		 
		 oSecPd:Cell("NOVEMBRO")				:SetValue(QMPF->NOVEMBRO)
		 //	oSecPd:Cell("DEVOL")				:SetAlign("LEFT")
		 
		 oSecPd:Cell("DEZEMBRO")				:SetValue(QMPF->DEZEMBRO)
		 //	oSecPd:Cell("DEVOL")				:SetAlign("LEFT")     
		 
		 oSecPd:Cell("ULTIMA")				:SetValue(QMPF->ULTIMA)
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
	If(mv_par10 == 2 )
							
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
	

			Aadd( aEmpresas , { "01" , {{ "01" , "01" , "0" }} } )
		
			RestArea(xAliasSM0)
			

			Aadd( aEmpresas , { "04" , {{ "01" , "01" , "0" }} } )
		
			RestArea(xAliasSM0)
			
	
     
  //cQuery += " FROM SD1" + aEmpresas[nX,1] + "0 SD1" 
	//Monta a query dos itens 
        

				cQr := " SELECT 
				cQr += " 		VENDMES.CODCLI			CODCLI
				cQr += " 		,VENDMES.LOJA			LOJA
				cQr += " 		,VENDMES.RAZAOSOCIAL	RAZAOSOCIAL
				cQr += " 		,VENDMES.NOMEREDUZ		NOMEREDUZ
				cQr += " 		,VENDMES.BAIRRO			BAIRRO
				cQr += " 		,VENDMES.CIDADE			CIDADE
				cQr += " 		,VENDMES.ESTADO			UF
				cQr += " 		,VENDMES.VENDEDOR		VENDEDOR
				cQr += " 		,VENDMES.NOMEVEND		NOMEVEND
				cQr += " 		,VENDMES.JANEIRO		JANEIRO
				cQr += " 		,VENDMES.FEVEREIRO		FEVEREIRO
				cQr += " 		,VENDMES.MARCO			MARCO
				cQr += " 		,VENDMES.ABRIL			ABRIL
				cQr += " 		,VENDMES.MAIO			MAIO
				cQr += " 		,VENDMES.JUNHO			JUNHO
				cQr += " 		,VENDMES.JULHO			JULHO
				cQr += " 		,VENDMES.AGOSTO			AGOSTO
				cQr += " 		,VENDMES.SETEMBRO		SETEMBRO
				cQr += " 		,VENDMES.OUTUBRO		OUTUBRO
				cQr += " 		,VENDMES.NOVEMBRO		NOVEMBRO
				cQr += " 		,VENDMES.DEZEMBRO		DEZEMBRO
				cQr += " 		,VENDMES.ULTIMA		ULTIMA
				cQr += " 
				cQr += " FROM (
				
				For nX := 1 To Len(aEmpresas)  
				
				cQr += " SELECT	SA1.A1_COD		CODCLI
				cQr += " 		,SA1.A1_LOJA	LOJA
				cQr += " 		,SA1.A1_NOME	RAZAOSOCIAL
				cQr += " 		,SA1.A1_NREDUZ	NOMEREDUZ
				cQr += " 		,SA1.A1_BAIRRO	BAIRRO
				cQr += " 		,SA1.A1_MUN		CIDADE
				cQr += " 		,SA1.A1_EST		ESTADO
				cQr += " 		,SA1.A1_VEND	VENDEDOR
				cQr += " 		,SA3.A3_NOME	NOMEVEND
				cQr += " 		,
				cQr += " 		(
				cQr += " 			ISNULL(
				cQr += " 					(SELECT SUM(SD2.D2_TOTAL)
				cQr += " 					FROM	SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE SD2.D_E_L_E_T_ = ''
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA
				cQr += " 						AND SD2.D2_EMISSAO BETWEEN  '" + mv_par09 + "0101'  AND '" + mv_par09 + "0131' 
				cQr += " 						AND SD2.D2_CF IN ('5101','5102','5124','5401','5403','5405','6101', '6102','6107','6108','6110','6116','6118','6119', '6124','6125','6401','6404','7101','7102')),0)
				cQr += " 		)				JANEIRO
				cQr += " 		,		(
				cQr += " 			ISNULL(
				cQr += " 					(SELECT SUM(SD2.D2_TOTAL)
				cQr += " 					FROM	SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE SD2.D_E_L_E_T_ = ''
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA
				cQr += " 						AND SD2.D2_EMISSAO BETWEEN '" + mv_par09 + "0201'  AND '" + mv_par09 + "0229'
				cQr += " 						AND SD2.D2_CF IN ('5101','5102','5124','5401','5403','5405','6101', '6102','6107','6108','6110','6116','6118','6119', '6124','6125','6401','6404','7101','7102')),0)
				cQr += " 		)				FEVEREIRO
				cQr += " 		,		(
				cQr += " 			ISNULL(
				cQr += " 					(SELECT SUM(SD2.D2_TOTAL)
				cQr += " 					FROM	SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE SD2.D_E_L_E_T_ = ''						
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA
				cQr += " 						AND SD2.D2_EMISSAO BETWEEN '" + mv_par09 + "0301'  AND '" + mv_par09 + "0331'
				cQr += " 						AND SD2.D2_CF IN ('5101','5102','5124','5401','5403','5405','6101', '6102','6107','6108','6110','6116','6118','6119', '6124','6125','6401','6404','7101','7102')),0)
				cQr += " 		)				MARCO
				cQr += " 		,		(
				cQr += " 			ISNULL(
				cQr += " 					(SELECT SUM(SD2.D2_TOTAL)
				cQr += " 					FROM	SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE SD2.D_E_L_E_T_ = ''
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA
				cQr += " 						AND SD2.D2_EMISSAO BETWEEN '" + mv_par09 + "0401'  AND '" + mv_par09 + "0430'
				cQr += " 						AND SD2.D2_CF IN ('5101','5102','5124','5401','5403','5405','6101', '6102','6107','6108','6110','6116','6118','6119', '6124','6125','6401','6404','7101','7102')),0)
				cQr += " 		)				ABRIL
				cQr += " 		,		(
				cQr += " 			ISNULL(
				cQr += " 					(SELECT SUM(SD2.D2_TOTAL)
				cQr += " 					FROM SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE SD2.D_E_L_E_T_ = ''
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA
				cQr += " 						AND SD2.D2_EMISSAO BETWEEN '" + mv_par09 + "0501'  AND '" + mv_par09 + "0531'
				cQr += " 						AND SD2.D2_CF IN ('5101','5102','5124','5401','5403','5405','6101', '6102','6107','6108','6110','6116','6118','6119', '6124','6125','6401','6404','7101','7102')),0)
				cQr += " 
				cQr += " 		)				MAIO
				cQr += " 		,		(
				cQr += " 			ISNULL(
				cQr += " 					(SELECT SUM(SD2.D2_TOTAL)
				cQr += " 					FROM SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE SD2.D_E_L_E_T_ = ''
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA						 
				cQr += " 						AND SD2.D2_EMISSAO BETWEEN '" + mv_par09 + "0601'  AND '" + mv_par09 + "0630'
				cQr += " 						AND SD2.D2_CF IN ('5101','5102','5124','5401','5403','5405','6101', '6102','6107','6108','6110','6116','6118','6119', '6124','6125','6401','6404','7101','7102')),0)
				cQr += " 
				cQr += " 		)				JUNHO
				cQr += " 		,		(
				cQr += " 			ISNULL(
				cQr += " 					(SELECT SUM(SD2.D2_TOTAL)
				cQr += " 					FROM SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE SD2.D_E_L_E_T_ = ''
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA						 
				cQr += " 						AND SD2.D2_EMISSAO BETWEEN '" + mv_par09 + "0701'  AND '" + mv_par09 + "0731'
				cQr += " 						AND SD2.D2_CF IN ('5101','5102','5124','5401','5403','5405','6101', '6102','6107','6108','6110','6116','6118','6119', '6124','6125','6401','6404','7101','7102')),0)
				cQr += " 
				cQr += " 		)				JULHO
				cQr += " 		,		(
				cQr += " 			ISNULL(
				cQr += " 					(SELECT SUM(SD2.D2_TOTAL)
				cQr += " 					FROM SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE SD2.D_E_L_E_T_ = ''
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA						 
				cQr += " 						AND SD2.D2_EMISSAO BETWEEN '" + mv_par09 + "0801'  AND '" + mv_par09 + "0831'
				cQr += " 						AND SD2.D2_CF IN ('5101','5102','5124','5401','5403','5405','6101', '6102','6107','6108','6110','6116','6118','6119', '6124','6125','6401','6404','7101','7102')),0)
				cQr += " 
				cQr += " 		)				AGOSTO
				cQr += " 		,		(
				cQr += " 			ISNULL(
				cQr += " 					(SELECT SUM(SD2.D2_TOTAL)
				cQr += " 					FROM SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE SD2.D_E_L_E_T_ = ''
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA						 
				cQr += " 						AND SD2.D2_EMISSAO BETWEEN '" + mv_par09 + "0901'  AND '" + mv_par09 + "0930'
				cQr += " 						AND SD2.D2_CF IN ('5101','5102','5124','5401','5403','5405','6101', '6102','6107','6108','6110','6116','6118','6119', '6124','6125','6401','6404','7101','7102')),0)
				cQr += " 
				cQr += " 		)				SETEMBRO
				cQr += " 		,		(
				cQr += " 			ISNULL(
				cQr += " 					(SELECT SUM(SD2.D2_TOTAL)
				cQr += " 					FROM SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE SD2.D_E_L_E_T_ = ''
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA						 
				cQr += " 						AND SD2.D2_EMISSAO BETWEEN '" + mv_par09 + "1001'  AND '" + mv_par09 + "1031'
				cQr += " 						AND SD2.D2_CF IN ('5101','5102','5124','5401','5403','5405','6101', '6102','6107','6108','6110','6116','6118','6119', '6124','6125','6401','6404','7101','7102')),0)
				cQr += " 		)				OUTUBRO
				cQr += " 		,		(
				cQr += " 			ISNULL(
				cQr += " 					(SELECT SUM(SD2.D2_TOTAL)
				cQr += " 					FROM SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE SD2.D_E_L_E_T_ = ''
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA						 
				cQr += " 						AND SD2.D2_EMISSAO BETWEEN '" + mv_par09 + "1101'  AND '" + mv_par09 + "1130'
				cQr += " 						AND SD2.D2_CF IN ('5101','5102','5124','5401','5403','5405','6101', '6102','6107','6108','6110','6116','6118','6119', '6124','6125','6401','6404','7101','7102')),0)
				cQr += " 		)				NOVEMBRO
				cQr += " 		,		(
				cQr += " 			ISNULL(
				cQr += " 					(SELECT SUM(SD2.D2_TOTAL)
				cQr += " 					FROM SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE SD2.D_E_L_E_T_ = '' 
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA						 
				cQr += " 						AND SD2.D2_EMISSAO BETWEEN '" + mv_par09 + "1201'  AND '" + mv_par09 + "1231'			
				cQr += " 						AND SD2.D2_CF IN ('5101','5102','5124','5401','5403','5405','6101', '6102','6107','6108','6110','6116','6118','6119', '6124','6125','6401','6404','7101','7102')),0)
				cQr += " 		)				DEZEMBRO
				cQr += " 		,ISNULL(
				cQr += " 					(SELECT MAX(SD2.D2_EMISSAO)
				cQr += " 					FROM SD2" + aEmpresas[nX,1] + "0 SD2
				cQr += " 					WHERE	SD2.D_E_L_E_T_ = ''
				cQr += " 						AND SD2.D2_CLIENTE = SA1.A1_COD
				cQr += " 						AND SD2.D2_LOJA	=  SA1.A1_LOJA)						
				cQr += " 		,'19000101')				ULTIMA
				cQr += " FROM SA1010	SA1
				cQr += " INNER JOIN	SA3010		SA3
				cQr += " 		ON	SA1.A1_VEND = SA3.A3_COD
				cQr += " WHERE	SA1.D_E_L_E_T_ = ''
				cQr += " 		AND SA1.A1_EST BETWEEN  '" + mv_par05 + "' AND '" + mv_par06 + "'
				cQr += " 		AND SA1.A1_MUN BETWEEN  '" + mv_par03 + "' AND '" + mv_par04 + "'
				If nX < Len(aEmpresas)
          			cQr +=  " UNION "
     					Endif
Next
				cQr += " )	AS	VENDMES	

							

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
                    "De Cliente?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("A1_COD")[01]                     ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SA1"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe o Codigo inicial do Cliente "     ,;
                     "" }       ; // array de help
                  }                                             ;
      )
  
  	//Cria as perguntas do array  02    
        aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até Cliente?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("A1_COD")[01]                     ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SA1"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe o Código final do cliente"     ,;
                     "" }       ; // array de help
                  }                                             ;
      )
 
	//Cria as perguntas do array  03
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Cidade?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("A1_MUN")[01]                     ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "CC2"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe o Codigo inicial da cidade  "     ,;
                     "" }       ; // array de help
                  }                                             ;
      )
      
  	//Cria as perguntas do array  04
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Cidade?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("A1_MUN")[01]                     ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "CC2"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe o Codigo do final da cidade"     ,;
                     "" }       ; // array de help
                  }                                             ;
      )
      
 	//Cria as perguntas do array  05
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "De UF?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    2                     ,; // tamanho
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
                    {"Informe o Codigo inicial da cidade  "     ,;
                     "" }       ; // array de help
                  }                                             ;
      )
      
  	//Cria as perguntas do array  06
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até UF"                          ,; // descrição
                    "C"                                        ,; // tipo
                    2                     ,; // tamanho
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
                    {"Informe o Codigo do final da cidade"     ,;
                     "" }       ; // array de help
                  }                                             ;
      )     
      
        	//Cria as perguntas do array  07
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "De Vendedor?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("A3_COD")[01]                     ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SA3"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe o Codigo inicial do vendedor"     ,;
                     "" }       ; // array de help
                  }                                             ;
      )
      
              	//Cria as perguntas do array  08
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Até Vendedor?"                          ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("A3_COD")[01]                     ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    "SA3"                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                                         ,; // item 1 do combo
                    ""                                         ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                    {"Informe o Codigo final do vendedor"     ,;
                     "" }       ; // array de help
                  }                                             ;
      )

	//Cria as perguntas do array  09
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Ano?"                                 ,; // descrição
                    "C"                                        ,; // tipo
                    4                                          ,; // tamanho
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
                    {"Informe o ano a ser considerado"  ,;
                     "" }       ; // array de help
                  }                                             ;
      )
    
      
	//Cria as perguntas do array  10
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
                    "***"                           ,; // item 1 do combo
                    "***"                       ,; // item 2 do combo
                    "***"                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                   {"Informe o tipo de relatório." }            ; // array de help
                  }                                             ;
      )   
      
            	//Cria as perguntas do array  11
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
                   {"Informe a filial a ser considerada" }            ; // array de help
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