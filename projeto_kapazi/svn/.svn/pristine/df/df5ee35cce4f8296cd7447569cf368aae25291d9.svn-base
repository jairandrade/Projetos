
/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Atualização                                             !
+------------------+----------------S-----------------------------------------+
!Modulo            ! FAT - Faturamento     	                                  !
+------------------+---------------------------------------------------------+
!Nome              ! M460FIM                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! P.E. Após a gravação da NF e títulos					 !
!                  !                                                         !
+------------------+---------------------------------------------------------+
!Autor             ! KELLEN ZIEM                                      !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 01/10/2011                                              !
+------------------+---------------------------------------------------------+
*/
// Compilado em produção -- incluido campos memo no titulo -- Andre/Rsac -- 10.08.2017 00:10hrs
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

User Function M460FIM()
Local aArea			:= GetArea()
Local _cPedido
Local cMSGPDV 		:= ""
Local nPrcJr 		:= IIf(SF2->F2_TIPO$"B|D",0,SA1->A1_PORCJUR)  //acrescentado por Willian Duda em 26/08/2015 a pedido da Debora  -- Inclusão -- 09.10.2017 -- Andre/Rsac
Local cIdNFSE		:= SC5->C5_XIDVNFK
Local cTipoPVK		:= SC5->C5_XTIPONF
Local lAtvNFM		:= GetMv("KP_ATVNFM",,.F.) //Verifica se a NF mista esta ativa
Private cCondPGK	:= SC5->C5_CONDPAG
Private cQr			:= ""
Private _cLogFtK 	:= ""
Private _dData	 	:= Date()
Private	_cHora	 	:= Time()

If !Empty(cIdNFSE) .AND.  Alltrim(cTipoPVK) == '1' .And. cEmpAnt == "04" .And. cFilAnt == "01" .And. lAtvNFM
	Private cNumNfK		:= ""
	Private cTxtC5kp		:= SC5->C5_MSGCLI //E1_XINFOKA
EndIf

If ExistBlock("KFATR15")
	U_KFATR15("05",SC5->C5_NUM,,SF2->F2_DOC,SF2->F2_SERIE)
Endif
// valida se o campo existe
IF SF2->( FieldPos("F2_K_USRCO") ) > 0
	// trava o registro
	RecLock("SF2",.F.)
		// atualiza o usuario que gerou a nota
		SF2->F2_K_USRCO := RetCodUsr()
	// destrava o registro
	MsUnLock("SF2")
Endif


SE1->(dbSetOrder(1))
if SE1->(dbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC))
	While SE1->(!Eof()) .and. xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC==SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM
		RecLock("SE1",.F.)
		SE1->E1_X_POR := SC5->C5_X_POR 
		SE1->E1_MSGCLI:= SC5->C5_MSGCLI   // ANDRE/RSAC  -- 04.08.2017 
		SE1->E1_MSGPDV:= u_MSGCLI() // Andre/Rsac -- 08.08.2017
		SE1->E1_XCONDPA := SC5->C5_CONDPAG   // 16.08.2017 -- Andre/Rsac inclusao da coluna condiçao pagamento no browser do bordero
		SE1->E1_PORCJUR := nPrcJr //acrescentado por Willian Duda em 26/08/2015 a pedido da Debora -- Inclusão -- 09.10.2017 -- Andre/Rsac
		SE1->(MsUnLock())
		SE1->(dbSkip())
	Enddo
Endif

// Ricardo Luiz da Rocha 21/11/2011 GNSJC
_cPedido:=sc5->c5_num

if sc5->(dbseek(xfilial()+_cPedido,.f.).and.reclock(alias(),.f.))
	sc5->c5_xsitlib:=u_KpFatC01(_cPedido)
	
	//alert(Procname()+": Resultado: "+sc5->c5_xsitlib)
	
	sc5->(msunlock())
endif

//Verifica se é o pedido original
If (Empty(SC5->C5_K_PO)) .And. Empty(cIdNFSE) .And. Alltrim(SC5->C5_K_OPER) != '08' .And. Alltrim(SC5->C5_K_OPER) != '14' .And. Alltrim(SC5->C5_XGERASV) <> "S"
	
	//Verifica gera pedido "Intangíveis"
	//EM 002/06/2016
	//	GeraIntang()
	GeraIntang(SC5->C5_EMPDEST,"01")  //FIXO "01" Sempre filial 01 Matriz
	
EndIf

// ---------------------------------------------------
// INTREGRACAOO MADEIRAMADEIRA -- GOlive            
// ---------------------------------------------------
If ExistBlock("M050105")
	U_M050105(SF2->F2_DOC,SF2->F2_SERIE)
Endif

//Validacoes para NFMista e Supplier da Empresa 0401
If cEmpAnt == '04' .And. cFilAnt == "01"

	If !Empty(cIdNFSE) .AND.  Alltrim(cTipoPVK) == '1' .And. lAtvNFM .And. SC5->C5_XPVSPC  != 'S' //Validacao para NFMista - NF gerada para produto
		Reclock("SF2",.F.)
		SF2->F2_XIDVNFK := cIdNFSE
		SF2->F2_XTIPONF	:= "1" //Produto --- XINDNFMIST
		MsUnlock()
		
		cQr := " UPDATE SE1040
		cQr += " SET E1_XIDVNFK = '"+cIdNFSE+"'
		cQr += " WHERE D_E_L_E_T_ = ''
		cQr += " 	AND E1_PREFIXO = '"+SF2->F2_SERIE+"'
		cQr += " 	AND E1_NUM = '"+SF2->F2_DOC+"'
		cQr += " 	AND E1_TIPO = 'NF'
		TcSqlExec(cQr)
		
		cNumNfK		:= SF2->F2_DOC
		
		Conout("Gerando NFSE")
		xGeraNFSE(cIdNFSE)
		
		xGerFKAP(cIdNFSE) //Liquidacao-Fatura
		xAtDesC(cIdNFSE)	//Atualiza o campo observacao da fatura
		
	EndIf
	
	//Supplier - NFmista
	If !Empty(cIdNFSE) .AND.  Alltrim(cTipoPVK) == '1' .And. lAtvNFM .And. SC5->C5_XPVSPC  == 'S' //Validacao para NFMista - NF gerada para produto
		Reclock("SF2",.F.)
		SF2->F2_XIDVNFK := cIdNFSE
		SF2->F2_XTIPONF	:= "1" //Produto --- XINDNFMIST
		SF2->F2_XPVSPP := 'S'
		MsUnlock()
		
		cQr := " UPDATE SE1040
		cQr += " SET E1_XIDVNFK = '"+cIdNFSE+"'
		cQr += " WHERE D_E_L_E_T_ = ''
		cQr += " 	AND E1_PREFIXO = '"+SF2->F2_SERIE+"'
		cQr += " 	AND E1_NUM = '"+SF2->F2_DOC+"'
		cQr += " 	AND E1_TIPO = 'NF'
		TcSqlExec(cQr)
		
		cNumNfK		:= SF2->F2_DOC
		
		Conout("Gerando NFSE")
		xGeraNFSE(cIdNFSE)
		
		xGerFSUP(cIdNFSE) 	//Liquidacao-Fatura Supplier
		xAtDesC(cIdNFSE)	//Atualiza o campo observacao da fatura
		VerSPLim()//Ajuste de limite supplier --- para os casos em que nao for NF mista
	EndIf
	
	//Tratativa para outros pedidos supplier
	If Empty(cIdNFSE) .AND.  Alltrim(cTipoPVK) == '1' .And. SC5->C5_XPVSPC  == 'S'  //(pedido supplier == S)
		xGerFSPP() 	//Liquidacao-//Faturas supplier - outros pedidos
		VerSPLim()//Ajuste de limite supplier --- para os casos em que nao for NF mista
	EndIf

EndIf

//Verificacoes da NFmista de outras filiais da empresa 04(02-03-04-05)
If cEmpAnt == '04' .And. cFilAnt != "01"
	
	If !Empty(cIdNFSE) .AND.  Alltrim(cTipoPVK) == '1' .And. lAtvNFM //.And. SC5->C5_XPVSPC  != 'S' //Validacao para NFMista - NF gerada para produto
			
			If  Alltrim(SC5->C5_XPVSPC) == 'S'
					Reclock("SF2",.F.)
					SF2->F2_XIDVNFK := cIdNFSE
					SF2->F2_XTIPONF	:= "1" //Produto --- XINDNFMIST
					SF2->F2_XPVSPP := 'S'
					SF2->(MsUnlock())
				Else
					Reclock("SF2",.F.)
					SF2->F2_XIDVNFK := cIdNFSE
					SF2->F2_XTIPONF	:= "1" //Produto --- XINDNFMIST
					SF2->(MsUnlock())
			EndIf
			
			cQr := " UPDATE SE1040
			cQr += " SET E1_XIDVNFK = '"+cIdNFSE+"'
			cQr += " WHERE D_E_L_E_T_ = ''
			cQr += " 	AND E1_PREFIXO = '"+SF2->F2_SERIE+"'
			cQr += " 	AND E1_NUM = '"+SF2->F2_DOC+"'
			cQr += " 	AND E1_TIPO = 'NF'
			TcSqlExec(cQr)
			
			cNumNfK		:= SF2->F2_DOC
			
			Conout("Gerando NFSE")
			If !StartJob("U_NWNFSEKP", GetEnvServer(), .T., cIdNFSE,cNumNfK)
					MsgInfo("Pedido NFMista nao incluído, informe o TI","KAPAZI")
				Else
					xAtDesC(cIdNFSE)	//Atualiza o campo observacao da fatura
					MsgInfo("Nota Fiscal de serviço emitida com sucesso na Filial 01. ID -> " + cIdNFSE)
			EndIf
			
			If SC5->C5_XPVSPC  == 'S'
				VerSPLim()//Ajuste de limite supplier --- para os casos em que nao for NF mista
			EndIf
		
		ElseIf Empty(cIdNFSE) .AND.  Alltrim(cTipoPVK) == '1' .And. lAtvNFM .And. SC5->C5_XPVSPC  == 'S' //(pedido supplier == S)	
			xGerFSPP() 	//Liquidacao-//Faturas supplier - outros pedidos
			VerSPLim()//Ajuste de limite supplier --- para os casos em que nao for NF mista
			
	EndIf
EndIf

If cEmpAnt == '04'
	If SC5->C5_XPVSPC  == 'S' .And. Empty(SF2->F2_XPVSPP)
		Reclock("SF2",.F.)
		SF2->F2_XPVSPP := 'S'
		SF2->(MsUnlock())
	EndIf
EndIf
//Transmite a NFSe - Adicionado por Antonio
//Comentado pois foi movido para o fonte BETHANOTA
/*
if SF2->F2_SERIE == 'NFS' .And. cEmpAnt == "04" .And. cFilAnt == "01" .And. lAtvNFM
	cCodMun		:= if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )	
	U_nfseXMLUni( cCodMun, "1", SF2->F2_EMISSAO, SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_CLIENTE, SF2->F2_LOJA, "", {} )
	U_xAtuZP6(cIdNFSE)
EndIf
*/

RestArea(aArea)
Return()

/**---------------------------------------------------------------------------------------------------------------**/
/** NOME DA FUNÇÃO: GeraIntang()														                          **/
/** DESCRIÇÃO	  	: Verifica a geração de pedido intangíveis, gera e fatura o pedido      				      **/
/**---------------------------------------------------------------------------------------------------------------**/
/**																		  CRIAÇÃO /ALTERAÇÕES / MANUTENÇÕES                       	   			 				**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Data       	| Desenvolvedor          | Solicitação         | Descrição                                    		**/
/**---------------------------------------------------------------------------------------------------------------**/
/** 05/02/2014 	| Velton Teixeira        | 	                   |   							 																	**/
/**---------------------------------------------------------------------------------------------------------------**/
/**	   					                  				             PARAMETROS     	              		      									**/
/**---------------------------------------------------------------------------------------------------------------**/
/** Nenhum parametro esperado para essa rotina                                                                  	**/
/**---------------------------------------------------------------------------------------------------------------**/

Static Function GeraIntang(cEmpNew, cFilNew )
Local 	nX					:= 0																		//Contador
Local 	nY					:= 0																		//Contador
Local 	aSC5 				:= {}																		//Array de dados da SC5
Local 	aSC6 				:= {}																		//Array de dados da SC6
Local 	aItens			:= {}																		//Linha
Local 	cEmpbkp			:= cFilAnt 															//Empresa atual
Local 	cFilbkp			:= cEmpAnt 															//Filial atual
//EM 02/06/2016
//Local 	cFilNew			:= Substr(GetMv("MV_EMPINT"), 3, 2)     //Nova filial
//Local 	cEmpNew			:= Substr(GetMv("MV_EMPINT"), 1, 2)     //Nova Empresa

Local 	cNum				:= ""																		//Numero do Pedido
Local 	cNumOrig		:= ""																		//Número original do pedido
Local 	nPosFil			:= 0																		//Posição filial
Local 	nPosNum			:= 0																		//Posição numero do pedido
Local 	lConec			:= .F.																	//Conectou no novo ambinete
Private lMsErroAuto := .F.                                  //Erro


//Verifica a houve intagíveis no pedido
If (SC5->C5_K_INTAN > 0) .and. SC5->C5_PVINTAN $ ' S'
	
	//Ordena SX3
	SX3->(DbSetOrder(1))
	
	//Posiciona na tabela de cabeçalho do pedido
	If SX3->(DbSeek("SC5"))
		
		//Loop na SX3
		While (!SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SC5")
			
			//Verifica se o campo é real
			If (SX3->X3_CONTEXT != "V")
				
				//Verifica se existe conteúdo
				If (!Empty(SC5->&(SX3->X3_CAMPO)) .OR. Alltrim(SX3->X3_CAMPO) == "C5_K_PO")
					
					//Verifica os campos
					Do Case
						
						//Nota|Série|Numero do pedido
						//						Case (Alltrim(SX3->X3_CAMPO) $ "C5_NUM")
						
						//Adiciona o dado ao array do cabeçalho
						//							Aadd(aSC5, {SX3->X3_CAMPO, Space(06), Nil})
						
						//Valores
						Case (Alltrim(SX3->X3_CAMPO) == "C5_XTOTMER")
							
							//Adiciona o valor
							Aadd(aSC5, {SX3->X3_CAMPO, (SC5->&(SX3->X3_CAMPO) * (100 - SC5->C5_K_INTAN) / SC5->C5_K_INTAN), Nil})
							
							//Percentual do pedido
						Case (Alltrim(SX3->X3_CAMPO) == "C5_K_INTAN")
							
							//Adiciona o valor
							Aadd(aSC5, {SX3->X3_CAMPO, 100 - SC5->&(SX3->X3_CAMPO), Nil})
							
							//Percentual do pedido
						Case (Alltrim(SX3->X3_CAMPO) == "C5_K_PO")
							
							//Adiciona o valor
							//alterado em 16/07/14 - grava a filial origem junto com o pedido original
							//alterado em 16/03/16 - grava a empresa/filial origem junto com o pedido original
							//Aadd(aSC5, {SX3->X3_CAMPO, SC5->C5_NUM, Nil})
							Aadd(aSC5, {SX3->X3_CAMPO, cEmpAnt+SC5->C5_FILIAL+SC5->C5_NUM, Nil})

							//EM 06/06/2017
							//Tipode operacao
						Case (Alltrim(SX3->X3_CAMPO) == "C5_K_OPER")
							
							//Adiciona o valor
							Aadd(aSC5, {SX3->X3_CAMPO, ALLTRIM(GetMv("MV_OPERINT")), Nil})
							//ATE AQUI - EM 06/06/2017
							
							//Nota|Série|Numero do pedido
						Case (Alltrim(SX3->X3_CAMPO) $ "C5_TIPO|C5_CLIENTE|C5_CLIENT|C5_LOJAENT|C5_LOJACLI|C5_CGCCLI|C5_TRANSP|C5_TPFRETE|C5_TIPOCLI|C5_CONDPAG|C5_TABELA|C5_VEND1|C5_COMIS1|C5_MENNOTA|C5_USER|C5_MSGNOTA|C5_MSGCLI")
							
							//Adiciona o dado ao array do cabeçalho
							Aadd(aSC5, {SX3->X3_CAMPO, SC5->&(SX3->X3_CAMPO), Nil})
							
					EndCase
					
				EndIf
				
			EndIf
			
			//Próximo registro
			SX3->(DbSkip())
			
		EndDo
		
	EndIf
	
	//Ordena a tabela
	SC6->(DbSetOrder(1))
	
	//Posiciona do pedido
	If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
		
		//Faz loop nos ítens do pedido
		While (!SC6->(Eof()) .AND. SC6->C6_NUM == SC5->C5_NUM)
			//Limpa o array
			aSC6 := {}
			
			//em 22/01/2015
			If SC6->C6_K_INTAN <> 0
				
				//Ordena SX3
				SX3->(DbSetOrder(1))
				
				//Posiciona na tabela de cabeçalho do pedido
				If SX3->(DbSeek("SC6"))
					
					//Loop na SX3
					While (!SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SC6")
						
						//Verifica se o campo é real
						If (SX3->X3_CONTEXT != "V")
							
							//Verifica as opções
							Do Case
								
								//Valores
								Case (Alltrim(SX3->X3_CAMPO) $ "C6_PRCVEN|C6_PRUNIT|C6_XPRECPC|C6_X_PRCVE")
									
									//Adiciona o valor
									Aadd(aSC6, {SX3->X3_CAMPO, (SC6->&(SX3->X3_CAMPO) * (100 - SC5->C5_K_INTAN) / SC5->C5_K_INTAN), Nil})
									
									//Tes
								Case (Alltrim(SX3->X3_CAMPO) == "C6_TES")
									
									//Adiciona o valor
									Aadd(aSC6, {SX3->X3_CAMPO, GetMv("MV_TESINT"), Nil})

									//em 06/06/2017
									//Tipo de operacao
								Case (Alltrim(SX3->X3_CAMPO) == "C6_OPER")
									
									//Adiciona o valor

									Aadd(aSC6, {SX3->X3_CAMPO, ALLTRIM(GetMv("MV_OPERINT")), Nil})
									//Ate aqui - em 06/06/2017
																		
									//Nota fiscal|Série|Número do Pedido|Data do Faturamento
									//								Case (Alltrim(SX3->X3_CAMPO) $ "C6_NUM")
									
									//Adiciona o valor
									//									Aadd(aSC6, {SX3->X3_CAMPO, CriaVar(SX3->X3_CAMPO), Nil})
									
									//Quantidade de venda
								Case (Alltrim(SX3->X3_CAMPO) $ "C6_QTDVEN")
									
									//Grava a quantidade
									nQtdVen	 := SC6->&(SX3->X3_CAMPO)
									
									//Adiciona o dado ao array dos itens do pedido
									Aadd(aSC6, {SX3->X3_CAMPO, SC6->&(SX3->X3_CAMPO), Nil})
									
									//Quantidade liberada
								Case (Alltrim(SX3->X3_CAMPO) $ "C6_QTDLIB")
									
									//Adiciona o dado ao array dos itens do pedido
									Aadd(aSC6, {SX3->X3_CAMPO, nQtdVen, Nil})
									
									//Demais campos
								Case (Alltrim(SX3->X3_CAMPO) $ "C6_PRODUTO|C6_XLARG|C6_XCOMPRI|C6_XQTDPC|C6_ITEM")
									
									//Adiciona o dado ao array dos itens do pedido
									Aadd(aSC6, {SX3->X3_CAMPO, SC6->&(SX3->X3_CAMPO), Nil})
									
							EndCase
							
						EndIf
						
						//Próximo registro na SX3
						SX3->(DbSkip())
						
					EndDo
					
				EndIf
			EndIf
			If Len(aSC6) > 0
				Aadd(aItens, aSC6)
			EndIf
			
			//Próximo refistro SC6
			SC6->(DbSkip())
			
		EndDo
		
	EndIf
	
EndIf

If Len(aSC5) > 0
	conout("INICIO - intangiveis")
	conout(varinfo("aSC5",aSC5))
	//Executa um job
	//MATA410(aSC5,aItens,3)
	
	StartJob("U_KFATA001", GetEnvServer(), .T., aSC5, aItens, cEmpNew, cFilNew)
	
	If lMsErroAuto
		
		//Mostra mensagem de erro
		MostraErro()
		
		CONOUT("ERRO: " + MostraErro())
		
	endif
endif

Return Nil

//função para converter campo Memo - -Andre/Rsac -- 09.08.2017
USER FUNCTION MSGCLI()

cQry:=" SELECT
cQry+="    ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),C5_MSGCLI)),'') AS [MEMO]
cQry+="  FROM "+retSqlName('SC5')
cQry+=" WHERE "
cQry+=" C5_NUM = '"+SD2->D2_PEDIDO+"'

IF Select('TRBMSG') <> 0
	TRBMSG->(DBCloseArea())
EndIF

TcQuery cQry new Alias "TRBMSG"
cMSGPDV:= TRBMSG->MEMO
cMSGPDV:= strtran(cMSGPDV, chr(13),"")  // retira quebra de linha
cMSGPDV:= strtran(cMSGPDV, chr(10)," ") // retira quebra de linha

RETURN(cMSGPDV)


Static Function xGeraNFSE(cIdNFSE)
Local aPvlNfs		:= {}
Local cSerieNFS		:= 'NFS'
Local lMostraCtb	:= .F.
Local lAglutCtb		:= .F.
Local lCtbOnLine	:= .F.
Local lCtbCusto		:= .F.
Local lReajuste		:= .F.
Local nCalAcrs		:= 1
Local nArredPrcLis	:= 1
Local lAtuSA7		:= .F.
Local lECF			:= .F.
Local cEmbExp		:= nil
Local bAtuFin		:= {|| .T.}
Local bAtuPGerNF	:= {||}
Local bAtuPvl		:= {||}
Local bFatSE1		:= {|| .T. }
Local dDataMoe		:= dDatabase

Local aBloqueio		:= {}
Local aParam460		:= Array(30)
Local nIndSF2 		:= SF2->(IndexOrd())
Local nRecSF2 		:= SF2->(Recno())
Local nIndSD2 		:= SD2->(IndexOrd())
Local nRecSD2 		:= SD2->(Recno())
Local aArea 		:= GetArea()
Local cBkp  		:= Alias()
Local lPedSpp		:= .F.

/*
Parametros³ExpA1: Array com os itens a serem gerados                   
          ³ExpC2: Serie da Nota Fiscal                                 
          ³ExpL3: Mostra Lct.Contabil                                  
          ³ExpL4: Aglutina Lct.Contabil                                
          ³ExpL5: Contabiliza On-Line                                  
          ³ExpL6: Contabiliza Custo On-Line                            
          ³ExpL7: Reajuste de preco na nota fiscal                     
          ³ExpN8: Tipo de Acrescimo Financeiro                         
          ³ExpN9: Tipo de Arredondamento                               
          ³ExpLA: Atualiza Amarracao Cliente x Produto                 
          ³ExplB: Cupom Fiscal                                         
          ³ExpCC: Numero do Embarque de Exportacao                     
          ³ExpBD: Code block para complemento de atualizacao dos titulos financeiros.                                     
          ³ExpBE: Code block para complemento de atualizacao dos dados apos a geracao da nota fiscal.                       
          ³ExpBF: Code Block de atualizacao do pedido de venda antes da geracao da nota fiscal                            
*/

If Alltrim(SC5->C5_XPVSPC) == 'S'
	lPedSpp	:= .T.
EndIf
		
//Posiciona no pedido para liberação
DbSelectArea("SC5")
SC5->(DbOrderNickName("XIDNFSE"))
SC5->(DbGoTop())
If SC5->(DbSeek(xFilial("SC5") + cIdNFSE + "2" )) //Posiciona no pedido de serviço
		
		// Liberacao de pedido
		Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
		// Checa itens liberados
		Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
		
		//Grupo de pergunta de geracao de nota
		//Pergunte("MT460A",.F.)
		
		//For nx := 1 to 30
			//aParam460[nx] := &("mv_par" + StrZero(nx, 2) )
		//Next nx
		
		// Caso tenha itens liberados manda faturar
		If Empty(aBloqueio) .And. !Empty(aPvlNfs)
				cNumNFS := MaPvlNfs(aPvlNfs,cSerieNFS,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajuste,nCalAcrs,nArredPrcLis,lAtuSA7,lECF,cEmbExp,bAtuFin,bAtuPGerNF,bAtuPvl,bFatSE1,dDataMoe)
				
				If !Empty(cNumNFS)
						cQr := " UPDATE SE1040
						cQr += " SET E1_XIDVNFK = '"+cIdNFSE+"'
						cQr += " WHERE D_E_L_E_T_ = ''
						cQr += " 	AND E1_PREFIXO = '"+SF2->F2_SERIE+"'
						cQr += " 	AND E1_NUM = '"+SF2->F2_DOC+"'
						cQr += " 	AND E1_TIPO = 'NF'
						TcSqlExec(cQr)
						
						MsgInfo("NFSE gerada com sucesso!!! NF: "+cNumNFS + " -- Serie: " + Alltrim(SF2->F2_SERIE) + " -- ID: "+cIdNFSE, "NFSE KAPAZI")
						Conout("NFSE gerada com sucesso!!! NF: "+cNumNFS + " -- Serie: " + Alltrim(SF2->F2_SERIE) + " -- ID: "+cIdNFSE)
					Else
						MsgInfo("O pedido de venda de serviço possui itens que nao foram liberados!!! ->"+ SC5->C5_NUM + "ID: "+cIdNFSE, "NFSE KAPAZI")
				EndIf
				
			Else
				//MsgInfo("O pedido de venda de serviço possui itens que nao foram liberados!!! -> "+ SC5->C5_NUM + " -- ID: "+cIdNFSE, "NFSE KAPAZI")
		EndIf
	Else
		MsgInfo("NFSE - Não foi possível localizar o pedido de venda(serviço)!!! ID: "+cIdNFSE, "NFSE KAPAZI")
EndIf


If lPedSpp
		Reclock("SF2",.F.)
		SF2->F2_XIDVNFK := cIdNFSE
		SF2->F2_XTIPONF	:= "2" //Servico
		SF2->F2_XPVSPP 	:= "S"
		MsUnlock()
	Else
		Reclock("SF2",.F.)
		SF2->F2_XIDVNFK := cIdNFSE
		SF2->F2_XTIPONF	:= "2" //Servico
		SF2->(MsUnlock())
EndIf

DbSelectArea(cBkp)
RestArea(aArea)
SF2->(DbSetOrder(nIndSF2))
SF2->(DbGoTo(nRecSF2))
SD2->(DbSetOrder(nIndSD2))
SD2->(DbGoTo(nRecSD2))
Return()


Static Function xGerFKAP(cIdNFSE)
Local cParceAt		:= ''
Local cParceNw		:= ''
Local cTipoTit		:= "FT"
Local nValor		:= 0 
Local nZ			:=1
Local cNumLiq
Local cFiltro		:= ""
Local aCab			:= {}
Local aParcelas		:= {}
Local aItens		:= {}
Local lCont			:= .T.
Private cFatura		:= ""
Private lMsErroAuto	:= .F.
 
If Select('FATKAPAZ')<>0
	FATKAPAZ->(DBCloseArea())
Endif

cQr := " SELECT E1_XIDVNFK,*
cQr += " FROM SE1040
cQr += " WHERE	D_E_L_E_T_ = ''
cQr += "		AND E1_XIDVNFK = '"+cIdNFSE+"'
cQr += "		AND E1_EMISSAO = '"+DTOS(dDatabase)+"'
cQr += " ORDER BY E1_VENCTO,E1_PREFIXO

TcQuery cQr new alias "FATKAPAZ"

DbSelectArea("FATKAPAZ")
FATKAPAZ->(DbGoTop())

While !FATKAPAZ->(EOF())

	nValor	+= FATKAPAZ->E1_VALOR
	FATKAPAZ->(DbSkip())
EndDo

DbSelectArea("FATKAPAZ")
FATKAPAZ->(DbGoTop())

//Filtro do Usuário
cFiltro := " E1_FILIAL == '"+xFilial("SE1")+"' .And. "
cFiltro += " E1_CLIENTE == '" + FATKAPAZ->E1_CLIENTE + "' .And. E1_LOJA == '" + FATKAPAZ->E1_LOJA + "' .And. "
cFiltro += " E1_SITUACA $ '0FG' .And. E1_SALDO > 0 .And. "
cFiltro += " DTOS(E1_EMISSAO) == '" + DTOS(dDataBase) + "' .And. "
cFiltro += " E1_NUMLIQ == '" + Space(TamSx3("E1_NUMLIQ")[1]) + "' .And. "
cFiltro += " E1_XIDVNFK == '" + cIdNFSE + "'"

//Array do processo automatico (aAutoCab)
aCab:={	{ "cCondicao"	, cCondPGK 					},;
		{ "cNatureza"	, FATKAPAZ->E1_NATUREZ	 	},;
		{ "E1_TIPO"		, cTipoTit 					},;
		{ "cCliente"	, FATKAPAZ->E1_CLIENTE 		},;
		{ "nMoeda"		, FATKAPAZ->E1_MOEDA		},;		
		{ "cLoja"		, FATKAPAZ->E1_LOJA 		} }

//------------------------------------------------------------
//Monta as parcelas de acordo com a condição de pagamento
//------------------------------------------------------------
aParcelas:=Condicao(nValor,cCondPGK,,dDataBase)

//--------------------------------------------------------------
//Não é possivel mandar Acrescimo e Decrescimo junto.
//Se mandar os dois valores maiores que zero considera Acrescimo
//--------------------------------------------------------------

While lCont
	cNumLiq 	:= cNumNfK
	lCont		:= ValidNuLi(cNumLiq,lCont)
	
	If lCont
		cNumLiq		:= GetMv("MV_NUMLIQ")
		cNumLiq		:= Soma1(cNumLiq,Len(Alltrim(cNumLiq)))  
		lCont		:= ValidNuLi(cNumLiq,lCont)
		
		If lCont
				PutMv("MV_NUMLIQ",cNumLiq)
			Else
				PutMv("MV_NUMLIQ",cNumLiq)
		EndIf
		
	EndIf
	
EndDo


For nZ:=1 to Len(aParcelas)
	//Dados das parcelas a serem geradas                         
	Aadd(aItens,{	{"E1_PREFIXO"	,"FAT"  		},;//Prefixo
					{"E1_BCOCHQ" 	,""  			},;//Banco
					{"E1_AGECHQ" 	,""  			},;//Agencia
					{"E1_CTACHQ" 	,""  			},;//Conta
					{"E1_NUM"  		,cNumLiq   		},;//Nro. cheque (dará origem ao numero do titulo)
					{"E1_PARCELA"  	,StrZero(nZ,2)   },;//Parcela
					{"E1_VENCTO" 	,aParcelas[nZ,1]},;//Data boa 
					{"E1_VLCRUZ" 	,aParcelas[nZ,2]},;//Valor do cheque/titulo
					{"E1_ACRESC" 	,0    			},;//Acrescimo
					{"E1_DECRESC" 	,0    			}})//Acrescimo
					//{"E1_EMITCHQ" 	,"ZELAO"  },;//Emitente do cheque
//cNumLiq	:=	Soma1(cNumLiq,Len(Alltrim(cNumLiq)))
//PutMv("MV_NUMLIQ",cNumLiq)	
Next nZ

pergunte("AFI460",.F.)
MV_PAR08	:= "FAT"
If Len(aParcelas) > 0
	//Liquidacao e reliquidacao   
	//FINA460(nPosArotina,aAutoCab,aAutoItens,nOpcAuto,cAutoFil,cNumLiqCan)
	//FINA460(,aCab,aItens,3,cFiltro)
//	pergunte("AFI460",.F.)
//	MV_PAR01	:= 2
	lMsErroAuto := .F.
	Begin Transaction
	MSExecAuto({|a,b,c,d,e|FINA460(a,b,c,d,e)},,aCab,aItens,3,cFiltro)
	If lMsErroAuto
			DisarmTransaction()
			_cLogFtK := MostraErro()
			Alert("Erro na geracao de faturas! Informe o TI(Aluisio) e envie o print desta tela("+ Dtoc(_dData) +" - "+_cHora+")")
			
			DbSelectArea("ZLF")
			Reclock("ZLF",.T.)			
			ZLF->ZLF_FILIAL	:= SC5->C5_FILIAL
			ZLF->ZLF_USER	:= __cUserId
			ZLF->ZLF_DATA	:= _dData
			ZLF->ZLF_HORA	:= _cHora
			ZLF->ZLF_LOG	:= _cLogFtK
			ZLF->ZLF_XID	:= cIdNFSE
			ZLF->(MsUnlock())
		Else
			//MsgInfo("Faturas geradas com sucesso!!!" , "NFSE KAPAZI")
	EndIf
	End Transaction
	
	If !lMsErroAuto
		xAtualLiq(cIdNFSE,cNumLiq)
	EndIf
	// Este aviso funciona apenas para teste monousuario
	//Alert("Liquidacao Incluida -> "+GetMv("MV_NUMLIQ")) 
Endif

FATKAPAZ->(DbCloseArea())
Return()


//Faturas supplier
Static Function xGerFSUP(cIdNFSE)
Local nPrcJr 		:= IIf(SF2->F2_TIPO$"B|D",0,SA1->A1_PORCJUR)  //acrescentado por Willian Duda em 26/08/2015 a pedido da Debora  -- Inclusão -- 09.10.2017 -- Andre/Rsac
Local cTipoPVK		:= SC5->C5_XTIPONF
Local lAtvNFM		:= GetMv("KP_ATVNFM",,.F.) //Verifica se a NF mista esta ativa
Local cParceAt		:= ''
Local cParceNw		:= ''
Local cTipoTit		:= "FT"
Local nValor		:= 0 
Local nZ			:=1
Local cNumLiq
Local cFiltro		:= ""
Local aCab			:= {}
Local aParcelas		:= {}
Local aItens		:= {}
Local lCont			:= .T.
Local cCondSPP		:= ""
Private cFatura		:= ""
Private lMsErroAuto	:= .F.
Private cCondPGK	:= SC5->C5_CONDPAG
Private cQr			:= ""
 
If Select('FATKAPAZ')<>0
	FATKAPAZ->(DBCloseArea())
Endif


DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbGoTOP())
If SE4->(DbSeek(xFilial("SE4") + cCondPGK))

	If !Empty(SE4->E4_XCONDPM)
		
		cQr := " SELECT E1_XIDVNFK,*
		cQr += " FROM SE1040
		cQr += " WHERE	D_E_L_E_T_ = ''
		cQr += "		AND E1_XIDVNFK = '"+cIdNFSE+"'
		cQr += "		AND E1_EMISSAO = '"+DTOS(dDatabase)+"'
		cQr += " ORDER BY E1_VENCTO,E1_PREFIXO
		
		TcQuery cQr new alias "FATKAPAZ"
		
		DbSelectArea("FATKAPAZ")
		FATKAPAZ->(DbGoTop())
		
		While !FATKAPAZ->(EOF())
		
			nValor	+= FATKAPAZ->E1_VALOR
			FATKAPAZ->(DbSkip())
		EndDo
		
		DbSelectArea("FATKAPAZ")
		FATKAPAZ->(DbGoTop())
		
		//Filtro do Usuário
		cFiltro := " E1_FILIAL == '"+xFilial("SE1")+"' .And. "
		cFiltro += " E1_CLIENTE == '" + FATKAPAZ->E1_CLIENTE + "' .And. E1_LOJA == '" + FATKAPAZ->E1_LOJA + "' .And. "
		cFiltro += " E1_SITUACA $ '0FG' .And. E1_SALDO > 0 .And. "
		cFiltro += " DTOS(E1_EMISSAO) == '" + DTOS(dDataBase) + "' .And. "
		cFiltro += " E1_NUMLIQ == '" + Space(TamSx3("E1_NUMLIQ")[1]) + "' .And. "
		cFiltro += " E1_XIDVNFK == '" + cIdNFSE + "'"
		
		//Array do processo automatico (aAutoCab)
		aCab:={	{ "cCondicao"	, SE4->E4_XCONDPM			},;
				{ "cNatureza"	, FATKAPAZ->E1_NATUREZ	 	},;
				{ "E1_TIPO"		, cTipoTit 					},;
				{ "cCliente"	, "999999" 					},;
				{ "nMoeda"		, FATKAPAZ->E1_MOEDA		},;		
				{ "cLoja"		, "01" 						} }
		
		//------------------------------------------------------------
		//Monta as parcelas de acordo com a condição de pagamento
		//------------------------------------------------------------
		aParcelas:=Condicao(nValor,SE4->E4_XCONDPM,,dDataBase)
		
		//--------------------------------------------------------------
		//Não é possivel mandar Acrescimo e Decrescimo junto.
		//Se mandar os dois valores maiores que zero considera Acrescimo
		//--------------------------------------------------------------
		
		While lCont
			cNumLiq 	:= cNumNfK
			lCont		:= ValidNuLi(cNumLiq,lCont)
			
			If lCont
				cNumLiq		:= GetMv("MV_NUMLIQ")
				cNumLiq		:= Soma1(cNumLiq,Len(Alltrim(cNumLiq)))  
				lCont		:= ValidNuLi(cNumLiq,lCont)
				
				If lCont
						PutMv("MV_NUMLIQ",cNumLiq)
					Else
						PutMv("MV_NUMLIQ",cNumLiq)
				EndIf
				
			EndIf
			
		EndDo
		
		
		For nZ:=1 to Len(aParcelas)
			//Dados das parcelas a serem geradas                         
			Aadd(aItens,{	{"E1_PREFIXO"	,"FAT"  		},;//Prefixo
							{"E1_BCOCHQ" 	,""  			},;//Banco
							{"E1_AGECHQ" 	,""  			},;//Agencia
							{"E1_CTACHQ" 	,""  			},;//Conta
							{"E1_NUM"  		,cNumLiq   		},;//Nro. cheque (dará origem ao numero do titulo)
							{"E1_PARCELA"  	,StrZero(nZ,2)   },;//Parcela
							{"E1_VENCTO" 	,aParcelas[nZ,1]},;//Data boa 
							{"E1_VLCRUZ" 	,aParcelas[nZ,2]},;//Valor do cheque/titulo
							{"E1_ACRESC" 	,0    			},;//Acrescimo
							{"E1_DECRESC" 	,0    			}})//Acrescimo
							//{"E1_EMITCHQ" 	,"ZELAO"  },;//Emitente do cheque
		//cNumLiq	:=	Soma1(cNumLiq,Len(Alltrim(cNumLiq)))
		//PutMv("MV_NUMLIQ",cNumLiq)	
		Next nZ
		
		pergunte("AFI460",.F.)
		MV_PAR08	:= "FAT"
		If Len(aParcelas) > 0
			//Liquidacao e reliquidacao   
			//FINA460(nPosArotina,aAutoCab,aAutoItens,nOpcAuto,cAutoFil,cNumLiqCan)
			//FINA460(,aCab,aItens,3,cFiltro)
		//	pergunte("AFI460",.F.)
		//	MV_PAR01	:= 2
			lMsErroAuto := .F.
			
			Begin Transaction
			MSExecAuto({|a,b,c,d,e|FINA460(a,b,c,d,e)},,aCab,aItens,3,cFiltro)
			If lMsErroAuto
					DisarmTransaction()
					_cLogFtK := MostraErro()
					Alert("Erro na geracao de faturas! Informe o TI(Aluisio) e envie o print desta tela("+ Dtoc(_dData) +" - "+_cHora+")")
					
					DbSelectArea("ZLF")
					Reclock("ZLF",.T.)			
					ZLF->ZLF_FILIAL	:= SC5->C5_FILIAL
					ZLF->ZLF_USER	:= __cUserId
					ZLF->ZLF_DATA	:= _dData
					ZLF->ZLF_HORA	:= _cHora
					ZLF->ZLF_LOG	:= _cLogFtK
					ZLF->ZLF_XID	:= cIdNFSE
					ZLF->(MsUnlock())
				Else
					//MsgInfo("Faturas geradas com sucesso!!!" , "NFSE KAPAZI")
			EndIf
			End Transaction
			
			If !lMsErroAuto
				Conout("Fatura gerada -> " + cNumLiq)
				xAtSPLiq(cIdNFSE,cNumLiq)
			EndIf
			
			
			// Este aviso funciona apenas para teste monousuario
			//Alert("Liquidacao Incluida -> "+GetMv("MV_NUMLIQ")) 
		Endif
		
		FATKAPAZ->(DbCloseArea())
	EndIf
EndIf

Return()

Static Function xAtSPLiq(cIdNFSE,cNumLiq)
Local cSql	:= ""

cSql	:= " UPDATE SE1040 "
cSql	+= " SET E1_XIDVNFK = '"+cIdNFSE+"' "
cSql	+= " WHERE E1_PREFIXO = 'FAT' "
cSql	+= " AND E1_NUM = '"+ StrZero((Val(cNumLiq)),9)+"'"
cSql	+= " AND E1_TIPO = 'FT' "
cSql	+= " AND E1_CLIENTE = '999999' "
cSql	+= " AND E1_LOJA = '01'	"
cSql	+= " AND E1_EMISSAO = '"+ DTOS(dDataBase) +"' "
cSql	+= " AND E1_XIDVNFK = '' "
cSql	+= " AND D_E_L_E_T_ = '' "

//Conout(cSql)
If TCSqlExec(cSql) < 0
	Conout("TCSQLError() " + TCSQLError())
Endif
Return()


Static Function xAtualLiq(cIdNFSE,cNumLiq)
Local cSql	:= ""

cSql	:= " UPDATE SE1040 "
cSql	+= " SET E1_XIDVNFK = '"+cIdNFSE+"' "
cSql	+= " WHERE E1_PREFIXO = 'FAT' "
cSql	+= " AND E1_NUM = '"+ StrZero((Val(cNumLiq)),9)+"'"
cSql	+= " AND E1_TIPO = 'FT' "
cSql	+= " AND E1_CLIENTE = '"+FATKAPAZ->E1_CLIENTE+"' "
cSql	+= " AND E1_LOJA = '"+FATKAPAZ->E1_LOJA+"'	"
cSql	+= " AND E1_EMISSAO = '"+ DTOS(dDataBase) +"' "
cSql	+= " AND E1_XIDVNFK = '' "
cSql	+= " AND D_E_L_E_T_ = '' "

//Conout(cSql)
If TCSqlExec(cSql) < 0
	Conout("TCSQLError() " + TCSQLError())
Endif
Return()


//Valida se tem um numero de fatura na base
Static Function ValidNuLi(cNumLiq,lCont)
Local lRet		:= lCont
Local cSql		:= ""
Local cAliasFT	
Local nRegs		:= 0

If Select('cAliasFT')<>0
	cAliasFT->(DBSelectArea('cAliasFT'))
	cAliasFT->(DBCloseArea())
Endif

cSql	:= " SELECT E1_NUMLIQ,*
cSql	+= " FROM SE1040
cSql	+= " WHERE D_E_L_E_T_ = ''
cSql	+= "		AND E1_PREFIXO = 'FAT'
cSql	+= "		AND E1_TIPO = 'FT'
cSql	+= "		AND E1_NUM = '"+ (StrZero((Val(cNumLiq)),9)) +"'
cSql	+= "		AND E1_FILIAL = '"+xFilial("SE1")+"'

TcQuery cSql new Alias "cAliasFT"
Count To nRegs

If nRegs = 0 //Caso nao tenha registros, esta Ok e retorna falso
	lRet := .F.
EndIf

cAliasFT->(DbCloseArea())
Return(lRet)

User Function xAtuZP6(cIdNFSE)
Local aArea		:= GetArea()
Local cSql		:= ""
Local cAliasNM	
Local nRegs		:= 0
Local cNota		:= "NFS"+SF2->F2_DOC

If Select('cAliasNM')<>0
	cAliasNM->(DBSelectArea('cAliasNM'))
	cAliasNM->(DBCloseArea())
Endif

cSql	:= " SELECT C5_NOTA,C5_SERIE,C5_XTOTMER,C5_XIDVNFK,ISNULL((SELECT TOP 1 C5_NUM FROM SC5040 WHERE C5_XIDVNFK = SC5.C5_XIDVNFK AND C5_XTIPONF = '2'),'') AS PEDSV,*
cSql	+= " FROM "+RetSQLName("SC5")+" SC5
cSql	+= " WHERE C5_XIDVNFK  = '"+cIdNFSE+"'
cSql	+= " AND D_E_L_E_T_ = ''
cSql	+= "AND C5_SERIE = '1'

TcQuery cSql new Alias "cAliasNM"

DbSelectArea("cAliasNM")
cAliasNM->(DbGoTop())

DbSelectArea("ZP6")
ZP6->(DbSetOrder(1))
ZP6->(DbGoTop())
If ZP6->(DbSeek(xFilial("ZP6") + cNota ))
	RecLock("ZP6",.F.)
	ZP6->ZP6_PEDSV	:= cAliasNM->PEDSV
	ZP6->ZP6_PEDPRO	:= cAliasNM->C5_NUM
	ZP6->ZP6_NFPROD	:= cAliasNM->C5_NOTA
	ZP6->ZP6_IDNFMI	:= cAliasNM->C5_XIDVNFK
	ZP6->(MsUnlock())
EndIf

cAliasNM->(DBCloseArea())

RestArea(aArea)
Return()

//Atualiza informacoes complementares nos titulos
Static Function xAtDesC(cIdNFSE)
Local aArea		:= GetArea()
Local aAreaE1	:= GetArea()

If !Empty(cIdNFSE)

	DbSelectArea("SE1")
	SE1->(DbOrderNickName("E1XIDVNFK"))
	SE1->(DbGoTop())
	If SE1->(DbSeek( xFilial("SE1") + cIdNFSE ))
		
		While SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_XIDVNFK == cIdNFSE
			
			If SE1->E1_PREFIXO == "FAT" .And. SE1->E1_XIDVNFK == cIdNFSE
				
				Reclock("SE1",.F.)
				SE1->E1_MSGCLI	:= cTxtC5kp
				SE1->(MsUnlock())
				
			EndIf
			
			SE1->(DbSkip())
		EndDo
		
	EndIf
	
EndIf

RestArea(aArea)
RestArea(aAreaE1)
Return()

//Ajusta o limite de acordo com alguma liberacao anterior
Static Function VerSPLim()
Local cQry 	:= ""
Local cSeq 	:= ""
Local nNew 	:= 0
Local nValPV := 0
 
cQry:=" SELECT  TOP 1 ZCL_FILINC,ZCL_PEDIDO,ZCL_SEQ,ZCL_VALOR,ZCL_RECSC5,ZCL_CDUSER,ZCL_NMUSER,ZCL_DTALT,ZCL_HRALT,ZCL_OFF,R_E_C_N_O_ AS RECOZCL 
cQry+=" FROM "+ RETSQLNAME('ZCL')
cQry+=" WHERE D_E_L_E_T_<>'*'"
cQry+=" AND ZCL_PEDIDO = '"+ SC5->C5_NUM +"'"
cQry+=" AND ZCL_FILINC = '"+ xFilial("SC5") +"'"
cQry+=" ORDER BY ZCL_SEQ DESC"

IF Select('TRZCL')<>0
	TRZCL->(DBCloseArea())
EndIF

TcQuery cQry New Alias 'TRZCL'

If !TRZCL->(EOF()) .And. TRZCL->ZCL_OFF <> 'X'
	
	nValPV := TRZCL->ZCL_VALOR
	
	DbSelectArea("ZCL")
	Reclock("ZCL",.T.)
	ZCL->ZCL_FILINC	:= xFilial("SC5")
	ZCL->ZCL_PEDIDO	:= SC5->C5_NUM
	ZCL->ZCL_SEQ	:= PegaSeq()
	ZCL->ZCL_VALOR	:= SC5->C5_XTOTMER
	ZCL->ZCL_RECSC5	:= SC5->(RECNO())
	ZCL->ZCL_CDUSER	:= __cUserId
	ZCL->ZCL_NMUSER	:= UsrFullName(__cUserID)
	ZCL->ZCL_DTALT	:= Date()
	ZCL->ZCL_HRALT	:= Time()
	ZCL->ZCL_OFF `	:= "X"
	ZCL->(MsUnLock())
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTOp())
	If SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
		
		nNew := nValPV + SA1->A1_SALPEDL
		
		RecLock("SA1",.F.)
		SA1->A1_SALPEDL := nNew
		SA1->(MsUnlock())
	EndIf
EndIf

TRZCL->(DBCloseArea())

Return()

//Pega o proximo sequencial
Static Function PegaSeq()
Local cQry := ""
Local cSeq := ""
 
cQry:=" SELECT  TOP 1 ZCL_SEQ FROM "+ RETSQLNAME('ZCL')
cQry+=" WHERE D_E_L_E_T_<>'*'"
cQry+=" AND ZCL_PEDIDO = '"+ SC5->C5_NUM +"'"
cQry+=" AND ZCL_FILINC = '"+ xFilial("SC5") +"'"
cQry+=" ORDER BY ZCL_SEQ DESC"

IF Select('TRZCLS')<>0
	TRZCLS->(DBCloseArea())
EndIF

TcQuery cQry New Alias 'TRZCLS'

If TRZCLS->(eof())
		cSeq := '001'
	Else
		cSeq := Soma1(TRZCLS->ZCL_SEQ)
EndIf

TRZCLS->(DBCloseArea())
Return(cSeq)


//Faturas supplier - outros pedidos 
Static Function xGerFSPP()
Local nPrcJr 		:= IIf(SF2->F2_TIPO$"B|D",0,SA1->A1_PORCJUR)  //acrescentado por Willian Duda em 26/08/2015 a pedido da Debora  -- Inclusão -- 09.10.2017 -- Andre/Rsac
Local cTipoPVK		:= SC5->C5_XTIPONF
Local lAtvNFM		:= GetMv("KP_ATVNFM",,.F.) //Verifica se a NF mista esta ativa
Local cParceAt		:= ''
Local cParceNw		:= ''
Local cTipoTit		:= "FT"
Local nValor		:= 0 
Local nZ			:=1
Local cNumLiq
Local cFiltro		:= ""
Local aCab			:= {}
Local aParcelas		:= {}
Local aItens		:= {}
Local lCont			:= .T.
Local cCondSPP		:= ""
Local cNumFTN		:= ""
Private cFatura		:= ""
Private lMsErroAuto	:= .F.
Private cCondPGK	:= SC5->C5_CONDPAG
Private cQr			:= ""
 
cNumFTN		:= SF2->F2_DOC 
 
If Select('FATKAPAZ')<>0
	FATKAPAZ->(DBCloseArea())
Endif

DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbGoTOP())
If SE4->(DbSeek(xFilial("SE4") + cCondPGK))

	If !Empty(SE4->E4_XCONDPM)
		
		cQr := " SELECT *
		cQr += " FROM SE1040
		cQr += " WHERE	D_E_L_E_T_ = ''
		cQr += "		AND E1_NUM = '"+SF2->F2_DOC+"'
		cQr += "		AND E1_PREFIXO = '"+SF2->F2_SERIE+"'
		cQr += "		AND E1_CLIENTE 	= '"+SF2->F2_CLIENTE+"'
		cQr += "		AND E1_LOJA 	= '"+SF2->F2_LOJA+"'
		cQr += "		AND E1_EMISSAO = '"+DTOS(dDatabase)+"'
		cQr += " ORDER BY E1_VENCTO,E1_PREFIXO
		
		TcQuery cQr new alias "FATKAPAZ"
		
		DbSelectArea("FATKAPAZ")
		FATKAPAZ->(DbGoTop())
		
		While !FATKAPAZ->(EOF())
			nValor	+= FATKAPAZ->E1_VALOR
			FATKAPAZ->(DbSkip())
		EndDo
		
		DbSelectArea("FATKAPAZ")
		FATKAPAZ->(DbGoTop())
		
		//Filtro do Usuário
		cFiltro := " E1_FILIAL == '"+xFilial("SE1")+"' .And. "
		cFiltro += " E1_CLIENTE == '" + FATKAPAZ->E1_CLIENTE + "' .And. E1_LOJA == '" + FATKAPAZ->E1_LOJA + "' .And. "
		cFiltro += " E1_SITUACA $ '0FG' .And. E1_SALDO > 0 .And. "
		cFiltro += " DTOS(E1_EMISSAO) == '" + DTOS(dDataBase) + "' .And. "
		cFiltro += " E1_NUMLIQ == '" + Space(TamSx3("E1_NUMLIQ")[1]) + "' .And. "
		cFiltro += " E1_NUM == '" + FATKAPAZ->E1_NUM + "' .And. "
		cFiltro += " E1_PREFIXO == '" + FATKAPAZ->E1_PREFIXO + "' .And. "
		cFiltro += " E1_TIPO == '" + FATKAPAZ->E1_TIPO + "'"
		
		//Array do processo automatico (aAutoCab)
		aCab:={	{ "cCondicao"	, SE4->E4_XCONDPM			},;
				{ "cNatureza"	, FATKAPAZ->E1_NATUREZ	 	},;
				{ "E1_TIPO"		, cTipoTit 					},;
				{ "cCliente"	, "999999" 					},;
				{ "nMoeda"		, FATKAPAZ->E1_MOEDA		},;		
				{ "cLoja"		, "01" 						} }
		
		//------------------------------------------------------------
		//Monta as parcelas de acordo com a condição de pagamento
		//------------------------------------------------------------
		aParcelas:=Condicao(nValor,SE4->E4_XCONDPM,,dDataBase)
		
		//--------------------------------------------------------------
		//Não é possivel mandar Acrescimo e Decrescimo junto.
		//Se mandar os dois valores maiores que zero considera Acrescimo
		//--------------------------------------------------------------
		
		While lCont
			cNumLiq 	:= cNumFTN
			lCont		:= ValidNuLi(cNumLiq,lCont)
			
			If lCont
				cNumLiq		:= GetMv("MV_NUMLIQ")
				cNumLiq		:= Soma1(cNumLiq,Len(Alltrim(cNumLiq)))  
				lCont		:= ValidNuLi(cNumLiq,lCont)
				
				If lCont
						PutMv("MV_NUMLIQ",cNumLiq)
					Else
						PutMv("MV_NUMLIQ",cNumLiq)
				EndIf
				
			EndIf
			
		EndDo
		
		
		For nZ:=1 to Len(aParcelas)
			//Dados das parcelas a serem geradas                         
			Aadd(aItens,{	{"E1_PREFIXO"	,"FAT"  		},;//Prefixo
							{"E1_BCOCHQ" 	,""  			},;//Banco
							{"E1_AGECHQ" 	,""  			},;//Agencia
							{"E1_CTACHQ" 	,""  			},;//Conta
							{"E1_NUM"  		,cNumLiq   		},;//Nro. cheque (dará origem ao numero do titulo)
							{"E1_PARCELA"  	,StrZero(nZ,2)   },;//Parcela
							{"E1_VENCTO" 	,aParcelas[nZ,1]},;//Data boa 
							{"E1_VLCRUZ" 	,aParcelas[nZ,2]},;//Valor do cheque/titulo
							{"E1_ACRESC" 	,0    			},;//Acrescimo
							{"E1_DECRESC" 	,0    			}})//Acrescimo
							//{"E1_EMITCHQ" 	,"ZELAO"  },;//Emitente do cheque
		//cNumLiq	:=	Soma1(cNumLiq,Len(Alltrim(cNumLiq)))
		//PutMv("MV_NUMLIQ",cNumLiq)	
		Next nZ
		
		pergunte("AFI460",.F.)
		MV_PAR08	:= "FAT"
		If Len(aParcelas) > 0
			//Liquidacao e reliquidacao   
			//FINA460(nPosArotina,aAutoCab,aAutoItens,nOpcAuto,cAutoFil,cNumLiqCan)
			//FINA460(,aCab,aItens,3,cFiltro)
		//	pergunte("AFI460",.F.)
		//	MV_PAR01	:= 2
		
			lMsErroAuto := .F.
			Begin Transaction
			MSExecAuto({|a,b,c,d,e|FINA460(a,b,c,d,e)},,aCab,aItens,3,cFiltro)
			If lMsErroAuto
					DisarmTransaction()
					_cLogFtK := MostraErro()
					Alert("Erro na geracao de faturas! Informe o TI(Aluisio) e envie o print desta tela("+ Dtoc(_dData) +" - "+_cHora+")")
					
					DbSelectArea("ZLF")
					Reclock("ZLF",.T.)			
					ZLF->ZLF_FILIAL	:= SC5->C5_FILIAL
					ZLF->ZLF_USER	:= __cUserId
					ZLF->ZLF_DATA	:= _dData
					ZLF->ZLF_HORA	:= _cHora
					ZLF->ZLF_LOG	:= _cLogFtK
					ZLF->ZLF_XID	:= cIdNFSE
					ZLF->(MsUnlock())
				Else
					//MsgInfo("Faturas geradas com sucesso!!!" , "NFSE KAPAZI")
			EndIf
			End Transaction
		EndIf
		
		FATKAPAZ->(DbCloseArea())
	EndIf
EndIf

Return()
