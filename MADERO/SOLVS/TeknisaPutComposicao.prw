#include 'protheus.ch'
/*-----------------+---------------------------------------------------------+
!Nome              ! TkPutCompo                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Funcao para chamr o metodo PutComposicao via Menu     !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
user function TkPutCompo()

 		// -> Executa o processo para inclusão de estrutura de produtos
	    TkCompo("Post")

 		// -> Executa o processo para exclusao de estrutura de produtos	
	    TkCompo("Delete")  
	    
Return


/*-----------------+---------------------------------------------------------+
!Nome              ! TkCompo                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para processar o WS                          !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function TkCompo(cMetEnv)
Local oIntegra
Local cMethod	:= "PutComposicao"
Local cAlias	:= "Z14"
Local cAlRot	:= "SG1"
Local oEventLog := EventLog():start("Composicao - "+AllTrim(cMetEnv), Date(), "Iniciando processo de integracao...", cMetEnv, cAlRot) 
	
	//instancia a classe
	oIntegra := TeknisaPutComposicao():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	If oIntegra:isEnable()

		//busca os registros e se sequencia em lotes
		oIntegra:prepare()

		oIntegra:send()

	EndIf
	
	oEventLog:Finish()

return


/*-----------------+---------------------------------------------------------+
!Nome              ! PutComposicao                                           !
+------------------+---------------------------------------------------------+
!Descrição         ! Classe PutComposicao                                    !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
class TeknisaPutComposicao from TeknisaMethodAbstract
Data oLog
Data cMetE

	method new() constructor
	method analise(oXmlItem,lNewReg)
	method fetch()
	method makeXml(aLote,cMetEnv) 

endclass


/*-----------------+---------------------------------------------------------+
!Nome              ! new                                                     !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo inicializador da classe                          !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaPutComposicao

	//inicialisa a classe
	::init(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)
	::oLog :=oEventLog
	::cMetE:=cMetEnv

return



/*-----------------+---------------------------------------------------------+
!Nome              ! fetch                                                   !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para aseleção dos dados a enviar                 !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method fetch() class TeknisaPutComposicao
Local cQuery	:= ''
Local cPreAli	:= If(Len(PrefixoCpo(::cAlias)) == 2,"S" + PrefixoCpo(::cAlias), PrefixoCpo(::cAlias))
Local cErrorLog := ""

	cErrorLog:=": Selecionando dados da estrutura do produto..." 
	::oLog:SetAddInfo(cErrorLog,"Gerando XML...")
	ConOut(cErrorLog)

	cQuery += "	SELECT " + CRLF
	cQuery += "		0 ROT_REG, " + CRLF	//Recno da tabela Principal
	cQuery += "		" + cPreAli + ".R_E_C_N_O_ ALI_REG " + CRLF		//Recno da tabela Auxiliar
	
	cQuery += "	FROM " + RetSqlName(::cAlias) + " " + cPreAli + " " + CRLF
	
	cQuery += "	WHERE  " + CRLF
	cQuery += "			" + PrefixoCpo(::cAlias) + "_FILIAL = '" + xFilial(::cAlias) + "' " + CRLF
	
	If Upper(::cMetEnv) == "POST"
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XSTINT IN ('P','E') " + CRLF
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XEXC   != 'S'       " + CRLF
	ElseIf Upper(::cMetEnv) == "DELETE"
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XSTINT IN ('P','E') " + CRLF
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XEXC    = 'S'       " + CRLF
	EndIf	
	
	cQuery += "		AND " + cPreAli + ".D_E_L_E_T_ = ' ' " + CRLF

	MemoWrite("C:\TEMP\" + ::cMethod + "_" + ::cMetEnv + ".sql",cQuery)

	cQuery := ChangeQuery(cQuery)

return MPSysOpenQuery(cQuery)


/*-----------------+---------------------------------------------------------+
!Nome              ! analise                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para analizar e gravar os dados de retorno do WS !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method analise(oXmlItem,lNewReg) class TeknisaPutComposicao
Local lIntegrado := .F.
Local cErrorLog  := ""
Local cCodEmp 	 := ""
Local cCodFil 	 := ""
Local cCodProd   := ""
Local cCodTek    := ""
Local cMsgErro   := ""
Private oItem 	 := oXmlItem

	// -> verifica se a propriedade integrado existe
	cMsgErro:=IIF(type("oItem:_CONFIRMACAO:_MENSAGEM:TEXT")=="C",oItem:_CONFIRMACAO:_MENSAGEM:TEXT,"")
	If type("oItem:_CONFIRMACAO:_INTEGRADO:TEXT") == "C"

		cCodEmp :=IIF(Type("oItem:_FILIAL:_CDEMPRESA:TEXT") == "C",oItem:_FILIAL:_CDEMPRESA:TEXT,"")
		cCodFil :=IIF(Type("oItem:_FILIAL:_CDFILIAL:TEXT")  == "C",oItem:_FILIAL:_CDFILIAL:TEXT ,"")
		cCodProd:=IIF(Type("oItem:_ID:_CODIGOPRODUTO:TEXT") == "C",oItem:_ID:_CODIGOPRODUTO:TEXT,"")
		cCodTek :=IIF(Type("oItem:_ID:_CDPRODUTO:TEXT")     == "C",oItem:_ID:_CDPRODUTO:TEXT    ,"")

		//agora testa se o conteudo é true
		lIntegrado := lower(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "true"
		If lIntegrado
			
			lIntegrado := lIntegrado .And. !Empty(cCodEmp)
			lIntegrado := lIntegrado .And. !Empty(cCodFil)
			lIntegrado := lIntegrado .And. !Empty(cCodProd)
			lIntegrado := lIntegrado .And. !Empty(cCodTek)

			// -> Se o código da empresa do Teknisa não retornou, registra erro no log
			If Empty(cCodEmp)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo da empresa do Teknisa. [_CDEMPRESA = " + IIF(Empty(cCodEmp),"Vazio",cCodEmp)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
				ConOut(cErrorLog)
			EndIf	

			// -> Se o código da filial do Teknisa não retornou, registra erro no log
			If Empty(cCodFil)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo da filial no Teknisa. [_CDFILIAL = " + IIF(Empty(cCodFil),"Vazio",cCodFil)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
				ConOut(cErrorLog)
			EndIf	

			// -> Se o código do produto do Teknisa não retornou, registra erro no log
			If Empty(cCodTek)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo produto do Teknisa. [_CODIGOPRODUTO = " + IIF(Empty(cCodTek),"Vazio",cCodTek)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
				ConOut(cErrorLog)
			EndIf	
			
			// -> Se o código do produto do Protheus não retornou, registra erro no log
			If Empty(cCodProd)
				cErrorLog:="O metodo " + Self:cMetEnv + " no retornou o codigo do produto no Protheus. [_CDPRODUTO = " + IIF(Empty(cCodProd),"Vazio",cCodProd)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
				ConOut(cErrorLog)
			EndIf	
		
		Else

			cErrorLog:=cMsgErro
			::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
			ConOut(cErrorLog)
		
		EndIf

		// -> Se ocorreu erro na integra��o, atualiza status de erro
		If !lIntegrado

			cCodProd :=PadR(IIF(Type("oItem:_ID:_CODIGOPRODUTO:TEXT") == "C",oItem:_ID:_CODIGOPRODUTO:TEXT,""),TamSx3("B1_COD")[1])
			cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")

			dbSelectArea("Z14")
			Z14->(dbSetOrder(1))
			Z14->(dbSeek(xFilial("Z14")+cCodProd))
			If Z14->(Found())
				recLock("Z14", .F.)
				Z14->Z14_XSTINT := "E"
				Z14->Z14_XDINT  := Date()
				Z14->Z14_XHINT  := Time()
				Z14->Z14_XLOG   := cErrorLog
				Z14->(msUnLock())
			EndIf	

		EndIf
	
	Else

		cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")
		::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
		ConOut(cErrorLog)
	
	EndIf

	// -> Se Ok, continua...
	If lIntegrado
		
		//cCodEmp :=IIF(Type("oItem:_FILIAL:_CDEMPRESA:TEXT") == "C",oItem:_FILIAL:_CDEMPRESA:TEXT,"")
		//cCodFil :=IIF(Type("oItem:_FILIAL:_CDFILIAL:TEXT")  == "C",oItem:_FILIAL:_CDFILIAL:TEXT ,"")
		cCodProd:=PadR(IIF(Type("oItem:_ID:_CODIGOPRODUTO:TEXT") == "C",oItem:_ID:_CODIGOPRODUTO:TEXT,""),TamSx3("B1_COD")[1])
		cCodTek :=IIF(Type("oItem:_ID:_CDPRODUTO:TEXT")     == "C",oItem:_ID:_CDPRODUTO:TEXT    ,"")

		cErrorLog:=": "+AllTrim(cCodProd)+": Atualizando status no ERP..." 
		::oLog:SetAddInfo(cErrorLog,"Retorno dos dados.")
		ConOut(cErrorLog)

		dbSelectArea("Z14")
		Z14->(dbSetOrder(1))
		Z14->(dbSeek(xFilial("Z14")+cCodProd))
		lIntegrado:=Z14->(Found())
		If lIntegrado

			recLock("Z14", .F.)
			Z14->Z14_XCODEX := IIF(UPPER(Self:cMetEnv) == "POST",cCodTek,Z14->Z14_XCODEX) 
			Z14->Z14_XSTINT := "I" 
			Z14->Z14_XDINT  := Date()
			Z14->Z14_XHINT  := Time()
			Z14->Z14_XLOG   := "Estrutura "+IIF(UPPER(Self:cMetEnv) == "POST","incluida ",IIF(UPPER(Self:cMetEnv) == "PUT","alterada ","excluida ")) + " com sucesso em " + DtoC(Date()) + " as " + Time()
			Z14->( msUnLock() )

			cErrorLog:="Ok: Estrutura "+IIF(UPPER(Self:cMetEnv) == "POST","incluida ",IIF(UPPER(Self:cMetEnv) == "PUT","alterada ","excluida "))
			::oLog:SetAddInfo(cErrorLog,"Confirmacao dos dados.")
			ConOut(cErrorLog)

			::oLog:setCountInc()

		Else

			cErrorLog:="Erro: Nao encontrado codigo de produto do Teknisa na processo de integracao. [Z14_XCODEX="+cCodTek+" e Z14_COD="+cCodProd+"]"
			::oLog:SetAddInfo(cErrorLog,"Erro de cadastro.")
			ConOut(cErrorLog)

		EndIf

	EndIf	

return


/*-----------------+---------------------------------------------------------+
!Nome              ! makeXml                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para gerar o XML de envio                        !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method makeXml(aLote,cMetEnv) class TeknisaPutComposicao
Local nC
Local cXml      := ""
Local cCodEmp	:= ""
Local cCodFil	:= ""
Local cDesFilP  := ""
Local cErrorLog := ""
Local lErroXML  := .F.
Local cFilSG1	:= xFilial("SG1")
	
	cErrorLog:=": Gerando XML..." 
	::oLog:SetAddInfo(cErrorLog,"Gerando XML...")
	ConOut(cErrorLog)
	
	dbSelectArea("SG1")
	SG1->( dbSetOrder(1) )

	dbSelectArea("SB1")
	SB1->( dbSetOrder(1) )
	
	dbSelectArea("Z14")
	Z14->( dbSetOrder(1) )
	
	dbSelectArea("Z13")
	Z13->( dbSetOrder(1) )

	// -> Pesquisa no cadastro de empresas
	ADK->(DbOrderNickName("ADKXFILI"))
	ADK->(DbSeek(xFilial("ADK")+cFilAnt))
	If !ADK->(Found())
		cErrorLog:="Erro: Empresa e/ou filial do Teknisa nao encontrada no cadastro de unidades de negocio. [ADK_XFILI="+cFilAnt+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
		ConOut(cErrorLog)
		Return("")
	ElseIf Empty(ADK->ADK_XFIL) .or. ADK->ADK_XFIL == "0000"
		cErrorLog:="Erro: Empresa e/ou filial nao integrada corretamente no Teknisa. [ADK_XFILI="+IIF(Empty(ADK->ADK_XEMP),"Vazio",ADK->ADK_XEMP)+" e ADK_XFIL="+IIF(Empty(ADK->ADK_XFIL),"Vazio",ADK->ADK_XFIL)+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
		ConOut(cErrorLog)
		Return("")
	Else
		cCodEmp :=ADK->ADK_XEMP
		cCodFil :=ADK->ADK_XFIL		
		cDesFilP:=ADK->ADK_NOME
	EndIf			

	cXml := '<estruturas>'

	For nC := 1 to len(aLote)
	
		lErroXML :=.F.
		If Lower(cMetEnv) != "delete"
		
			// -> Posiciona na tabela de composições a integrar
			Z14->( dbGoTo(aLote[nC,02]) )
			If Z14->(Eof()) 
				lErroXML :=.T.
				cErrorLog:="Erro: Produto com RECNO " + AllTrim(Str(aLote[nC,02])) + " nao encontrado na Z14." 
				::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
				ConOut(cErrorLog)						
			Else
				// -> Posiciona no cadastro do produto
				SB1->(DbGoTop())
				SB1->(dbSeek(xFilial("SB1") + Z14->Z14_COD))
				If !SB1->(Found()) 
					lErroXML :=.T.
					cErrorLog:="Erro: Codigo do produto  " + AllTrim(Z14->Z14_COD) + " nao encontrado na tabela SB1." 
					::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
					ConOut(cErrorLog)
				Else
					// -> Posiciona no cadastro da estrutura do produto
					SG1->(DbGoTop())
					SG1->(dbSeek(xFilial("SG1") + Z14->Z14_COD))
					If !SG1->(Found()) 
						lErroXML :=.T.
						cErrorLog:="Erro: Codigo do produto  " + AllTrim(Z14->Z14_COD) + " nao encontrado na tabela SG1." 
						::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
						ConOut(cErrorLog)
					Else
						// -> Verifica dados da estrutura do produto
						While !SG1->(Eof()) .and. SG1->G1_FILIAL == cFilSG1 .and. SG1->G1_COD == Z14->Z14_COD
							// -> Posiciona no produto da composição
							SB1->(DbGoTop())
							SB1->(DbSeek(xFilial("SB1")+SG1->G1_COMP))
							If !SB1->(Found())
								lErroXML :=.T.
								cErrorLog:="Erro: Codigo do produto  " + AllTrim(SG1->G1_COD) + " nao encontrado na tabela SB1." 
								::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
								ConOut(cErrorLog)
							Else
								// -> Posiciona no relacionamento do produto do Protheus x Teknisa
								Z13->(DbGoTop())
								Z13->(dbSeek(xFilial("Z13")+SG1->G1_COMP))
								If !Z13->(Found()) .or. AllTrim(Z13->Z13_XCODEX) == ""
									lErroXML :=.T.
									cErrorLog:="Erro: Produto ainda nao integrado e/ou ativado no Teknisa. [Z13_COD="+AllTrim(SG1->G1_COMP)+" e Z13_XCODEX="+Z13->Z13_XCODEX+"]" 
									::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")	
									ConOut(cErrorLog)
								Else 
									// -> Verifica se o produto foi ativado no Teknisa
									dbSelectArea("Z17")
									Z17->(dbSetOrder(1))
									Z17->(dbSeek(xFilial("Z17")+Z13->Z13_COD))
									If !Z17->(Found()) .or. Empty(Z17->Z17_XCODEX)
										lErroXML :=.T.
										cErrorLog:="Erro: Produto nao ativado no Teknisa. [Z17_COD="+AllTrim(Z13->Z13_COD)+" e Z13_XCODEX="+Z17->Z17_XCODEX+"]" 
										::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
										ConOut(cErrorLog)
									EndIf	
								EndIf							
							EndIf
							SG1->(DbSkip())
						EndDo
					EndIf
				EndIf
			
				// -> Verifica se ocorreu erro e grava no log
				If lErroXML
					RecLock("Z14")
					Z14->Z14_XLOG  :=cErrorLog
					Z14->Z14_XSTINT:="E"
					Z14->(MsUnlock())
				EndIf	
			
			EndIf
		
			// -> Se nao ocorreu erro, gera o XML
			If !lErroXML

				// -> Reposiciona no cadastro de produtos x fornecedor
				SB1->(DbGoTop())
				SB1->(dbSeek(xFilial("SB1") + Z14->Z14_COD))
				
				// -> Reposiciona no cadastro de estrutura de produtos 
				SG1->(DbGoTop())
				SG1->(dbSeek(xFilial("SG1") + Z14->Z14_COD))
				
				cXml += '<estrutura>'
	
				cXml += '<id'
				cXml +=	::tag('cdproduto'	 ,Z14->Z14_XCODEX) 								
				cXml += ::tag('nmprodut'	 ,SB1->B1_DESC)						
				cXml += ::tag('codigoproduto',SB1->B1_COD)						
				cXml += '/>'
	
				cXml += '<insumos>'
			
				While !SG1->(Eof()) .and. SG1->G1_FILIAL == cFilSG1 .and. SG1->G1_COD == Z14->Z14_COD
			
					// -> Reposiciona na tabela Z13
					Z13->(dbSeek(xFilial("Z13") + SG1->G1_COMP))	
					
					// -> Reposiciona na tabela SB1
					SB1->(dbSeek(xFilial("SB1") + SG1->G1_COMP))
			
					cXml += '<insumo'
					cXml += ::tag('cdsubproduto'	,Z13->Z13_XCODEX)
					cXml += ::tag('codigoproduto'	,SG1->G1_COMP)
					cXml += ::tag('nmprodut'		,SB1->B1_DESC)
					cXml += ::tag('tipo'			,SB1->B1_TIPO)
					cXml += ::tag('sunidade'		,SB1->B1_UM)
					cXml += ::tag('quantidade'		,SG1->G1_QUANT,"decimal")
					cXml += ::tag('dtinicial'		,DtoS(SG1->G1_INI))
					cXml += ::tag('dtfinal'		    ,DtoS(SG1->G1_FIM))
					cXml += '/>'
			
					SG1->(DbSkip())
				
				EndDo
	
				cXml += '</insumos>'
	
				cXml += '<empresas>'
			
				cXml += '<filial' 
				cXml += ::tag('cdempresa'	,cCodEmp)
				cXml += ::tag('cdfilial'	,cCodFil)
				cXml += ::tag('filial'		,Z14->Z14_FILIAL) 
				cXml += ::tag('nmfilial'	,cDesFilP)
				cXml += '/>'
			
				cXml += '</empresas>'
	
				cXml += '</estrutura>'
				
			EndIf	
		
		Else
		
			Z14->( dbGoTo(aLote[nC,02]) )
			
			// -> Reposiciona no cadastro de produtos x fornecedor
			SB1->(DbGoTop())
			SB1->(dbSeek(xFilial("SB1") + Z14->Z14_COD))
			
			
			cXml += '<estrutura>'
	
			cXml += '<id'
			cXml +=	::tag('cdproduto'		,SB1->B1_XCODEXT) 								
			cXml += ::tag('nmprodut'		,SB1->B1_DESC)						
			cXml += ::tag('codigoproduto'	,SB1->B1_COD)						
			cXml += '/>'
	
			cXml += '<insumos>'
			
			cXml += '<insumo'
			cXml += ::tag('cdsubproduto'	,"")
			cXml += ::tag('codigoproduto'	,"")
			cXml += ::tag('nmprodut'		,"")
			cXml += ::tag('tipo'			,"")
			cXml += ::tag('sunidade'		,"")
			cXml += ::tag('quantidade'		,0		,"decimal")
			cXml += '/>'
	
			cXml += '</insumos>'
	
			cXml += '<empresas>'
			
			cXml += '<filial' 
			cXml += ::tag('cdempresa'	,Z14->Z14_XEMP)
			cXml += ::tag('cdfilial'	,Z14->Z14_XFIL)
			cXml += ::tag('filial'		,Z14->Z14_FILIAL) 
			cXml += ::tag('nmfilial'	,cDesFilP)
			cXml += '/>'
			
			cXml += '</empresas>'
	
			cXml += '</estrutura>'
			
		EndIf

 	Next nC

	cXml += '</estruturas>'
	
	If AllTrim(cXml) == "<estruturas></estruturas>"
		cXml:=""
	EndIf
	
	MemoWrite("C:\TEMP\XML_" + cMetEnv + ".XML",cXml)

return cXml