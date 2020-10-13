#include 'protheus.ch'           

/*/{Protheus.doc} ProtheusMethodAbstract
//TODO Clase abstrata com funções de uso comum no WS Protheus
@author Mario L. B. Faria
@since 17/07/2018
@version 1.0
/*/
Class ProtheusMethodAbstract From LongClassName

	data cMethod

	Method new(cMethod) constructor
	Method makeXml()
	Method tag(cTag,xValor,cTipo)
	Method xmlParser(cXml,oEventLog)
	Method AnaliseAll(oXml)
	Method Analise(oXmlItem)

EndClass

/*/{Protheus.doc} new
//TODO metodo inicializador na classe de cada WS
//TODO Obriga  gerar o XML na classe de cada WS 
@author Mario L. B. Faria
@since 17/07/2018
@version 1.0
/*/
Method new() Class ProtheusMethodAbstract
	UserException("Classe abstrata não pode ser instanciada, apenas herdada.")
Return

/*/{Protheus.doc} makeXml
//TODO Obriga  gerar o XML na classe de cada WS 
@author Mario L. B. Faria
@since 17/07/2018
@version 1.0
/*/
Method makeXml() Class ProtheusMethodAbstract
	UserException("Metodo 'makeXml' abstrato, implemente na classe.")
Return

/*/{Protheus.doc} tag
//TODO Metodo para gerar a TAG do XML
@author Mario L. B. Faria
@since 17/07/2018
@version 1.0
@return cXml, Caracter, 
@param cTag, characters, Tag
@param xValor, , COnteudo
@param cTipo, characters, tipo da informação
/*/
Method tag(cTag,xValor,cTipo) Class ProtheusMethodAbstract

	//Tipos de Dados
	//DECIMAL
	//INTEGER
	//DATE
	//STRING
	//BOOLEAN

	Default cTipo := "string"

	If ValType(xValor) == "C"
		xValor := AllTrim(xValor)
	EndIf

Return WSSoapValue(cTag,xValor,xValor,cTipo,.F.,.F.,2,NIL,.F.)

/*/{Protheus.doc} xmlPar
//TODO Metodo para parsear o XML 
@author Mario L. B. Faria
@since 17/07/2018
@version 1.0
@return oXml, Obketo do XML
@param cXml, characters, XML
/*/
Method xmlParser(cXml,oEventLog) Class ProtheusMethodAbstract
Local cError	:= ""
Local cWarning	:= ""
Local oRet 		:= xmlParser( cXml, "_", @cError, @cWarning ) 
                         
	IF oRet == Nil
		ConOut("Erro: Parse fail.")
		If oEventLog <> Nil
			oEventLog:SetAddInfo("PARSE FAIL: "+cError+" / "+cWarning,"")
		EndIf	
	EndIF

Return oRet


/*/{Protheus.doc} analiseAll
//TODO Efetua a validação e envio de cada item
@author Mario L. B. Faria
@since 21/05/2018
@version 1.0
@return .T. ou .F.
@param cXml, characters, XML de envio
/*/
Method AnaliseAll(oXml) class ProtheusMethodAbstract

	Local nItem := 0

	Do Case

		Case type("oXml:_RETORNOS:_RETORNO") == "O"
			lOk := ::Analise(oXml:_RETORNOS:_RETORNO)

		Case type("oXml:_RETORNOS:_RETORNO") == "A"
			For nItem := 1 to len(oXml:_RETORNOS:_RETORNO)
				lOk := ::Analise(oXml:_RETORNOS:_RETORNO[nItem])
			Next nItem

	EndCase

Return lOk


/*/{Protheus.doc} analise
//TODO Obriga a criação do método na classe individual de cada WS
@author Mario L. B. Faria
@since 21/05/2018
@version 1.0
@return ${return}, ${return_description}
@param oXmlItem, object, descricao
/*/
Method Analise(oXmlItem) class ProtheusMethodAbstract

    Local lOk := .T.
	//para poder usar função type
	Private oItem := oXmlItem
    
	UserException("Metodo 'analise' abstrato, implemente na classe.")

Return lOk