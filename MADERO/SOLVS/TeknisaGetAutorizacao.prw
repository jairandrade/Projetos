#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TkGetRec
//TODO Função para executa o metodo GetRecebimento
@author Mario L. B. Faria
@since 24/05/2018
@version 1.0
/*/
User Function TkGetAut(aChEnv,oEventLog)

	Local oIntegra
	Local cMethod	:= "GetAutorizacaoStatus"
	Local cMetEnv	:= "Get"
	Local cAlias	:= "Z01"
	Local cAlRot	:= ""
	Local aRet 		:= {,}
	Local oXMPProd  
	
	//instancia a classe
	oIntegra := TeknisaGetAutorizacao():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	IF oIntegra:isEnable()
	
		aRet := oIntegra:sendGet(aChEnv)
		oXMPProd := oIntegra:getXML()

	EndIF
	
return({aRet,oXMPProd})


/*/{Protheus.doc} TeknisaGetAutorizacao
//TODO Clasee contrutora do metodo TeknisaGetAutorizacao
@author Mario L. B. Faria
@since 24/05/2018
@version 1.0
/*/
class TeknisaGetAutorizacao from TeknisaMethodAbstract
data oEventLog
data oXML
	
	method new() constructor
	method analise(oXmlItem)            
	method getXML()
	
endclass


/*/{Protheus.doc} new
//TODO Inicializador da Classe
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cMethod, characters, Metodo a ser executado
@param cMetEnv, characters, Metodo de Envio
@param cAlias, characters, Alias da tabela tenporária
@param cAlRot, characters, Alias da tabela pricipal
/*/
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaGetAutorizacao
	::oXML 		:= Nil                                     
	::oEventLog := oEventLog
	::init(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)
return


/*/{Protheus.doc} analise
//TODO Metodo para analisar retorno do WS
@author Mario L. B. Faria
@since 24/05/2018
@version 1.0
@param oXmlItem, object, descricao
/*/
method analise(oXmlItem) class TeknisaGetAutorizacao
Local lOk 	  := ValType(oXmlItem) == "O"
Private oItem := oXmlItem

	::oXML := oXmlItem
	
	//Valida se houve retorno válido
	If ValType(oItem) == "O"


		If ValType(oItem:_VENDA:_ID:_NRSEQVENDA:TEXT) <> "C"
			Alert("Erro no XML: "+oXmlItem)
		EndIf
	
		If Upper(oItem:_VENDA:_CONFIRMACAO:_INTEGRADO:TEXT) == "TRUE"

			//Verifica Sequencia e caixa
			lOk := lOk .And. ::Integrado("oItem:_VENDA:_ID:_CDCAIXA:TEXT"		,"U","Erro na estrutura do XML: Tag Código do Caixa Teknisa inexistente")
			lOk := lOk .And. ::Integrado("oItem:_VENDA:_ID:_NRSEQVENDA:TEXT"	,"U","Erro na estrutura do XML: Tag Código da Sequencia de Venda Teknisa inexistente")
			
			If lOk
			
				//Valida Empresa e Filial
				lOk := lOk .And. ::Integrado("oItem:_VENDA:_ID:_CDEMPRESA:TEXT"	,"U","Erro na estrutura do XML: Tag Código da Empresa Teknisa inexistente")
				lOk := lOk .And. ::Integrado("oItem:_VENDA:_ID:_CDFILIAL:TEXT"	,"U","Erro na estrutura do XML: Tag Código da Filial Teknisa inexistentea")
				
				If lOk
						
					//Valida conteudo dos campos
					lOk := lOk .And. ::Integrado("oItem:_VENDA:_ID:_CDEMPRESA:TEXT"		,"","Código da Empresa Teknisa inválido")
					lOk := lOk .And. ::Integrado("oItem:_VENDA:_ID:_CDFILIAL:TEXT"		,"","Código da Filial Teknisa inválido")
					lOk := lOk .And. ::Integrado("oItem:_VENDA:_ID:_CDCAIXA:TEXT"		,"","Código da Filial Teknisa inválido")
					lOk := lOk .And. ::Integrado("oItem:_VENDA:_ID:_NRSEQVENDA:TEXT"	,"","Código da Sequencia de Venda Teknisa inválido")
						
				Else
				
					::oEventLog:SetAddInfo("Erro: Estrutura do XML da autorizacao da venda: Tag CDEMPRESA ou CDFILIAL nao existem no XML.","")
					ConOut("Erro: Estrutura do XML da autorizacao da venda: Tag CDEMPRESA ou CDFILIAL nao existem no XML.")
					lOk := .F.				
				
				EndIf
			
			Else

				::oEventLog:SetAddInfo("Erro: Estrutura do XML da autorizacao da venda: Tag CDCAIXA ou NRSEQVENDA nao existem no XML.","")
				ConOut("Erro: Estrutura do XML da autorizacao da venda: Tag CDCAIXA ou NRSEQVENDA nao existem no XML.")
				lOk := .F.							
			
			EndIf
				
		Else

			::oEventLog:SetAddInfo("Erro: " + oItem:_VENDA:_CONFIRMACAO:_MENSAGEM:TEXT,"")
			ConOut("Erro: " + oItem:_VENDA:_CONFIRMACAO:_MENSAGEM:TEXT)
			lOk := .F.							

		EndIf
	
	EndIf	
	 
	If !lOk 
		ConOut("Erro: Falha no XML de utorizacao da venda.")
		::oEventLog:broken("Erro: Falha no XML de autorizacao da venda.", "", .T.)
	EndIf

return lOk         



method getXML() class TeknisaGetAutorizacao

Return ::oXML