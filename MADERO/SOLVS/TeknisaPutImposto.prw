#include 'protheus.ch'
#include 'parmtype.ch'
/*-----------------+---------------------------------------------------------+
!Nome              ! TkPutImp                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para chamr o metodo PutImposto via Menu          !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function TkPutImp()

 	// -> Executa o processo para inclusão de impostos
 	TkImp("Post")
 	
	// -> Executa o processo para exclusão de impostos
 	TkImp("Delete") 		
	
Return


/*-----------------+---------------------------------------------------------+
!Nome              ! TkImp                                                   !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para processar o WS                              !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static Function TkImp(cMetEnv)
Local oIntegra
Local cMethod	:= "PutImposto"
Local cAlias	:= "Z16"
Local cAlRot	:= "SF7"   
Local oEventLog := EventLog():start("Impostos - "+AllTrim(cMetEnv), Date(), "Iniciando processo de integracao...", cMetEnv, cAlRot) 

	//instancia a classe
	oIntegra := TeknisaPutImposto():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	If oIntegra:isEnable()

		//busca os registros e se sequencia em lotes
		oIntegra:prepare()

		oIntegra:send()

	EndIf
	
	oEventLog:Finish()

return


/*-----------------+---------------------------------------------------------+
!Nome              ! TeknisaPutImposto                                       !
+------------------+---------------------------------------------------------+
!Descrição         ! Classe PutImposto                                       !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
class TeknisaPutImposto from TeknisaMethodAbstract
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
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaPutImposto

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
method fetch() class TeknisaPutImposto
Local cQuery	:= ''
Local cGrpClie  := GetMv("MV_XGRCLIU",,"")
Local cErrorLog := ""

	cErrorLog:=": Selecionando dados de impostos..." 
	::oLog:SetAddInfo(cErrorLog,"Selecionando dados...")
	ConOut(cErrorLog)
	
	cQuery += "	SELECT DISTINCT                    " + CRLF 
	cQuery += "		Z16.Z16_FILIAL,                " + CRLF
	cQuery += "		Z16.Z16_COD,                   " + CRLF
	cQuery += "		Z16.Z16_GRPTRI                 " + CRLF
	cQuery += "	FROM " + RetSqlName("Z16") + " Z16 " + CRLF
	cQuery += "	WHERE Z16_FILIAL = '" + xFilial("Z16") + "' "  + CRLF 
	cQuery += "	  AND Z16_XSTINT IN ('P','E')               "  + CRLF 
	If Upper(::cMetEnv) == "POST"
		cQuery += "		AND Z16.Z16_XEXC = 'N' "               + CRLF 
	ElseIf Upper(::cMetEnv) == "DELETE"
		cQuery += "		AND Z16.Z16_XEXC = 'S' "               + CRLF 
	EndIf
	cQuery += "		AND Z16.D_E_L_E_T_ = ' ' "                 + CRLF 
	cQuery += "	ORDER BY Z16_FILIAL,Z16_COD,Z16_GRPTRI "       + CRLF	
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
method analise(oXmlItem,lNewReg) class TeknisaPutImposto
Local lIntegrado := .F.
Local cCodEmp 	 := ""
Local cCodFil 	 := ""
Local cCodTrib   := ""
Local cCodProd   := ""
Local cCodTek    := ""
Local cSiglaUF   := ""
Local cMsgErro   := ""
Private oItem 	 := oXmlItem

	// -> verifica se a propriedade integrado existe
	cMsgErro:=IIF(type("oItem:_CONFIRMACAO:_MENSAGEM:TEXT")=="C",oItem:_CONFIRMACAO:_MENSAGEM:TEXT,"")
	If type("oItem:_CONFIRMACAO:_INTEGRADO:TEXT") == "C"

		cCodEmp :=IIF(Type("oItem:_FILIAL:_CDEMPRESA:TEXT")      == "C",oItem:_FILIAL:_CDEMPRESA:TEXT,"")
		cCodFil :=IIF(Type("oItem:_FILIAL:_CDFILIAL:TEXT")       == "C",oItem:_FILIAL:_CDFILIAL:TEXT ,"")
		cCodTrib:=IIF(Type("oItem:_ID:_GRUPOTRIB:TEXT")           == "C",oItem:_ID:_GRUPOTRIB:TEXT,"")
		cCodProd:=IIF(Type("oItem:_PRODUTO:_CODIGOPRODUTO:TEXT") == "C",oItem:_PRODUTO:_CODIGOPRODUTO:TEXT,"")
		cCodTek :=IIF(Type("oItem:_PRODUTO:_CDPRODUTO:TEXT")     == "C",oItem:_PRODUTO:_CDPRODUTO:TEXT,"")
		cSiglaUF:=IIF(Type("oItem:_PRODUTO:_UF:TEXT")            == "C",oItem:_PRODUTO:_UF:TEXT,"")

		// -> Agora testa se o conteudo é true
		lIntegrado := lower(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "true"
		If lIntegrado
			
			lIntegrado := lIntegrado .And. !Empty(cCodEmp)
			lIntegrado := lIntegrado .And. !Empty(cCodFil)
			lIntegrado := lIntegrado .And. !Empty(cCodTrib)
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
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo da filial do Teknisa. [_CDFILIAL = " + IIF(Empty(cCodFil),"Vazio",cCodFil)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
				ConOut(cErrorLog)
			EndIf	

			// -> Se o codigo do grupo de tributacao do produto nao retornou no XML, registra erro no log
			If Empty(cCodTrib)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o grupo tributario produto do Protheus. [_GRUPOPRODUTO = " + IIF(Empty(cCodTrib),"Vazio",cCodTrib)+"]" 
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
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou o codigo do produto do Protheus. [_CDPRODUTO = " + IIF(Empty(cCodProd),"Vazio",cCodProd)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
				ConOut(cErrorLog)
			EndIf	

			// -> Se a UF do produto do Protheus não retornou, registra erro no log
			If Empty(cSiglaUF)
				cErrorLog:="O metodo " + Self:cMetEnv + " nao retornou a UF relacionada ao grupo tributario. [_UF = " + IIF(Empty(cSiglaUF),"Vazio",cSiglaUF)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
				ConOut(cErrorLog)
			EndIf	

		Else

			cErrorLog:=cMsgErro
			::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
			ConOut(cErrorLog)
			
		EndIf

		// -> Se ocorreu erro na integração, atualiza status de erro
		If !lIntegrado

			cCodTrib :=PadR(IIF(Type("oItem:_ID:_GRUPOTRIB:TEXT")          == "C",oItem:_ID:_GRUPOTRIB:TEXT,""),TamSx3("B1_GRTRIB")[1])
			cCodProd :=PadR(IIF(Type("oItem:_PRODUTO:_CODIGOPRODUTO:TEXT") == "C",oItem:_PRODUTO:_CODIGOPRODUTO:TEXT,""),TamSx3("B1_COD")[1])
			cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")
		
			// -> Posiciona no cadastro do porduto
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+cCodProd))

			// -> Posiciona na tabela de integração dos impostos x unidades de negócio
			DbSelectArea("Z16")
			Z16->(DbSetOrder(1) )
			Z16->(DbSeek(xFilial("Z16")+cCodTrib+cCodProd))
			If Z16->(Found())
				RecLock("Z16",.F.)
				Z16->Z16_XSTINT:="E" 
				Z16->Z16_XDINT	:= Date()
				Z16->Z16_XHINT	:= Time()
				//Z16->Z16_XUSER  := IIF(Empty(cUserName),SB1->B1_XUSER,cUserName)
				Z16->Z16_XLOG   :=cErrorLog
				Z16->(msUnLock())
			EndIf

		EndIf

	Else
	
		cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")
		::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
		ConOut(cErrorLog)
	
	EndIf

	// -> Se tudo ok, continua....
	If lIntegrado

		cCodTrib:=PadR(IIF(Type("oItem:_ID:_GRUPOTRIB:TEXT")          == "C",oItem:_ID:_GRUPOTRIB:TEXT,""),TamSx3("B1_GRTRIB")[1])
		cCodProd:=PadR(IIF(Type("oItem:_PRODUTO:_CODIGOPRODUTO:TEXT") == "C",oItem:_PRODUTO:_CODIGOPRODUTO:TEXT,""),TamSx3("B1_COD")[1])
		cCodTek :=IIF(Type("oItem:_PRODUTO:_CDPRODUTO:TEXT")          == "C",oItem:_PRODUTO:_CDPRODUTO:TEXT,"")
		cSiglaUF:=IIF(Type("oItem:_PRODUTO:_UF:TEXT")                 == "C",oItem:_PRODUTO:_UF:TEXT,"")
		
		cErrorLog:=": "+AllTrim(cCodProd)+":"+AllTrim(cCodTrib)+":"+cSiglaUF+": Atualizando status no ERP..." 
		::oLog:SetAddInfo(cErrorLog,"Retorno dos dados.")
		ConOut(cErrorLog)

		// -> Posiciona no cadastro do porduto
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cCodProd))

		// -> Posiciona na tabela de integração dos impostos x unidades de negócio
		DbSelectArea("Z16")
		Z16->(DbSetOrder(1) )
		Z16->(DbSeek(xFilial("Z16")+cCodTrib+cCodProd))
		lIntegrado:=Z16->(Found())
		If lIntegrado
			RecLock("Z16", .F.)
			Z16->Z16_XSTINT	:= "I"
			Z16->Z16_XDINT	:= Date()
			Z16->Z16_XHINT	:= Time()
			//Z16->Z16_XUSER  := IIF(Empty(cUserName),SB1->B1_XUSER,cUserName)
			Z16->Z16_XLOG   := "Informacao tributaria "+IIF(UPPER(Self:cMetEnv) == "POST","incluida ",IIF(UPPER(Self:cMetEnv) == "PUT","alterada ","excluida ")) + " com sucesso em " + DtoC(Date()) + " as " + Time()
			Z16->( msUnLock() )
 
			cErrorLog:="Ok: Informacao tributaria "+IIF(UPPER(Self:cMetEnv) == "POST","incluida ",IIF(UPPER(Self:cMetEnv) == "PUT","alterada ","excluida "))
			::oLog:SetAddInfo(cErrorLog,"Confirmacao dos dados.")
			ConOut(cErrorLog)

			::oLog:setCountInc()

		Else
			cErrorLog:="Erro: Nao encontrados o grupo e/ou codigo de produtos no processo de integracao. [Z16_GRPTRI="+cCodTrib+" e Z16_COD="+cCodProd+"]"
			::oLog:SetAddInfo(cErrorLog,"Retorno dos dados do XML.")
			ConOut(cErrorLog)	
		EndIf
	
	EndIf

Return


/*-----------------+---------------------------------------------------------+
!Nome              ! makeXml                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para gerar o XML de envio                        !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method makeXml(aLote,cMetEnv) class TeknisaPutImposto
Local cXml      := ""
Local cXmlItem  := ""
Local cXmlcBenef:= ""
Local nC		:= 0
Local nInc		:= 0
Local cCodEmp   := ""
Local cCodFil   := ""
Local cNomFil   := ""
Local cCodFili  := ""
Local cErrorLog := ""
Local lErroXML  := .F.
Local cGrpClie  := PadR(GetMv("MV_XGRCLIU",,""),TamSx3("F7_GRPCLI")[1])
Local cCodUF    := PadR(GetMV("MV_ESTADO",,""),TamSx3("F7_EST")[1])
Local cAuxLote  := ""
	
	cErrorLog:=": Gerando XML..." 
	::oLog:SetAddInfo(cErrorLog,"Gerando XML...")
	ConOut(cErrorLog)
	
	// -> Verifica se o código da empresa e filial do Teknisa 
	ADK->(DbOrderNickName("ADKXFILI"))
	ADK->(DbSeek(xFilial("ADK")+cFilAnt))
	If !ADK->(Found())
		cErrorLog:="Erro: Empresa e/ou filial do Teknisa nao encontrada no cadastro de unidades de negocio. [ADK_XFILI="+cFilAnt+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")	
		ConOut(cErrorLog)
		Return("")
	ElseIf Empty(ADK->ADK_XEMP) .or. Empty(ADK->ADK_XFIL)
		cErrorLog:="Erro: Empresa e/ou filial nao integrada corretamente no Teknisa. [ADK_XEMP="+IIF(Empty(ADK->ADK_XEMP),"Vazio",ADK->ADK_XEMP)+" e ADK_XFIL="+IIF(Empty(ADK->ADK_XFIL),"Vazio",ADK->ADK_XFIL)+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")		
		ConOut(cErrorLog)
		Return("")
	ElseIf AllTrim(ADK->ADK_EST) <> cCodUF
		cErrorLog:="Erro: UF cadastrada na unidade de negócio diferente do parametro MV_ESTADO. [ADK_EST="+ADK->ADK_EST+" e MV_ESTADO="+cCodUF+"]" 
		::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")	
		ConOut(cErrorLog)
		Return("")
	Else
		cCodEmp :=ADK->ADK_XEMP
		cCodFil :=ADK->ADK_XFIL		
		cCodUF  :=ADK->ADK_EST
		cNomFil :=ADK->ADK_NOME
		cCodFili:=ADK->ADK_XFILI
	EndIf	

	cXml      := '<impostos>'   	
	cAuxLote  :=""
	nInc	  :=0	
	cXmlItem  :=""
	cXmlcBenef:= ""
	For nC := 1 to len(aLote)

		// -> Posiciona nos dados da Z16
		Z16->(DbSetOrder(1))
		Z16->(DbSeek(aLote[nC,01]+aLote[nC,03]+aLote[nC,02]))

		// -> Gera o XML para inclusão dos impostos
		If Upper(Self:cMetEnv) == "POST"

			// -> Pesquisa cadastros do produto
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+Z16->Z16_COD))	
			If SB1->(Found()) .and. !Empty(SB1->B1_XCODEXT)

				// -> Verifica se o produto exeiste na tabela de processos de integração (Z13)
				DbSelectArea("Z13")
				Z13->(DbSetOrder(1))
				Z13->(DbSeek(xFilial("Z13")+Z16->Z16_COD))
				If !Z13->(Found())
					cErrorLog:="Erro: Nao encontrado processo de integracao do produto na tabela Z13. [Z13_FILIAL="+AllTrim(xFilial("Z13"))+" e Z13_COD="+Z16->Z16_COD+"]" 
					lErroXML :=.T.
					::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
					ConOut(cErrorLog)
				Else
					// -> Verifica se o produto foi integrado
					If !Z13->Z13_XSTINT == "I"
						cErrorLog:="Erro: Aguardando processo de integrcao do produto. [Z13_FILIAL="+AllTrim(xFilial("Z13"))+", Z13_COD="+Z16->Z16_COD+" e Z13_XSTINT="+Z13->Z13_XSTINT+"]" 
						lErroXML :=.T.
						::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
						ConOut(cErrorLog)
					EndIf
				EndIf

				// -> Posiciona na tabela de produtos ativados e verifica so o produto está ativo
				DbSelectArea("Z17")
				Z17->(dbSetOrder(1))			
				Z17->(dbSeek(xFilial("Z17")+Z16->Z16_COD))
				If !Z17->(Found())
					cErrorLog:="Erro: Produto nao ativado no Teknisa. [Z17_FILIAL="+xFilial("Z17")+" e Z17_COD="+Z16->Z16_COD+"]" 
					lErroXML :=.T.
					::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")	
					ConOut(cErrorLog)
				ElseIf !Z17->Z17_XSTINT == "I"
					cErrorLog:="Erro: Aguardando ativacao do produto no Teknisa. [Z17_FILIAL="+xFilial("Z17")+", Z17_COD="+Z16->Z16_COD+" e Z17_XSTINT="+Z17->Z17_XSTINT+"]" 
					lErroXML :=.T.
					::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")	
					ConOut(cErrorLog)
				EndIf

				// -> Se Ok, continua....
				If !lErroXML
					// -> Posiciona na tabela de tributação 
					DbSelectArea("SF7")
					SF7->(DbOrderNickName("SF7GRPEST"))
					SF7->(dbSeek(xFilial("SF7")+Z16->Z16_GRPTRI+cGrpClie+cCodUF))
					If !SF7->(Found())
						cErrorLog:="Erro: Não foram encontrados excecoes fiscais para a filial e estado. [FILIAL="+ADK->ADK_XFILI+", ESTADO="+ADK->ADK_EST+", GRUPO TRIBUTARIO="+Z16->Z16_GRPTRI+" GRUPO CLIENTE="+cGrpClie+"]" 
						lErroXML :=.T.
						::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")	
						ConOut(cErrorLog)				
					EndIf
			
					// -> Se Ok, gera XML
					If !lErroXML
						// -> Gera o XML
						While !SF7->(Eof()) .and. SF7->F7_FILIAL = xFilial("SF7") .and. SF7->F7_GRTRIB == Z16->Z16_GRPTRI .and. SF7->F7_GRPCLI == cGrpClie .and. SF7->F7_EST == cCodUF
							cXmlItem += '<item'
							cXmlItem += ::tag('cdproduto'			,SB1->B1_XCODEXT)
							cXmlItem += ::tag('codigoproduto'		,Z16->Z16_COD)
							cXmlItem += ::tag('nmprodut'			,Z16->Z16_DESC)
							cXmlItem += ::tag('situacaotributaria'	,SF7->F7_SITTRIB)
							cXmlItem += ::tag('uf'					,SF7->F7_EST)
							cXmlItem += ::tag('grupocliente'		,SF7->F7_GRPCLI)
							cXmlItem += ::tag('grupoproduto'		,SB1->B1_GRUPO)
							cXmlItem += ::tag('reducaoicms'			,StrTran(Transform(IIF(SF7->F7_BASEICM>0,100-SF7->F7_BASEICM,0),"@E 99.99"),",","."))
							cXmlItem += ::tag('aliquotaicms'		,StrTran(Transform(SF7->F7_ALIQDST	                           ,"@E 99.99"),",","."))
							cXmlItem += ::tag('reducaopis'			,StrTran(Transform(IIF(SF7->F7_REDPIS>0,100-SF7->F7_REDPIS,0)  ,"@E 99.99"),",","."))
							cXmlItem += ::tag('aliqutapis'			,StrTran(Transform(SF7->F7_ALIQPIS	                           ,"@E 99.99"),",","."))
							cXmlItem += ::tag('reducaocofins'		,StrTran(Transform(IIF(SF7->F7_REDCOF>0,100-SF7->F7_REDCOF,0)  ,"@E 99.99"),",","."))
							cXmlItem += ::tag('aliquotacofins'		,StrTran(Transform(SF7->F7_ALIQCOF	                           ,"@E 99.99"),",","."))
							cXmlItem += ::tag('origem'				,SF7->F7_ORIGEM)
							cXmlItem += '>'
								cXmlItem += '<cbenfeitem>'
									// -> Consulta dados do CBenef
									DbSelectArea("F3K")
									F3K->(DbSetOrder(1))
									F3K->(DbSeek(xFilial("F3K")+Z16->Z16_COD))
									While !F3K->(Eof()) .and. xFilial("F3K") == F3K->F3K_FILIAL .and. Z16->Z16_COD == F3K->F3K_PROD 
										cXmlItem += '<cbenfe'
										cXmlItem += ::tag('cfop'   ,F3K->F3K_CFOP)
										cXmlItem += ::tag('cst'	   ,F3K->F3K_CST)
										cXmlItem += ::tag('cbenef' ,F3K->F3K_CODAJU)
										cXmlItem += '/>'
										F3K->(DbSkip())
									EndDo
								cXmlItem += '</cbenfeitem>'
							cXmlItem += '</item>'
							SF7->(DbSkip())
						EndDo

						// -> Verifica se o grupo mudou		
						If nC >= Len(aLote)
							nInc:=nInc+1
							cAuxLote:=Z16->Z16_FILIAL+Z16->Z16_GRPTRI
						Else
							cAuxLote:=IIF(nC<=1,Z16->Z16_FILIAL+Z16->Z16_GRPTRI,cAuxLote)
							If cAuxLote <> aLote[nC+1,01]+aLote[nC+1,03]			
								nInc:=nInc+1
								cAuxLote:=aLote[nC+1,01]+aLote[nC+1,03]
							EndIf	
						EndIf	

						// -> Se encontrou itens relacionados ao impostos
						If nInc > 0
		
							cXml += '<imposto>'

							cXml += '<id'
							cXml += ::tag('grupotrib'	,Z16->Z16_GRPTRI)
							cXml += '/>'
			
							cXml += '<fiscais>'
							cXml += cXmlItem
							cXml += '</fiscais>'
		
							cXml += '<empresas>'
		
							cXml += '<filial'
							cXml += ::tag('cdempresa'	,cCodEmp)
							cXml += ::tag('cdfilial'	,cCodFil)
							cXml += ::tag('filial'		,cCodFili)
							cXml += ::tag('nmfilial'	,cNomFil)
							cXml += '/>'
		
							cXml += '</empresas>'

							cXml += '</imposto>'

							nInc	:=0	
							cXmlItem:=""

						EndIf
			
					EndIf

				EndIf	
				
			Else
			
				cErrorLog:="Erro: Produto nao encontrado e/ou nao integraco com o Teknisa. [B1_FILIAL="+xFilial("SB1")+", B1_COD="+Z16->Z16_COD+" e B1_XCODEXT="+SB1->B1_XCODEXT+"]" 
				lErroXML :=.T.
				::oLog:SetAddInfo(cErrorLog,"Geracao do XML")	
				ConOut(cErrorLog)
		
			EndIf

		ElseIf Upper(Self:cMetEnv) == "DELETE"
			
			// -> Vaida integraçao com o Teknisa
			DbSelectArea("Z13")
			Z13->(DbSetOrder(1))
			Z13->(DbSeek(xFilial("Z13")+Z16->Z16_COD))
			If !Z13->(Found())
				cErrorLog:="Erro: Nao encontrado processo de integracao do produto na tabela Z13. [Z13_FILIAL="+AllTrim(xFilial("Z13"))+" e Z13_COD="+Z16->Z16_COD+"]" 
				lErroXML :=.T.
				::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
				ConOut(cErrorLog)
			Else
				// -> Verifica se o produto foi integrado
				If !Z13->Z13_XSTINT == "I"
					cErrorLog:="Erro: Aguardando processo de integrcao do produto. [Z13_FILIAL="+AllTrim(xFilial("Z13"))+", Z13_COD="+Z16->Z16_COD+" e Z13_XSTINT="+Z13->Z13_XSTINT+"]" 
					lErroXML :=.T.
					::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
					ConOut(cErrorLog)
				EndIf
			EndIf

			// -> Gera XML se não ocorreu nenhum erro
			If !lErroXML

				cXmlItem += '<item'
				cXmlItem += ::tag('cdproduto'			,Z13->Z13_COD)
				cXmlItem += ::tag('codigoproduto'		,Z16->Z16_COD)
				cXmlItem += ::tag('nmprodut'			,Z16->Z16_DESC)
				cXmlItem += ::tag('grupocliente'		,cGrpClie)
				cXmlItem += ::tag('grupoproduto'		,Z16->Z16_GRPTRI)
				cXmlItem += ::tag('uf'					,cCodUF)
				cXmlItem += ::tag('situacaotributaria'	,"")
				cXmlItem += ::tag('aliquota'			,StrTran(Transform(0	,"@E 99.99"),",","."))
				cXmlItem += ::tag('reducaopis'			,StrTran(Transform(0	,"@E 99.99"),",","."))
				cXmlItem += ::tag('aliqutapis'			,StrTran(Transform(0	,"@E 99.99"),",","."))
				cXmlItem += ::tag('reducao'				,StrTran(Transform(0	,"@E 99.99"),",","."))
				cXmlItem += ::tag('aliquotacofins'		,StrTran(Transform(0	,"@E 99.99"),",","."))
				cXmlItem += ::tag('origem'				," ")

				cXmlItem += '/>'
						
				// -> Verifica se o grupo mudou		
				If nC >= Len(aLote)
					nInc:=nInc+1
					cAuxLote:=Z16->Z16_FILIAL+Z16->Z16_GRPTRI
				Else
					cAuxLote:=IIF(nC<=1,Z16->Z16_FILIAL+Z16->Z16_GRPTRI,cAuxLote)
					If cAuxLote <> aLote[nC+1,01]+aLote[nC+1,03]			
						nInc:=nInc+1
						cAuxLote:=aLote[nC+1,01]+aLote[nC+1,03]
					EndIf	
				EndIf	

				// -> Se encontrou itens relacionados ao impostos
				If nInc > 0

					cXml += '<imposto>'

					cXml += '<id'
					cXml += ::tag('grupotrib'	,Z16->Z16_GRPTRI)
					cXml += '/>'

					cXml += '<fiscais>'
					cXml += cXmlItem
					cXml += '</fiscais>'

					cXml += '<empresas>'
		
					cXml += '<filial'
					cXml += ::tag('cdempresa'	,cCodEmp)
					cXml += ::tag('cdfilial'	,cCodFil)
					cXml += ::tag('filial'		,cCodFili)
					cXml += ::tag('nmfilial'	,cNomFil)
					cXml += '/>'
		
					cXml += '</empresas>'

					cXml += '</imposto>'

					nInc	:=0	
					cXmlItem:=""

				EndIf	

			EndIf

		EndIf
		
	 Next nC

	cXml += '</impostos>'
	
	If AllTrim(cXml) == "<impostos></impostos>" .or. lErroXML
		cXml:=""
	EndIf
	
	MemoWrite("C:\TEMP\XML_" + cMetEnv + ".XML",cXml)

return cXml


/*-----------------+---------------------------------------------------------+
!Nome              ! prepare                                                 !
+------------------+---------------------------------------------------------+
!Descrição         ! Metoto para preparar os lotes a enviar                  !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method prepare() class TeknisaPutImposto
Local cAlias   := ::fetch()
Local nAux     := 0

	::aLotes := {}

	While ! (cAlias)->( Eof() )
	
		IF Len(::aLotes) == 0 .Or. len(::aLotes[len(::aLotes)]) >= ::nLimite
			aAdd(::aLotes, {})
		EndIf

		aAdd(::aLotes[len(::aLotes)],{(cAlias)->Z16_FILIAL,(cAlias)->Z16_COD,(cAlias)->Z16_GRPTRI})	
		nAux:=nAux+1
		::oLog:setCountOk()

		(cAlias)->(DbSkip()) 
	EndDo

	(cAlias)->(DbCloseArea())
	
	::oLog:setCountTot(nAux)
	cErrorLog:=": "+AllTrim(Str(nAux))+" itens selecionados." 
	::oLog:SetAddInfo(cErrorLog,"Selecionando dados...")
	ConOut(cErrorLog)

return len(::aLotes) > 0
