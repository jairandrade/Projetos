#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TkGetRec
//TODO Fun��o para executa o metodo GetRecebimento
@author Mario L. B. Faria
@since 16/05/2018
@version 1.0
@param cExp01, characters, Codigo da filial Teknisa
@param cExp02, characters, C�digo do caixa Teknisa
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
@param cAlias, characters, Alias da tabela tenpor�ria
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
	                                	
	//Valida se houve retorno v�lido
	If ValType(oItem) == "O"
	
		//Verifica Sequencia e caixa
		lOk := lOk .And. ::Integrado("oItem:_ID:_CDCAIXA:TEXT"		  ,"U","Erro na estrutura do XML: Tag C�digo do Caixa Teknisa inexistente")
		lOk := lOk .And. ::Integrado("oItem:_ID:_NRSEQVENDA:TEXT"	  ,"U","Erro na estrutura do XML: Tag C�digo da Sequencia de Venda Teknisa inexistente")
		lOk := lOk .And. ::Integrado("oItem:_CONDICAO:_CDTIPOREC:TEXT","U","Erro na estrutura do XML: Tag Condi��o de recebimento inexistente")
		
		If lOk
						                    
			//Valida Empresa e Filial
			lOk := lOk .And. ::Integrado("oItem:_ID:_CDEMPRESA:TEXT"	,"U","Erro na estrutura do XML: Tag C�digo da Empresa Teknisa inexistente")
			lOk := lOk .And. ::Integrado("oItem:_ID:_CDFILIAL:TEXT"		,"U","Erro na estrutura do XML: Tag C�digo da Filial Teknisa inexistentea")
			
			If lOk
					
				//Valida conteudo dos campos
				lOk := lOk .And. ::Integrado("oItem:_ID:_CDEMPRESA:TEXT"		,"","C�digo da Empresa Teknisa inv�lida no XML")
				lOk := lOk .And. ::Integrado("oItem:_ID:_CDFILIAL:TEXT"			,"","C�digo da Filial Teknisa inv�lida no XML")
				lOk := lOk .And. ::Integrado("oItem:_ID:_CDCAIXA:TEXT"			,"","C�digo da Filial Teknisa inv�lida no XML")
				lOk := lOk .And. ::Integrado("oItem:_ID:_NRSEQVENDA:TEXT"		,"","C�digo da Sequencia de Venda Teknisa inv�lido no XML")			
				lOk := lOk .And. ::Integrado("oItem:_CONDICAO:_CDTIPOREC:TEXT"	,"","Condi��o de recebimento inv�lida no XML")

			Else
				::oEventLog:SetAddInfo("Erro: Estrutura do XML da condi��o de pagamento: Tag CDEMPRESA ou CDFILIAL invalida.","")
				ConOut("Erro: Estrutura do XML da condi��o de pagamento: Tag CDEMPRESA ou CDFILIAL invalida.") 
				lOk := .F.		
			EndIf
		
		Else

			::oEventLog:SetAddInfo("Erro: Estrutura do XML da condi��o de pagamento: Tag CDCAIXA, NRSEQVENDA ou CDTIPOREC invalida.","")
			ConOut("Erro: Estrutura do XML da condi��o de pagamento: Tag CDCAIXA, NRSEQVENDA ou CDTIPOREC invalida.")
			lOk := .F.		

		EndIf
	
	Else
		::oEventLog:SetAddInfo("Erro: Estrutura do XML da condi��o de pagamento: Sem XML.","")
		ConOut("Erro: Estrutura do XML da condi��o de pagamento: Sem XML.")
		lOk := .F.
	EndIf	
	
	
	If !lOk

		cAuxLog:=StrZero(ThreadId(),10)+":[GETRECEBIMENTO] Verificar SEQVENDA: "+ oItem:_ID:_NRSEQVENDA:TEXT + " no caixa " + oItem:_ID:_CDCAIXA:TEXT + "."
		Conout(cAuxLog)
		::oEventLog:setDetail(DtoS(dDataBase), "Z01", "E","3",cAuxLog,.T.,"",dDataBase, 0, "DOCUMENTO FISCAL", "", "", .F., ThreadId())
		::oEventLog:SetAddInfo(cAuxLog,"")

	EndIf
	 

	IF !lOk           
		ConOut("Erro: Falha na integra��o da condi��o de pagamento. Verificar detalhes.")
		::oEventLog:broken("Erro: Falha na integra��o da condi��o de pagamento. Verificar detalhes.", "", .T.)
	EndIf

return lOk