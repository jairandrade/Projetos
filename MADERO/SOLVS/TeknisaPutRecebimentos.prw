#include 'protheus.ch'
/*-----------------+---------------------------------------------------------+
!Nome              ! TkPutReceb                                              !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para chamr o metodo PutRecebimentos via Menu     !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
user function TkPutReceb()
 	
	 // -> Executa o processo para inclusão de recebimentos
	TkReceb("Post")    
 	
	 // -> Executa o processo para alteração de recebimentos
	TkReceb("Put")    
 	
	 // -> Executa o processo oara exclusão de unidades de negócio
	TkReceb("Delete")    
    
Return


/*-----------------+---------------------------------------------------------+
!Nome              ! TkReceb                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para processar o WS                              !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function TkReceb(cMetEnv)
Local oIntegra
Local cMethod	:= "PutRecebimentos"
Local cAlias	:= "Z10"
Local cAlRot	:= "SA3"
Local oEventLog := EventLog():start("Recebimentos - "+AllTrim(cMetEnv), Date(), "Iniciando processo de integracao...", cMetEnv, cAlRot) 

	//instancia a classe
	oIntegra := TeknisaPutRecebimentos():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	If oIntegra:isEnable()

		//busca os registros e se sequencia em lotes
		oIntegra:prepare()

		oIntegra:send()

	EndIf
	
	oEventLog:Finish()

return


/*-----------------+---------------------------------------------------------+
!Nome              ! TeknisaPutRecebimentos                                  !
+------------------+---------------------------------------------------------+
!Descrição         ! Classe PutRecebimentos                                  !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
class TeknisaPutRecebimentos from TeknisaMethodAbstract
Data oLog
Data cMetE

	method new() constructor
	method makeXml(aLote,cMetEnv)
	method analise(oXmlItem,lNewReg)
	method fetch() 
	method prepare()

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
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaPutRecebimentos

	//inicialisa a classe
	::init(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)
	::oLog :=oEventLog
	::cMetE:=cMetEnv

return


/*-----------------+---------------------------------------------------------+
!Nome              ! fetch                                                   !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para a seleção dos dados a enviar                !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method fetch() class TeknisaPutRecebimentos
Local cQuery := ''
Local cErrorLog := ""

	cErrorLog:=": Selecionando recebimentos..." 
	::oLog:SetAddInfo(cErrorLog,"Selecionando dados...")
	ConOut(cErrorLog)

	cQuery := "	SELECT " + CRLF
	cQuery += "		Z10.R_E_C_N_O_ Z10_REG, " + CRLF
	If Upper(::cMetEnv) != "DELETE"
		cQuery += "		SE4.R_E_C_N_O_ SE4_REG " + CRLF
	Else
		cQuery += "		0 SE4_REG " + CRLF
	EndIf
	cQuery += "	FROM " + RetSqlName("Z10") + " Z10 " + CRLF 
	If Upper(::cMetEnv) != "DELETE"
		cQuery += "	INNER JOIN " + RetSqlName("SE4") + " SE4 ON      " + CRLF
		cQuery += "			SE4.E4_FILIAL  = '" + xFilial("SE4") + "'" + CRLF
		cQuery += "		AND SE4.E4_CODIGO  = Z10.Z10_CODIGO          " + CRLF
		cQuery += "		AND SE4.D_E_L_E_T_ = ' '                     " + CRLF
 	EndIf
	cQuery += "	WHERE "                                                + CRLF  
	cQuery += "			Z10.Z10_FILIAL = '" + xFilial("Z10") + "' "    + CRLF
	If Upper(::cMetEnv) == "POST"
		cQuery += "		AND Z10.Z10_XSTINT IN ('P','E') " + CRLF 
		cQuery += "		AND Z10.Z10_XDINT   = ' '       " + CRLF
		cQuery += "		AND Z10.Z10_XEXC   != 'S'       " + CRLF
	ElseIf Upper(::cMetEnv) == "PUT"
		cQuery += "		AND Z10.Z10_XSTINT IN ('P','E') " + CRLF 
		cQuery += "		AND Z10.Z10_XDINT != ' '        " + CRLF
		cQuery += "		AND Z10.Z10_XEXC  != 'S'        " + CRLF	
	ElseIf Upper(::cMetEnv) == "DELETE"
		cQuery += "		AND Z10.Z10_XSTINT IN ('P','E') " + CRLF 
		cQuery += "		AND Z10.Z10_XEXC    = 'S'       " + CRLF
	EndIf
	cQuery += "		AND Z10.Z10_XFILI  = '"+cFilAnt+"' "     + CRLF 
	cQuery += "		AND Z10.D_E_L_E_T_ = ' ' "     + CRLF 

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
method analise(oXmlItem,lNewReg) class TeknisaPutRecebimentos
Local lIntegrado:= .F.
Local cCodRec 	:= ""
Local cE4CODIGO := ""
Local cErrorLog := ""
Local cMsgErro  := ""
Private oItem 	:= oXmlItem

	//verifica se a propriedade integrado existe
	cMsgErro:=IIF(type("oItem:_CONFIRMACAO:_MENSAGEM:TEXT")=="C",oItem:_CONFIRMACAO:_MENSAGEM:TEXT,"")
	If type("oItem:_CONFIRMACAO:_INTEGRADO:TEXT") == "C"
		
		cCodRec  :=IIF(type("oItem:_ID:_CDTIPOREC:TEXT"    ) == "C",oItem:_ID:_CDTIPOREC:TEXT,"")
		cE4CODIGO:=IIF(type("oItem:_ID:_CODIGO:TEXT"       ) == "C",oItem:_ID:_CODIGO:TEXT,""   )
		
		// -> Verifica reorno do processo
		lIntegrado := lower(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "true"
		If lIntegrado
			
			lIntegrado := lIntegrado .And. !Empty(cCodRec)
			lIntegrado := lIntegrado .And. !Empty(cE4CODIGO)

			// -> Se o codigo do recebimento nao retornou no XML, registra erro no log
			If Empty(cCodRec)
				cErrorLog:="O metodo " + Seff:cMetEnv + " nao retornou o codigo de recebimento no Teknisa apos a chamada no metodo. [_CDTIPOREC = " + IIF(Empty(cCodRec),"Vazio",cCodRec)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
				ConOut(cErrorLog)
			EndIf	

			// -> Se o codigo da condicao de pagamento do protheus nao retornou no XML, registra erro no log
			If Empty(cE4CODIGO)
				cErrorLog:="O metodo " + Seff:cMetEnv + " nao retornou o codigo da condicao de recebimento do Protheus. [_CODIGOC = " + IIF(Empty(cE4CODIGO),"Vazio",cE4CODIGO)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")		
				ConOut(cErrorLog)
			EndIf	

		Else

			cErrorLog:=cMsgErro
			::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")		
			ConOut(cErrorLog)

		EndIf

		// -> Se ocorreu erro na integra��o
		If !lIntegrado
			
			cE4CODIGO:=PadR(IIF(type("oItem:_ID:_CODIGO:TEXT"  ) == "C",oItem:_ID:_CODIGO:TEXT,""),TamSx3("E4_CODIGO")[1])
			cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")
			
			// -> Posiciona no registro da tabela de condi��es de pagamento do processo de integra��o
			dbSelectArea("Z10")
			Z10->( dbSetOrder(1) )
			Z10->( dbSeek( xFilial("Z10") + cE4CODIGO))
			If Z10->(Found())
				recLock("Z10", .F.)
				Z10->Z10_XSTINT := "E"
				Z10->Z10_XDINT  := Date()
				Z10->Z10_XHINT  := Time()
				Z10->Z10_XLOG   := cErrorLog
				Z10->( msUnLock() )
			EndIf
		
		EndIf

	Else

		cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")
		::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
		ConOut(cErrorLog)

	EndIf

	// -> Se nao ocorreu erro, continua....
	If lIntegrado
		
		cCodRec  :=IIF(type("oItem:_ID:_CDTIPOREC:TEXT"    ) == "C",oItem:_ID:_CDTIPOREC:TEXT,"")
		cE4CODIGO:=PadR(IIF(type("oItem:_ID:_CODIGO:TEXT"  ) == "C",oItem:_ID:_CODIGO:TEXT,""),TamSx3("E4_CODIGO")[1])

		cErrorLog:=": "+AllTrim(cE4CODIGO)+": Atualizando status no ERP..." 
		::oLog:SetAddInfo(cErrorLog,"Retorno dos dados.")
		ConOut(cErrorLog)
		
		// -> Verifica se a consicao de pagamento existe no protheus
		dbSelectArea("SE4")
		SE4->(DbSetOrder(1))
		If SE4->(DbSeek(xFilial("SE4") + cE4CODIGO))
			recLock("SE4", .F.)
			SE4->E4_CODEXT := cCodRec
			SE4->( msUnLock() )

			// -> Posiciona no registro da tabela de condi��es de pagamento do processo de integra��o
			dbSelectArea("Z10")
			Z10->( dbSetOrder(1) )
			Z10->( dbSeek( xFilial("Z10") + cE4CODIGO))
			lIntegrado := Z10->( Found() )
			If lIntegrado

				recLock("Z10", .F.)
				Z10->Z10_CODEXT := cCodRec
				Z10->Z10_XSTINT := "I" //Integrado
				Z10->Z10_XDINT  := Date()
				Z10->Z10_XHINT  := Time()
				Z10->Z10_XLOG   := "Condicao de recebimento "+IIF(UPPER(Self:cMetEnv) == "POST","incluida ",IIF(UPPER(Self:cMetEnv) == "PUT","alterada ","excluida ")) + " com sucesso em " + DtoC(Date()) + " as " + Time()
				Z10->( msUnLock() )
		
				cErrorLog:="Ok: Condicao de recebimento "+IIF(UPPER(Self:cMetEnv) == "POST","incluida ",IIF(UPPER(Self:cMetEnv) == "PUT","alterada ","excluida "))
				::oLog:SetAddInfo(cErrorLog,"Gravacao dos dados.")
				ConOut(cErrorLog)
				::oEventLog:setCountInc()

			EndIf

		Else

			cErrorLog:="Erro: Condicao de pagamento nao encontrada no Prothues. [E4_CODIGO="+oItem:_ID:_CODIGO:TEXT+"]"
			::oLog:SetAddInfo(cErrorLog,"Gravacao dos dados.")
			ConOut(cErrorLog)

		EndIf

	EndIf

Return

/*-----------------+---------------------------------------------------------+
!Nome              ! makeXml                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Metodo para gerar o XML de envio                        !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method makeXml(aLote,cMetEnv) class TeknisaPutRecebimentos
Local cXml
Local nC
Local cAETIPO     := ""
Local nAETAXA	  := 0
Local nAEVENCFIN  := 0
Local cZ11XCLIEN  := ""
Local cZ11XCONSU  := ""
Local cAECODCLI   := ""
Local cA1LOJA     := ""
Local cAEXCCRED   := ""
Local cAEREDE     := "" 
Local cA1CGC      := ""
Local cAEADMCART  := ""
Local cAEMSBLQL   := ""                      
Local cSE4XTPREC  := ""
Local cErrorLog   := ""
Local cTefPos	  := ""
Local lErroXML    := .F.
	
	If Len(aLote) <= 0
		Return("")
	EndIf
		
	dbSelectArea("Z10")
	Z10->(dbGoTo(aLote[01,01]))
	
	cErrorLog:=": Gerando XML..." 
	::oLog:SetAddInfo(cErrorLog,"Gerando XML...")
	ConOut(cErrorLog)

	// -> Pesquisa no cadastro de empresas
	ADK->(DbOrderNickName("ADKXFILI"))
	ADK->(DbSeek(xFilial("ADK")+cFilAnt))
	If !ADK->(Found())
		cErrorLog:="Erro: Filial " + cFilAnt + " nao encontrada no cadastro de unidades de negocio. [ADK_XFILI="+cFilAnt+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")		
		ConOut(cErrorLog)
		Return("")
	ElseIf Empty(ADK->ADK_XFIL) .or. ADK->ADK_XFIL == "0000"
		cErrorLog:="Erro: Filial " + cFilAnt + " nao integrada corretamente no Teknisa. [ADK_XFILI="+IIF(Empty(ADK->ADK_XEMP),"Vazio",ADK->ADK_XEMP)+" e ADK_XFIL="+IIF(Empty(ADK->ADK_XFIL),"Vazio",ADK->ADK_XFIL)+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")		
		ConOut(cErrorLog)
		Return("")
	EndIf			

	cXml := '<recebimentos>'
	
	For nC := 1 to len(aLote)

		cAETIPO    := ""
		nAETAXA	   := 0
		nAEVENCFIN := 0
		cZ11XCLIEN := ""
		cZ11XCONSU := ""
		cAECODCLI  := ""
		cA1LOJA    := ""
		cAEXCCRED  := ""
		cAEREDE    := "" 
		cA1CGC     := ""
		cAEADMCART := ""
		cAEMSBLQL  := "1"
		lErroXML   := .F.

		If UPPER(cMetEnv) != "DELETE"

			Z10->( dbGoTo(aLote[nC,01]) )
			SE4->( dbGoTo(aLote[nC,02]) )
			
			cSE4XTPREC := SE4->E4_XTPREC
			
			If !Empty(SE4->E4_XTPREC)
				// -> Posiciona na administradora
				SAE->(dbOrderNickName("AEXCOD"))
				If SAE->(DbSeek(xFilial("SE4")+SE4->E4_CODIGO))
					cAETIPO    := SAE->AE_TIPO
					nAETAXA	   := SAE->AE_TAXA
					nAEVENCFIN := SAE->AE_VENCFIN
					cAECODCLI  := SAE->AE_CODCLI
					cAEXCCRED  := SAE->AE_XCCRED
					cAEREDE    := SAE->AE_REDE
					cAEADMCART := SAE->AE_ADMCART
					cTefPos	   := SAE->AE_XTEFPO
					cAEMSBLQL  := IIF(FieldPos("AE_MSBLQL") > 0,IIF(SAE->AE_MSBLQL == "1","N","S"),"S")					
					// -> Posiciona na tabela de Clientes, para 'pegar' o cliente relacionado a administrdora
					SA1->(DbSetOrder(1))
					If SA1->(DbSeek(xFilial("SA1")+SAE->AE_CODCLI))
						cA1LOJA := SA1->A1_LOJA
						cA1CGC  := SA1->A1_CGC			    
					Else
						// -> Se o cliente relacionado a administradora não estiver cadastrado no Protheus, gera log
						lErroXML:=.T.
						cErrorLog:="Cliente relacionado a administradora de cartao nao cadastrado no Protheus. [AE_CODCLI = " + IIF(Empty(SAE->AE_CODCLI),"Vazio",SAE->AE_CODCLI)+"]" 
						::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")		
						ConOut(cErrorLog)
					EndIf
				EndIf				
			Else
				lErroXML:=.T.
				cErrorLog:="Tipo do recebimento nao informado na condicao de pagamento. [E4_XTPREC="+cSE4XTPREC+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")			
				ConOut(cErrorLog)			
			EndIf
	                                  
			// -> Apenas gera o XML se nao ocorreu erro
			If !lErroXML
			
				cXml += '<recebimento>'
			
				cXml += '<id'
				cXml += ::tag('cdtiporec'		,Z10->Z10_CODEXT)
				cXml += ::tag('idtiporec'		,cSE4XTPREC)
				cXml += ::tag('codigo'			,Z10->Z10_CODIGO)
				cXml += '/>'
			
				cXml += '<cadastral'
				cXml += ::tag('tefpos'			,cTefPos)
				cXml +=	::tag('nmtiporec'		,Z10->Z10_DESC)
				cXml +=	::tag('formapgto'		,cAETIPO)
				cXml +=	::tag('vrtaxaadmi'		,nAETAXA   ,"DECIMAL")
				cXml +=	::tag('nrdiasadmi'		,nAEVENCFIN,"DECIMAL")
				cXml +=	::tag('cdcliente'		,cZ11XCLIEN)
				cXml +=	::tag('cdconsumidor'	,cZ11XCONSU)
				cXml +=	::tag('cliente'			,cAECODCLI)
				cXml +=	::tag('loja'			,cA1LOJA)
				cXml +=	::tag('ativa'			,cAEMSBLQL)
				cXml +=	::tag('codcredenciadora',cAEXCCRED)
				cXml +=	::tag('bandeira'		,cAEREDE)
				cXml +=	::tag('cnpjadm'			,cA1CGC)
				cXml +=	::tag('codbandeira'		,cAEADMCART)
				cXml += '/>'	
				cXml += '</recebimento>'
				
			EndIf	
		
		Else

			Z10->( dbGoTo(aLote[nC,01]) )
			// -> Apenas gera o XML se nao ocorreu erro
			If !lErroXML

				cXml += '<recebimento>'
			
				cXml += '<id'
				cXml += ::tag('cdtiporec'		,Z10->Z10_CODEXT)
				cXml += ::tag('idtiporec'		,"")
				cXml += ::tag('codigo'			,Z10->Z10_CODIGO)
				cXml += '/>'
			
				cXml += '<cadastral'
				cXml +=	::tag('nmtiporec'		,Z10->Z10_DESC)
				cXml +=	::tag('formapgto'		,"")
				cXml +=	::tag('vrtaxaadmi'		,0	,"DECIMAL")
				cXml +=	::tag('nrdiasadmi'		,0	,"DECIMAL")
				cXml +=	::tag('cdcliente'		,"")
				cXml +=	::tag('cdconsumidor'	,"")
				cXml +=	::tag('cliente'			,"")
				cXml +=	::tag('loja'			,"")
				cXml +=	::tag('ativa'			,"")
				cXml +=	::tag('codcredenciadora',"")
				cXml +=	::tag('bandeira'		,"")
				cXml +=	::tag('cnpjadm'			,"")
				cXml += '/>'	
			
				cXml += '</recebimento>'
		
			EndIf
			
		EndIf
		
 	Next nC

	cXml += '</recebimentos>'
	
	If AllTrim(cXml) == "<recebimentos></recebimentos>"
		cXml:=""
	EndIf	
	
	MemoWrite("C:\TEMP\XML_" + cMetEnv + ".XML",cXml)

return cXml


/*-----------------+---------------------------------------------------------+
!Nome              ! prepare                                                 !
+------------------+---------------------------------------------------------+
!Descricao         ! Metoto para preparar os lotes a enviar                  !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/

method prepare() class TeknisaPutRecebimentos
Local cAlias	:= ::fetch()
Local nCont		:= 0
Local cErrorLog	:= ""
	
	::aLotes := {}

	While !(cAlias)->(Eof())
	
		nCont:=nCont+1

		IF Len(::aLotes) == 0 .Or. len(::aLotes[len(::aLotes)]) >= ::nLimite
			aAdd(::aLotes, {})
		EndIF

		aAdd( ::aLotes[len(::aLotes)],	{;
											(cAlias)->Z10_REG,;
											(cAlias)->SE4_REG,;
										} )	
		
		(cAlias)->( dbSkip() )
	
	EndDo

	(cAlias)->( dbCloseArea() )
	
	::oLog:setCountTot(nCont)
	cErrorLog:=": "+AllTrim(Str(nCont))+" item(ns) selecionado(s)."
	::oLog:SetAddInfo(cErrorLog,"Pesquisando dados.")
	ConOut(cErrorLog)

return len(::aLotes) > 0