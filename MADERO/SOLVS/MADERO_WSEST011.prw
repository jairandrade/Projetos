#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#Include "TOPCONN.CH"
#include "tbiconn.ch"
#INCLUDE "restful.ch"
/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! PutProdutosARequisitar                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do Metodo PutProdutosARequisitar                                   !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. FariaV                                                            !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSRESTFUL PutProdutosARequisitar DESCRIPTION "Madero - Requisições de produtos ao estoque"

	WSMETHOD POST DESCRIPTION "Produtos a Inventariar" WSSYNTAX "/PutProdutosARequisitar"

End WSRESTFUL



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! GET                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaracao do metodo GET                                                      !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSMETHOD POST WSSERVICE PutProdutosARequisitar
Local cBody     := ::GetContent()
Local cXml	    := ""
Local nThrdID   := ThreadId()
Local cEmpProth := "01"
Local cFilProth := "01GDAD0001"

	ConOut(AllTrim(Str(nThrdID))+": Requisitando metodo PutProdutosARequisitar em " + DtoC(Date()) + " as " + Time())
	::SetContentType("application/xml")

	ConOut(AllTrim(Str(nThrdID))+": PutProdutosARequisitar: Carregando dicionario de dados...")
	RpcClearEnv()
	RPcSetType(3)
	RpcSetEnv(cEmpProth,cFilProth,,,"FAT",GetEnvServer() )
	OpenSm0(cEmpProth, .f.)
	nModulo:=5
	SM0->(dbSetOrder(1))
	If SM0->(dbSeek(cEmpProth+cFilProth))
		cEmpAnt  := cEmpProth
		cFilAnt  := cFilProth						
		dDataBase:=Date()
	Else
		ConOut(AllTrim(Str(nThrdID))+": PutProdutosARequisitar: Erro ao abrir o dicionário de dados.")
		Return(.F.)
	EndIf
	
	cXml := WSEST011(cBody,nThrdID)

	::SetResponse(cXML)	

Return .T.



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! ProtheusPutProdutosARequisitar                                                !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração das classe ProtheusPutProdutosARequisitar para gerar o XML         !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Class ProtheusPutProdutosARequisitar From ProtheusMethodAbstract

	Method new(cMethod) constructor
	Method MakeXml(aXMLRet)
	Method AnaliseAce(oXmlAce) 

EndClass



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! New                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo Inicializados da Classe Protheus ProtheusPutProdutosARequisitar        !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                

Method New(cMethod) Class ProtheusPutProdutosARequisitar
	::cMethod := cMethod
Return



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! New                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo Inicializados da Classe Protheus ProtheusPutProdutosARequisitar        !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 12/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Method MakeXml(aXMLRet) Class ProtheusPutProdutosARequisitar
Local cXml 	:= ''
Local nI    := 0
Local nAux  := 0
Local nTamQt:= TamSX3("D3_QUANT")[1]
Local nDecQt:= TamSX3("D3_QUANT")[2]
Local lErro := .F.
	
	cXml += '<?xml version="1.0" encoding="ISO-8859-1"?>'
	
	cXml += '<retorno>'
	
	cXml += '<id' 
	cXml += ::tag('cdempresa' ,IIF(Len(aXMLRet)>0,aXMLRet[01,04],""))	
	cXml += ::tag('cdfilial'  ,IIF(Len(aXMLRet)>0,aXMLRet[01,05],""))		
	cXml += ::tag('filial'	  ,IIF(Len(aXMLRet)>0,aXMLRet[01,06],""))		
	cXml += ::tag('idusuario' ,IIF(Len(aXMLRet)>0,aXMLRet[01,07],""))		
	cXml += ::tag('datamov'	  ,IIF(Len(aXMLRet)>0,aXMLRet[01,08],""))
	cXml += '/>'

	cXml += '<produtos>'
	
	For nI:=1 to Len(aXMLRet)		 
		cXml += '<cdproduto'
		cXml += ::tag('cdproduto'		,aXMLRet[nI,10])
		cXml += ::tag('dsproduto'		,aXMLRet[nI,11])
		cXml += ::tag('cdcodmov'        ,aXMLRet[nI,13])
		cXml += ::tag('quantidade'		,AllTrim(Str(aXMLRet[nI,12],nTamQt,nDecQt)))
		cXml +=	'/>'

		cXml += '<confirmacao'
		cXml += ::tag('integrado'		,IIF(aXMLRet[nI,02],"true","false"))
		cXml += ::tag('mensagem'		,IIF(aXMLRet[nI,02],"Baixa realizada com sucesso.","Erro no processo: " + aXMLRet[nI,03]))
		cXml += ::tag('data'		    ,Dtos(Date()))
		cXml += ::tag('hora'		    ,Time())
		cXml +=	'/>'

		lErro:=IIF(aXMLRet[nI,02],lErro,.T.)
		nAux :=nI 
	Next
	
	cXml += '</produtos>'

	cXml += '<confirmacao>'
		
	cXml += '<confirmacao' 
	cXml += ::tag('integrado', IIF(!lErro,"true","false"))
	cXml += ::tag('mensagem',  IIF(!lErro,"Processo ok.","Erro na execucao do processo."))
	cXml += ::tag('data',	   Dtos(Date()))
	cXml += ::tag('hora',	   Time())
	cXml += '/>'

	cXml += '</confirmacao>'

	cXml += '</retorno>'

	If lErro
		ConOut('Erro.')
	Else
		ConOut('Ok.')
	EndIf	


Return cXml


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! WSEST011                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função Princiapal do WS                                                       !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Mario L. B. Faria                                                             !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 24/07/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Static Function WSEST011(cXml,nThrdID)
Local lCont		:= .T.
Local lErro     := .F.
Local aXML      := {}
Local aXMLRet   := {}
Local cErro		:= ""
Local oWs		:= ProtheusPutProdutosARequisitar():New("Tag")
Local oXml		:= Nil
Local oXmlAce	:= Nil
Local oXmlId	:= Nil
Local cRot      := "MTA240 "
Local nI
Local cPathTmp  := "\temp\"
Local cFileErr  := ""
Local cCodFilTek:= ""
Local cEmpWS    := ""
Local cFilWS    := ""
Local cxEmpant  := ""
Local cxFilAnt  := ""
Local cUsrName  := ""
Local cIdUser   := ""
Local cdataMov  := ""
Local dDataAnt  := Ctod("  /  /  ")
Local cUserA    := RetCodUsr()
Local cdproduto := ""
Local dsproduto := ""
Local dscodmov  := ""
Local cdcodmov  := ""
Local qtdemovim := 0
Local cCustoMv  := ""
Local cErroItem := ""
	
	ConOut("-> Iniciando processo de requisicao de itens ao estoque...")
	// -> Seleciona tabelas
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	DbSelectArea("Z13")
	Z13->(DbSetOrder(1))

	DbSelectArea("SF5")
	SF5->(DbSetOrder(1))


	// -> Verifica se o XML é vazio ou inválido
	lCont:=!Empty(cXml)
	If lCont
		oXml	  :=oWs:xmlParser(cXml)
		oXmlId	  :=oXml:_MOVIMENTO:_ID
		cIdUser   :=oXml:_MOVIMENTO:_ID:_idusuario:TEXT
		cdataMov  :=oXml:_MOVIMENTO:_ID:_datamov:TEXT
		cCodEmpTek:=oXmlId:_CDEMPRESA:TEXT
		cCodFilTek:=oXmlId:_CDFILIAL:TEXT


		ConOut(AllTrim(Str(nThrdID))+": Validando dados da empresa...")
		lCont := VerEmp(cCodEmpTek,cCodFilTek,@cEmpWS,@cFilWS,@cxEmpant,@cxFilAnt)
		If lCont
	
			// -> Carrega o ambiente conforme dados da empresa e filial passados nos parâmetros do método
			ConOut(AllTrim(Str(nThrdID))+": Carregando ambiente para empresa " + cEmpWS + " e filial "+cFilWS)
			RpcClearEnv()
			RPcSetType(3)
			RpcSetEnv(cEmpWS,cFilWS, , ,'EST' , GetEnvServer() )
			OpenSm0(cEmpWS, .f.)
			nModulo := 4
			SM0->(dbSetOrder(1))
			If !SM0->(dbSeek(cEmpWS+cFilWS))
				lCont:=.F.
			EndIf				
			
			// -> Se o ambiente está ok, continua
			If lCont				
				// -> Posiciona no acesso do usuário
				PswOrder(1)
				PswSeek(cIdUser,.T.) 
				cUsrName :=UsrRetName(cIdUser)
				__cUserID:=cUsrName
				aGrpUser := UsrRetGrp(cUsrName)
				cEmpAnt  := SM0->M0_CODIGO
				cFilAnt  := SM0->M0_CODFIL	
				dDataAnt := dDataBase

				// -> Verifica se é Admin
				lCont:=!("ADMIN" $ Upper(cUsrName))
				If lCont
					// -> Se o usuário ok, continua
					lCont:=!Empty(cUsrName)
					If lCont								
						// -> Transforma em array um objeto (nó) da estrutura do XML 
						lCont:=valType(oXml:_MOVIMENTO:_PRODUTOS) == "O" 
						If lCont
							XmlNode2Arr (oXml:_MOVIMENTO:_PRODUTOS:_CDPRODUTO, "_CDPRODUTO") 
							aXML     := aClone(oXml:_MOVIMENTO:_PRODUTOS:_CDPRODUTO) 
							dDataBase:= StoD(cdataMov)

							// -> Verifica parâmetro de fechamento do estoque
							ConOut(AllTrim(Str(nThrdID))+": Gerando movimento...")
							lCont:=GetMv("MV_ULMES",,Ctod("  /  /  ")) <= dDataBase
							If lCont

								// -> Verifica o centro de custo do restaurante
								DbSelectArea("ZA0")
								ZA0->(DbSetOrder(1))
								ZA0->(DbSeek(xFilial("ZA0")+cFilAnt))
								lCont:=ZA0->(Found())
								If lCont
								
									Begin Transaction

										lErro:=.F.
										For nI := 1 To Len(aXML) 
											
											cErroItem:=""
											cdproduto:=AllTrim(aXML[nI]:_cdproduto:TEXT)
											cdcodmov :=AllTrim(aXML[nI]:_cdcodmov:TEXT)
											qtdemovim:=Val(AllTrim(aXML[nI]:_qtdemovim:TEXT))
											cCustoMv :=ZA0->ZA0_CUSTO
											aMata240 :={}

											// -> Verifica a quantidade
											lCont:=qtdemovim > 0
											If lCont
											
												// -> Posiciona no Produto
												SB1->(DbOrderNickName("B1XCODEXT"))
												SB1->(DbSeek(xFilial("SB1")+cdproduto))
												lCont:=SB1->(Found())
												If lCont
												
													cdproduto:=SB1->B1_COD
													dsproduto:=SB1->B1_DESC

													// -> Posiciona na TM
													DbSelectArea("SF5")
													SF5->(DbSetOrder(1))
													SF5->(DbSeek(xFilial("SF5")+cdcodmov))
													lCont:=SF5->(Found())
													If lCont

														cdcodmov:=SF5->F5_CODIGO
														dscodmov:=SF5->F5_TEXTO
													
														// -> Verifica se o usuario possui acesso para fazer a baixa
														lCont:=u_EST200RL(cRot,SB1->B1_COD,SB1->B1_GRUPO,cIdUser,aGrpUser,SF5->F5_CODIGO,.F.)
														If lCont
														
															ConOut(AllTrim(Str(nThrdID))+": incluindo movimento para o produto "+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+"...")
															aAdd( aMata240, { "D3_DOC"    , "REC"+SubStr(DtoS(dDataBase),3,6)   , Nil})
															aAdd( aMata240, { "D3_TM"     , SF5->F5_CODIGO						, Nil})
															aAdd( aMata240, { "D3_COD"    , SB1->B1_COD   						, Nil})
															aAdd( aMata240, { "D3_CC"     , cCustoMv      						, Nil})
															aAdd( aMata240, { "D3_USUARIO", cIdUser       						, Nil})
															aAdd( aMata240, { "D3_QUANT"  , qtdemovim     						, Nil})
															aAdd( aMata240, { "D3_EMISSAO", dDataBase     						, Nil})
								
															lMsErroAuto := .F.
															//Pergunte("MTA240")
															SetMVValue("MTA240", "MV_PAR01", 2) // Mostra lcto contábil (2=Nao)
															SetMVValue("MTA240", "MV_PAR02", 2) // Aglutina lct contábil (2=Nao)
															SetMVValue("MTA240", "MV_PAR03", 1) // Considera saldo poder de 3os (1=Sim)

															DbSelectArea("SD3")
															MSExecAuto({|x,y| mata240(x,y)},aMata240,3)		
															
															// -> Gera retorno do XML
															If lMsErroAuto		
																cFileErr := "log_"+cFilAnt+"_"+strtran(time(),":","")
																lCont    :=.F.
																lErro    :=.T.
																MostraErro(cPathTmp, cFileErr)
																cErroItem:=memoread(cPathTmp+cFileErr)
																FErase(cPathTmp+cFileErr)
																Aadd(aXMLRet,{oXml,.F.,cErroItem,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,cdataMov,cdcodmov,SB1->B1_COD,SB1->B1_DESC,qtdemovim,dscodmov})
															Else
																RecLock("SD3",.F.)
																SD3->D3_CC:=cCustoMv
																SD3->(MsUnLock())																
																cErroItem:="Retirada ok."
																Aadd(aXMLRet,{oXml,.T.,cErroItem,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,cdataMov,cdcodmov,SB1->B1_COD,SB1->B1_DESC,qtdemovim,dscodmov})
															EndIf	
														Else
															cErroItem:="Usuarioi " + cIdUser + " sem permissao para gerar o movimento na tabela Z30."														
															lErro    :=.T.
															Aadd(aXMLRet,{oXml,.F.,cErroItem,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,cdataMov,cdcodmov,SB1->B1_COD,SB1->B1_DESC,qtdemovim,dscodmov})
														EndIf		
													Else
														cErroItem:="Tipo de movimento " + cdcodmov + " nao encontrado na tabela SF5."
														lErro    :=.T.
														Aadd(aXMLRet,{oXml,.F.,cErroItem,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,cdataMov,cdcodmov,SB1->B1_COD,SB1->B1_DESC,qtdemovim,dscodmov})
													EndIf
												Else
													cErroItem:="Produto " + cdproduto + " nao encontrado na tabela SB1."
													lErro    :=.T.
													Aadd(aXMLRet,{oXml,.F.,cErroItem,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,cdataMov,cdcodmov,SB1->B1_COD,SB1->B1_DESC,qtdemovim,dscodmov})
												EndIf
											Else
												cErroItem:="A quantidade do produto e menor ou igual a zero."
												lErro    :=.T.
												Aadd(aXMLRet,{oXml,.F.,cErroItem,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,cdataMov,cdcodmov,SB1->B1_COD,SB1->B1_DESC,qtdemovim,dscodmov})
											EndIf
										
										Next nI

										// -> Se ocorreu erro, desarma a transaçao
										If lErro
											DisarmTransaction()
										EndIf

									End Transaction	

								Else
									cErro:="Centro de custo nao encontrado para filial " + cFilAnt
									lCont:=.F.
								EndIf
							Else
								cErro:="A data de movimento e menor ou igual ao fechamnto. Verifique parametro MV_ULMES da filial " + cFilAnt
								lCont:=.F.
							EndIf
						Else
							cErro:="Erro no XML enviado. Favor enviar um produto de cada vez para fazer a baixa."
							lCont:=.F.
						EndIf		
					Else
						cErro :="Usuario " + cIdUser + " nao encontrado no Protheus."
						lCont:=.F.		
					EndIf
				Else		
					cErro :="Nao eh permitido utilizar o acesso do usuario Admin."
					lCont:=.F.		
				EndIf	
			Else
				cErro :="Erro ao carregar as filiais na tabela SM0 do Protheus [M0_CODIGO = " + cEmpWS + " e M0_CODFIL = " + cFilWS + "]"
				lCont:=.F.		
			EndIf

			// -> Retorna o ambiente anterior
			RpcClearEnv()
			RPcSetType(3)
			RpcSetEnv(cxEmpant,cxFilAnt, , ,'EST' , GetEnvServer() )
			OpenSm0(cxEmpant, .f.)
			nModulo := 4
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cxEmpant+cxFilAnt))
			PswOrder(1)
			PswSeek(cUserA,.T.) 
			cUsrName :=UsrRetName(cIdUser)
			__cUserID:=cUsrName
			aGrpUser := UsrRetGrp(cUsrName)
			cEmpAnt  := SM0->M0_CODIGO
			cFilAnt  := SM0->M0_CODFIL	
			dDataAnt := dDataAnt

		Else
			cErro :="Empresa e filial nao encontradas da tabela ADK do Protheus."
			lCont:=.F.		
		EndIf
	Else
		cErro :="XML enviado vazio ou inválido."
		lCont:=.F.		
	EndIf

	// -> Gera XML
	If Empty(cErro)
		cXml := oWs:MakeXml(aXMLRet)
	Else
		aXMLRet:={}
		Aadd(aXMLRet,{IIF(!Empty(cXml),oXml,Nil),.F.,cErro,cCodEmpTek,cCodFilTek,cFilWS,cIdUser,cdataMov,cdcodmov,cdproduto,dsproduto,qtdemovim,""})
		cXml:=oWs:MakeXml(aXMLRet)
	EndIf		
	
Return cXml




/*                                          
+------------------+-------------------------------------------------------------------------------+
! Nome             ! VerEmp                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Verifica os dados da filial de conexão                                        !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Paulo Gabriel França e Silva                                                  !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 15/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/         
Static Function VerEmp(xEmp,xFil,cEmpWS,cFilWS,cxEmpant,cxFilAnt)
Local lRet:=.F.
	
	// -> Pesquisa filiais
	cQuery := "	SELECT ADK_XFILI,ADK_XGEMP      " + CRLF
	cQuery += "	FROM  " + RetSqlName("ADK")       + CRLF
	cQuery += "	WHERE "                           + CRLF  
	cQuery += " ADK_XEMP   = '" + xEmp + "' AND " + CRLF
	cQuery += " ADK_XFIL   = '" + xFil + "' AND " + CRLF
	cQuery += "	D_E_L_E_T_ = ' '                " + CRLF	
	cQuery := ChangeQuery(cQuery)
	cAlQry := MPSysOpenQuery(cQuery)
		
	If !(cAlQry)->(Eof())
		cFilWS:=(cAlQry)->ADK_XFILI 
		cEmpWS:=(cAlQry)->ADK_XGEMP
		lRet:=.T.
	EndIf
	(cAlQry)->(dbCloseArea())
	cxEmpant:=cEmpAnt
	cxFilAnt:=cFilAnt

Return lRet