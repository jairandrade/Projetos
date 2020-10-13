#INCLUDE 'protheus.ch'
#INCLUDE "restful.ch"

/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! PutProdutosConferidos                                                         !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do WebService PutProdutosConferidos                                !
!                  !                                                                               !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
! Parametros       ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Retorno          ! N/A                                                                           !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                

WSRESTFUL PutProdutosConferidos DESCRIPTION "Madero - Produtos Conferidos"
	
	WSMETHOD POST DESCRIPTION "Produtos Conferidos" WSSYNTAX "/PutProdutosConferidos"

End WSRESTFUL


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! PUT                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do Metodo PutProdutosConferidos                                    !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
WSMETHOD POST WSSERVICE PutProdutosConferidos
Local cBody		:= ::GetContent()
Local cXml		:= ""
Local nThrdID := ThreadId()
Local cEmpProth := "01"
Local cFilProth := "01GDAD0001"

	ConOut(AllTrim(Str(nThrdID))+": Requisitando metodo PutProdutosConferidos em " + DtoC(Date()) + " as " + Time())
	::SetContentType("application/xml")

	ConOut(AllTrim(Str(nThrdID))+": PutProdutosConferidos: Carregando dicionario de dados...")
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
		ConOut(AllTrim(Str(nThrdID))+": PutProdutosConferidos: Erro ao abrir o dicionário de dados.")
		Return(.F.)
	EndIf

	cXml := U_WSEST021(cBody,nThrdID)

	::SetResponse(cXml)

Return .T.


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! PUT                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Declaração do Metodo PutProdutosConferidos                                    !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Class ProtheusPutProdutosConferidos From ProtheusMethodAbstract

	Method new(cMethod) constructor
	Method makeXml(cdempresa,cdfilial,lOk,cErro,filial,numeronf,serienf,emissaonf,cnpj,idusuario,aItem)
	Method getVars(oXml)
	Method procRegs(cDoc,cSer,cFor,cLoja,cUsrLogin,aProds)

EndClass




/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! New                                                                           !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo Inicializados da Classe ProtheusPutProdutosConferidos                  !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Method New(cMethod) Class ProtheusPutProdutosConferidos
	::cMethod := cMethod
Return


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! getRegs                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo busca dados que serão processados.                                     !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 07/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Method getVars(oXml) Class ProtheusPutProdutosConferidos
Local aRet  := {}
Local nX    := 0
lOCAL aProds:= {}

	Aadd(aRet,oXml:_CONFERENCIA:_ID:_CDEMPRESA:TEXT)
	Aadd(aRet,oXml:_CONFERENCIA:_ID:_CDFILIAL:TEXT)
	Aadd(aRet,oXml:_CONFERENCIA:_ID:_NUMERONF:TEXT)
	Aadd(aRet,oXml:_CONFERENCIA:_ID:_SERIENF:TEXT)
	Aadd(aRet,SToD(oXml:_CONFERENCIA:_ID:_EMISSAONF:TEXT))
	Aadd(aRet,oXml:_CONFERENCIA:_ID:_CNPJ:TEXT)
	Aadd(aRet,oXml:_CONFERENCIA:_ID:_IDUSUARIO:TEXT)
		
	If ValType( oXml:_CONFERENCIA:_PRODUTOS:_PRODUTO ) != "A"
		XmlNode2Arr( oXml:_CONFERENCIA:_PRODUTOS:_PRODUTO, "_PRODUTO" )
	EndIf
	
	For nX := 1 to Len(oXml:_CONFERENCIA:_PRODUTOS:_PRODUTO)
		AAdd( aProds, {PadR(oXml:_CONFERENCIA:_PRODUTOS:_PRODUTO[nX]:_CDITEM:TEXT, Len( SD1->D1_ITEM ),""),;	    
							oXml:_CONFERENCIA:_PRODUTOS:_PRODUTO[nX]:_CDPRODUTO:TEXT,;								
						    oXml:_CONFERENCIA:_PRODUTOS:_PRODUTO[nX]:_DSPRODUTO:TEXT,;
						Val(oXml:_CONFERENCIA:_PRODUTOS:_PRODUTO[nX]:_QTDECONFERIDA:TEXT)})	
	Next nX
	
	Aadd(aRet,aProds)

Return aRet


/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! procRegs                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo de processamento de registros                                          !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 07/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Method procRegs(cDoc,cSer,cFor,cLoja,cUsrLogin,aProds) Class ProtheusPutProdutosConferidos
Local cRet 		:= ""
Local cAux      := ""
Local nX		:= 0
Local lAchou	:= .F.
Local lErro     := .F.
Local lConf     := .F.
Local nTamQuant := TamSx3("D1_QUANT")[1]
Local nDecQuant := TamSx3("D1_QUANT")[2]

	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))

	DbSelectArea("ZCA")
	ZCA->(DbSetOrder(1))

	DbSelectArea("SB1")
	SB1->(DbOrderNickName("B1XCODEXT"))
	
	// -> Valida produtos enviados no XML
	For nX:=1 to Len(aProds)
		// -> Pesquisa código do produto	
		SB1->(DbSeek(xFilial("SB1")+aProds[nX,02]))
		If !SB1->(Found())
			cRet += PadR( aProds[nX,01], 04, " " )
			cRet += " "
			cRet += PadR( aProds[nX,02], 16, " " )
			cRet += " "
			cRet += PadR( aProds[nX,03], 60, " " )
			cRet += "  -> Nao encontrado na tabela SB1."
			cRet += CRLF 
			lErro:=.T.
		Else	
			lAchou:=SD1->(dbSeek(xFilial("SD1")+cDoc+cSer+cFor+cLoja+SB1->B1_COD+aProds[nX,01]))					
			If !lAchou .or. StrZero(SD1->D1_QUANT,nTamQuant,nDecQuant) != StrZero(aProds[nX,04],nTamQuant,nDecQuant)
				cRet += PadR( aProds[nX,01], 04, " " )
				cRet += " "
				cRet += PadR( aProds[nX,02], 16, " " )
				cRet += " "
				cRet += PadR( aProds[nX,03], 60, " " )
				cRet += " "
				If lAchou
					cRet += Transform( SD1->D1_QUANT, "@E 999,999.99" )
				Else
					cRet += Transform( 0, "@E 999,999.99" )
				EndIf
				cRet += Transform( aProds[nX,04], "@E 9,999,999.99" )
				cRet += CRLF 
				lConf:=.T.
			EndIf			
		EndIf	
	Next nX

	// -> Retorna os erros do processo 
	If lErro .or. lConf
		cAux := cRet
		cRet := "Item Codigo           Descricao                                                      Qtde NF   Qtde Conf. " + CRLF 
		cRet += "---- ---------------- -------------------------------------------------------------- --------- ---------- " + CRLF
		cRet += cAux
	EndIf	


	// -> Se não ocorreu nenhum erro, atualiza os dados de conferência
	If !lErro
		cRet :=""
		Begin Transaction
			For nX := 1 to Len(aProds)
				// -> Posiciona no cadastro do produto
				SB1->(DbSeek(xFilial("SB1")+aProds[nX,02]))
				// -> Posiciona no item do documento de entrada
				SD1->(DbSeek(xFilial("SD1")+cDoc+cSer+cFor+cLoja+SB1->B1_COD+aProds[nX,01]))
				// -> Verifica se existe o registro na ZCA. Se existir retorna erro e, se não existir, cria o registro.
				If !ZCA->(DbSeek(SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO+SD1->D1_ITEM+SD1->D1_COD))
					RecLock( "ZCA", .T. )
					ZCA->ZCA_FILIAL := SD1->D1_FILIAL
					ZCA->ZCA_DOC    := SD1->D1_DOC
					ZCA->ZCA_SERIE  := SD1->D1_SERIE
					ZCA->ZCA_FORNEC := SD1->D1_FORNECE
					ZCA->ZCA_LOJA   := SD1->D1_LOJA
					ZCA->ZCA_TIPO   := SD1->D1_TIPO
					ZCA->ZCA_XCONF	:= "S"
					ZCA->ZCA_XQTDCO	:= aProds[nX,04]
					ZCA->ZCA_XUSCON := cUsrLogin
					ZCA->ZCA_XDTCON := Date()
					ZCA->ZCA_XHRCON := Time()
					ZCA->ZCA_XITEM  := SD1->D1_ITEM
					ZCA->ZCA_XPROD  := SD1->D1_COD
					ZCA->(MsUnlock())

					cRet += PadR( aProds[nX,01], 04, " " )
					cRet += " "
					cRet += PadR( aProds[nX,02], 16, " " )
					cRet += " "
					cRet += PadR( aProds[nX,03], 60, " " )
					cRet += " "
					cRet += Transform( SD1->D1_QUANT, "@E 999,999.99" )
					cRet += Transform( aProds[nX,04], "@E 9,999,999.99" )
					cRet += CRLF 
				Else
					cRet:=IIF(!lErro,cRet:="Documento " + SD1->D1_DOC + " e serie " + SD1->D1_SERIE + " ja conferido.",cRet)
					lErro:=.T.
				EndIf	
			Next nX	
		End Transaction	
	EndIf	

Return({!lErro,cRet})



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! makeXml                                                                       !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Metodo para gerar XML do WS PutProdutosConferidos                             !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 07/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
Method makeXml(cdempresa,cdfilial,lOk,cErro,filial,numeronf,serienf,emissaonf,cnpj,idusuario,aItem) Class ProtheusPutProdutosConferidos
Local cXml 		:= ''
Local nX		:= 0

	cXml += '<?xml version="1.0" encoding="ISO-8859-1"?>'

	cXml += '<retorno>'

	cXml += '<id '
	cXml += ::tag('cdempresa'	, cdempresa)
	cXml += ::tag('cdfilial'	, cdfilial)
	cXml += ::tag('filial'		, filial)
	cXml += ::tag('numeronf'	, numeronf)
	cXml += ::tag('serienf'		, serienf)
	cXml += ::tag('emissaonf'	, DToS(emissaonf))
	cXml += ::tag('cnpj'		, cnpj)
	cXml += ::tag('idusuario'	, idusuario)
	cXml += '/>'		

	cXml += '<produtos>'	
	If lOk
		For nX:=1 to Len(aItem)

			cXml += '<produto '
			cXml += ::tag('cditem'		 ,aItem[nX,01])
			cXml += ::tag('cdproduto'	 ,aItem[nX,02])
			cXml += ::tag('dsproduto'	 ,aItem[nX,03])
			cXml += ::tag('qtdeconferida',cValToChar(aItem[nX,04]))
			cXml += '/>'		

		Next nX
	EndIf
	cXml += '</produtos>'

	cXml += '<confirmacao>'
	cXml += '<confirmacao'
	cXml += ::tag('integrado'		,IIF(lOk,"true","false"))
	cXml += ::tag('mensagem'		,IIF(lOk,"Conferencia ok.",cErro))
	cXml += ::tag('data'			,DtoS(Date()))		
	cXml += ::tag('hora'			,Time())	
	cXml += '/>'
	cXml += '</confirmacao>'
	
	cXml += '</retorno>'

Return cXml



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! VerEmp                                                                        !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função para validar e posicionar na Empresa/Filial informada                  !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
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



/*                                                    
+------------------+-------------------------------------------------------------------------------+
! Nome             ! WSEST021                                                                      !
+------------------+-------------------------------------------------------------------------------+
! Descrição        ! Função principal de processamento                                             !
+------------------+-------------------------------------------------------------------------------+
! Autor            ! Vinicius Moreira                                                              !
+------------------+-------------------------------------------------------------------------------+
! Data             ! 06/08/2018                                                                    !
+------------------+-------------------------------------------------------------------------------+
*/                                                                                
User Function WSEST021(cXml,nThrdID)
Local cErro 	:= ""
Local aErro     := {}
Local aDadosXML := {}
Local cUserA    := RetCodUsr()
Local dDataAnt  := dDataBase
Local cUsrName  := ""
Local aGrpUser  := {}
Local lCont     := .T.
Local oTag      := ProtheusPutProdutosConferidos():New("Tag")
Local cEmpWS    := ""
Local cFilWS    := "" 
Local cxEmpant  := "" 
Local cxFilAnt  := ""

	// ------------------------------------------------------------------
	//	Estrutura do array aDadosXML:		
	//	01 - Código da empresa do Teknisa
	//	02 - Filial do Teknisa
	//	03 - Número da nota fiscal
	//	04 - Série da nota fiscal
	//	05 - Data de emissão da nota fiscal
	//	06 - CNPJ do fornecedor
	//	07 - ID do usuário
	//	08 - Array cod os dados de produtos: 
	//	08:01 - Item da nota fiscal
	//	08:02 - Código do produto
	//	08:03 - descricao do produto
	//	08:04 - Quantidade conferida
	// ------------------------------------------------------------------

	// -> Verifica se o XML foi enviado
	lCont:=!Empty(cXml) .or. cXml == Nil
	If lCont
		// -> Verifica se o XML é válido
		oXml :=oTag:XmlParser(cXml)
		lCont:=!oXml == Nil
		If lCont
			// -> Carrega dados do XML
			aDadosXML:=oTag:getVars(oXml)
			lCont    :=VerEmp(aDadosXML[01],aDadosXML[02],@cEmpWS,@cFilWS,@cxEmpant,@cxFilAnt)
			If lCont
				// -> Carrega o ambiente conforme dados da empresa e filial passados nos parâmetros do método
				ConOut(AllTrim(Str(nThrdID))+": Carregando ambiente para empresa " + cEmpWS + " e filial "+cFilWS)
				RpcClearEnv()
				RPcSetType(3)
				RpcSetEnv(cEmpWS,cFilWS, , ,'EST' , GetEnvServer() )
					OpenSm0(cEmpWS, .f.)
					nModulo := 4
					SM0->(dbSetOrder(1))
					lCont:=SM0->(dbSeek(cEmpWS+cFilWS))
					
					// -> Se o ambiente está ok, continua
					If lCont				
						// -> Posiciona no acesso do usuário
						PswOrder(1)
						PswSeek(aDadosXML[07],.T.) 
						cUsrName :=UsrRetName(aDadosXML[07])
						__cUserID:=cUsrName
						aGrpUser :=UsrRetGrp(cUsrName)
						cEmpAnt  :=SM0->M0_CODIGO
						cFilAnt  :=SM0->M0_CODFIL	
						dDataBase:=Date() 
						// -> Verifica se é Admin
						lCont:=!("ADMIN" $ Upper(cUsrName))
						If lCont						
							// -> Se o usuário ok, continua
							lCont:=!Empty(cUsrName)
							If lCont																				
								// -> Atualizando dados
								ConOut(AllTrim(Str(nThrdID))+": Processando conferencia...")
								// -> Verifica fornecedor
								DbSelectArea("SA2")
								SA2->(DbSetOrder(3))
								SA2->(DbSeek(xFilial("SA2")+aDadosXML[06]))
								lCont:=SA2->(Found()) .and. !Empty(aDadosXML[06])
								// -> Se o fornecedor estiver ok, continua
								If lCont
									DbSelectArea("SF1")
									SF1->(DbSetOrder(1))
									SF1->(DbSeek(xFilial("SF1")+aDadosXML[03]+aDadosXML[04]+SA2->A2_COD+SA2->A2_LOJA))
									lCont:=SF1->(Found())
									// -> Se o documento de entrada estiver ok, continua
									If lCont
										// -> Se a nota nao estiver bloqueada, prossegue.
										lCont:=!(SF1->F1_STATUS=="B")
										If lCont
											// -> Se a nota nao estiver classificada, prossegue.
											lCont:=Empty(SF1->F1_STATUS)
											If lCont
												aErro:=oTag:procRegs(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,cUsrName,aDadosXML[08])												
												lCont:=aErro[01]
												cErro:=aErro[02]
											Else
												cErro:="Documento " + SF1->F1_DOC + " e serie " + SF1->F1_SERIE + " ja classificado em " + DtoC(SF1->F1_DTDIGIT)									
											EndIf	
										Else
											cErro:="Documento " + SF1->F1_DOC + " e serie " + SF1->F1_SERIE + " encontra-se com bloqueio."
										EndIf
									Else									
										cErro:="Documento "+aDadosXML[03]+" e serie " + aDadosXML[04] + " nao enocontrados na tabela SF1."								
									EndIf
								Else
									cErro:="Fornecedor com o CNPJ " + aDadosXML[06] + " nao encontrado na tabela SA2 ."
								EndIf
							Else
								cErro :="Usuario " + aDadosXML[07] + " nao encontrado no Protheus."
							EndIf
						Else
							cErro:="Nao eh permitido utilizar o acesso do usuario Admin."
						EndIf	
					Else
						cErro :="Erro ao carregar as filiais na tabela SM0 do Protheus [M0_CODIGO = " + cEmpWS + " e M0_CODFIL = " + cFilWS + "]"
					EndIf

				// -> Recarrega o ambiente anterior
				RpcClearEnv()
				RPcSetType(3)
				RpcSetEnv(cxEmpant,cxFilAnt, , ,'EST' , GetEnvServer() )
				OpenSm0(cxEmpant, .f.)
				nModulo := 4
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cxEmpant+cxFilAnt))
				PswOrder(1)
				PswSeek(cUserA,.T.) 
				cUsrName :=UsrRetName(cUserA)
				__cUserID:=cUsrName
				aGrpUser := UsrRetGrp(cUsrName)
				cEmpAnt  := SM0->M0_CODIGO
				cFilAnt  := SM0->M0_CODFIL	
				dDataBase:=dDataAnt
			Else
				cErro :="Empresa e filial nao cadastrada na tabela ADK."
			EndIf
		Else
			cErro :="XML invalido."
		EndIf	
	Else
		cErro :="XML invalido ou vazio."
	EndIf	

	// -> Retorna XML com o resultado do processamento
	cXml := oTag:MakeXml(aDadosXML[01],aDadosXML[02],lCont,cErro,cFilWS,aDadosXML[03],aDadosXML[04],aDadosXML[05],aDadosXML[06],aDadosXML[07],aDadosXML[08])		
	If lCont
		ConOut("Ok.")
	Else
		ConOut("Erro.")		
	EndIf

Return cXml