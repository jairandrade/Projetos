#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TkGetPro
//TODO Função para executa o metodo GetRecebimento
@author Mario L. B. Faria
@since 24/05/2018
@version 1.0
/*/
User Function TkGetPro(aChEnv,oEventLog)

	Local oIntegra
	Local cMethod	:= "GetProducaoFull"
	Local cMetEnv	:= "Get"
	Local cAlias	:= ""
	Local cAlRot	:= ""
	Local aRet 		:= {,}
	Local oXMPProd  
	
	Private	aChEnvP := aClone(aChEnv)

	//instancia a classe
	oIntegra := TeknisaGetProducao():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	IF oIntegra:isEnable()
	
		aRet     := oIntegra:sendGet(aChEnv)
		oXMPProd := oIntegra:getXML()

	EndIF      
	
	oIntegra := Nil
	
return({aRet,oXMPProd})


/*/{Protheus.doc} TeknisaGetProducao
//TODO Clasee contrutora do metodo TeknisaGetProducao
@author Mario L. B. Faria
@since 24/05/2018
@version 1.0
/*/
class TeknisaGetProducao from TeknisaMethodAbstract
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
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaGetProducao
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
method analise(oXmlItem) class TeknisaGetProducao
Local lOk 		:= .T.
Private oItem := oXmlItem

	::oXML := oXmlItem 
	
	//Valida se houve retorno válido
	If ValType(oItem) == "O"
	
		
		//Verifica se o retorno do XML foi ok
		If Upper(oItem:_CONFIRMACAO:_INTEGRADO:TEXT) == "TRUE"        
			
			//Verifica Sequencia de Venda e Caixa
  			//lOk := lOk .And. ::Integrado("oItem:_ID:_CDCAIXA:TEXT"		 ,"U","Erro na estrutura do XML: Tag Código do Caixa Teknisa inexistente")
			//lOk := lOk .And. ::Integrado("oItem:_ID:_NRSEQVENDAMSDE:TEXT","U","Erro na estrutura do XML: Tag Código da Sequencia de Venda Teknisa inexistente")
			If lOk                               

				//Valida Empresa e Filial
				lOk := lOk .And. ::Integrado("oItem:_ID:_CDEMPRESA:TEXT","U","Erro na estrutura do XML: Tag Código da Emariompresa Teknisa inexistente")
				lOk := lOk .And. ::Integrado("oItem:_ID:_CDFILIAL:TEXT"	,"U","Erro na estrutura do XML: Tag Código da Filial Teknisa inexistentea")
				
				If lOk

					//Valida conteudo dos campos
					lOk := lOk .And. ::Integrado("oItem:_ID:_CDEMPRESA:TEXT"	 ,"","Código da Empresa Teknisa inválido no XML")
					lOk := lOk .And. ::Integrado("oItem:_ID:_CDFILIAL:TEXT"		 ,"","Código da Filial Teknisa inválido no XML")
					lOk := lOk .And. ::Integrado("oItem:_ID:_CDCAIXA:TEXT"		 ,"","Código da Filial Teknisa inválida no XML")							
					lOk := lOk .And. ::Integrado("oItem:_ID:_NRSEQVENDAMSDE:TEXT","","Código da Sequencia de Venda Teknisa inválido no XML")									
						
					If !lOk

						::oEventLog:SetAddInfo("Erro: Estrutura do XML da composicao dos produtos: Dados da empresa, filial, caixa e sequencia de vendas invalidos","")
						ConOut("Erro: Estrutura do XML da composicao dos produtos: Dados da empresa, filial, caixa e sequencia de vendas invalidos")				
						
					EndIf
				
				Else
			
					::oEventLog:SetAddInfo("Erro: Estrutura do XML da composicao dos produtos: Tag CDEMPRESA e CDFILIAL inexistente","")
					ConOut("Erro: Estrutura do XML da composicao dos produtos: Dados da empresa, filial, caixa e sequencia de vendas invalidos.")				
						
				EndIf

			Else
        	
				::oEventLog:SetAddInfo("Erro: Estrutura do XML da composicao dos produtos =: Tag CDCAIXA ou NRSEQVENDAMSDE inexistente","")
				ConOut("Erro: Estrutura do XML da composicao dos produtos.")				
				lOk := .F.		

			EndIf
										
		Else 
			    	
			::oEventLog:SetAddInfo("Erro: "+oItem:_CONFIRMACAO:_MENSAGEM:TEXT,"")
			ConOut("Erro: "+oItem:_CONFIRMACAO:_MENSAGEM:TEXT)				
			lOk := .F.
			    
		EndIf
			    
	Else

		::oEventLog:SetAddInfo("Erro: Estrutura do XML da composicao dos produtos: Tags de confirmacao do XML inexistente.","")
		ConOut("Erro: Estrutura do XML da composicao dos produtos: Tags de confirmacao do XML inexistente.")				
		lOk := .F.		
							
	EndIf
	    	    	
	IF !lOk           
		ConOut("Erro: Falha no XML de composicao de cErrorprodutos.")
		::oEventLog:broken("Erro: Falha no XML de composicao de produtos", "", .T.)
	EndIf
                             

return lOk



method getXML() class TeknisaGetProducao

Return ::oXML