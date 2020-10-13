#include 'protheus.ch'
/*-----------------+---------------------------------------------------------+
!Nome              ! TkPutUnid                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para chamr o metodo PutUnidade via Menu          !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
User Function TkPutUnid()

 	// -> Executa o processo de inclusão de unidadesde negócio
	TkUnid("Post")
 	// -> Executa o processo de alteração de unidades de negócio
 	TkUnid("Put")
 	// -> Executa o processo de exclusao de unidades de negócio
 	TkUnid("Delete")

Return


/*-----------------+---------------------------------------------------------+
!Nome              ! TkUnid                                                  !
+------------------+---------------------------------------------------------+
!Descrição         ! Função para processar o WS                              !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
Static function TkUnid(cMetEnv)
Local oIntegra
Local cMethod	:= "PutUnidade"
Local cAlias	:= ""
Local cAlRot	:= "ADK" 
Local oEventLog := EventLog():start("Unidades - "+AllTrim(cMetEnv), Date(), "Iniciando processo de integracao...", cMetEnv, cAlRot) 

	//instancia a classe
	oIntegra := TeknisaPutUnidade():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	If oIntegra:isEnable()

		//busca os registros e se sequencia em lotes
		oIntegra:prepare()

		oIntegra:send()

	EndIf

	oEventLog:Finish()

return


/*-----------------+---------------------------------------------------------+
!Nome              ! TeknisaPutUnidade                                       !
+------------------+---------------------------------------------------------+
!Descrição         ! Classe PutUnidade                                       !
+------------------+---------------------------------------------------------+
!Autor             ! Mario L. B. Faria                                       !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
class TeknisaPutUnidade from TeknisaMethodAbstract
Data oLog
Data cMetE

	method new() constructor
	method makeXml(aLote)
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
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaPutUnidade

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
method fetch() class TeknisaPutUnidade
Local cQuery := ''  
Local cErrorLog := ""

	cErrorLog:=": Selecionando unidades de negocio..." 
	::oLog:SetAddInfo(cErrorLog,"Selecionando dados...")
	ConOut(cErrorLog)
	cQuery:="SELECT R_E_C_N_O_ ROT_REG, 0 ALI_REG"
	cQuery+="FROM " + RetSqlName(::cAlRot) + "        " 
	cQuery+="WHERE ADK_FILIAL  = '" + xFilial(::cAlRot) + "' AND "
	cQuery+="      ADK_XFILI   = '" + cFilAnt           + "' AND "
	cQuery+="      ADK_XSTINT IN ('P','E')                   AND "
	If Upper(::cMetEnv)     == "POST"
		cQuery+="ADK_XEMP    = '00'         AND "
		cQuery+="ADK_XFIL    = '0000'       AND "
	ElseIf Upper(::cMetEnv) == "PUT"
      	cQuery+="ADK_XEMP   <> '00'         AND "
      	cQuery+="ADK_XFIL   <> '0000'       AND "
	ElseIf Upper(::cMetEnv) == "DELETE"
		cQuery+="ADK_XEMP   <> '00'         AND "
		cQuery+="ADK_XFIL   <> '0000'       AND "
		cQuery+="ADK_MSBLQL = '1'           AND "
	EndIf	
	cQuery+="D_E_L_E_T_ <> '*' " 
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
method analise(oXmlItem,lNewReg) class TeknisaPutUnidade
Local lIntegrado := .F.
Local cCodEmp 	:= ""
Local cCodFil 	:= ""
Local cCodFilPro:= ""
Local cMsgErro  := ""
Private oItem   := oXmlItem

	// -> verifica se a propriedade integrado existe
	cMsgErro:=IIF(type("oItem:_CONFIRMACAO:_MENSAGEM:TEXT")=="C",oItem:_CONFIRMACAO:_MENSAGEM:TEXT,"")
	If type("oItem:_CONFIRMACAO:_INTEGRADO:TEXT") == "C" .and. type("oItem:_CONFIRMACAO:_MENSAGEM:TEXT") == "C"
		
		cCodEmp   :=IIF(type("oItem:_FILIAL:_CDEMPRESA:TEXT") == "C",oItem:_FILIAL:_CDEMPRESA:TEXT,"")
		cCodFil   :=IIF(type("oItem:_FILIAL:_CDFILIAL:TEXT" ) == "C",oItem:_FILIAL:_CDFILIAL:TEXT,"" )
		cCodFilPro:=IIF(type("oItem:_FILIAL:_FILIAL:TEXT")    == "C",oItem:_FILIAL:_FILIAL:TEXT,"")

		//agora testa se o conteudo é true
		lIntegrado := lower(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "true"
		
		//se integrado OK, verifica se tem a chave para entrar o registro. Se não encontrado... não marca como integrado OK
		If lIntegrado

			lIntegrado := lIntegrado .And. !Empty(cCodEmp)
			lIntegrado := lIntegrado .And. !Empty(cCodFil)
			lIntegrado := lIntegrado .And. !Empty(cCodFilPro)

			If lIntegrado

				cErrorLog:=": "+AllTrim(cCodFilPro)+": Atualizando status no ERP..." 
				::oLog:SetAddInfo(cErrorLog,"Retorno dos dados.")
				ConOut(cErrorLog)

				// -> Poaiciona na tabela de unidades de negócio
				DbSelectArea("ADK")
				ADK->(DbOrderNickname("ADKXFILI"))
				ADK->(DbSeek(xFilial("ADK")+cCodFilPro))
				If ADK->(Found()) 

					RecLock("ADK", .F.)
					ADK->ADK_XSTINT := "I" //Integrado
					ADK->ADK_XDINT  := Date()
					ADK->ADK_XHINT  := Time()
					If UPPER(Self:cMetEnv) == "POST"
						ADK->ADK_XEMP:=cCodEmp
						ADK->ADK_XFIL:=cCodFil
					EndIf
					ADK->(MsUnLock())
					::oEventLog:setCountInc()

					cErrorLog:="Ok." 
					::oLog:SetAddInfo(cErrorLog,"Confirmacao dos dados.")
					ConOut(cErrorLog)

				Else

					cErrorLog:="Erro: Registro nao encontrado na tabela de unidades de negócio.[ADK_XFILI="+cCodFilPro+"+]"
					::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
					ConOut(cErrorLog)
						
				EndIf
				
			Else

				cErrorLog:="Erro: O metodo " + Self:cMetEnv + " retornou os dados da empresa e/ou filial do Teknisa/Protheus vazios. [ADK_XEMP="+cCodEmp+", ADK_XFIL="+cCodFil+" ou ADK_XFILI="+cCodFilPro+"+]"
				::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
				ConOut(cErrorLog)

			EndIf

		Else

			cErrorLog:=cMsgErro
			::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")
			ConOut(cErrorLog)

		EndIf

	Else 

		cErrorLog:=IIF(!Empty(cMsgErro),cMsgErro,"Erro indeterminado, verifique com a area de TI do MADERO")
		::oLog:SetAddInfo(cErrorLog,"Erro no retorno do XML.")	
		ConOut(cErrorLog)
	
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
method makeXml(aLote) class TeknisaPutUnidade
Local cXml
Local nC
Local aAreaSM0	:= SM0->(Getarea())
Local cErrorLog := ""
Local lErroXML  := .F.
Local lFoundSM0 := .F.
Local cFilAux   := cFilAnt
Local cEmpAux   := cEmpAnt
	
	cErrorLog:=": Gerando XML..." 
	::oLog:SetAddInfo(cErrorLog,"Gerando XML...")
	ConOut(cErrorLog)

	cXml := '<empresas>'
	
	For nC := 1 to len(aLote)

		lErroXML := .F.
		lFoundSM0:= .F.
		
		// -> Posiciona na unidade de negocio
		ADK->(dbGoTo(aLote[nC,01]))
		
		// -> Se for alteração
		If Upper(Self:cMetEnv) == "POST"

			SM0->(dbGoTop())
			SM0->(dbSeek((cEmpAnt)))
			While !(SM0->(Eof())) .AND. SM0->M0_CODIGO == cEmpAnt
				If Padr(SM0->M0_CODFIL,TamSx3("ADK_FILIAL")[01]) == Padr(ADK->ADK_XFILI,TamSx3("ADK_FILIAL")[01])
					lFoundSM0:=.T.
					Exit
				EndIf
				SM0->(dbSkip())
			EndDo
			
			// -> Se nao encontrou a filial relacionada a ADK, exibe log de erro
			If !lFoundSM0
				lErroXML:=.T.
				cErrorLog:="Filial "+cEmpAnt+" nao relacionada no cadastro de unidades de negocio. Favor verificar o codigo da filial no cadastro de unidades de negocio. [ADK_XFILI="+AllTrim(ADK->ADK_XFILI)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
				ConOut("Erro: "+cErrorLog)	
			EndIf

		// -> Se for inclusao
		ElseIf Upper(::cMetEnv) $ "PUT/DELETE"

			SM0->(dbGoTop())
			SM0->(dbSeek((cEmpAnt)))
			While !(SM0->(Eof())) .AND. SM0->M0_CODIGO == cEmpAnt
				If Padr(SM0->M0_CODFIL,TamSx3("ADK_FILIAL")[01]) == Padr(ADK->ADK_XFILI,TamSx3("ADK_FILIAL")[01])
					lFoundSM0:=.T.
					Exit
				EndIf
				SM0->(dbSkip())
			EndDo
			
			// -> Se nao encontrou a filial relacionada a ADK, exibe log de erro
			If !lFoundSM0
				lErroXML:=.T.
				cErrorLog:="Filial do Protheus nao relacionada com no cadastro de unidades de negocio. Favor verificar o codigo da filial no cadastro de unidades de negocio. [ADK_XFILI="+AllTrim(ADK->ADK_XFILI)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
				ConOut("Erro: "+cErrorLog)	
			EndIf

			// -> Se nao encontrou o codigo da empresa e filial do Teknisa na unidade de negocio
			If Empty(ADK->ADK_XFIL) .or. ADK->ADK_XFIL == "0000"
				lErroXML:=.T.
				cErrorLog:="Filial " +cEmpAnt+ " nao integrada corretamente no Teknisa. [ADK_XEMP="+AllTrim(ADK->ADK_XEMP)+" e ADK_XFIL="+AllTrim(ADK->ADK_XFIL)+"]" 
				::oLog:SetAddInfo(cErrorLog,"Erro na geracao do XML.")
				ConOut("Erro: "+cErrorLog)	
			EndIf
		
		EndIf
		
		// -> Se nao ocorreu erro, gera o XML
		If !lErroXML

			cXml += '<empresa>'
		
			cXml += '<id'
			cXml += ::tag('cdempresa'		,IIF(ADK->ADK_XEMP=="00" .and. ADK->ADK_XFIL=="0000","  "  ,ADK->ADK_XEMP))
			cXml += ::tag('cdfilial'		,IIF(ADK->ADK_XEMP=="00" .and. ADK->ADK_XFIL=="0000","    ",ADK->ADK_XFIL) )
			cXml += '/>'
		
			cXml += '<empresa'
			cXml += ::tag('filial'			,ADK->ADK_XFILI)
			cXml += ::tag('nmfilial'		,SubStr(SM0->M0_FILIAL,1,30))
			cXml += ::tag('negocio'		    ,ADK->ADK_XNEGOC)
			cXml += '/>'
	
			cXml += '<fiscal'
			cXml += ::tag('idtpijurfili'	,cValToChar(SM0->M0_TPINSC))
			cXml += ::tag('nrinsjurfili'	,SM0->M0_CGC) 
			cXml += ::tag('cdinscmuni'		,IIF(AllTrim(SM0->M0_INSCM)=="","ISENTO",SM0->M0_INSCM))
			cXml += ::tag('cdinscesta'		,SM0->M0_INSC) 
			cXml += ::tag('nmrazsocfili'	,SM0->M0_FILIAL) 
			cXml += ::tag('cnae'			,SM0->M0_CNAE)
			cXml += ::tag('nire'			,SM0->M0_NIRE) 
			cXml += ::tag('datanire'		,Dtos(SM0->M0_DTRE))
			cXml += '/>'
	
			cXml += '<estabelecimento'
			cXml += ::tag('sgestado'		,SM0->M0_ESTENT)
			cXml += ::tag('codmunicipio'	,SM0->M0_CODMUN)
			cXml += ::tag('nmmunicipio'		,SM0->M0_CIDENT)
			cXml += ::tag('endereco'		,SM0->M0_ENDENT) 
			cXml += ::tag('nmbairfili'		,SM0->M0_BAIRENT)
			cXml += ::tag('nrcepfili'		,SM0->M0_CEPENT) 
			cXml += ::tag('nrtelefili'		,SM0->M0_TEL)
			cXml += ::tag('nrfaxfili'		,SM0->M0_FAX )
			cXml += ::tag('dscompendfil'	,SM0->M0_COMPENT) 
			cXml += '/>'		

			cXml += '</empresa>'
			
		EndIf	

 	Next nC

	// -> Reposiciona na empresa e filial
	SM0->(DBSetOrder(1))
	SM0->(dbSeek(cEmpAux+cFilAux))

	cXml += '</empresas>'

	If AllTrim(cXml) == "<empresas></empresas>"
		cXml:=""
	EndIf	

	RestArea(aAreaSM0)

return cXml