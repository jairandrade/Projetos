#include 'protheus.ch'
/*-----------------+---------------------------------------------------------+
!Nome              ! TkPutClie                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para chamr o metodo PutCliente via Menu          !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function TkPutClie()

 	// -> Executa o processo para inclusão de clientes
 	TkClie("Post")			 		
 	
	 // -> Executa o processo para alteração de clientes
 	TkClie("Put")			
 	
	 // -> Executa o processo para exclusão de clientes
 	TkClie("Delete")	    
	    
Return


/*-----------------+---------------------------------------------------------+
!Nome              ! TkClie                                                  !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para processar o WS                              !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function TkClie(cMetEnv)
Local oIntegra
Local cMethod	:= "PutCliente"
Local cAlias	:= "Z11"
Local cAlRot	:= "SA1"
Local oEventLog := EventLog():start("Clientes - "+AllTrim(cMetEnv), Date(), "Iniciando processo de integracao...", cMetEnv, cAlRot) 
	
	//instancia a classe
	oIntegra := TeknisaPutCliente():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	If oIntegra:isEnable()

		//busca os registros e se sequencia em lotes
		oIntegra:prepare()

		oIntegra:send()

	EndIf
	
	oEventLog:Finish()

return


/*-----------------+---------------------------------------------------------+
!Nome              ! TeknisaPutCliente                                       !
+------------------+---------------------------------------------------------+
!Descrição         ! Classe PutCliente                                       !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
class TeknisaPutCliente from TeknisaMethodAbstract
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
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaPutCliente

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
method fetch() class TeknisaPutCliente
Local cQuery	:= ''
Local cPreRot	:= If(Len(PrefixoCpo(::cAlRot)) == 2,"S" + PrefixoCpo(::cAlRot), PrefixoCpo(::cAlRot))
Local cPreAli	:= If(Len(PrefixoCpo(::cAlias)) == 2,"S" + PrefixoCpo(::cAlias), PrefixoCpo(::cAlias))
Local cErrorLog := ""

	cErrorLog:=": Selecionando clientes..." 
	::oLog:SetAddInfo(cErrorLog,"Selecionando dados...")
	ConOut(cErrorLog)

	cQuery += "	SELECT " + CRLF
	cQuery += "		" + cPreRot + ".R_E_C_N_O_ ROT_REG, " + CRLF	//Recno da tabela Principal
	cQuery += "		" + cPreAli + ".R_E_C_N_O_ ALI_REG  " + CRLF    //Recno da tabela Auxiliar
	
	cQuery += "	FROM " + RetSqlName(::cAlias) + " " + cPreAli + " " + CRLF
	
	cQuery += "	LEFT JOIN " + RetSqlName(::cAlRot) + " " + cPreRot + " ON "                          + CRLF
	cQuery += "			  " + PrefixoCpo(::cAlRot) + "_FILIAL = '" + xFilial("SA1")       + "'     " + CRLF
	cQuery += "		  AND " + PrefixoCpo(::cAlRot) + "_COD    =  " + PrefixoCpo(::cAlias) + "_COD  " + CRLF
	cQuery += "		  AND " + PrefixoCpo(::cAlRot) + "_LOJA   =  " + PrefixoCpo(::cAlias) + "_LOJA " + CRLF
	cQuery += "		  AND " + cPreRot + ".D_E_L_E_T_ = ' ' " + CRLF
	
	cQuery += "	WHERE  " + CRLF
	
	If xFilial(::cAlias) == '          '
		cQuery += "			" + PrefixoCpo(::cAlias) + "_XFILI = '" + cFilAnt + "' " 			+ CRLF
	Else
		cQuery += "			" + PrefixoCpo(::cAlias) + "_FILIAL = '" + xFilial(::cAlias) + "' " + CRLF
	EndIf
	
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
method analise(oXmlItem,lNewReg) class TeknisaPutCliente
Local lIntegrado := .F.
Local cCdCliente := ""
Local cCdConsum  := ""
Local cErrorLog  := ""
Local cCliente   := ""
Local cLoja      := ""
Local cMsgErro   := ""
Private oItem := oXmlItem

	//verifica se a propriedade integrado existe
	cMsgErro := IIF(type("oItem:_CONFIRMACAO:_MENSAGEM:TEXT")=="C",oItem:_CONFIRMACAO:_MENSAGEM:TEXT,"")
	If type("oItem:_CONFIRMACAO:_INTEGRADO:TEXT") == "C"
	
		cCdCliente:=IIF(type("oItem:_ID:_CDCLIENTE:TEXT"   ) == "C",oItem:_ID:_CDCLIENTE:TEXT   ,"")
		cCdConsum :=IIF(type("oItem:_ID:_CDCONSUMIDOR:TEXT") == "C",oItem:_ID:_CDCONSUMIDOR:TEXT,"")
		cCliente  :=IIF(type("oItem:_ID:_CODIGO:TEXT")       == "C",oItem:_ID:_CODIGO:TEXT      ,"")
		cLoja     :=IIF(type("oItem:_ID:_LOJA:TEXT")         == "C",oItem:_ID:_LOJA:TEXT        ,"") 

		// agora testa se o conteudo é true
		lIntegrado := lower(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "true"		
		If lIntegrado

			lIntegrado := lIntegrado .And. !Empty(cCdCliente)
			lIntegrado := lIntegrado .And. !Empty(cCdConsum)
			lIntegrado := lIntegrado .and. !Empty(cCliente)
			lIntegrado := lIntegrado .and. !Empty(cLoja)

			// -> Se o código do cliente no Teknisa não retornou, registra erro no log
			If Empty(cCdCliente)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo do cliente. [_CDCLIENTE = " + IIF(Empty(cCdCliente),"Vazio",cCdCliente)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Retorno do XML.")
				ConOut(cErrorLog)
			EndIf	

			// -> Se o código do consumidor no Teknisa não retornou, registra erro no log
			If Empty(cCdConsum)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo do consumidor. [_CDCONSUMIDOR = " + IIF(Empty(cCdConsum),"Vazio",cCdConsum)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Retorno do XML.")
				ConOut(cErrorLog)
			EndIf	

			// -> Se o código do cliente do Protheus não retornou, registra erro no log
			If Empty(cCliente)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo do cliente do Protheus. [_CODIGO = " + IIF(Empty(cCliente),"Vazio",cCliente)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Retorno do XML.")
				ConOut(cErrorLog)
			EndIf	

			// -> Se o código da loja do cliente não retornou, registra erro no log
			If Empty(cLoja)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo da loja do cliente do Protheus. [_LOJA = " + IIF(Empty(cLoja),"Vazio",cLoja)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Retorno do XML.")
				ConOut(cErrorLog)
			EndIf	

		Else
						
			cErrorLog:=cMsgErro
			::oLog:SetAddInfo(cErrorLog,"Retorno do XML.")
			ConOut(cErrorLog)

		EndIf

		// -> Se ocorreu erro na integração
		If !lIntegrado
			
			cCliente :=PadR(IIF(type("oItem:_ID:_CODIGO:TEXT") == "C",oItem:_ID:_CODIGO:TEXT,""),TamSx3("A1_COD")[1]) 
			cLoja    :=PadR(IIF(type("oItem:_ID:_LOJA:TEXT")   == "C",oItem:_ID:_LOJA:TEXT,""),TamSx3("A1_LOJA")[1]) 
			cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")
			
			// -> Posiciona na tabela de integração de clientes e atualiza o registro com o status de erro
			dbSelectArea("Z11")
			Z11->( dbSetOrder(1) )
			Z11->( dbSeek( xFilial("Z11") + cCliente + cLoja ) )
			If Z11->(Found()) .and. !Empty(cCliente)
				RecLock("Z11", .F.)
				Z11->Z11_XSTINT := "E"
				Z11->Z11_XDINT  := Date()
				Z11->Z11_XHINT  := Time()
				Z11->Z11_XLOG   := cErrorLog
				Z11->( msUnLock() )
			EndIf
		
		EndIf

	Else

		cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")
		::oLog:SetAddInfo(cErrorLog,"Retorno do XML.")
		ConOut(cErrorLog)

	EndIf

	// -> Se não ocorreu erro, continua...
	If lIntegrado

		cCdCliente:=IIF(type("oItem:_ID:_CDCLIENTE:TEXT"   ) == "C",oItem:_ID:_CDCLIENTE:TEXT   ,"")
		cCdConsum :=IIF(type("oItem:_ID:_CDCONSUMIDOR:TEXT") == "C",oItem:_ID:_CDCONSUMIDOR:TEXT,"")
		cCliente  :=PadR(IIF(type("oItem:_ID:_CODIGO:TEXT")  == "C",oItem:_ID:_CODIGO:TEXT,"")  ,TamSx3("A1_COD")[1]) 
		cLoja     :=PadR(IIF(type("oItem:_ID:_LOJA:TEXT")    == "C",oItem:_ID:_LOJA:TEXT,"")    ,TamSx3("A1_LOJA")[1]) 
			
		cErrorLog:=": "+AllTrim(cCliente)+": "+AllTrim(cLoja)+": Atualizando status no ERP..." 
		::oLog:SetAddInfo(cErrorLog,"Retorno do XML.")
		ConOut(cErrorLog)

		// -> Posiciona na tabela de integração de clientes
		dbSelectArea("Z11")
		Z11->( dbSetOrder(1) )
		Z11->( dbSeek( xFilial("Z11") + cCliente + cLoja ) )
		lIntegrado := Z11->(Found()) .and. !Empty(cCliente)
		If lIntegrado

			RecLock("Z11", .F.)
			If UPPER(Self:cMetEnv) == "POST"
				Z11->Z11_XCLIEN	:= cCdCliente
				Z11->Z11_XCONSU := cCdConsum
			EndIf	
			Z11->Z11_XSTINT := "I" //Integrado
			Z11->Z11_XDINT  := Date()
			Z11->Z11_XHINT  := Time()
			Z11->Z11_XLOG   := "Cliente "+IIF(UPPER(Self:cMetEnv) == "POST","incluido ",IIF(UPPER(Self:cMetEnv) == "PUT","alterado ","excluido ")) + " com sucesso em " + DtoC(Date()) + " as " + Time()
			Z11->( msUnLock() )
			
			cErrorLog:="Ok: Cliente "+IIF(UPPER(Self:cMetEnv) == "POST","incluido ",IIF(UPPER(Self:cMetEnv) == "PUT","alterado ","excluido ")) + "." 
			::oLog:SetAddInfo(cErrorLog,"Gravacao dodados.")
			ConOut(cErrorLog)

			::oEventLog:setCountInc()

		Else
		
			cErrorLog:="Erro: Nao encontrado registro na tabela de integracao de clientes. Z11_COD="+cCliente+" e Z11_LOJA="+cLoja+"]" 
			::oLog:SetAddInfo(cErrorLog,"Retorno do XML.")
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
method makeXml(aLote,cMetEnv) class TeknisaPutCliente
Local cXml
Local nC
Local cErrorLog := ""
	
	cErrorLog:=": Gerando XML..." 
	::oLog:SetAddInfo(cErrorLog,"Gerando XML...")
	ConOut(cErrorLog)

	dbSelectArea("Z11")
	Z11->( dbSetOrder(1) )

	// -> Pesquisa no cadastro de empresas
	ADK->(DbOrderNickName("ADKXFILI"))
	ADK->(DbSeek(xFilial("ADK")+cFilAnt))
	If !ADK->(Found())
		cErrorLog:="Erro: Filial " + cFilAnt + " nao encontrado(s) no cadastro de unidades de negocio. [ADK_XFILI="+cFilAnt+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
		ConOut(cErrorLog)
		Return("")
	ElseIf Empty(ADK->ADK_XFIL) .or. ADK->ADK_XFIL == "0000"
		cErrorLog:="Erro: Filial " +  cFilAnt + " nao integrada corretamente no Teknisa. [ADK_XFILI="+IIF(Empty(ADK->ADK_XEMP),"Vazio",ADK->ADK_XEMP)+" e ADK_XFIL="+IIF(Empty(ADK->ADK_XFIL),"Vazio",ADK->ADK_XFIL)+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
		ConOut(cErrorLog)
		Return("")
	EndIf		

	// -> Verifica se o ponto de entrada utilizado para geração dos dados de integração está sesativado no configurador
	DbSelectArea("XX7")	
	XX7->(DbSelectArea(1))
	XX7->(DbSeek("CRMA980"))
	If XX7->(Found()) .and. XX7->XX7_STATUS <> "1"
		cErrorLog:="Erro: Ponto de entrada CRMA980 foi desabilitado no configurador. Favor verificar." 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")	
		ConOut(cErrorLog)
		Return("")
	EndIf


	cXml := '<clientes>'                                    

	For nC := 1 to len(aLote)

		If Lower(cMetEnv) != "delete"

			// -> posiciona no cliente
			IF valtype(aLote[nC]) == "C"
				SA1->( dbSetOrder(1) )
				SA1->( dbSeek( xFilial("SA1") + aLote[nC,01] ) )
			Else
				SA1->( dbGoTo(aLote[nC,01]) )
			EndIF
			
			Z11->( dbGoTo(aLote[nC,02]) )
	
			cXml += '<cliente>'
	
			cXml += '<id'
			cXml += ::tag('loja'			,SA1->A1_LOJA)
			cXml += ::tag('codigo'			,SA1->A1_COD)
			cXml += ::tag('cdconsumidor'	,Z11->Z11_XCONSU)
			cXml += ::tag('cdcliente'		,Z11->Z11_XCLIEN)						
			cXml += '/>'
			
			cXml += '<fiscal'
			cXml += ::tag('nrinsestcli'		,SA1->A1_INSCR)
			cXml += ::tag('nrinsjurcli'		,SA1->A1_CGC)
			cXml += ::tag('sgestado'		,SA1->A1_EST)
			cXml += ::tag('cdpais'			,SA1->A1_CODPAIS)
			cXml += '/>'
	
			cXml += '<cadastral'
			cXml += ::tag('nmrazsocclie'	,SA1->A1_NOME)
			cXml += ::tag('nmfantcli'		,SA1->A1_NREDUZ)
			cXml += ::tag('enderprinc'		,"S")
			cXml += ::tag('codmunicipio'	,SA1->A1_COD_MUN)
			cXml += ::tag('dsmunicipio'		,SA1->A1_MUN)
			cXml += ::tag('dsendcons'		,SA1->A1_END)
			cXml += ::tag('nrendecons'		,FisGetEnd(SA1->A1_END, SA1->A1_EST)[03])
			cXml += ::tag('dscomplendecons'	,SA1->A1_COMPLEM)
			cXml += ::tag('nrcepcons'		,SA1->A1_CEP)
			cXml += ::tag('nmbaircons'		,SA1->A1_BAIRRO)
			cXml += ::tag('ddi'				,SA1->A1_DDI)
			cXml += ::tag('ddd'				,SA1->A1_DDD)
			cXml += ::tag('nrtelecons'		,SA1->A1_TEL)
			cXml += ::tag('nrtele2cons'		,SA1->A1_XFONE2)
			cXml += ::tag('nrcelularcons'	,SA1->A1_XCELULA)
			cXml += ::tag('nmrespcons'		,SA1->A1_CONTATO)
			cXml += ::tag('dsemailcons'		,SA1->A1_EMAIL)
			cXml += ::tag('dtnasccons'		,DtoS(SA1->A1_DTNASC))
			cXml += ::tag('rgcliente'		,SA1->A1_PFISICA)
			cXml += ::tag('dtcadaclie'		,DtoS(SA1->A1_DTCAD))
			cXml += ::tag('hrcadclie'		,SA1->A1_HRCAD)	
			cXml += ::tag('ativo'			,If(SA1->A1_MSBLQL == "1","N","S"))
			
			cXml += '/>'
			 	
			cXml += '</cliente>'	
			
		Else
		
			Z11->( dbGoTo(aLote[nC,02]) )
	
			cXml += '<cliente>'
	
			cXml += '<id'
			cXml += ::tag('loja'			,Z11->Z11_LOJA)
			cXml += ::tag('codigo'			,Z11->Z11_COD)
			cXml += ::tag('cdconsumidor'	,Z11->Z11_XCONSU)
			cXml += ::tag('cdcliente'		,Z11->Z11_XCLIEN)						
			cXml += '/>'
			
			cXml += '<fiscal'
			cXml += ::tag('nrinsestcli'		,"")
			cXml += ::tag('nrinsjurcli'		,"")
			cXml += ::tag('sgestado'		,"")
			cXml += ::tag('cdpais'			,"")
			cXml += '/>'
	
			cXml += '<cadastral'
			cXml += ::tag('nmrazsocclie'	,"")
			cXml += ::tag('nmfantcli'		,"")
			cXml += ::tag('enderprinc'		,"")
			cXml += ::tag('codmunicipio'	,"")
			cXml += ::tag('dsmunicipio'		,"")
			cXml += ::tag('dsendcons'		,"")
			cXml += ::tag('nrendecons'		,"")
			cXml += ::tag('dscomplendecons'	,"")
			cXml += ::tag('nrcepcons'		,"")
			cXml += ::tag('nmbaircons'		,"")
			cXml += ::tag('ddi'				,"")
			cXml += ::tag('ddd'				,"")
			cXml += ::tag('nrtelecons'		,"")
			cXml += ::tag('nrtele2cons'		,"")
			cXml += ::tag('nrcelularcons'	,"")
			cXml += ::tag('nmrespcons'		,"")
			cXml += ::tag('dsemailcons'		,"")
			cXml += ::tag('dtnasccons'		,"")
			cXml += ::tag('rgcliente'		,"")
			cXml += ::tag('dtcadaclie'		,"")
			cXml += ::tag('hrcadclie'		,"")
			cXml += ::tag('ativo'			,"")
			
			cXml += '/>'
			 	
			cXml += '</cliente>'		
		
		EndIf
	
 	Next nC

	cXml += '</clientes>'
	
	If AllTrim(cXml) == "<clientes></clientes>"
		cXml:=""
	EndIf
	
	MemoWrite("C:\TEMP\XML_" + cMetEnv + ".XML",cXml)

return cXml