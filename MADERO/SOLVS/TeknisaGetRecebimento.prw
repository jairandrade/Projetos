#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TkGetRec
//TODO Função para executa o metodo GetRecebimento
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@param cExp01, characters, Codigo da filial Teknisa
@param cExp02, characters, Código do caixa Teknisa
@param cExp03, characters, Sequencia de venda Teknisa
/*/
User Function TkGetRec(cExp01,cExp02,cExp03,cExp04,oEventLog)

	Local oIntegra
	Local cMethod	:= "GetRecebimento"
	Local cMetEnv	:= "Get"
	Local cAlias	:= ""
	Local cAlRot	:= ""
	Local lOk		:= .T.
	Local aRet 		:= {,}
	
	Private cCdFil	:= cExp01
	Private cCaixa	:= cExp02
	Private cSeqVd	:= cExp03
	Private cEntreg := cExp04
	
	//instancia a classe
	oIntegra := TeknisaGetRecebimento():new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)

	//se estiver ativo
	IF oIntegra:isEnable()
	
		aRet := oIntegra:sendGet()

	EndIF 
	
	oIntegra:=Nil
	
return aRet


/*/{Protheus.doc} TeknisaGetPedidos
//TODO Clasee contrutora do metodo GetRecebimento
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
/*/
class TeknisaGetRecebimento from TeknisaMethodAbstract
data oEventLog
	
	method new() constructor
	method analise(oXmlItem)
	
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
method new(cMethod, cMetEnv, cAlias, cAlRot, oEventLog) class TeknisaGetRecebimento
    ::oEventLog := oEventLog
	::init(cMethod, cMetEnv, cAlias, cAlRot, oEventLog)
return


/*/{Protheus.doc} analise
//TODO Metodo para analisar retorno do WS
@author Mario L. B. Faria
@since 21/05/2018
@version 1.0
@param oXmlItem, object, descricao
/*/
method analise(oXmlItem) class TeknisaGetRecebimento

Local lOk 		:= .T.
Local cMsgAux	:= ""
Private oItem := oXmlItem
	                                	
	//Valida se houve retorno válido
	If ValType(oItem) == "O"
	
		//Verifica Sequencia e caixa
		lOk := lOk .And. ::Integrado("oItem:_ID:_CDCAIXA:TEXT"		  ,"U","Erro na estrutura do XML: Tag Código do Caixa Teknisa inexistente")
		lOk := lOk .And. ::Integrado("oItem:_ID:_NRSEQVENDA:TEXT"	  ,"U","Erro na estrutura do XML: Tag Código da Sequencia de Venda Teknisa inexistente")
		lOk := lOk .And. ::Integrado("oItem:_CONDICAO:_CDTIPOREC:TEXT","U","Erro na estrutura do XML: Tag Condição de recebimento inexistente")
		
		If lOk
						                    
			//Valida Empresa e Filial
			lOk := lOk .And. ::Integrado("oItem:_ID:_CDEMPRESA:TEXT"	,"U","Erro na estrutura do XML: Tag Código da Empresa Teknisa inexistente")
			lOk := lOk .And. ::Integrado("oItem:_ID:_CDFILIAL:TEXT"		,"U","Erro na estrutura do XML: Tag Código da Filial Teknisa inexistentea")
			
			If lOk
					
				//Valida conteudo dos campos
				lOk := lOk .And. ::Integrado("oItem:_ID:_CDEMPRESA:TEXT"		,"","Código da Empresa Teknisa inválida no XML")
				lOk := lOk .And. ::Integrado("oItem:_ID:_CDFILIAL:TEXT"			,"","Código da Filial Teknisa inválida no XML")
				lOk := lOk .And. ::Integrado("oItem:_ID:_CDCAIXA:TEXT"			,"","Código da Filial Teknisa inválida no XML")
				lOk := lOk .And. ::Integrado("oItem:_ID:_NRSEQVENDA:TEXT"		,"","Código da Sequencia de Venda Teknisa inválido no XML")			
				lOk := lOk .And. ::Integrado("oItem:_CONDICAO:_CDTIPOREC:TEXT"	,"","Condição de recebimento inválida no XML")

			Else
				::oEventLog:SetAddInfo("Erro: Estrutura do XML da condição de pagamento: Tag CDEMPRESA ou CDFILIAL invalida.","")
				ConOut("Erro: Estrutura do XML da condição de pagamento: Tag CDEMPRESA ou CDFILIAL invalida.") 
				lOk := .F.		
			EndIf
		
		Else

			::oEventLog:SetAddInfo("Erro: Estrutura do XML da condição de pagamento: Tag CDCAIXA, NRSEQVENDA ou CDTIPOREC invalida.","")
			ConOut("Erro: Estrutura do XML da condição de pagamento: Tag CDCAIXA, NRSEQVENDA ou CDTIPOREC invalida.")
			lOk := .F.		

		EndIf
	
	Else
		::oEventLog:SetAddInfo("Erro: Estrutura do XML da condição de pagamento: Sem XML.","")
		ConOut("Erro: Estrutura do XML da condição de pagamento: Sem XML.")
		lOk := .F.
	EndIf	
	
	
	If !lOk

		cAuxLog:=StrZero(ThreadId(),10)+":[GETRECEBIMENTO] Verificar SEQVENDA: "+ oItem:_ID:_NRSEQVENDA:TEXT + " no caixa " + oItem:_ID:_CDCAIXA:TEXT + "."
		Conout(cAuxLog)
		::oEventLog:setDetail(DtoS(dDataBase), "Z01", "E","3",cAuxLog,.T.,"",dDataBase, 0, "DOCUMENTO FISCAL", "", "", .F., ThreadId())
		::oEventLog:SetAddInfo(cAuxLog,"")

	EndIf
	 

	IF !lOk           
		ConOut("Erro: Falha na integração da condição de pagamento. Verificar detalhes.")
		::oEventLog:broken("Erro: Falha na integração da condição de pagamento. Verificar detalhes.", "", .T.)
	EndIf

return lOk