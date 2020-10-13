#include 'protheus.ch'
/*-----------------+---------------------------------------------------------+
!Nome              ! TkPutVend                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para chamr o metodo PutVendedor via Menu         !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
user function TkPutVend(lBatch)
Private cPerg := padr("TPMETODO",10)
Default lBatch:= .F.
	
    // -> Se não for executado por job
    If !lBatch
 		U_CRSX01MD()
		if !Pergunte(cPerg,.T.)
			Return .F.
		EndIf
	
		Do Case
			Case MV_PAR01 = 1
				TkVend("Post")
			Case MV_PAR01 = 2
				TkVend("Put")
			Case MV_PAR01 = 3
				TkVend("Delete")
		EndCase
	EndIf
	
	// -> Se for executado por job
    If lBatch
 		// -> Executa o processo de inclusão de vendedores 
 		TkVend("Post")       
 		// -> Executa o processo de alteração de vendedores 
 		TkVend("Put")
 		// -> Executa o processo de exclusao de vendedores 
		TkVend("Delete")                 		
 	EndIf			

Return



/*-----------------+---------------------------------------------------------+
!Nome              ! TkVend                                                  !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para processar o WS                              !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function TkVend(cMetEnv)
Local oIntegra
Local cMethod	:= "PutVendedor"
Local cAlias	:= "Z15"
Local cAlRot	:= "SA3"
Local oEventLog := EventLog():start("Vendedores - "+AllTrim(cMetEnv), Date(), "Iniciando processo de integracao...", cMetEnv, cAlRot) 
	
	//instancia a classe
	oIntegra := TeknisaPutVendedor():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	If oIntegra:isEnable()

		//busca os registros e se sequencia em lotes
		oIntegra:prepare()

		oIntegra:send()

	EndIf
	
	oEventLog:Finish()

return



/*-----------------+---------------------------------------------------------+
!Nome              ! TeknisaPutVendedor                                      !
+------------------+---------------------------------------------------------+
!Descrição         ! Classe PutVendedor                                      !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
class TeknisaPutVendedor from TeknisaMethodAbstract
Data oLog
Data cMetE

	method new() constructor
	method makeXml(aLote,cMetEnv)
	method analise(oXmlItem,lNewReg)
	method fetch()

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
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaPutVendedor

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
method fetch() class TeknisaPutVendedor
Local cQuery	:= ''
Local cPreRot	:= If(Len(PrefixoCpo(::cAlRot)) == 2,"S" + PrefixoCpo(::cAlRot), PrefixoCpo(::cAlRot))
Local cPreAli	:= If(Len(PrefixoCpo(::cAlias)) == 2,"S" + PrefixoCpo(::cAlias), PrefixoCpo(::cAlias))
Local cErrorLog := ""

	cErrorLog:=": Selecionando vendedores..." 
	::oLog:SetAddInfo(cErrorLog,"Selecionando dados...")
	ConOut(cErrorLog)

	cQuery += "	SELECT " + CRLF
	cQuery += "		" + cPreRot + ".R_E_C_N_O_ ROT_REG, " + CRLF	//Recno da tabela Principal
	cQuery += "		" + cPreAli + ".R_E_C_N_O_ ALI_REG " + CRLF		//Recno da tabela Auxiliar
	
	cQuery += "	FROM " + RetSqlName(::cAlias) + " " + cPreAli + " " + CRLF
	
	cQuery += "	LEFT JOIN " + RetSqlName(::cAlRot) + " " + cPreRot + " ON "                         + CRLF
	cQuery += "	 		  " + PrefixoCpo(::cAlRot) + "_FILIAL = '" + xFilial(::cAlRot)    + "' "    + CRLF
	cQuery += "		  AND " + PrefixoCpo(::cAlRot) + "_COD    = "  + PrefixoCpo(::cAlias) + "_COD " + CRLF
	cQuery += "		  AND " + cPreRot + ".D_E_L_E_T_ = ' ' " + CRLF
	
	cQuery += "	WHERE  " + CRLF
	cQuery += "			" + PrefixoCpo(::cAlias) + "_FILIAL = '" + xFilial(::cAlias) + "' " + CRLF
	
	If Upper(::cMetEnv) == "POST"
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XSTINT IN ('P','E') " + CRLF
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XDINT   = ' '       " + CRLF
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XEXC   != 'S'       " + CRLF
	ElseIf Upper(::cMetEnv) == "PUT"
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XSTINT IN ('P','E') " + CRLF
		cQuery += "		AND " + PrefixoCpo(::cAlias) + "_XDINT  != ' '       " + CRLF
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
method analise(oXmlItem,lNewReg) class TeknisaPutVendedor

Local lIntegrado:= .F.
Local cCodVend 	:= ""
Local cA3Cod    := ""
Local cErrorLog := ""
Local cMsgErro  := ""
Private oItem   := oXmlItem

	// -> verifica se a propriedade integrado existe
	cMsgErro:=IIF(type("oItem:_CONFIRMACAO:_MENSAGEM:TEXT")=="C",oItem:_CONFIRMACAO:_MENSAGEM:TEXT,"")
	If type("oItem:_CONFIRMACAO:_INTEGRADO:TEXT") == "C"
		
		lIntegrado := lower(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "true"
		
		If lIntegrado

			cCodVend:=IIF(type("oItem:_ID:_CDVENDEDOR:TEXT") == "C",oItem:_ID:_CDVENDEDOR:TEXT,"")
			cA3Cod  :=IIF(type("oItem:_ID:_CODIGO:TEXT"    ) == "C",oItem:_ID:_CODIGO:TEXT,"")
			
			lIntegrado := lIntegrado .And. !Empty(cCodVend)
			lIntegrado := lIntegrado .And. !Empty(cA3Cod)

			// -> Se o codigo do vendedor do Teknisa nao retornou no XML
			If Empty(cCodVend)
				cErrorLog:="O metodo " +Self:cMetEnv +" nao retornou o codigo de vendedor do Teknisa. [_CDVENDEDOR = " + IIF(Empty(cCodVend),"Vazio",cCodVend)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
				ConOut(cErrorLog)
			EndIf	

			// -> Se o codigo do vendedor do Protheus nao retornou no XML
			If Empty(cCodVend)
				cErrorLog:="O metodo " +Self:cMetEnv +" nao retornou o codigo de vendedor do Protheus. [_CODIGO = " + IIF(Empty(cA3Cod),"Vazio",cA3Cod)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
				ConOut(cErrorLog)
			EndIf	

		Else	

			cErrorLog:=cMsgErro
			::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
			ConOut(cErrorLog)

		EndIf

		// -> Se oorreu erro de integração, atualiza status com erro
		If !lIntegrado
			
			cA3Cod   :=PadR(IIF(type("oItem:_ID:_CODIGO:TEXT"    ) == "C",oItem:_ID:_CODIGO:TEXT,""),TamSX3("A3_COD")[1])
			cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")

			// -> Pasiciona na tabela de vendedores
			dbSelectArea("Z15")
			Z15->(dbSetOrder(1))
			Z15->(dbSeek( xFilial("Z15")+cA3Cod))
			If Z15->(Found())
				recLock("Z15", .F.)
				Z15->Z15_XSTINT := "E"
				Z15->Z15_XDINT  := Date()
				Z15->Z15_XHINT  := Time()
				Z15->Z15_XLOG   := cErrorLog
				Z15->( msUnLock() )
			EndIf

		EndIf	

	Else
		
		cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")
		::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
		ConOut(cErrorLog)

	EndIf

	// Se ok, continua....
	If lIntegrado

		cCodVend:=IIF(type("oItem:_ID:_CDVENDEDOR:TEXT") == "C",oItem:_ID:_CDVENDEDOR:TEXT,"")
		cA3Cod  :=PadR(IIF(type("oItem:_ID:_CODIGO:TEXT"    ) == "C",oItem:_ID:_CODIGO:TEXT,""),TamSX3("A3_COD")[1])

		cErrorLog:=": "+AllTrim(cA3Cod)+": Atualizando status no ERP..." 
		::oLog:SetAddInfo(cErrorLog,"Retorno dos dados.")
		ConOut(cErrorLog)

		//tabela de vendedores
		dbSelectArea("Z15")
		Z15->(dbSetOrder(1))
		Z15->(dbSeek( xFilial("Z15")+cA3Cod))
		lIntegrado:=Z15->(Found())
		If lIntegrado

			recLock("Z15", .F.)
			Z15->Z15_XSTINT := "I" //Integrado
			Z15->Z15_XVEND	:= oItem:_ID:_CDVENDEDOR:TEXT
			Z15->Z15_XDINT  := Date()
			Z15->Z15_XHINT  := Time()
			Z15->Z15_XLOG   := "Vendedor "+IIF(UPPER(Self:cMetEnv) == "POST","incluido ",IIF(UPPER(Self:cMetEnv) == "PUT","alterado ","excluido ")) + " com sucesso em " + DtoC(Date()) + " as " + Time()
			Z15->(msUnLock())

			cErrorLog:="Ok: Vendedor "+IIF(UPPER(Self:cMetEnv) == "POST","incluido ",IIF(UPPER(Self:cMetEnv) == "PUT","alterado ","excluido "))
			::oLog:SetAddInfo(cErrorLog,"Retorno dos dados.")
			ConOut(cErrorLog)

			::oEventLog:setCountInc()

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
method makeXml(aLote,cMetEnv) class TeknisaPutVendedor
Local cXml
Local nC
Local cErrorLog := ""
Local lErroXML  := .F.
	
	cErrorLog:=": Gerando XML..." 
	::oLog:SetAddInfo(cErrorLog,"Gerando XML...")
	ConOut(cErrorLog)
	
	cXml := '<vendedores>'
	
	For nC := 1 to len(aLote)

		lErroXML:=.F.
		// posiciona no produto
		SA3->(dbGoTo(aLote[nC,01]))
		
		Z15->( dbGoTo(aLote[nC,02]) )
		
		If cMetEnv != "DELETE"

			cXml += '<vendedor>'

			cXml += '<id'
			cXml += ::tag('codigo'			,Z15->Z15_COD)
			cXml += ::tag('cdvendedor'		,Z15->Z15_XVEND)
			cXml += '/>'

			cXml += '<cadastral'
			cXml += ::tag('nmrazsocial'		,SA3->A3_NOME) 
			cXml += ::tag('nmfanven'		,SA3->A3_NREDUZ)  
			cXml += ::tag('endereco'		,SA3->A3_END)  
			cXml += ::tag('bairro'			,SA3->A3_BAIRRO)
			cXml += ::tag('municipio'		,SA3->A3_MUN) 
			cXml += ::tag('uf'				,SA3->A3_EST) 
			cXml += ::tag('cep'				,SA3->A3_CEP)
			cXml += ::tag('ddd'				,SA3->A3_DDDTEL)
			cXml += ::tag('telefone'		,SA3->A3_TEL)  
			cXml += ::tag('tipo'			,SA3->A3_TIPO) 
			cXml += ::tag('cgc'				,SA3->A3_CGC)
			cXml += ::tag('increst'			,SA3->A3_INSCR)
			cXml += ::tag('email'			,SA3->A3_EMAIL)  
			cXml += ::tag('codigousr'		,SA3->A3_CODUSR) 
			cXml += ::tag('supervisor'		,SA3->A3_SUPER)
			cXml += ::tag('gerente'			,SA3->A3_GEREN) 
			cXml += ::tag('codfunc'			,SA3->A3_NUMRA) 
			cXml += ::tag('codforn'			,SA3->A3_FORNECE) 
			cXml += ::tag('lojaforn'		,SA3->A3_LOJA) 
			cXml += ::tag('ativo'			,If(SA3->A3_MSBLQL == "1","N","S")) 
			cXml += '/>'

			cXml += '</vendedor>'
			
		Else
		
			// -> Verifica se o vendedor já foi integrado no Teknisa
			If Empty(Z15->Z15_XVEND) 
				lErroXML:=.T.
				cErrorLog:="Vendedor ainda nao integrado com o Teknisa. Favor verificar o codigo do vendedor relacionado ao Tknisa na tabela Z15. [Z15_XVEND=Vazio]" 
				::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
				ConOut("Erro: "+cErrorLog)	
			EndIf

			// -> Se não ocorreu erro, gera o XML
			If !lErroXML
			
				cXml += '<vendedor>'

				cXml += '<id'
				cXml += ::tag('codigo'			,Z15->Z15_COD)
				cXml += ::tag('cdvendedor'		,Z15->Z15_XVEND)
				cXml += '/>'

				cXml += '<cadastral'
				cXml += ::tag('nmrazsocial'		,SA3->A3_NOME) 
				cXml += ::tag('nmfanven'		,SA3->A3_NREDUZ)  
				cXml += ::tag('endereco'		,SA3->A3_END)  
				cXml += ::tag('bairro'			,SA3->A3_BAIRRO)
				cXml += ::tag('municipio'		,SA3->A3_MUN) 
				cXml += ::tag('uf'				,SA3->A3_EST) 
				cXml += ::tag('cep'				,SA3->A3_CEP)
				cXml += ::tag('ddd'				,SA3->A3_DDDTEL)
				cXml += ::tag('telefone'		,SA3->A3_TEL)  
				cXml += ::tag('tipo'			,SA3->A3_TIPO) 
				cXml += ::tag('cgc'				,SA3->A3_CGC)
				cXml += ::tag('increst'			,SA3->A3_INSCR)
				cXml += ::tag('email'			,SA3->A3_EMAIL)  
				cXml += ::tag('codigousr'		,SA3->A3_CODUSR) 
				cXml += ::tag('supervisor'		,SA3->A3_SUPER)
				cXml += ::tag('gerente'			,SA3->A3_GEREN) 
				cXml += ::tag('codfunc'			,SA3->A3_NUMRA) 
				cXml += ::tag('codforn'			,SA3->A3_FORNECE) 
				cXml += ::tag('lojaforn'		,SA3->A3_LOJA) 
				cXml += ::tag('ativo'			,If(SA3->A3_MSBLQL == "1","N","S")) 
				cXml += '/>'
			
			EndIf	
				
		EndIf	

 	Next nC

	cXml += '</vendedores>'                            

	If AllTrim(cXml) == "<vendedores></vendedores>"
		cXml:=""
	EndIf	
		
	MemoWrite("C:\TEMP\XML_" + cMetEnv + ".XML",cXml)

return cXml