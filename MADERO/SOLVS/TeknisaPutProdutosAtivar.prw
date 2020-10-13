#include 'protheus.ch'
/*-----------------+---------------------------------------------------------+
!Nome              ! TkPutPAt                                                !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o         ! FunÃ§Ã£o para chamr o metodo PutProdutosAtivar            !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function TkPutPAt()

 	// -> Executa o processo para ativaÃ§Ã£o de produtos
	TkPAti("Post")
 	
	// -> Executa o processo para desativar produtos
	TkPAti("Delete")

Return


/*-----------------+---------------------------------------------------------+
!Nome              ! TkImp                                                   !
+------------------+---------------------------------------------------------+
!Descricao         ! FunÃ§Ã£o para processar o WS                            !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function TkPAti(cMetEnv)
Local oIntegra
Local cMethod	:= "PutProdutosAtivar"
Local cAlias	:= "Z17"
Local cAlRot	:= "SB1" 
Local oEventLog := EventLog():start("Ativar Produto - "+AllTrim(cMetEnv), Date(), "Iniciando processo de integracao...", cMetEnv, cAlRot) 

	//instancia a classe
	oIntegra := TeknisaPutProdutosAtivar():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	If oIntegra:isEnable()

		//busca os registros e se sequencia em lotes
		oIntegra:prepare()

		oIntegra:send()

	EndIf
	
	oEventLog:Finish()

return



/*-----------------+---------------------------------------------------------+
!Nome              ! PutProdutosAtivar                                       !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o         ! Classe PutProdutosAtivar                                !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
class TeknisaPutProdutosAtivar from TeknisaMethodAbstract
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
!DescriÃ§Ã£o         ! Metodo inicializador da classe                          !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaPutProdutosAtivar

	//inicialisa a classe
	::init(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)
	::oLog :=oEventLog
	::cMetE:=cMetEnv

return


/*-----------------+---------------------------------------------------------+
!Nome              ! fetch                                                   !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o         ! Metodo para a seleÃ§Ã£o dos dados a enviar                !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method fetch() class TeknisaPutProdutosAtivar
Local cQuery	:= ''

	cQuery += "	SELECT Z17.R_E_C_N_O_ ROT_REG, " 
	cQuery += "		   0              ALI_REG  " 
	cQuery += "	FROM " + RetSqlName("Z17") + " Z17                  "
	cQuery += "	WHERE  Z17_FILIAL = '" + xFilial(::cAlias) + "' AND "
	cQuery += "		   Z17_XSTINT = 'P'                         AND "
	
	If Upper(::cMetEnv) == "POST"
		cQuery += "	   Z17_XATIVO = 'S' AND " 
		
	ElseIf Upper(::cMetEnv) == "DELETE"
		cQuery += "	   Z17_XATIVO = 'N' AND "
	EndIf
	cQuery += "		  Z17.D_E_L_E_T_ = ' '                          "
	cQuery := ChangeQuery(cQuery)

return MPSysOpenQuery(cQuery)


/*-----------------+---------------------------------------------------------+
!Nome              ! analise                                                 !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o         ! Metodo para analizar e gravar os dados de retorno do WS !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method analise(oXmlItem,lNewReg) class TeknisaPutProdutosAtivar
Local lIntegrado := .F.
Local cErrorLog  := ""
Local cCodEmp    := ""
Local cCodFil    := ""
Local cCodProd   := ""
Local cCodTek    := ""
Local cMsgErro   := ""
Local cTpIpImp   := SUPERGETMV("MV_XTIPIMP",.F.,"PA/PI/ME" )
Local cGrpClie   := PadR(GetMv("MV_XGRCLIU",,""),TamSx3("F7_GRPCLI")[1])
Local cUFFil     := PadR(GetMV("MV_ESTADO",,""),TamSx3("F7_EST")[1])
Local lAtivar    := .F.
Local lAtivo     := .F.
Private oItem 	 := oXmlItem

	// -> verifica se a propriedade integrado existe
	cMsgErro:=IIF(type("oItem:_CONFIRMACAO:_MENSAGEM:TEXT")=="C",oItem:_CONFIRMACAO:_MENSAGEM:TEXT,"")
	If type("oItem:_CONFIRMACAO:_INTEGRADO:TEXT") == "C"
		
		cCodEmp :=IIF(Type("oItem:_FILIAL:_CDEMPRESA:TEXT") == "C",oItem:_FILIAL:_CDEMPRESA:TEXT,"")
		cCodFil :=IIF(Type("oItem:_FILIAL:_CDFILIAL:TEXT")  == "C",oItem:_FILIAL:_CDFILIAL:TEXT ,"")
		cCodProd:=IIF(Type("oItem:_ID:_CODIGOPRODUTO:TEXT") == "C",oItem:_ID:_CODIGOPRODUTO:TEXT,"")
		cCodTek :=IIF(Type("oItem:_ID:_CDPRODUTO:TEXT")     == "C",oItem:_ID:_CDPRODUTO:TEXT    ,"")

		// -> Verifica retorno no método
		lIntegrado := lower(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "true"
		If lIntegrado

			lIntegrado := lIntegrado .And. !Empty(cCodEmp)
			lIntegrado := lIntegrado .And. !Empty(cCodFil)
			lIntegrado := lIntegrado .And. !Empty(cCodProd)
			lIntegrado := lIntegrado .And. !Empty(cCodTek)

			// -> Se o cÃ³digo da empresa do Teknisa nÃ£o retornou, registra erro no log
			If Empty(cCodEmp)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo da empresa do Teknisa. [_CDEMPRESA = " + IIF(Empty(cCodEmp),"Vazio",cCodEmp)+"]" 
				::oLog:broken("Retorno do XML.", cErrorLog, .T.)	
				ConOut(cErrorLog)
			EndIf	

			// -> Se o cÃ³digo da filial do Teknisa nÃ£o retornou, registra erro no log
			If Empty(cCodFil)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo da filial do Teknisa. [_CDFILIAL = " + IIF(Empty(cCodFil),"Vazio",cCodFil)+"]" 
				::oLog:broken("Retorno do XML.", cErrorLog, .T.)	
				ConOut(cErrorLog)
			EndIf	

			// -> Se o cÃ³digo do produto do Teknisa nÃ£o retornou, registra erro no log
			If Empty(cCodTek)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo produto do Teknisa. [_CDPRODUTO = " + IIF(Empty(cCodTek),"Vazio",cCodTek)+"]" 
				::oLog:broken("Retorno do XML.", cErrorLog, .T.)	
				ConOut(cErrorLog)
			EndIf	
			
			// -> Se o cÃ³digo do produto do Protheus nÃ£o retornou, registra erro no log
			If Empty(cCodProd)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo do produto do Protheus. [_CODIGOPRODUTO = " + IIF(Empty(cCodProd),"Vazio",cCodProd)+"]" 
				::oLog:broken("Retorno do XML.", cErrorLog, .T.)	
				ConOut(cErrorLog)
			EndIf	

		Else

			cErrorLog:=cMsgErro
			::oLog:broken("Retorno do XML do metodo.", cErrorLog, .F.)	
			ConOut(cErrorLog)
		
		EndIf

		// -> Se ocorreu erro na integração 
		If !lIntegrado 
			
			cCodProd :=PadR(IIF(Type("oItem:_ID:_CODIGOPRODUTO:TEXT") == "C",oItem:_ID:_CODIGOPRODUTO:TEXT,""),TamSx3("B1_COD")[1])
			cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")

			// -> Posiciona no cadastro de produto
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+cCodProd))

			// -> Posiciona no registro de ativação de produtos do processo de integração
			dbSelectArea("Z17")
			Z17->(dbSetOrder(1))
			Z17->(dbSeek(xFilial("Z17") +cCodProd))
			If Z17->(Found())
				RecLock("Z17", .F.)
				Z17->Z17_XSTINT:="E"
				Z17->Z17_XUSER := IIF(Empty(SB1->B1_XUSER),cUserName,SB1->B1_XUSER)
				Z17->Z17_XDINT := Date()
				Z17->Z17_XHINT := Time()
				Z17->Z17_XLOG  :=cErrorLog
				Z17->(msUnLock())	
			EndIf

		EndIf

	Else

		cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")
		::oLog:broken("Retorno do XML do metodo.", cErrorLog, .F.)	
		ConOut(cErrorLog)

	EndIf

	// -> Se ok, continua...
	If lIntegrado
		
		cCodProd:=PadR(IIF(Type("oItem:_ID:_CODIGOPRODUTO:TEXT") == "C",oItem:_ID:_CODIGOPRODUTO:TEXT,""),TamSx3("B1_COD")[1])
		cCodTek :=IIF(Type("oItem:_ID:_CDPRODUTO:TEXT")     == "C",oItem:_ID:_CDPRODUTO:TEXT    ,"")

		cErrorLog:=": "+AllTrim(cCodProd)+": Atualizando status no ERP..." 
		::oLog:SetAddInfo(cErrorLog,"Retorno dos dados.")
		ConOut(cErrorLog)
		
		// -> Posiciona no registro de ativação de produtos do processo de integração
		dbSelectArea("Z17")
		Z17->(dbSetOrder(1))
		Z17->(dbSeek(xFilial("Z17") +cCodProd))
		lIntegrado := Z17->(Found())
		lAtivo     := Z17->Z17_XATIVO == "S"
		If lIntegrado

			// -> Posiciona no cadastro de produto
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+Z17->Z17_COD))
			If SB1->(Found()) .and. lAtivo
	
				Begin transaction 
			
					RecLock("Z17", .F.)
					Z17->Z17_XCODEX		:= cCodTek
					Z17->Z17_XSTINT		:= "I" 
					Z17->Z17_XDINT		:= Date()
					Z17->Z17_XHINT		:= Time()
					Z17->Z17_XDTMOV 	:= Date()
					Z17->Z17_XHRMOV 	:= Time()
					Z17->Z17_XUSER  	:= IIF(Empty(SB1->B1_XUSER),cUserName,SB1->B1_XUSER)
					Z17->Z17_XLOG       := "Produto "+IIF(UPPER(Self:cMetEnv) == "POST","ativado ","desativado ") + " com sucesso em " + DtoC(Date()) + " as " + Time()
					Z17->(msUnLock())
					::oEventLog:setCountInc()
				
					cErrorLog:=": Gerando atualização de impostos..." 
					::oLog:SetAddInfo(cErrorLog,"Gravacao dos dados.")
					ConOut(cErrorLog)

					// -> Posiciona na tabela de integraçao dos impostos everifica se existem processos a serem excluidos
					DbSelectArea("Z16")
					Z16->(DbSetOrder(2))
					Z16->(DbSeek(xFilial("Z16")+Z17->Z17_COD))
					While !Z16->(Eof()) .and. Z16->Z16_FILIAL == xFilial("Z16") .and. Z16->Z16_COD == Z17->Z17_COD
						RecLock("Z16",.F.)
						Z16->Z16_XSTINT	:= "P"
						Z16->Z16_XEXC	:= "S"
						Z16->Z16_XATIVO	:= IIF(lAtivo,"S","N")
						Z16->Z16_XDTMOV := Date()
						Z16->Z16_XHRMOV := Time()
						Z16->Z16_XUSER  := IIF(Empty(SB1->B1_XUSER),cUserName,SB1->B1_XUSER)
						Z16->Z16_XLOG   := "Informacoes tributarias excluidas para o produto na filial " + cFilAnt + " e aguardando a integracao com o Teknisa."
						Z16->(MsUnlock())
						Z16->(DbSkip())
					EndDo
		
					// -> Gera dados para integração de impostos para produtos ativos
					lAtivar:=Z17->(found()) .and. Z17->Z17_XSTINT == "I" .and. Z17->Z17_XATIVO == "S"
					If SB1->B1_TIPO $ cTpIpImp
						// -> Verifica se existe o grupo de tributação para a UF e grupo do produto
						DbSelectArea("SF7")
						SF7->(dbOrderNickName("SF7GRPEST"))
						SF7->(DbSeek(xFilial("SF7")+SB1->B1_GRTRIB+cGrpClie+cUFFil))
						If SF7->(Found())
							// -> Posiciona na tabela de integraçao dos impostos
							dbSelectArea("Z16")
							Z16->(dbSetOrder(1))
							Z16->(dbSeek(xFilial("Z16")+SB1->B1_GRTRIB+SB1->B1_COD))
							If Z16->(found()) .and. !Empty(SB1->B1_GRTRIB)
								RecLock("Z16",.F.)
								Z16->Z16_GRPTRI	:= SB1->B1_GRTRIB
								Z16->Z16_COD 	:= SB1->B1_COD
								Z16->Z16_DESC   := SB1->B1_DESC
								Z16->Z16_XSTINT	:= "P"
								Z16->Z16_XEXC	:= IIF(!lAtivo,"S","N")
								Z16->Z16_XATIVO	:= IIF(lAtivo,"S","N")
								Z16->Z16_XDTMOV := Date()
								Z16->Z16_XHRMOV := Time()
								Z16->Z16_XUSER  := IIF(Empty(cUserName),SB1->B1_XUSER,cUserName)
								Z16->Z16_XLOG   := "Informacoes tributarias " + IIF(!lAtivo,"excluidas","alteradas") + " para o produto na filial " + cFilAnt + " e aguardando a integracao com o Teknisa."
								Z16->(msUnLock())	
							ElseIf !Z16->(found()) .and. !Empty(SB1->B1_GRTRIB) .and. lAtivar
								RecLock("Z16",.T.)
								Z16->Z16_FILIAL	:= xFilial("Z16")
								Z16->Z16_XEMP	:= cCodEmp
								Z16->Z16_XFIL	:= cCodFil
								Z16->Z16_GRPTRI	:= SB1->B1_GRTRIB
								Z16->Z16_COD 	:= SB1->B1_COD
								Z16->Z16_DESC   := SB1->B1_DESC
								Z16->Z16_XSTINT	:= "P"
								Z16->Z16_XEXC	:= "N"
								Z16->Z16_XATIVO	:= "S"
								Z16->Z16_XDINT  := CtoD("  /  /  ")
								Z16->Z16_XHINT  := " "
								Z16->Z16_XDTMOV := Date()
								Z16->Z16_XHRMOV := Time()
								Z16->Z16_XUSER  := IIF(Empty(cUserName),SB1->B1_XUSER,cUserName)
								Z16->Z16_XLOG   := "Informacoes tributarias incluidas para o produto na filial " + cFilAnt + " e aguardando a integracao com o Teknisa."
								Z16->(msUnLock())	
							EndIf						
						Endif
					EndIf

				End Transaction	
	
			ElseIf !lAtivo

				Begin Transaction
					// -> Desativa o produto da filial
					RecLock("Z17", .F.)
					Z17->Z17_XCODEX		:= cCodTek
					Z17->Z17_XSTINT		:= "I" 
					Z17->Z17_XDINT		:= Date()
					Z17->Z17_XHINT		:= Time()
					Z17->Z17_XDTMOV     := Date()
					Z17->Z17_XHRMOV     := Time()
					Z17->Z17_XUSER      := IIF(Empty(cUserName),Z17->Z17_XUSER,cUserName)
					Z17->Z17_XLOG       := "Produto "+IIF(UPPER(Self:cMetEnv) == "POST","ativado ","desativado ") + " com sucesso em " + DtoC(Date()) + " as " + Time()
					Z17->(msUnLock())

					// -> Exclui os impostos
					DbSelectArea("Z16")
					Z16->(DbSetOrder(2))
					Z16->(DbSeek(xFilial("Z16")+Z17->Z17_COD))
					While !Z16->(Eof()) .and. Z16->Z16_FILIAL == xFilial("Z16") .and. Z16->Z16_COD == Z17->Z17_COD
						RecLock("Z16",.F.)
						Z16->Z16_XSTINT	:= "P"
						Z16->Z16_XEXC	:= "S"
						Z16->Z16_XATIVO	:= IIF(lAtivo,"S","N")
						Z16->Z16_XDTMOV := Date()
						Z16->Z16_XHRMOV := Time()
						Z16->Z16_XUSER  := IIF(Empty(cUserName),Z17->Z17_XUSER,cUserName)
						Z16->Z16_XLOG   := "Informacoes tributarias excluidas para o produto na filial " + cFilAnt + " e aguardando a integracao com o Teknisa."
						Z16->(MsUnlock())
						Z16->(DbSkip())
					EndDo

					::oEventLog:setCountInc()

				End Transaction	
			
			Else
	
				cErrorLog:="Erro: Produto nao encontrado na tabela de cadastro de produtos. [B1_COD="+cCodProd+"]"
				::oLog:SetAddInfo(cErrorLog,"Gravacao dos dados.")
				ConOut(cErrorLog)		
	
			Endif

			cErrorLog:="Ok: Produto "+IIF(UPPER(Self:cMetEnv) == "POST","ativado","desativado")
			::oLog:SetAddInfo(cErrorLog,"Gravacao dos dados.")
			ConOut(cErrorLog)
			
		Else
		
			cErrorLog:="Erro: Produto nao encontrado na tabela de ativacao do processo de integracao. [Z17_COD="+cCodProd+"]"
			::oLog:SetAddInfo(cErrorLog,"Gravacao dos dados.")
			ConOut(cErrorLog)		
		
		EndIf

	EndIf

return


/*-----------------+---------------------------------------------------------+
!Nome              ! makeXml                                                 !
+------------------+---------------------------------------------------------+
!DescriÃ§Ã£o         ! Metodo para gerar o XML de envio                        !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method makeXml(aLote,cMetEnv) class TeknisaPutProdutosAtivar
Local cXml
Local nC
Local cCodEx	:= ""
Local cCodEmp   := ""
Local cCodFil   := ""
Local cDescEmp  := ""
Local cErrorLog := ""

	cErrorLog:=": Gerando XML..." 
	::oLog:SetAddInfo(cErrorLog,"Gerando XML...")
	ConOut(cErrorLog)

	// -> Verifica se a empresa do Teknisa
	ADK->(DbOrderNickName("ADKXFILI"))
	ADK->(DbSeek(xFilial("ADK")+cFilAnt))
	If !ADK->(Found())
		cErrorLog:="Erro: Empresa e/ou filial do Teknisa nao encontrado(s) no cadastro de unidades de negocio. [ADK_XEMP="+IIF(Empty(Z17->Z17_XEMP),"Vazio",Z17->Z17_XEMP)+" e ADK_XFIL="+IIF(Empty(Z17->Z17_XFIL),"Vazio",Z17->Z17_XFIL)+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
		ConOut(cErrorLog)
		Return("")
	ElseIf Empty(ADK->ADK_XEMP) .or. Empty(ADK->ADK_XFIL)
		cErrorLog:="Erro: Empresa e/ou filial do Teknisa nao foram preenchidos no cadastro de unidades de negocio. [ADK_XEMP="+IIF(Empty(ADK->ADK_XEMP),"Vazio",ADK->ADK_XEMP)+" e ADK_XFIL="+IIF(Empty(ADK->ADK_XFIL),"Vazio",ADK->ADK_XFIL)+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
		ConOut(cErrorLog)
		Return("")
	EndIf
	
	cDescEmp:=ADK->ADK_NOME
	cXml 	:= '<produtos>'    	

	For nC := 1 to len(aLote)
		
		cCodEx  := ""	
		// -> Posiciona no registro da tabela de ativção de produtos
		dbSelectArea("Z17")
		Z17->(dbSetOrder(1))
		Z17->(dbGoTo(aLote[nC,01]))
		cCodEx:=AllTrim(Z17->Z17_XCODEX)

		// -> Verifica se o produto exeiste na tabela de processos de integração (Z13)
		DbSelectArea("Z13")
		Z13->(dbSetOrder(1))
		Z13->(DbSeek(xFilial("Z13")+Z17->Z17_COD))
		If !Z13->(Found())
			cErrorLog:="Erro: Nao encontrado processo de integracao do produto na tabela Z13. [Z13_FILIAL="+AllTrim(xFilial("Z13"))+" e Z13_COD="+Z17->Z17_COD+"]" 
			::oLog:broken("Geracao do XML", cErrorLog, .F.)	
			ConOut(cErrorLog)
			Loop
		Else
			// -> Verifica se o produto foi integrado
			If !Z13->Z13_XSTINT == "I" .and. !Z13->Z13_XEXC == "S"
				cErrorLog:="Aviso: Aguardando processo de integrcao do produto. [Z13_FILIAL="+AllTrim(xFilial("Z13"))+", Z13_COD="+Z17->Z17_COD+" e Z13_XSTINT="+Z13->Z13_XSTINT+"]" 
				::oLog:SetAddInfo(cErrorLog,"Aviso na geracao do XML")	
				ConOut(cErrorLog)
				Loop
			EndIf
			// -> Verifica se o produto foi excluido
			If Z13->Z13_XEXC == "S"
				cErrorLog:="Aviso: Aguardando processo de integrcao da exclusao do produto. [Z13_FILIAL="+AllTrim(xFilial("Z13"))+", Z13_COD="+Z17->Z17_COD+" e Z13_XSTINT="+Z13->Z13_XSTINT+"]" 
				::oLog:SetAddInfo(cErrorLog,"Aviso na geracao do XML")	
				ConOut(cErrorLog)
				Loop
			EndIf
		EndIf
		
		cCodEx:=IIF(Empty(cCodEx),Z13->Z13_XCODEX,cCodEx)
		cCodEmp:=ADK->ADK_XEMP
		cCodFil:=ADK->ADK_XFIL		

		// -> Verifica se o codigo do produto no teknisa está ok
		If Empty(cCodEx)
			cErrorLog:="Erro: o campo do codigo do produto do Teknisa nao esta preenchido no cadastro de integracao de produtos. [Z13_XCODEX="+cCodEx+"]" 
			::oLog:broken("Geracao do XML.", cErrorLog, .F.)	
			ConOut(cErrorLog)
			Loop
		EndIf
		
		cXml += '<produto>'
		
		cXml += '<id'
		cXml += ::tag('cdproduto'		,cCodEx)
		cXml += ::tag('codigoproduto'	,Z17->Z17_COD)
		cXml += '/>'
		
		cXml += '<empresas>'
		
		cXml += '<filial'
		cXml += ::tag('cdempresa'	,cCodEmp)
		cXml += ::tag('cdfilial'	,cCodFil)
		cXml += ::tag('filial'		,Z17->Z17_FILIAL)
		cXml += ::tag('nmfilial'	,cDescEmp)	
		cXml += '/>'

		cXml += '</empresas>'

		cXml += '</produto>'
		
 	Next nC

	cXml += '</produtos>'
	
	If AllTrim(cXml) == "<produtos></produtos>"
		cXml:=""
	EndIf
		
	MemoWrite("C:\TEMP\XML_" + cMetEnv + ".XML",cXml)

return cXml