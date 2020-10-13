#include 'protheus.ch'
#include "parmtype.ch"
/*-----------------+---------------------------------------------------------+
!Nome              ! TeknisaConexao                                          !
+------------------+---------------------------------------------------------+
!Descrição         ! Classe para efetuara conexão com todos os WS's Teknisa  !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
class TeknisaConexao from LongClassName

	data cMethod
	data cIP
	data cPorta
	data cChConex
	data cIdConex
	data cCnpj
	data cMetEnv
	data oEventLog
	data lIsEnable
	data oRestClient
	data oResult
	method new() constructor
	method isEnable()

	method setMethod(cMethod)
	method send()

	method getUrl()
	method xmlParse()
	method getResult()
	method getError()

endclass


/*-----------------+---------------------------------------------------------+
!Nome              ! new                                                     !
+------------------+---------------------------------------------------------+
!Descrição         ! Metido inicializador sa classe                          !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              ! 
+------------------+--------------------------------------------------------*/
method new(cCnpj, cMethod, cMetEnv, oEventLog) class TeknisaConexao

	paramtype 0 var cCnpj as character optional default SM0->M0_CGC

	::lIsEnable := .F.
	::cIP       := ''
	::cPorta    := ''
	::cChConex	:= ''
	::cIdConex	:= ''
	::cCnpj		:= cCnpj
	::cMethod	:= cMethod
	::cMetEnv	:= cMetEnv                   
	::oEventLog := oEventLog
	
return self


/*-----------------+---------------------------------------------------------+
!Nome              ! isEnable                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para buscar dados para conexão especifica        !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method isEnable() class TeknisaConexao
Local oRestClient
Local cReturn
Local cUrl := SuperGetMv("MD_TEKURL",,"")
Private oXml

	If !Empty(cUrl)
	
		If ::lIsEnable
			return  ::lIsEnable
		EndIf

		oRestClient := FWRest():New(cUrl)
		oRestClient:setPath("/GetConexao/Get?cnpj=" + ::cCnpj + "&metodo=" + ::cMethod)

		If oRestClient:Get()

			cReturn := oRestClient:GetResult()

			oXml := ::xmlParse(cReturn)

			If oXml != Nil .And. type("oXml:_RETORNOS:_RETORNO:_RETORNO:_INTEGRADO:TEXT") != "U"
				::lIsEnable := lower(oXml:_RETORNOS:_RETORNO:_RETORNO:_INTEGRADO:TEXT) == "true"
				IF ::lIsEnable
					::cIP		:= oXml:_RETORNOS:_RETORNO:_CONEXAO:_URL:TEXT
					::cPorta	:= oXml:_RETORNOS:_RETORNO:_CONEXAO:_PORTA:TEXT
					::cIdConex	:= oXml:_RETORNOS:_RETORNO:_CONEXAO:_IDCONEXAO:TEXT
					::cChConex	:= oXml:_RETORNOS:_RETORNO:_CONEXAO:_CHAVECONEXAO:TEXT
				Else
					ConOut("Erro na Conexao: "+oXml:_RETORNOS:_RETORNO:_RETORNO:_MENSAGEM:TEXT)
					::oEventLog:SetAddInfo("Erro na onexao: "+oXml:_RETORNOS:_RETORNO:_RETORNO:_MENSAGEM:TEXT,"Erro de conexao")
				EndIf
			EndIf
		EndIf

	Else

		ConOut("Erro na conexao: Parametro MD_TEKURL sem o endereco de conexao do web service")
		::oEventLog:SetAddInfo("Erro na conexao: Parametro MD_TEKURL sem o endereco de conexao do web service","Erro de conexao")

	EndIf	

return ::lIsEnable


/*-----------------+---------------------------------------------------------+
!Nome              ! setMethod                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Método para retornar o metodo                           !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method setMethod(cMethod) class TeknisaConexao
	::cMethod := cMethod
return



/*-----------------+---------------------------------------------------------+
!Nome              ! send                                                    !
+------------------+---------------------------------------------------------+
!Descrição         ! Método para enviar o WS                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
/*
		Método GetAutorizacao
			xAux == array com os dados da busca
			[01] - Filial
			[02] - Empresa Teknisa
			[03] - Filial Teknisa 
			[04] - Filial Caixa
			[05] - Sequência Inicial
			[06] - Sequência Final
			[07] - Data Entrega
		                                  		
		Método GetProducaoFull
			[01] - Empresa Teknisa		
			[02] - Filial Teknisa		
			[03] - Sequência de Venda	
			[04] - Data Entrega		       
			[05] - Caixa	               
*/
method send(xAux) class TeknisaConexao

	Local aHeader	:= {}
	Local lRet		:= .T.
	Local cUrl		:= ::getUrl()
	Local cPath		:= ""

	aAdd( aHeader, "Content-Type: text/xml")
	
	::oRestClient := FWRest():New(cUrl)
	
	If Upper(::cMetEnv) == "GET" 
		
		Do Case
			Case Upper(::cMethod) == "GETPEDIDOS" 
				cPath := "/api/" + ::cMethod + "/" + ::cMetEnv + "?cdempresa=" + ADK->ADK_XEMP + "&cdfilial=" + ADK->ADK_XFIL +;
						 "&dtinicial=" + cDataIni + "&dtfinal=" + cDataFim

			Case Upper(::cMethod) == "GETAUTORIZACAO"
				cPath := "/api/" + ::cMethod + "/" + ::cMetEnv + "?cdempresa=" + ADK->ADK_XEMP + "&cdfilial=" + ADK->ADK_XFIL +;
						 "&cdcaixa=" + xAux[04] + "&nrseqvenda=" + xAux[05] + "&dtentrvenda=" + xAux[06]

			Case Upper(::cMethod) == "GETAUTORIZACAOSTATUS"
				cPath := "/api/" + ::cMethod + "/" + ::cMetEnv + "?cdempresa=" + ADK->ADK_XEMP + "&cdfilial=" + ADK->ADK_XFIL +;
						 "&cdcaixa=" + xAux[04] + "&nrseqvenda=" + xAux[05] + "&dtentrvenda=" + xAux[06]

			Case Upper(::cMethod) == "GETPRODUCAOFULL"
				cPath := "/api/" + ::cMethod + "/" + ::cMetEnv + "?cdempresa=" + ADK->ADK_XEMP + "&cdfilial=" + ADK->ADK_XFIL +;
						 "&cdcaixa=" + xAux[05] + "&nrseqvendamsde=" + xAux[03] + "&dtentrvenda=" + xAux[04] 				
				
			Case Upper(::cMethod) == "GETFECHAMENTOCAIXAMATRIZ"
				cPath := "/api/" + ::cMethod + "/" + ::cMetEnv + "?cdempresa=" + ADK->ADK_XEMP + "&cdfilial=" + ADK->ADK_XFIL +;
						 "&datacaixa=" + cDataCaixa 

			OtherWise	//GetVenda e GetRecebimento
				cPath := "/api/" + ::cMethod + "/" + ::cMetEnv + "?cdempresa=" + ADK->ADK_XEMP + "&cdfilial=" + ADK->ADK_XFIL +;
						 "&nrseqvenda=" + cSeqVd + "&cdcaixa=" + cCaixa + "&dtentrvenda=" + cEntreg

		EndCase
				
		Aadd(aHeader,"Authorization: Basic "+ Encode64(::cIdConex+':'+::cChConex))			
		::oRestClient:SetPath( cPath )
		
	Else
		
		::oRestClient:SetPath( "/api/" + ::cMethod + "/" + ::cMetEnv)
	
	EndIf

	Do Case
		Case Upper(::cMetEnv) == "POST"
			::oRestClient:SetPostParams(xAux)
			lRet := ::oRestClient:Post(aHeader)
			
		Case Upper(::cMetEnv) == "PUT"
			lRet := ::oRestClient:Put(aHeader,xAux)
			
		Case Upper(::cMetEnv) == "DELETE"
			lRet := ::oRestClient:Delete(aHeader,xAux)
			
		Case Upper(::cMetEnv) == "GET"
			lRet := ::oRestClient:Get(aHeader)

	EndCase

return lRet



/*-----------------+---------------------------------------------------------+
!Nome              ! getResult                                               !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para pegar o resultado da transmissão            !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method getResult() class TeknisaConexao
return ::oRestClient:GetResult()


/*-----------------+---------------------------------------------------------+
!Nome              ! getUrl                                                  !
+------------------+---------------------------------------------------------+
!Descrição         ! Metofo para gerar a URL de conexão                      !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method getUrl() class TeknisaConexao
return "http://" + ::cIP + ":" + ::cPorta //+ "/api/" //+ ::cMethod + "/" + ::cMetEnv



/*-----------------+---------------------------------------------------------+
!Nome              ! xmlParse                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Metodo para parsear o XML                               !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/
method xmlParse(cXml) class TeknisaConexao
Local cError	:= ""
Local cWarning	:= ""
Local oXml := XmlParser( cXml, "_", @cError, @cWarning )
                         
	If oXml == Nil
		ConOut("Parse fail: Verifique se o XML está com a estrutura correta e informe a TOTVS")
		::oEventLog:SetAddInfo("Parse fail. Verifique se o XML está com a estrutura correta e informe a TOTVS: "+cError+" / "+cWarning,"Parse fail")
	EndIf

return oXml



/*-----------------+---------------------------------------------------------+
!Nome              ! getError                                                !
+------------------+---------------------------------------------------------+
!Descrição         ! Exibe o erro                                            !
+------------------+---------------------------------------------------------+
!Autor             ! Rafael Vieceli                                          !
+------------------+---------------------------------------------------------!
!Data              ! 25/05/2018                                              !
+------------------+--------------------------------------------------------*/

method getError() class TeknisaConexao
Return ::oRestClient:GetLastError()