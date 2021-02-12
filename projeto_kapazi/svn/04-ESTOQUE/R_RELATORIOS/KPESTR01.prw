/**---------------------------------------------------------------------------------------------------------------**/
/** PROPRIETARIO: KAPAZI                    																													  	 		    **/
/** MODULO			: Estoque   																																									 		**/
/** NOME 				: KPESTR01.RPW																  																									**/
/** FINALIDADE	: RELATORIO DE VENDAS POR MEDIA DE PERIODO                                                        **/
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
/** NOME DA FUNCAO: U_KPESTR01()														                                                      **/
/** DESCRICAO	  	: Gerenciador do Relatório                                  					                					**/
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

User Function KPESTR01()
	
	Private cPerg   	:= "KPESTR01"				//Grupo de pergunta
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
	Local oSecLotes := Nil					//Sessão Lotes
	
	Local oSomNf		:= Nil					//Sessão Soma Diária  
	Local oTotal		:= Nil					//Sessão total geral

	//Cria o relatório
	oReport := TReport():New(cPerg, "Media de Vendas", Nil, {|oReport| ImpRelNl() }, "Este relatório exibe a media de Vendas por período")
		
	//Cria Seção Nota Fiscal
	oSecPd := TRSection():New(oReport, Nil, {}, Nil)
	
	
		//Campos
		TRCell():New(oSecPd, "COD_PRODUTO"			, Nil, "CODIGO"					, PesqPict("SB1", "B1_COD")				, TamSX3("B1_COD")[1])
		TRCell():New(oSecPd, "DESCRI"				, Nil, "DESCRICAO"			, PesqPict("SB1", "B1_DESC")			, TamSX3("B1_DESC")[1])     
		TRCell():New(oSecPd, "TIPO" 						, Nil, "TP"							, PesqPict("SB1", "B1_TIPO")			, TamSX3("B1_TIPO")[1])
		TRCell():New(oSecPd, "LOCALP"						, Nil, "LOCAL"					, PesqPict("SB1", "B1_LOCPAD")		, TamSX3("B1_LOCPAD")[1])
		TRCell():New(oSecPd, "UNIDADE"					, Nil, "UN"							, PesqPict("SB1", "B1_UM")	 			, TamSX3("B1_UM")[1])
		TRCell():New(oSecPd, "GRUPO"						, Nil, "GRUPO"					, PesqPict("SB1", "B1_GRUPO")			, TamSX3("B1_GRUPO")[1])
		TRCell():New(oSecPd, "COD_SUBGRUPO"			, Nil, "COD GRUPO"			, PesqPict("SB1", "B1_GRUPO")			, TamSX3("B1_GRUPO")[1])
		TRCell():New(oSecPd, "SUBGRUPO"					, Nil, "SUBGRUPO"				, PesqPict("SZ2", "Z2_SBGRUP")		, TamSX3("Z2_SBGRUP")[1])
		TRCell():New(oSecPd, "PESO"							, Nil, "PESO"						, PesqPict("SB1", "B1_PESO")			, TamSX3("B1_PESO")[1])
		TRCell():New(oSecPd, "SALDO_ATUAL"			, Nil, "SLD ATUAL"			, PesqPict("SB2", "B2_QATU")			, TamSX3("B2_QATU")[1])
		TRCell():New(oSecPd, "QTD_PEDIDO"				, Nil, "QTD PED VEND"		, PesqPict("SB2", "B2_QPEDVEN")		, TamSX3("B2_QPEDVEN")[1])
		TRCell():New(oSecPd, "QTD_DISPONIVEL"		, Nil, "QTD DISPONIVEL"	, PesqPict("SB2", "B2_QATU")			, TamSX3("B2_QATU")[1])
		TRCell():New(oSecPd, "VEND"							, Nil, "QTD VENDIDO"		, PesqPict("SB2", "B2_QATU")			, TamSX3("B2_QATU")[1])
		TRCell():New(oSecPd, "DEVOL"						, Nil, "QTD DEVOLVIDO"	, PesqPict("SB2", "B2_QATU")			, TamSX3("B2_QATU")[1])
		TRCell():New(oSecPd, "QTD_MES"					, Nil, "QTD MES"				, PesqPict("SB2", "B1_LOCPAD")			, TamSX3("B1_LOCPAD")[1])
		TRCell():New(oSecPd, "QTD_VENDIDO"			, Nil, "VENDIDO"		, PesqPict("SB2", "B2_QATU")			, TamSX3("B2_QATU")[1])
		TRCell():New(oSecPd, "MEDIA"						, Nil, "MEDIA"					, PesqPict("SB2", "B2_QATU")			, TamSX3("B2_QATU")[1])
		//TRCell():New(oSecPd, "AUTONOMIA"			, Nil, "AUTONOMIA"			, PesqPict("SB2", "B2_QATU")			, TamSX3("B2_QATU")[1])
		TRCell():New(oSecPd, "PESO_MEDIO"				, Nil, "PESO MEDIO "		, PesqPict("SB2", "B2_QATU")			, TamSX3("B2_QATU")[1])
								
     

Return oReport 

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNCAO: ImpRelNl()							  							                                                      **/
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

Static Function ImpRelNl()

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
  		
			oSecPd:Cell("COD_PRODUTO")	:SetValue(QMPF->COD_PRODUTO)
			//oSecPd:Cell("COD_PRODUTO")	:SetAlign("LEFT")
			 
			oSecPd:Cell("DESCRI")				:SetValue(QMPF->DESCRI)
		 //	oSecPd:Cell("DESCRI")				:SetAlign("LEFT")
			 
			oSecPd:Cell("TIPO")					:SetValue(QMPF->TIPO)
		 //	oSecPd:Cell("TIPO")					:SetAlign("LEFT")
			 
			oSecPd:Cell("LOCALP")				:SetValue(QMPF->LOCALP) 
		 //	oSecPd:Cell("LOCALP")				:SetAlign("LEFT")
			  
		  oSecPd:Cell("UNIDADE")			:SetValue(QMPF->UNIDADE)
		  //oSecPd:Cell("UNIDADE")			:SetAlign("LEFT")
		   
			oSecPd:Cell("GRUPO")				:SetValue(QMPF->GRUPO) 
			//oSecPd:Cell("GRUPO")				:SetAlign("LEFT")
			
			oSecPd:Cell("COD_SUBGRUPO")	:SetValue(QMPF->COD_SUBGRUPO)
		 //	oSecPd:Cell("COD_SUBGRUPO")	:SetAlign("LEFT")
			 		
			oSecPd:Cell("SUBGRUPO")			:SetValue(QMPF->SUBGRUPO)
			//oSecPd:Cell("SUBGRUPO")			:SetAlign("LEFT")
			
			oSecPd:Cell("PESO")					:SetValue(QMPF->PESO)  
			//oSecPd:Cell("PESO")					:SetAlign("LEFT") 
			
			oSecPd:Cell("SALDO_ATUAL")	:SetValue(QMPF->SALDO_ATUAL) 
			//oSecPd:Cell("SALDO_ATUAL")	:SetAlign("LEFT")
			
			oSecPd:Cell("QTD_PEDIDO")		:SetValue(QMPF->QTD_PEDIDO)
			//oSecPd:Cell("QTD_PEDIDO")		:SetAlign("LEFT") 
			
			oSecPd:Cell("QTD_DISPONIVEL"):SetValue(QMPF->QTD_DISPONIVEL)   
			//oSecPd:Cell("QTD_DISPONIVEL"):SetAlign("LEFT")
			
			oSecPd:Cell("VEND")					:SetValue(QMPF->VEND)
			//oSecPd:Cell("VEND")				  :SetAlign("LEFT")         
			
			oSecPd:Cell("DEVOL")				:SetValue(QMPF->DEVOL)
		 //	oSecPd:Cell("DEVOL")				:SetAlign("LEFT")      
			
			oSecPd:Cell("QTD_MES")			:SetValue(QMPF->QTD_MES)
			//oSecPd:Cell("QTD_MES")			:SetAlign("LEFT")    
			
			oSecPd:Cell("QTD_VENDIDO")	:SetValue(QMPF->QTD_VENDIDO)
			//oSecPd:Cell("QTD_VENDIDO")	:SetAlign("LEFT")  
			
			oSecPd:Cell("MEDIA")				:SetValue(QMPF->MEDIA)
			//oSecPd:Cell("MEDIA")				:SetAlign("LEFT")
			
						
			//oSecPd:Cell("AUTONOMIA")				:SetValue(QMPF->AUTONOMIA)
			//oSecPd:Cell("MEDIA")				:SetAlign("LEFT")        
			
			oSecPd:Cell("PESO_MEDIO")		:SetValue(QMPF->PESO_MEDIO)
			//oSecPd:Cell("QTD_MEDIO")		:SetAlign("LEFT")
			
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
	
		
	If(mv_par05 == 3)

			Aadd( aEmpresas , { SM0->M0_CODIGO , {{ SM0->M0_CODFIL , SubStr(SM0->M0_FILIAL,1,4) , 0 }} } )
		
			RestArea(xAliasSM0)
			
	EndIf	
	
     
  //cQuery += " FROM SD1" + aEmpresas[nX,1] + "0 SD1" 
	//Monta a query dos itens
	
 	 	cQr := "		SELECT	FINAL.COD_PRODUTO	COD_PRODUTO,
 	 	cQr += "			FINAL.DESCRI	DESCRI,
 	 	cQr += "			FINAL.TIPO		TIPO,
 	 	cQr += "			FINAL.LOCALP	LOCALP,
 	 	cQr += "			FINAL.UNIDADE	UNIDADE,
 	 	cQr += "			FINAL.GRUPO		GRUPO,
 	 	cQr += "			FINAL.COD_SUBGRUPO	COD_SUBGRUPO,
 	 	cQr += "			FINAL.SUBGRUPO		SUBGRUPO,
 	 	cQr += "			FINAL.PESO		PESO,
 	 	cQr += "			SUM(FINAL.SALDO_ATUAL)	SALDO_ATUAL,
 	 	cQr += "			SUM(FINAL.QTD_PEDIDO)	QTD_PEDIDO,
 	 	cQr += "			SUM(FINAL.VEND)	VEND,
 	 	cQr += "			SUM(FINAL.DEVOL)	DEVOL,
 	 	cQr += "			FINAL.QTD_MES	QTD_MES,
 	 	cQr += "			SUM(FINAL.QTD_VENDIDO)	QTD_VENDIDO,
 	 	cQr += "			SUM(FINAL.QTD_DISPONIVEL)	QTD_DISPONIVEL,
 	 	cQr += "			SUM(FINAL.MEDIA)	MEDIA,
 	 	//cQr += "			( CASE 
 	 	//cQr += "	           WHEN SUM(FINAL.QTD_DISPONIVEL) > 0 THEN 
 	 	//cQr += "	           SUM(FINAL.QTD_DISPONIVEL) / ( CASE 
 	 	//cQr += "	                                          WHEN SUM(FINAL.VEND) - SUM(FINAL.DEVOL) >= 0 THEN 
 	 	//cQr += "	           ( SUM(FINAL.VEND) - SUM(FINAL.DEVOL) ) / SUM(FINAL.QTD_MES) 
 	 	//cQr += "	           ELSE 0 
 	 	//cQr += "	                                        END ) 
 	  //cQr += "	           ELSE 0 
 	  //cQr += "	         END )                 AUTONOMIA,
		cQr += "	SUM(FINAL.PESO_MEDIO)	PESO_MEDIO
 	 	cQr += "	FROM
 	 	cQr += "	( 
 	 	cQr += "	SELECT	TAB1.COD			COD_PRODUTO
		cQr += "	,TAB1.DESCRI					DESCRI
		cQr += "	,TAB1.TIPO						TIPO
		cQr += "	,TAB1.LOCALP          LOCALP
		cQr += "	,TAB1.UNIDADE         UNIDADE
		cQr += "	,TAB1.GRUPO           GRUPO
		cQr += "	,TAB1.COD_SUBGRUPO    COD_SUBGRUPO
		cQr += "	,TAB1.SUBGRUPO        SUBGRUPO
		cQr += "	,TAB1.PESO 			PESO
		cQr += "	,SUM(TAB1.SALDO_ATUAL)SALDO_ATUAL
		cQr += "	,SUM(TAB1.QTD_PEDIDO)	QTD_PEDIDO
		cQr += "	,SUM(TAB1.QTD_DISPONIVEL)QTD_DISPONIVEL
		cQr += "	,TAB1.VEND				VEND
		cQr += "	,TAB1.DEVOL			DEVOL
    cQr += "	,TAB1.QTD_MES         QTD_MES 
    cQr += "	,TAB1.VEND -  TAB1.DEVOL QTD_VENDIDO
    cQr += " 	,	( 
		cQr += "	CASE  
		cQr += "	WHEN TAB1.VEND - TAB1.DEVOL >= 0 THEN (TAB1.VEND - TAB1.DEVOL)/TAB1.QTD_MES
		cQr += "	ELSE 0 
		cQr += "	END  )  MEDIA,
		
	  //cQr += "	 (
    //cQr += "   CASE
	  //cQr += "	WHEN	SUM(TAB1.QTD_DISPONIVEL) < 0 THEN
		//cQr += "			SUM(TAB1.QTD_DISPONIVEL)/ ( CASE WHEN TAB1.VEND - TAB1.DEVOL >= 0 THEN ( TAB1.VEND - TAB1.DEVOL ) / TAB1.QTD_MES ELSE 0 END )
		//cQr += "	ELSE	0
		//cQr += "	END) AUTONOMIA,

		cQr += " 		( 
		cQr += "	CASE  
		cQr += "	WHEN TAB1.VEND - TAB1.DEVOL = 0 THEN (TAB1.VEND - TAB1.DEVOL)/TAB1.QTD_MES * TAB1.PESO
		cQr += "	ELSE 0 
		cQr += "	END  )  PESO_MEDIO

		cQr += " 	FROM ( 
		
For nX := 1 To Len(aEmpresas)     

		cQr += "	SELECT	 
		cQr += " 	SB1.B1_COD COD
		cQr += " ,SB1.B1_DESC DESCRI
		cQr += " ,SB1.B1_TIPO TIPO
		cQr += " ,SB1.B1_LOCPAD LOCALP
		cQr += " ,SB1.B1_GRUPO GRUPO
		cQr += " ,SB1.B1_UM UNIDADE
		cQr += " ,ISNULL(
		cQr += " (
		cQr += " SELECT	SZ2.Z2_COD
		cQr += " FROM	SZ2010	SZ2
		cQr += " WHERE	SZ2.D_E_L_E_T_ = ''
		cQr += " AND	SZ2.Z2_COD = SB1.B1_SBGRUP 
		cQr += " ),0)COD_SUBGRUPO
		cQr += " ,ISNULL(
		cQr += " (
		cQr += " SELECT	SZ2.Z2_SBGRUP 
		cQr += " FROM	SZ2010	SZ2
		cQr += " WHERE	SZ2.D_E_L_E_T_ = ''
		cQr += " AND	SZ2.Z2_COD = SB1.B1_SBGRUP 

		cQr += " ),0)SUBGRUPO
		cQr += " ,SB1.B1_PESO PESO
		cQr += " ,SB1.B1_FILIAL	FILIALB1
		cQr += " ,SB2.B2_QATU SALDO_ATUAL
		cQr += " ,SB2.B2_QPEDVEN QTD_PEDIDO
		cQr += " ,SB2.B2_QATU - SB2.B2_QPEDVEN	QTD_DISPONIVEL
		cQr += " ,ISNULL(
		cQr += " (
		cQr += " SELECT SUM(SD2.D2_QUANT)
		cQr += " FROM	SD2" + aEmpresas[nX,1] + "0 SD2
		cQr += " WHERE	SD2.D_E_L_E_T_ = ''
		cQr += " AND SD2.D2_COD = SB2.B2_COD
		cQr += " AND SD2.D2_EMISSAO BETWEEN '" + Dtos(mv_par03) + "' AND '" + Dtos(mv_par04) + "'
		cQr += " AND SD2.D2_CF IN (	'5101','5102','5124','5401','5403','5405','6101',
		cQr += "										'6102','6107','6108','6110','6116','6118','6119',
		cQr += "										'6124','6125','6401','6404','7101','7102')
		
				If(mv_par05 == 1) 
					
						cQr += " AND SD2.D2_FILIAL = '" + mv_par06 + "'  
						
				EndIf
		cQr += " ),0)	VEND
		cQr += " ,ISNULL(
		cQr += " (
		cQr += " SELECT SUM(SD1.D1_QUANT)
		cQr += " FROM	SD1" + aEmpresas[nX,1] + "0	SD1
		cQr += " WHERE	SD1.D_E_L_E_T_ = ''
		cQr += " AND SD1.D1_COD  = SB2.B2_COD
		cQr += " AND SD1.D1_EMISSAO BETWEEN '" + Dtos(mv_par03) + "' AND '" + Dtos(mv_par04) + "'
		cQr += " AND SD1.D1_CF IN ('1201','1202','1410','1411','2201','2202','2410','2411')
				
				If(mv_par05 == 1) 
				
						cQr += " AND SD1.D1_FILIAL = '" + mv_par06 + "' 
						
		    EndIf
		    
		cQr += " ),0) DEVOL,
		//cQr += " ,ISNULL((DATEDIFF( MONTH,'" + Dtos(mv_par03) + "' , '" + Dtos(mv_par04) + "' )),0) QTD_MES
		cQr += " CASE WHEN ISNULL((DATEDIFF( MONTH,'" + Dtos(mv_par03) + "' , '" + Dtos(mv_par04) + "' )),1) > 0THEN ISNULL((DATEDIFF( MONTH,'" + Dtos(mv_par03) + "' , '" + Dtos(mv_par04) + "' )),1)ELSE  1	END QTD_MES,
		cQr += " SB2.B2_LOCAL LOCALMOV
		cQr += " ,SB2.B2_FILIAL FILIALB2
	
		cQr += " FROM	 SB2" + aEmpresas[nX,1] + "0 SB2
		cQr += " ,SB1010 SB1
		cQr += " WHERE	SB2.D_E_L_E_T_ = ''
		cQr += " 		AND	SB1.D_E_L_E_T_ = ''
		cQr += "		AND SB1.B1_COD = SB2.B2_COD
		
			If(mv_par05 == 1)
			
				cQr += "		AND SB2.B2_FILIAL = '" + mv_par06 + "'   
				
			EndIf 
			
			If(!empty(ALLTRIM(mv_par07)))
					
					cQr += "    AND SB1.B1_DESC LIKE '%" + ALLTRIM(mv_par07) + "%'	
			
			EndIf
			
		cQr += "		AND SB2.B2_COD BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'

     If nX < Len(aEmpresas)
          cQr +=  " UNION "
     Endif
Next
		cQr += "	) AS TAB1

		cQr += " GROUP BY 
		cQr += " TAB1.COD
		cQr += " ,TAB1.DESCRI
		cQr += " ,TAB1.TIPO
		cQr += " ,TAB1.LOCALP
		cQr += " ,TAB1.UNIDADE
		cQr += " ,TAB1.GRUPO
		cQr += " ,TAB1.COD_SUBGRUPO
		cQr += " ,TAB1.SUBGRUPO
		cQr += " ,TAB1.QTD_MES
		cQr += " ,TAB1.VEND
		cQr += " ,TAB1.DEVOL
		cQr += " ,TAB1.PESO  
		
		cQr += " 		 )	FINAL
       
		cQr += "  GROUP BY

		cQr += " 		FINAL.COD_PRODUTO,
		cQr += " 		FINAL.DESCRI,
		cQr += " 		FINAL.TIPO,
		cQr += " 		FINAL.LOCALP,
		cQr += " 		FINAL.UNIDADE,
		cQr += " 		FINAL.GRUPO,
		cQr += " 		FINAL.COD_SUBGRUPO,
		cQr += " 		FINAL.SUBGRUPO,
		cQr += " 		FINAL.PESO,
		cQr += " 		FINAL.QTD_MES

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
/** 28/05/2014 	| Marcos Sulivan        |                        |   																						**/
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
   Local ni
 
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
                    "Grupo Emp."                       ,; // item 2 do combo
                    "Empresa"                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                   {"Informe o tipo de relatório." }            ; // array de help
                  }                                             ;
      )
      
                  	//Cria as perguntas do array  6
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
      
                        	//Cria as perguntas do array  7
  aAdd( aParPerg, { cPerg                                      ,; // nome da pergunta
                    "Descricao"                		        		 ,; // descrição
                    "C"                                        ,; // tipo
                    TamSx3("B1_DESC")[01]                                          ,; // tamanho
                    0                                          ,; // decimais
                    1                                          ,; // indice de pre seleção (combo)
                    "G"                                        ,; // tipo de objeto
                    ""                                         ,; // rotina de validação do Sx1
                    ""                                         ,; // F3
                    ""                                         ,; // grupo de perguntas
                    ""                           							 ,; // item 1 do combo
                    ""                       									 ,; // item 2 do combo
                    ""                                         ,; // item 3 do combo
                    nil                                        ,; // item 4 do combo
                    nil                                        ,; // item 5 do combo
                   {"Informe a descricao contiga em qualquer posicao" }            ; // array de help
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